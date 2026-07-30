<?php
/**
 * Tasmio Drive — OneDrive OAuth connect flow (admin only).
 *
 *   oauth.php?connect=1   -> redirect the admin to Microsoft sign-in
 *   oauth.php?disconnect=1-> forget the stored OneDrive token
 *   oauth.php (with ?code)-> Microsoft's redirect back; exchange for tokens
 */

require __DIR__ . '/lib/helpers.php';
require __DIR__ . '/lib/Auth.php';
require __DIR__ . '/lib/OneDrive.php';

start_session();
$auth = new Auth();
$auth->requireAdmin();

$cfg = config();
$drive = new OneDrive($cfg);

// Start the connect flow
if (isset($_GET['connect'])) {
    $state = bin2hex(random_bytes(16));
    $_SESSION['oauth_state'] = $state;
    header('Location: ' . $drive->getAuthUrl($state));
    exit;
}

// Disconnect
if (isset($_GET['disconnect'])) {
    if (!check_csrf($_GET['csrf'] ?? '')) exit('Invalid token.');
    $drive->disconnect();
    header('Location: setup.php?msg=disconnected');
    exit;
}

// Callback from Microsoft
if (isset($_GET['error'])) {
    $desc = $_GET['error_description'] ?? $_GET['error'];
    render_message('Sign-in was cancelled or failed', e($desc), false);
    exit;
}

if (isset($_GET['code'])) {
    if (empty($_GET['state']) || ($_GET['state'] !== ($_SESSION['oauth_state'] ?? null))) {
        render_message('Security check failed', 'The state value did not match. Please try connecting again.', false);
        exit;
    }
    unset($_SESSION['oauth_state']);
    try {
        $drive->exchangeCode($_GET['code']);
        // Make sure a home folder exists for every current user
        foreach ($auth->listUsers() as $u) {
            try { $drive->ensureUserFolder($u['username']); } catch (Exception $e) {}
        }
        $account = $drive->accountName();
        render_message('OneDrive connected 🎉',
            'Tasmio Drive is now storing files in the OneDrive account: <b>' . e($account) . '</b>.', true);
    } catch (Exception $ex) {
        render_message('Could not connect OneDrive', e($ex->getMessage()), false);
    }
    exit;
}

header('Location: setup.php');
exit;

function render_message($title, $body, $ok) {
    $color = $ok ? '#0f7b3f' : '#b3261e';
    echo '<!doctype html><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">';
    echo '<title>' . e($title) . '</title>';
    echo '<div style="font-family:Segoe UI,system-ui,sans-serif;max-width:520px;margin:12vh auto;padding:32px;'
       . 'border:1px solid #e2e2e2;border-radius:12px;box-shadow:0 8px 30px rgba(0,0,0,.08)">';
    echo '<h2 style="margin:0 0 12px;color:' . $color . '">' . e($title) . '</h2>';
    echo '<p style="color:#333;line-height:1.6">' . $body . '</p>';
    echo '<p style="margin-top:24px"><a href="setup.php" style="background:#0067c0;color:#fff;'
       . 'padding:10px 18px;border-radius:6px;text-decoration:none">Back to Setup</a> '
       . '<a href="index.php" style="margin-left:8px;color:#0067c0">Open Tasmio Drive</a></p>';
    echo '</div>';
}
