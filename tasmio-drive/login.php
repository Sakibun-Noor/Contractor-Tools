<?php
require __DIR__ . '/lib/helpers.php';
require __DIR__ . '/lib/Auth.php';

start_session();
$auth = new Auth();
$cfg  = config();

// First run: no users yet -> send to registration to create the admin.
if (!$auth->hasUsers()) {
    header('Location: register.php');
    exit;
}
if ($auth->current()) {
    header('Location: index.php');
    exit;
}

$error = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (!check_csrf($_POST['csrf'] ?? '')) {
        $error = 'Session expired. Please try again.';
    } else {
        $u = $auth->verify($_POST['username'] ?? '', $_POST['password'] ?? '');
        if ($u) {
            $auth->login($u);
            header('Location: index.php');
            exit;
        }
        $error = 'Incorrect username or password.';
    }
}
$token = csrf_token();
?>
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Sign in · <?= e($cfg['app_name']) ?></title>
<link rel="stylesheet" href="assets/css/style.css">
</head>
<body class="auth-body">
  <div class="auth-card">
    <div class="auth-logo">☁️</div>
    <h1><?= e($cfg['app_name']) ?></h1>
    <p class="auth-sub">Sign in to your drive</p>
    <?php if ($error): ?><div class="auth-error"><?= e($error) ?></div><?php endif; ?>
    <form method="post" autocomplete="off">
      <input type="hidden" name="csrf" value="<?= e($token) ?>">
      <label>Username
        <input type="text" name="username" required autofocus>
      </label>
      <label>Password
        <input type="password" name="password" required>
      </label>
      <button type="submit" class="btn-primary">Sign in</button>
    </form>
    <p class="auth-foot">No account? <a href="register.php">Create one</a></p>
  </div>
</body>
</html>
