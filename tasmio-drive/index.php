<?php
require __DIR__ . '/lib/helpers.php';
require __DIR__ . '/lib/Auth.php';
require __DIR__ . '/lib/OneDrive.php';

start_session();
$auth = new Auth();
$user = $auth->requireLogin();
$cfg  = config();
$drive = new OneDrive($cfg);
$connected = $drive->isConnected();
$token = csrf_token();
?>
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">
<title><?= e($cfg['app_name']) ?></title>
<link rel="stylesheet" href="assets/css/style.css">
</head>
<body>
<div class="window" id="app">

  <!-- Title bar (Windows chrome) -->
  <header class="titlebar">
    <div class="tb-left">
      <span class="tb-icon">☁️</span>
      <span class="tb-title"><?= e($cfg['app_name']) ?></span>
    </div>
    <div class="tb-search">
      <input type="search" id="searchBox" placeholder="Search your drive" autocomplete="off">
    </div>
    <div class="tb-right">
      <span class="tb-user" title="<?= e($user['username']) ?> (<?= e($user['role']) ?>)">
        <?= e($user['username']) ?>
      </span>
      <?php if ($user['role'] === 'admin'): ?>
        <a class="tb-btn" href="setup.php" title="Setup & users">⚙️</a>
      <?php endif; ?>
      <a class="tb-btn" href="logout.php" title="Sign out">⎋</a>
      <span class="tb-controls"><i class="c-min"></i><i class="c-max"></i><i class="c-close"></i></span>
    </div>
  </header>

  <!-- Toolbar (ribbon) -->
  <div class="toolbar">
    <button class="tool" id="btnUpload">⬆️ <span>Upload</span></button>
    <button class="tool" id="btnNewFolder">📁 <span>New folder</span></button>
    <button class="tool" id="btnDownload" disabled>⬇️ <span>Download</span></button>
    <button class="tool" id="btnRename" disabled>✏️ <span>Rename</span></button>
    <button class="tool danger" id="btnDelete" disabled>🗑️ <span>Delete</span></button>
    <div class="tool-spacer"></div>
    <button class="tool" id="btnRefresh">🔄 <span>Refresh</span></button>
    <div class="view-toggle">
      <button class="vt" data-view="grid" title="Large icons">▦</button>
      <button class="vt" data-view="list" title="Details">☰</button>
    </div>
    <input type="file" id="fileInput" multiple hidden>
  </div>

  <div class="body">
    <!-- Sidebar -->
    <nav class="sidebar">
      <div class="side-group">Quick access</div>
      <a class="side-item active" data-path="" href="#"><span>🏠</span> Home</a>
      <div class="side-group">This drive</div>
      <div id="sideTree" class="side-tree"></div>
      <div class="side-spacer"></div>
      <div class="quota" id="quota"></div>
    </nav>

    <!-- Main -->
    <main class="main">
      <div class="addressbar">
        <div class="breadcrumbs" id="breadcrumbs"></div>
      </div>

      <?php if (!$connected): ?>
        <div class="notice">
          <b>Storage isn’t connected yet.</b>
          <?php if ($user['role'] === 'admin'): ?>
            Go to <a href="setup.php">Setup</a> to connect the OneDrive account.
          <?php else: ?>
            Please ask an administrator to finish OneDrive setup.
          <?php endif; ?>
        </div>
      <?php endif; ?>

      <div class="files" id="files"></div>
      <div class="empty" id="empty" hidden>This folder is empty. Upload files or create a folder.</div>
      <div class="loading" id="loading" hidden><span class="spinner"></span> Loading…</div>
      <div id="dropzone" class="dropzone-overlay" hidden>Drop files to upload</div>
    </main>
  </div>

  <div class="statusbar">
    <span id="statusCount">0 items</span>
    <span id="statusSel"></span>
  </div>
</div>

<!-- Context menu -->
<ul class="ctxmenu" id="ctxmenu" hidden>
  <li data-cmd="open">Open</li>
  <li data-cmd="download">Download</li>
  <li data-cmd="rename">Rename</li>
  <li class="sep"></li>
  <li data-cmd="delete" class="danger">Delete</li>
</ul>

<!-- Modal -->
<div class="modal-back" id="modalBack" hidden>
  <div class="modal">
    <h3 id="modalTitle">Title</h3>
    <input type="text" id="modalInput">
    <div class="modal-actions">
      <button class="btn-ghost" id="modalCancel">Cancel</button>
      <button class="btn-primary" id="modalOk">OK</button>
    </div>
  </div>
</div>

<div id="toast" class="toast" hidden></div>

<script>
  window.TASMIO = { csrf: <?= json_encode($token) ?>, connected: <?= $connected ? 'true' : 'false' ?> };
</script>
<script src="assets/js/app.js"></script>
</body>
</html>
