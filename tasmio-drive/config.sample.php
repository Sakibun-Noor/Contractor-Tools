<?php
/**
 * Tasmio Drive — CONFIG TEMPLATE (safe to commit to GitHub).
 *
 * Setup:  copy this file to  config.php  and fill in your two Microsoft values.
 * config.php is git-ignored so your secret never leaves your computer.
 */

return [
    'app_name'   => 'Tasmio Drive',

    // Public URL of this app WITHOUT a trailing slash.
    'base_url'   => 'http://localhost/tasmio-drive',

    // ---- Azure AD / Microsoft Entra app registration ----
    'client_id'     => 'PASTE_APPLICATION_CLIENT_ID',
    'client_secret' => 'PASTE_CLIENT_SECRET_VALUE',

    // 'common' works for personal AND work/school accounts.
    'tenant'        => 'common',

    // Must EXACTLY match the Redirect URI registered in Azure.
    'redirect_uri'  => 'http://localhost/tasmio-drive/oauth.php',

    // Leave as-is: enough for the signed-in account's own drive,
    // and valid for both personal and work/school accounts.
    'scopes'        => 'offline_access Files.ReadWrite User.Read',

    // Top-level folder in YOUR OneDrive holding every user's data.
    'root_folder'   => 'TasmioDrive',

    'max_upload'    => 250 * 1024 * 1024, // 250 MB
    'session_name'  => 'tasmio_sess',
];
