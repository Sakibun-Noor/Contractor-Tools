<?php
require __DIR__ . '/lib/helpers.php';
require __DIR__ . '/lib/Auth.php';
require __DIR__ . '/lib/OneDrive.php';

start_session();
$auth = new Auth();
$cfg  = config();

$firstRun = !$auth->hasUsers();          // no users yet -> this creates the admin
$error = '';
$ok = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (!check_csrf($_POST['csrf'] ?? '')) {
        $error = 'Session expired. Please try again.';
    } else {
        try {
            $username = trim($_POST['username'] ?? '');
            $pass = $_POST['password'] ?? '';
            if ($pass !== ($_POST['password2'] ?? '')) {
                throw new Exception('Passwords do not match.');
            }
            $newUser = $auth->createUser($username, $pass); // first user = admin
            // Try to pre-create their OneDrive folder if storage is connected.
            try {
                $drive = new OneDrive($cfg);
                if ($drive->isConnected()) $drive->ensureUserFolder($newUser['username']);
            } catch (Exception $e) { /* non-fatal */ }

            $auth->login($newUser);
            header('Location: ' . ($firstRun ? 'setup.php?msg=welcome' : 'index.php'));
            exit;
        } catch (Exception $ex) {
            $error = $ex->getMessage();
        }
    }
}
$token = csrf_token();
?>
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Create account · <?= e($cfg['app_name']) ?></title>
<link rel="stylesheet" href="assets/css/style.css">
</head>
<body class="auth-body">
  <div class="auth-card">
    <div class="auth-logo">☁️</div>
    <h1><?= e($cfg['app_name']) ?></h1>
    <p class="auth-sub"><?= $firstRun ? 'Create the administrator account' : 'Create your account' ?></p>
    <?php if ($firstRun): ?>
      <div class="auth-note">You are the first user, so this account will be the <b>admin</b>
      that connects OneDrive.</div>
    <?php endif; ?>
    <?php if ($error): ?><div class="auth-error"><?= e($error) ?></div><?php endif; ?>
    <form method="post" autocomplete="off">
      <input type="hidden" name="csrf" value="<?= e($token) ?>">
      <label>Username
        <input type="text" name="username" required autofocus
               pattern="[A-Za-z0-9_.\-]{3,32}" title="3–32 letters, numbers, . _ -">
      </label>
      <label>Password
        <input type="password" name="password" required minlength="6">
      </label>
      <label>Confirm password
        <input type="password" name="password2" required minlength="6">
      </label>
      <button type="submit" class="btn-primary">Create account</button>
    </form>
    <?php if (!$firstRun): ?>
      <p class="auth-foot">Already have an account? <a href="login.php">Sign in</a></p>
    <?php endif; ?>
  </div>
</body>
</html>
