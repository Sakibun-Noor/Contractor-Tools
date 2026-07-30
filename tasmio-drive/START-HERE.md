# 🚀 Tasmio Drive — Beginner Start Guide

Follow these in order. Total time: ~20 minutes.

---

## PART 1 — Install PHP (via XAMPP)

Your site is written in PHP, so your computer needs PHP to run it.
XAMPP is the easiest way to get it.

1. Go to **https://www.apachefriends.org**
2. Click **XAMPP for Windows** → the file downloads (~150 MB)
3. Run the installer:
   - If Windows shows a security warning, click **Yes / Run anyway**
   - On the "Select Components" screen you only need **Apache**.
     You can untick MySQL, FileZilla, Mercury, Tomcat, Perl.
   - Keep the install folder as **`C:\xampp`** (important — don't change it)
   - Click Next → Next → Install → Finish
4. The **XAMPP Control Panel** opens.

---

## PART 2 — Put the website in place

The site must live inside XAMPP's web folder: `C:\xampp\htdocs\`

Copy the whole `tasmio-drive` folder into `C:\xampp\htdocs\`
so you end up with: **`C:\xampp\htdocs\tasmio-drive\`**

(Claude can do this copy for you — just say "copy it over".)

---

## PART 3 — Turn the server on

1. In the **XAMPP Control Panel**, click **Start** next to **Apache**
2. "Apache" should turn **green**
3. Open your browser and go to:

   **http://localhost/tasmio-drive/**

You should see the Tasmio Drive sign-up page. 🎉

> **If Apache won't start (turns red):** something else is using port 80.
> Click **Config → Apache (httpd.conf)**, find `Listen 80`, change it to `Listen 8080`,
> save, and Start again. Then your address becomes
> `http://localhost:8080/tasmio-drive/`
> — if you do this, tell Claude so the OneDrive settings can be updated to match.

---

## PART 4 — Create your admin account

On the page that loads:
- Pick a username and password → **Create account**
- The first account is automatically the **admin**
- You'll land on the **Setup** page. It will say *"Not connected"* — that's expected.

Your login works now. Next we connect the storage.

---

## PART 5 — Connect OneDrive (the Microsoft part)

This tells Microsoft "this website is allowed to use my OneDrive".

### 5a. Register the app
1. Go to **https://entra.microsoft.com** and sign in with the Microsoft
   account whose OneDrive will store the files
2. In the left menu: **Applications → App registrations**
3. Click **+ New registration**
4. Fill in:
   - **Name:** `Tasmio Drive`
   - **Supported account types:** choose
     **"Accounts in any organizational directory and personal Microsoft accounts"**
   - **Redirect URI:** change the dropdown to **Web**, and type exactly:
     ```
     http://localhost/tasmio-drive/oauth.php
     ```
5. Click **Register**

### 5b. Copy the Client ID
On the page that appears, find **Application (client) ID**.
Click the copy icon. **Keep this — it's value #1.**

### 5c. Create the Client Secret
1. Left menu → **Certificates & secrets**
2. Click **+ New client secret**
3. Description: `tasmio`, Expires: leave default → **Add**
4. A row appears. Copy the text under the **Value** column
   (NOT the "Secret ID"). **This is value #2.**

   ⚠️ You can only see this once. If you lose it, just make a new secret.

### 5d. Add permissions
1. Left menu → **API permissions**
2. **+ Add a permission → Microsoft Graph → Delegated permissions**
3. Search for and tick each of these:
   - `offline_access`
   - `User.Read`
   - `Files.ReadWrite`
4. Click **Add permissions**

---

## PART 6 — Paste your two values into the site

1. Open this file in Notepad:
   **`C:\xampp\htdocs\tasmio-drive\config.php`**
2. Find these two lines:
   ```php
   'client_id'     => 'PASTE_APPLICATION_CLIENT_ID',
   'client_secret' => 'PASTE_CLIENT_SECRET_VALUE',
   ```
3. Replace the text inside the quotes with your two values:
   ```php
   'client_id'     => 'abc123-your-real-client-id',
   'client_secret' => 'Xy7~your-real-secret-value',
   ```
4. **Save** the file (Ctrl+S)

> 🔒 Keep the client secret private — it's like a password.
> Don't paste it into a chat, email, or screenshot.

---

## PART 7 — Finish

1. Go back to **http://localhost/tasmio-drive/setup.php**
2. Press **F5** to refresh — the warning should be gone
3. Click **Connect OneDrive**
4. Sign in with your Microsoft account → click **Accept** on the permissions screen
5. You'll come back to a green **"OneDrive connected 🎉"** message

**Done.** Click *Open Tasmio Drive* and upload a file to test it.

---

## Everyday use

- Start: open XAMPP Control Panel → **Start** Apache → go to `http://localhost/tasmio-drive/`
- Add more users: **Setup (⚙️) → Users → Add**
- Your files appear in your real OneDrive under the folder **`TasmioDrive`**

## If something goes wrong

| What you see | What to do |
|---|---|
| Page shows raw PHP code | Apache isn't running, or you opened the file directly instead of `http://localhost/...` |
| "Storage isn't connected" | Finish Parts 5–7 |
| `AADSTS50011` redirect error | The Redirect URI in Microsoft must match `http://localhost/tasmio-drive/oauth.php` exactly |
| `invalid_client` error | You copied the Secret **ID** instead of the Secret **Value**. Make a new secret. |
| Apache turns red | See the port-80 note in Part 3 |
