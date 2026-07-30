# ☁️ Tasmio Drive

A self-hosted file dashboard with a Windows-style desktop/mobile UI, built with **PHP + JSON**,
backed by **one OneDrive account** through the Microsoft Graph API.

- Users **sign in with local accounts** — they do **not** need their own OneDrive/Microsoft account.
- Every user gets an isolated folder inside your OneDrive: `/TasmioDrive/<username>/`.
- Full **CRUD**: upload, download, create folders, rename, delete (to Recycle Bin), search.
- **Responsive** Windows 11–style explorer that works on desktop and Android.

---

## 1. Requirements

- PHP **7.4+** (8.x recommended) with the **cURL** and **JSON** extensions.
- A web server (Apache/Nginx) or just `php -S` for local testing.
- One Microsoft account (personal **or** Microsoft 365 work/school) whose OneDrive stores the files.

Check PHP:
```bash
php -v
php -m | grep -i curl
```

---

## 2. Install

1. Copy the `tasmio-drive/` folder to your web root (e.g. `htdocs/tasmio-drive`).
2. Make sure `data/` is **writable** by PHP:
   ```bash
   chmod 770 data
   ```
3. Confirm `data/.htaccess` is present (it blocks web access to `users.json` and `token.json`).
   On **Nginx**, add instead:
   ```nginx
   location ~ ^/tasmio-drive/(data|lib)/ { deny all; return 403; }
   ```

Run locally for testing:
```bash
cd tasmio-drive
php -S localhost:8000
# open http://localhost:8000
```

---

## 3. Set up OneDrive (Azure app registration)

This is the part that connects Tasmio Drive to OneDrive. You do it **once**.

### 3.1 Register the app
1. Go to **https://entra.microsoft.com** → **Applications → App registrations → + New registration**
   (or the Azure Portal → *Azure Active Directory* → *App registrations*).
2. **Name:** `Tasmio Drive`.
3. **Supported account types:**
   - Personal OneDrive (outlook.com/hotmail/live) → **“Personal Microsoft accounts only”**
   - Work/school OneDrive → **“Accounts in this organizational directory only”**
   - Both → **“Accounts in any org directory and personal Microsoft accounts”**
4. **Redirect URI:** platform **Web**, value must EXACTLY equal your `redirect_uri`, e.g.
   - Local: `http://localhost:8000/oauth.php`
   - Server: `https://your-domain.com/tasmio-drive/oauth.php`
5. Click **Register**.

### 3.2 Copy the Client ID
On the app **Overview** page, copy **Application (client) ID** → this is `client_id`.

### 3.3 Create a Client Secret
1. **Certificates & secrets → + New client secret** → set an expiry → **Add**.
2. Copy the secret **Value** immediately (not the Secret ID) → this is `client_secret`.
   > The value is shown only once. If you lose it, make a new one.

### 3.4 Add API permissions
1. **API permissions → + Add a permission → Microsoft Graph → Delegated permissions**.
2. Add:
   - `offline_access`  (lets the app keep access via a refresh token)
   - `User.Read`
   - `Files.ReadWrite`  (enough — the app only uses the signed-in account's own drive;
     works for personal **and** work/school accounts)
3. (Work/school only) Click **Grant admin consent** if your tenant requires it.

### 3.5 Pick the right `tenant`
| Account type | `tenant` value |
|---|---|
| Personal OneDrive only | `consumers` |
| Work/school only | your Directory (tenant) ID, or `organizations` |
| Both | `common` |

---

## 4. Configure the app

Edit **`config.php`** and fill in:

```php
'base_url'      => 'https://your-domain.com/tasmio-drive',
'client_id'     => '<Application (client) ID>',
'client_secret' => '<Client secret VALUE>',
'tenant'        => 'common',        // or 'consumers' / tenant-id
'redirect_uri'  => 'https://your-domain.com/tasmio-drive/oauth.php',
'scopes'        => 'offline_access Files.ReadWrite User.Read',   // leave as-is
```

> `redirect_uri` here MUST be byte-for-byte identical to the one registered in Azure (step 3.1.4).

---

## 5. First run

1. Open the site → you’ll be asked to **create the admin account** (first user = admin).
2. You land on **Setup** → click **Connect OneDrive** → sign in with the Microsoft account
   that owns the storage → approve the permissions.
3. Done. Go to the drive and start uploading. Add more users from **Setup → Users**.

---

## 6. How it works

```
Browser (Windows-style UI, app.js)
        │  fetch()  JSON
        ▼
api.php  ──►  Auth.php (session, users.json)
        └──►  OneDrive.php  ──►  Microsoft Graph API
                                   └──►  /me/drive/root:/TasmioDrive/<user>/...
```

- **Auth:** local accounts in `data/users.json` (passwords hashed with `password_hash`).
- **Storage token:** the owner’s OAuth refresh/access tokens in `data/token.json`.
- **Isolation:** each API call is scoped to the caller’s `/TasmioDrive/<username>/` subtree,
  and item IDs are verified to belong to that subtree before download/rename/delete.

## 7. Security checklist

- [ ] Serve over **HTTPS** in production (OAuth + session cookies).
- [ ] `data/` is not web-accessible (test: visiting `/tasmio-drive/data/users.json` should 403).
- [ ] Rotate the client secret before it expires; reconnect from **Setup** if needed.
- [ ] `config.php` holds secrets — keep it out of public git (see `.gitignore`).

## 8. Troubleshooting

| Problem | Fix |
|---|---|
| `AADSTS50011` redirect mismatch | `redirect_uri` in `config.php` ≠ the one in Azure. Make them identical. |
| `invalid_client` | Wrong `client_secret` (used Secret **ID** not **Value**), or it expired. |
| Stuck “Not connected” | Admin hasn’t completed Setup → Connect OneDrive. |
| Upload fails on big files | Raise `upload_max_filesize` & `post_max_size` in `php.ini`. |
| Personal account 403 on Files | Use scope `Files.ReadWrite` and `tenant = consumers`. |
