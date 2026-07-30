<?php
require __DIR__ . '/lib/helpers.php';
require __DIR__ . '/lib/Auth.php';
$auth = new Auth();
$auth->logout();
header('Location: login.php');
exit;
