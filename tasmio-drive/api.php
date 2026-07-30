<?php
/**
 * Tasmio Drive — JSON API for file operations.
 * Every action is scoped to the logged-in user's own folder.
 *
 *   GET  ?action=list&path=Documents
 *   GET  ?action=search&q=report
 *   GET  ?action=quota
 *   GET  ?action=download&id=<itemId>
 *   POST action=upload   (multipart: file, path, csrf)
 *   POST action=mkdir    (path, name, csrf)
 *   POST action=rename   (id, name, csrf)
 *   POST action=delete   (id, csrf)
 */

require __DIR__ . '/lib/helpers.php';
require __DIR__ . '/lib/Auth.php';
require __DIR__ . '/lib/OneDrive.php';

start_session();
$auth = new Auth();
$user = $auth->current();
if (!$user) json_error('Not signed in.', 401);

$cfg = config();
$drive = new OneDrive($cfg);
$username = $user['username'];

$action = $_GET['action'] ?? $_POST['action'] ?? '';
$isPost = $_SERVER['REQUEST_METHOD'] === 'POST';

// CSRF on all mutating requests
if ($isPost && !check_csrf($_POST['csrf'] ?? '')) {
    json_error('Invalid session token. Refresh the page and try again.', 419);
}

if (!$drive->isConnected() && $action !== 'status') {
    json_error('Storage is not connected yet. Ask an admin to finish OneDrive setup.', 503);
}

try {
    switch ($action) {

        case 'status':
            json_out([
                'ok' => true,
                'connected' => $drive->isConnected(),
                'user' => $username,
                'role' => $user['role'],
            ]);
            break;

        case 'list': {
            $path = safe_path($_GET['path'] ?? '');
            $items = $drive->listFolder($username, $path);
            json_out(['ok' => true, 'path' => $path, 'items' => $items]);
            break;
        }

        case 'search': {
            $q = trim($_GET['q'] ?? '');
            if ($q === '') json_out(['ok' => true, 'items' => []]);
            $items = $drive->search($username, $q);
            json_out(['ok' => true, 'items' => $items]);
            break;
        }

        case 'quota': {
            json_out(['ok' => true, 'quota' => $drive->quota()]);
            break;
        }

        case 'mkdir': {
            $path = safe_path($_POST['path'] ?? '');
            $name = safe_name($_POST['name'] ?? '');
            if ($name === '') json_error('Folder name is required.');
            $res = $drive->createFolder($username, $path, $name);
            json_out(['ok' => true, 'item' => $res]);
            break;
        }

        case 'upload': {
            if (empty($_FILES['file'])) json_error('No file received.');
            $path = safe_path($_POST['path'] ?? '');
            $f = $_FILES['file'];
            if ($f['error'] !== UPLOAD_ERR_OK) {
                json_error('Upload error code ' . $f['error'] . '.');
            }
            if ($f['size'] > $cfg['max_upload']) {
                json_error('File exceeds the ' . human_size($cfg['max_upload']) . ' limit.');
            }
            $name = safe_name($f['name']);
            if ($name === '') $name = 'upload-' . time();
            $res = $drive->uploadFile($username, $path, $name, $f['tmp_name']);
            json_out(['ok' => true, 'item' => $res]);
            break;
        }

        case 'download': {
            $id = $_GET['id'] ?? '';
            if ($id === '') json_error('Missing file id.');
            if (!$drive->itemBelongsToUser($id, $username)) {
                json_error('You do not have access to that file.', 403);
            }
            $drive->streamDownload($id, 'download');
            exit;
        }

        case 'rename': {
            $id = $_POST['id'] ?? '';
            $name = safe_name($_POST['name'] ?? '');
            if ($id === '' || $name === '') json_error('Missing id or new name.');
            if (!$drive->itemBelongsToUser($id, $username)) {
                json_error('You do not have access to that item.', 403);
            }
            $res = $drive->rename($id, $name);
            json_out(['ok' => true, 'item' => $res]);
            break;
        }

        case 'delete': {
            $id = $_POST['id'] ?? '';
            if ($id === '') json_error('Missing id.');
            if (!$drive->itemBelongsToUser($id, $username)) {
                json_error('You do not have access to that item.', 403);
            }
            $drive->delete($id);
            json_out(['ok' => true]);
            break;
        }

        default:
            json_error('Unknown action.', 404);
    }
} catch (Exception $ex) {
    json_error($ex->getMessage(), 500);
}
