<?php
/**
 * Tasmio Drive — Microsoft Graph / OneDrive wrapper.
 *
 * The whole site is backed by ONE OneDrive account (the owner's). We hold a
 * refresh token for that account and store every site user's files inside
 * /<root_folder>/<username>/ so users are isolated from one another.
 */

class OneDrive {
    private $config;
    private $tokenFile;
    const GRAPH = 'https://graph.microsoft.com/v1.0';
    const SMALL_UPLOAD = 4000000; // ~4 MB — simple PUT limit

    public function __construct($config) {
        $this->config = $config;
        $this->tokenFile = __DIR__ . '/../data/token.json';
    }

    /* ---------------- OAuth ---------------- */

    public function isConnected() {
        return file_exists($this->tokenFile);
    }

    private function loadToken() {
        if (!file_exists($this->tokenFile)) {
            throw new Exception('OneDrive is not connected yet. An admin must connect it from Setup.');
        }
        return json_decode(file_get_contents($this->tokenFile), true);
    }

    private function saveToken($data) {
        file_put_contents($this->tokenFile, json_encode($data, JSON_PRETTY_PRINT), LOCK_EX);
    }

    public function disconnect() {
        if (file_exists($this->tokenFile)) unlink($this->tokenFile);
    }

    public function getAuthUrl($state) {
        $params = [
            'client_id'     => $this->config['client_id'],
            'response_type' => 'code',
            'redirect_uri'  => $this->config['redirect_uri'],
            'response_mode' => 'query',
            'scope'         => $this->config['scopes'],
            'state'         => $state,
        ];
        return 'https://login.microsoftonline.com/' . $this->config['tenant']
             . '/oauth2/v2.0/authorize?' . http_build_query($params);
    }

    public function exchangeCode($code) {
        $res = $this->tokenRequest([
            'client_id'     => $this->config['client_id'],
            'client_secret' => $this->config['client_secret'],
            'redirect_uri'  => $this->config['redirect_uri'],
            'grant_type'    => 'authorization_code',
            'code'          => $code,
        ]);
        $res['obtained_at'] = time();
        $this->saveToken($res);
        return $res;
    }

    private function tokenRequest($data) {
        $url = 'https://login.microsoftonline.com/' . $this->config['tenant'] . '/oauth2/v2.0/token';
        $ch = curl_init($url);
        curl_setopt_array($ch, [
            CURLOPT_POST           => true,
            CURLOPT_POSTFIELDS     => http_build_query($data),
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_HTTPHEADER     => ['Content-Type: application/x-www-form-urlencoded'],
            CURLOPT_TIMEOUT        => 30,
        ]);
        $body   = curl_exec($ch);
        $status = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $err    = curl_error($ch);
        curl_close($ch);
        if ($body === false) throw new Exception('Network error contacting Microsoft: ' . $err);
        $json = json_decode($body, true);
        if ($status >= 400) {
            throw new Exception('Auth error: ' . ($json['error_description'] ?? $body));
        }
        return $json;
    }

    public function getAccessToken() {
        $token = $this->loadToken();
        $expiresAt = ($token['obtained_at'] ?? 0) + ($token['expires_in'] ?? 3600) - 120;
        if (!empty($token['access_token']) && time() < $expiresAt) {
            return $token['access_token'];
        }
        if (empty($token['refresh_token'])) {
            throw new Exception('OneDrive session expired. An admin must reconnect it.');
        }
        $res = $this->tokenRequest([
            'client_id'     => $this->config['client_id'],
            'client_secret' => $this->config['client_secret'],
            'redirect_uri'  => $this->config['redirect_uri'],
            'grant_type'    => 'refresh_token',
            'refresh_token' => $token['refresh_token'],
        ]);
        $res['obtained_at'] = time();
        if (empty($res['refresh_token'])) $res['refresh_token'] = $token['refresh_token'];
        $this->saveToken($res);
        return $res['access_token'];
    }

    /* ---------------- Graph HTTP ---------------- */

    /** JSON Graph request. Returns decoded array. */
    private function graph($method, $endpoint, $body = null, $extraHeaders = []) {
        $token = $this->getAccessToken();
        $url = strpos($endpoint, 'http') === 0 ? $endpoint : self::GRAPH . $endpoint;
        $headers = ['Authorization: Bearer ' . $token];
        $ch = curl_init($url);
        curl_setopt($ch, CURLOPT_CUSTOMREQUEST, $method);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_TIMEOUT, 120);
        if ($body !== null) {
            $headers[] = 'Content-Type: application/json';
            curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($body));
        }
        $headers = array_merge($headers, $extraHeaders);
        curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
        $resp   = curl_exec($ch);
        $status = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        if ($status === 204 || $resp === '') return [];
        $json = json_decode($resp, true);
        if ($status >= 400) {
            $msg = $json['error']['message'] ?? $resp;
            throw new Exception('OneDrive error (' . $status . '): ' . $msg);
        }
        return $json;
    }

    /* ---------------- Path helpers ---------------- */

    /** Absolute OneDrive path for a given site user + relative path. */
    private function userBase($username) {
        return $this->config['root_folder'] . '/' . $username;
    }

    /**
     * Build a Graph address for a drive path.
     *   addr('')                 -> /me/drive/root
     *   addr('', '/children')    -> /me/drive/root/children
     *   addr('A/B')              -> /me/drive/root:/A/B
     *   addr('A/B', '/children') -> /me/drive/root:/A/B:/children
     * (No stray trailing colon when there is no suffix.)
     */
    private function addr($absPath, $suffix = '') {
        $absPath = trim($absPath, '/');
        if ($absPath === '') {
            return '/me/drive/root' . $suffix;
        }
        $encoded = implode('/', array_map('rawurlencode', explode('/', $absPath)));
        $base = '/me/drive/root:/' . $encoded;
        return $suffix === '' ? $base : $base . ':' . $suffix;
    }

    /** Resolve a drive path to its item id (throws if it doesn't exist). */
    private function getIdByPath($absPath) {
        $res = $this->graph('GET', $this->addr($absPath) . '?$select=id');
        return $res['id'];
    }

    /** Create the folder tree if missing; returns nothing. */
    private function ensureFolder($absPath) {
        $absPath = trim($absPath, '/');
        if ($absPath === '') return;
        $parts = explode('/', $absPath);
        $current = '';
        foreach ($parts as $part) {
            $parent = $current;
            $current = ($current === '' ? '' : $current . '/') . $part;
            // Does it already exist?
            try {
                $this->graph('GET', $this->addr($current));
                continue; // exists
            } catch (Exception $e) {
                // create under parent
                $parentAddr = ($parent === '')
                    ? '/me/drive/root/children'
                    : $this->addr($parent, '/children');
                $this->graph('POST', $parentAddr, [
                    'name'   => $part,
                    'folder' => new stdClass(),
                    '@microsoft.graph.conflictBehavior' => 'fail',
                ]);
            }
        }
    }

    /** Make sure the site user's home folder exists. */
    public function ensureUserFolder($username) {
        $this->ensureFolder($this->userBase($username));
    }

    /* ---------------- CRUD ---------------- */

    /** List children of a folder inside the user's space. */
    public function listFolder($username, $relPath = '') {
        $abs = $this->userBase($username) . ($relPath !== '' ? '/' . $relPath : '');
        $this->ensureFolder($this->userBase($username));
        $endpoint = $this->addr($abs, '/children')
            . '?$select=id,name,size,folder,file,lastModifiedDateTime,webUrl'
            . '&$expand=thumbnails&$top=200&$orderby=name';
        $items = [];
        do {
            $res = $this->graph('GET', $endpoint);
            foreach (($res['value'] ?? []) as $it) {
                $items[] = $this->normalizeItem($it);
            }
            $endpoint = $res['@odata.nextLink'] ?? null;
        } while ($endpoint);
        // folders first, then files, both alphabetical
        usort($items, function ($a, $b) {
            if ($a['is_folder'] !== $b['is_folder']) return $a['is_folder'] ? -1 : 1;
            return strcasecmp($a['name'], $b['name']);
        });
        return $items;
    }

    private function normalizeItem($it) {
        return [
            'id'       => $it['id'],
            'name'     => $it['name'],
            'is_folder'=> isset($it['folder']),
            'size'     => $it['size'] ?? 0,
            'modified' => $it['lastModifiedDateTime'] ?? null,
            'child_count' => $it['folder']['childCount'] ?? null,
            'mime'     => $it['file']['mimeType'] ?? null,
            // Pre-authenticated preview URL OneDrive generates for images, video
            // frames, PDFs and Office docs. Absent for plain files (zip, txt, etc.)
            // — the front-end falls back to the emoji icon in that case.
            'thumb'    => $it['thumbnails'][0]['small']['url'] ?? null,
        ];
    }

    public function createFolder($username, $relPath, $name) {
        $parentAbs = $this->userBase($username) . ($relPath !== '' ? '/' . $relPath : '');
        $this->ensureFolder($parentAbs);
        $parentAddr = $this->addr($parentAbs, '/children');
        return $this->graph('POST', $parentAddr, [
            'name'   => $name,
            'folder' => new stdClass(),
            '@microsoft.graph.conflictBehavior' => 'rename',
        ]);
    }

    /** Upload a local temp file into the user's space. */
    public function uploadFile($username, $relPath, $name, $localTmpPath) {
        $abs = $this->userBase($username) . ($relPath !== '' ? '/' . $relPath : '') . '/' . $name;
        $this->ensureFolder($this->userBase($username) . ($relPath !== '' ? '/' . $relPath : ''));
        $size = filesize($localTmpPath);
        if ($size <= self::SMALL_UPLOAD) {
            return $this->simplePut($abs, $localTmpPath);
        }
        return $this->uploadSession($abs, $localTmpPath, $size);
    }

    private function simplePut($absPath, $localTmpPath) {
        $token = $this->getAccessToken();
        $url = self::GRAPH . $this->addr($absPath, '/content')
             . '?@microsoft.graph.conflictBehavior=rename';
        $fh = fopen($localTmpPath, 'rb');
        $ch = curl_init($url);
        curl_setopt_array($ch, [
            CURLOPT_CUSTOMREQUEST  => 'PUT',
            CURLOPT_PUT            => true,
            CURLOPT_INFILE         => $fh,
            CURLOPT_INFILESIZE     => filesize($localTmpPath),
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_TIMEOUT        => 300,
            CURLOPT_HTTPHEADER     => [
                'Authorization: Bearer ' . $token,
                'Content-Type: application/octet-stream',
            ],
        ]);
        $resp   = curl_exec($ch);
        $status = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        fclose($fh);
        if ($status >= 400) {
            $j = json_decode($resp, true);
            throw new Exception('Upload failed: ' . ($j['error']['message'] ?? $resp));
        }
        return json_decode($resp, true);
    }

    private function uploadSession($absPath, $localTmpPath, $size) {
        $session = $this->graph('POST', $this->addr($absPath, '/createUploadSession'), [
            'item' => ['@microsoft.graph.conflictBehavior' => 'rename'],
        ]);
        $uploadUrl = $session['uploadUrl'];
        $chunk = 5 * 320 * 1024; // 1.6 MB, multiple of 320 KiB (Graph requirement)
        $fh = fopen($localTmpPath, 'rb');
        $start = 0;
        $result = null;
        while ($start < $size) {
            $data = fread($fh, $chunk);
            $len  = strlen($data);
            $end  = $start + $len - 1;
            $ch = curl_init($uploadUrl);
            curl_setopt_array($ch, [
                CURLOPT_CUSTOMREQUEST  => 'PUT',
                CURLOPT_POSTFIELDS     => $data,
                CURLOPT_RETURNTRANSFER => true,
                CURLOPT_TIMEOUT        => 300,
                CURLOPT_HTTPHEADER     => [
                    'Content-Length: ' . $len,
                    'Content-Range: bytes ' . $start . '-' . $end . '/' . $size,
                ],
            ]);
            $resp   = curl_exec($ch);
            $status = curl_getinfo($ch, CURLINFO_HTTP_CODE);
            curl_close($ch);
            if ($status >= 400) {
                fclose($fh);
                $j = json_decode($resp, true);
                throw new Exception('Chunk upload failed: ' . ($j['error']['message'] ?? $resp));
            }
            if ($status === 200 || $status === 201) $result = json_decode($resp, true);
            $start = $end + 1;
        }
        fclose($fh);
        return $result;
    }

    public function getItemById($id) {
        return $this->graph('GET', '/me/drive/items/' . rawurlencode($id)
            . '?$select=id,name,size,file,folder,parentReference');
    }

    /** Verify an item id really belongs to the given site user's tree. */
    public function itemBelongsToUser($id, $username) {
        $item = $this->getItemById($id);
        $path = $item['parentReference']['path'] ?? '';
        // path looks like: /drive/root:/TasmioDrive/<username>/...
        $needle = '/root:/' . $this->userBase($username);
        return strpos($path, $needle) !== false
            || strpos($path, rawurlencode_path($needle)) !== false;
    }

    /** Stream a file's bytes to the browser for download. */
    public function streamDownload($id, $filename) {
        $token = $this->getAccessToken();
        // Ask Graph for a short-lived direct download URL, then stream it.
        // NOTE: @microsoft.graph.downloadUrl is a computed annotation, not a normal
        // field — restricting the response with $select unreliably omits it, so we
        // fetch the item without $select to guarantee it's included.
        $meta = $this->graph('GET', '/me/drive/items/' . rawurlencode($id));
        $url  = $meta['@microsoft.graph.downloadUrl'] ?? null;
        $name = $meta['name'] ?? $filename;
        $mime = $meta['file']['mimeType'] ?? 'application/octet-stream';
        if (!$url) throw new Exception('No download URL available for this item.');

        header('Content-Type: ' . $mime);
        header('Content-Disposition: attachment; filename="' . rawurlencode($name) . '"');
        if (!empty($meta['size'])) header('Content-Length: ' . $meta['size']);
        $ch = curl_init($url);
        curl_setopt_array($ch, [
            CURLOPT_WRITEFUNCTION => function ($ch, $data) {
                echo $data;
                return strlen($data);
            },
            CURLOPT_TIMEOUT => 600,
        ]);
        curl_exec($ch);
        curl_close($ch);
    }

    public function rename($id, $newName) {
        return $this->graph('PATCH', '/me/drive/items/' . rawurlencode($id), [
            'name' => $newName,
        ]);
    }

    public function delete($id) {
        // Moves the item to the OneDrive recycle bin.
        $this->graph('DELETE', '/me/drive/items/' . rawurlencode($id));
        return true;
    }

    /** Search within the user's folder. */
    public function search($username, $query) {
        $this->ensureFolder($this->userBase($username));
        // Scope the search to the user's home folder via its item id.
        $folderId = $this->getIdByPath($this->userBase($username));
        $endpoint = '/me/drive/items/' . rawurlencode($folderId)
            . "/search(q='" . rawurlencode($query) . "')"
            . '?$select=id,name,size,folder,file,lastModifiedDateTime&$expand=thumbnails';
        $res = $this->graph('GET', $endpoint);
        $items = [];
        foreach (($res['value'] ?? []) as $it) $items[] = $this->normalizeItem($it);
        return $items;
    }

    /** Storage quota for the underlying OneDrive account. */
    public function quota() {
        $res = $this->graph('GET', '/me/drive?$select=quota,owner');
        return $res['quota'] ?? null;
    }

    public function accountName() {
        try {
            $res = $this->graph('GET', '/me?$select=displayName,userPrincipalName');
            return $res['displayName'] ?? ($res['userPrincipalName'] ?? 'OneDrive');
        } catch (Exception $e) {
            return 'OneDrive';
        }
    }
}

/** Encode each path segment but keep slashes (used for the belongs-to check). */
function rawurlencode_path($p) {
    return implode('/', array_map('rawurlencode', explode('/', $p)));
}
