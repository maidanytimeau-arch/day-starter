## GitHub Authentication

GitHub CLI authentication requires browser interaction. Since you need to do this manually, here's the faster path:

### Option 1: Manual Repo Creation (Fastest)

1. **Open GitHub app** or github.com
2. **Tap +** → "New repository"
3. **Fill in:**
   - Repository name: `day-starter`
   - Description: `Daily CLI dashboard - weather, calendar, news, and notes`
   - Visibility: Private or Public (your choice)
4. **Tap** "Create repository"

### Option 2: Browser Authentication for gh CLI

Run this command and follow browser prompts:
```bash
gh auth login --web --git-protocol ssh --skip-ssh-key
```

Then:
1. Open the URL it shows
2. Enter the device code
3. Authorize the app

---

### Current Status

✅ SSH keys generated and working
✅ Git initialized locally
⏸️ GitHub CLI not authenticated
⏸️ No remote repository connected

---

### What to Do Next

**Fastest route:** Create repo manually on GitHub, then tell me the repo URL.

I'll handle:
- Adding remote
- Making commits
- Pushing code
