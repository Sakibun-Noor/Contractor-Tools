<?php
/**
 * Tasmio Drive — shared helpers
 */

function config() {
    static $cfg = null;
    if ($cfg === null) {
        $cfg = require __DIR__ . '/../config.php';
    }
    return $cfg;
}

function start_session() {
    if (session_status() === PHP_SESSION_NONE) {
        session_name(config()['session_name']);
        session_set_cookie_params([
            'httponly' => true,
            'samesite' => 'Lax',
        ]);
        session_start();
    }
}

/** Send a JSON response and stop. */
function json_out($data, $status = 200) {
    http_response_code($status);
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode($data);
    exit;
}

function json_error($message, $status = 400) {
    json_out(['ok' => false, 'error' => $message], $status);
}

/** CSRF token for the current session. */
function csrf_token() {
    start_session();
    if (empty($_SESSION['csrf'])) {
        $_SESSION['csrf'] = bin2hex(random_bytes(32));
    }
    return $_SESSION['csrf'];
}

function check_csrf($token) {
    start_session();
    return isset($_SESSION['csrf']) && is_string($token)
        && hash_equals($_SESSION['csrf'], $token);
}

/**
 * Sanitize a user-supplied relative path so it can NEVER escape the
 * user's own folder. Returns a clean path like "Documents/report.pdf"
 * (no leading slash), or "" for the user's root.
 */
function safe_path($path) {
    $path = str_replace('\\', '/', (string)$path);
    $parts = [];
    foreach (explode('/', $path) as $seg) {
        $seg = trim($seg);
        if ($seg === '' || $seg === '.') continue;
        if ($seg === '..') { array_pop($parts); continue; }
        // strip characters OneDrive forbids in item names
        $seg = preg_replace('/[<>:"|?*\x00-\x1F]/', '', $seg);
        if ($seg !== '') $parts[] = $seg;
    }
    return implode('/', $parts);
}

/** A single path segment (a name), sanitized. */
function safe_name($name) {
    $name = str_replace(['\\', '/'], '', (string)$name);
    $name = preg_replace('/[<>:"|?*\x00-\x1F]/', '', $name);
    $name = trim($name, " .");
    return $name;
}

function human_size($bytes) {
    $bytes = (float)$bytes;
    $units = ['B', 'KB', 'MB', 'GB', 'TB'];
    $i = 0;
    while ($bytes >= 1024 && $i < count($units) - 1) {
        $bytes /= 1024;
        $i++;
    }
    return ($i === 0 ? (int)$bytes : round($bytes, 1)) . ' ' . $units[$i];
}

function e($s) {
    return htmlspecialchars((string)$s, ENT_QUOTES, 'UTF-8');
}
