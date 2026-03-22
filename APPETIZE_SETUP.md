# Publishing IK Subsea App to Appetize.io via GitHub Actions

This guide gets your app live at a shareable URL — no Mac hardware required on your end.
The GitHub Actions runner (a cloud Mac) does the build automatically every time you push code.

---

## What you need

| Requirement | Cost | Notes |
|---|---|---|
| GitHub account | Free | github.com |
| Appetize.io account | Free tier | 100 min/month free |
| Nothing else | — | No Mac, no Apple Developer account needed |

---

## Step 1 — Create a GitHub repository

1. Go to **github.com** → click **"New repository"**
2. Name it: `iksubsea-app`
3. Set it to **Private** (keeps your code confidential)
4. Click **Create repository**

GitHub will show you the repository URL, e.g.:
```
https://github.com/yourusername/iksubsea-app
```

---

## Step 2 — Push the project to GitHub

On your Windows machine, open a terminal (PowerShell or Command Prompt) and run:

```powershell
cd C:\Users\hbr\Documents\IKSubseaApp

# Initialise git
git init
git add .
git commit -m "Initial commit — IK Subsea Solutions app"

# Connect to your GitHub repo (replace with your actual URL)
git remote add origin https://github.com/yourusername/iksubsea-app.git
git branch -M main
git push -u origin main
```

If Git isn't installed: download from **git-scm.com** (free, 2 minutes).

---

## Step 3 — Create your Appetize.io account and get an API token

1. Go to **appetize.io** → **Sign up** (free)
2. After signing in, go to: **appetize.io/account**
3. Scroll to **"API Token"** section
4. Click **"Generate new token"**
5. Copy the token — it looks like: `tok_abc123xyz...`

---

## Step 4 — Get your Appetize app Public Key

### First upload (creates the app slot):

You need to do a one-time manual upload to create an app slot on Appetize, which gives you a **Public Key** (the permanent ID for your app). After this, the GitHub Action updates it automatically.

Option A — Upload via their website:
1. Go to **appetize.io/upload**
2. Select **iOS**
3. Upload any placeholder zip (or wait until Step 6 to do this via curl)

Option B — Create via API (paste this in PowerShell, replacing your token):
```powershell
$token = "tok_YOUR_TOKEN_HERE"
$response = Invoke-RestMethod -Uri "https://api.appetize.io/v1/apps" `
  -Method POST `
  -Headers @{ Authorization = "Token $token" } `
  -Body @{ platform = "ios" }
$response.publicKey
```

Copy the `publicKey` value — it looks like: `abc123xyz456`

---

## Step 5 — Add secrets to your GitHub repository

Your API token and app public key must be stored as **GitHub Secrets** (encrypted, never visible in logs).

1. Go to your GitHub repository
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **"New repository secret"** — add these two:

| Secret name | Value |
|---|---|
| `APPETIZE_API_TOKEN` | Your Appetize API token from Step 3 |
| `APPETIZE_PUBLIC_KEY` | Your Appetize app public key from Step 4 |

---

## Step 6 — Trigger the first build

The workflow runs automatically on every push to `main`. To trigger it manually:

1. Go to your GitHub repository
2. Click **Actions** tab
3. Click **"Build & Upload to Appetize.io"** in the left panel
4. Click **"Run workflow"** → **"Run workflow"**

The build takes approximately **8–12 minutes** (GitHub's Mac runner compiles everything from scratch).

---

## Step 7 — Get your shareable URL

When the workflow finishes:

1. Click on the completed workflow run
2. Scroll to the **"Print shareable URL"** step
3. Your URL will be displayed:

```
=============================================
  IK Subsea App is live on Appetize.io
  https://appetize.io/app/abc123xyz456
=============================================
```

**Share this URL with anyone.** They click it, the app opens in their browser — no install, no Apple ID, no friction.

---

## Step 8 — Automatic updates

From now on, every time you push changes to the `main` branch:
- GitHub Actions builds the new version automatically
- Uploads it to the same Appetize URL
- Your clients always see the latest version at the same link

---

## Appetize URL options

You can customise the experience by adding parameters to the URL:

| Parameter | Example | Effect |
|---|---|---|
| `device` | `?device=ipad` | Shows iPad frame |
| `orientation` | `?orientation=landscape` | Landscape mode |
| `scale` | `?scale=75` | 75% zoom |
| `embed` | Embed in iframe | Put app inside your website |

**Full client demo URL example:**
```
https://appetize.io/app/abc123xyz456?device=ipad&orientation=landscape&scale=75
```

**Embed in your website:**
```html
<iframe
  src="https://appetize.io/embed/abc123xyz456?device=ipad&orientation=landscape&scale=75"
  width="900"
  height="700"
  frameborder="0"
  scrolling="no">
</iframe>
```

---

## Troubleshooting

**Build fails: "No simulator found"**
→ The workflow uses `iPad Air (M2)`. If that name isn't available, edit the workflow and change to:
```
-destination 'platform=iOS Simulator,name=iPad (10th generation),OS=latest'
```

**Build fails: "Code signing required"**
→ The workflow already has `CODE_SIGNING_ALLOWED=NO` set, which disables signing for simulator builds. This is correct.

**Appetize upload fails: 401 Unauthorized**
→ Check that `APPETIZE_API_TOKEN` is set correctly in GitHub Secrets (no extra spaces).

**App loads but crashes on Appetize**
→ Download the zip artifact from the Actions run and test it locally first. Go to Actions → your run → Artifacts → download `IKSubsea-simulator-build`.

---

## Free tier limits

| Plan | Minutes/month | Session length | Cost |
|---|---|---|---|
| Free | 100 min | 3 min | $0 |
| Starter | 500 min | 10 min | $59/mo |
| Pro | Unlimited | Unlimited | $319/mo |

For client presentations, the **Starter plan at $59/month** gives you ~50 ten-minute demos per month — more than enough for a sales tool.
