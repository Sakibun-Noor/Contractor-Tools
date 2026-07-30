<?php
require __DIR__ . '/lib/helpers.php';
require __DIR__ . '/lib/Auth.php';
require __DIR__ . '/lib/OneDrive.php';

start_session();
$auth = new Auth();
$auth->requireAdmin();
$cfg = config();
$drive = new OneDrive($cfg);
$token = csrf_token();
$msg = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (!check_csrf($_POST['csrf'] ?? '')) {
        $msg = 'Session expired.';
    } elseif (($_POST['do'] ?? '') === 'add_user') {
        try {
            $u = $auth->createUser($_POST['username'] ?? '', $_POST['password'] ?? '', $_POST['role'] ?? 'user');
            if ($drive->isConnected()) { try { $drive->ensureUserFolder($u['username']); } catch (Exception $e) {} }
            $msg = 'User “' . e($u['username']) . '” created.';
        } catch (Exception $e) { $msg = $e->getMessage(); }
    } elseif (($_POST['do'] ?? '') === 'del_user') {
        $target = $_POST['username'] ?? '';
        if (strtolower($target) === strtolower($auth->current()['username'])) {
            $msg = 'You cannot delete your own account.';
        } else {
            $auth->deleteUser($target);
            $msg = 'User removed.';
        }
    } elseif (($_POST['do'] ?? '') === 'reset_pw') {
        try {
            $auth->setPassword($_POST['username'] ?? '', $_POST['password'] ?? '');
            $msg = 'Password updated.';
        } catch (Exception $e) { $msg = $e->getMessage(); }
    }
}

$configured = strpos($cfg['client_id'], 'PASTE_') !== 0;
$connected = $drive->isConnected();
$account = $quota = null;
if ($connected) {
    try { $account = $drive->accountName(); $quota = $drive->quota(); } catch (Exception $e) { $msg = $e->getMessage(); }
}
if (isset($_GET['msg']) && $_GET['msg'] === 'disconnected') $msg = 'OneDrive disconnected.';
?>
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Setup · <?= e($cfg['app_name']) ?></title>
<link rel="stylesheet" href="assets/css/style.css">
</head>
<body class="settings-body">
<div class="settings">
  <header class="settings-head">
    <a href="index.php" class="back">← Back to drive</a>
    <h1>⚙️ Setup &amp; Administration</h1>
  </header>

  <?php if ($msg): ?><div class="settings-msg"><?= $msg ?></div><?php endif; ?>

  <!-- OneDrive connection -->
  <section class="panel">
    <h2>OneDrive storage</h2>
    <?php if (!$configured): ?>
      <p class="warn">⚠️ Azure credentials are not filled in yet. Edit <code>config.php</code>
         (<code>client_id</code>, <code>client_secret</code>, <code>redirect_uri</code>) — see the README.</p>
    <?php endif; ?>

    <?php if ($connected): ?>
      <div class="status-line ok">● Connected</div>
      <p>Storing all files in: <b><?= e($account) ?></b></p>
      <?php if ($quota):
        $used = human_size($quota['used'] ?? 0);
        $total = human_size($quota['total'] ?? 0);
        $pct = !empty($quota['total']) ? round(($quota['used'] / $quota['total']) * 100, 1) : 0; ?>
        <div class="quota-bar"><div style="width:<?= $pct ?>%"></div></div>
        <p class="muted"><?= $used ?> used of <?= $total ?> (<?= $pct ?>%)</p>
      <?php endif; ?>
      <a class="btn-ghost danger" href="oauth.php?disconnect=1&csrf=<?= e($token) ?>"
         onclick="return confirm('Disconnect OneDrive? Files stay in OneDrive but the site loses access until reconnected.')">
         Disconnect</a>
    <?php else: ?>
      <div class="status-line off">● Not connected</div>
      <p>Click below and sign in with the Microsoft account whose OneDrive will hold everyone’s files.</p>
      <a class="btn-primary <?= $configured ? '' : 'disabled' ?>" href="oauth.php?connect=1">Connect OneDrive</a>
    <?php endif; ?>
    <details class="help">
      <summary>Current app settings</summary>
      <table class="kv">
        <tr><td>Redirect URI</td><td><code><?= e($cfg['redirect_uri']) ?></code></td></tr>
        <tr><td>Tenant</td><td><code><?= e($cfg['tenant']) ?></code></td></tr>
        <tr><td>Scopes</td><td><code><?= e($cfg['scopes']) ?></code></td></tr>
        <tr><td>Root folder</td><td><code>/<?= e($cfg['root_folder']) ?>/&lt;username&gt;/</code></td></tr>
      </table>
    </details>
  </section>

  <!-- User management -->
  <section class="panel">
    <h2>Users</h2>
    <table class="users">
      <thead><tr><th>Username</th><th>Role</th><th>Created</th><th></th></tr></thead>
      <tbody>
      <?php foreach ($auth->listUsers() as $u): ?>
        <tr>
          <td><?= e($u['username']) ?></td>
          <td><span class="badge <?= $u['role'] ?>"><?= e($u['role']) ?></span></td>
          <td class="muted"><?= e(substr($u['created'] ?? '', 0, 10)) ?></td>
          <td class="row-actions">
            <?php if (strtolower($u['username']) !== strtolower($auth->current()['username'])): ?>
            <form method="post" onsubmit="return confirm('Delete user <?= e($u['username']) ?>? Their files stay in OneDrive.')">
              <input type="hidden" name="csrf" value="<?= e($token) ?>">
              <input type="hidden" name="do" value="del_user">
              <input type="hidden" name="username" value="<?= e($u['username']) ?>">
              <button class="link-danger">Delete</button>
            </form>
            <?php else: ?><span class="muted">you</span><?php endif; ?>
          </td>
        </tr>
      <?php endforeach; ?>
      </tbody>
    </table>

    <h3>Add a user</h3>
    <form method="post" class="inline-form">
      <input type="hidden" name="csrf" value="<?= e($token) ?>">
      <input type="hidden" name="do" value="add_user">
      <input type="text" name="username" placeholder="username" required pattern="[A-Za-z0-9_.\-]{3,32}">
      <input type="password" name="password" placeholder="password (min 6)" required minlength="6">
      <select name="role"><option value="user">user</option><option value="admin">admin</option></select>
      <button class="btn-primary">Add</button>
    </form>
  </section>

  <section class="panel">
    <h2>How storage works</h2>
    <ul class="bullets">
      <li>Every site user gets a private folder at <code>/<?= e($cfg['root_folder']) ?>/&lt;username&gt;/</code> in your OneDrive.</li>
      <li>Users sign in with the local accounts above — they never need their own Microsoft/OneDrive account.</li>
      <li>Deleting a file sends it to the OneDrive Recycle Bin (recoverable there).</li>
    </ul>
  </section>
</div>
</body>
</html>
