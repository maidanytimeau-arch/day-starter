# Jarvis Remote Dashboard

**Telegram Bot + Web Dashboard** — Control Jarvis from your mobile phone securely.

## Features

### 🌐 Web Dashboard
Access via browser at `http://localhost:5000` or via secure tunnel for remote access.

Shows:
- Jarvis Kanban Board (live)
- Quick stats (tasks completed, in progress, to do)
- Active projects with progress bars
- Recent activity log

### 📱 Telegram Bot (Coming Soon)
Commands for quick actions from anywhere:

```
/dash      → View dashboard (screenshot)
/status     → Current Jarvis status
/tasks      → Kanban summary
/news       → Run Day Starter briefing
/stocks     → Get stock prices
/memo        → Quick capture note
/calendar    → Today's calendar
```

## Setup

### 1. Install Dependencies
```bash
brew install flask
```

### 2. Start Server
```bash
jarvis-server
```

### 3. Access Locally
Open browser: http://localhost:5000

### 4. Remote Access (Optional)

**Option A: Local Network Access**
```bash
jarvis-server
```

Access from phone via your Mac's local IP: `http://[YOUR-MAC-IP]:5000`

**Option B: Secure Tunnel (ngrok)**
```bash
brew install ngrok
ngrok http 5000
```

You'll get a secure URL like: `https://abc123.ngrok.io`

Use this URL on your phone!

## API Endpoints

```
GET  /              → Dashboard HTML
GET  /api/status    → Jarvis status (kanban data)
GET  /api/dash      → Generate fresh dashboard
GET  /api/stocks    → Stock prices
GET  /api/kanban    → Kanban board (JSON)
POST /api/memo      → Quick capture note
GET  /api/calendar  → Calendar events
```

## Security

🔐 **Auth Token:** `jarvis-2026` (for API endpoints)

For external access, add header:
```
X-Auth-Token: jarvis-2026
```

## Files

- `remote_dashboard.py` — Flask web server
- `jarvis-server` — Shell wrapper
- `DASHBOARD.html` — Generated dashboard (auto-updated)

## Next Steps

- [ ] Create Telegram bot with python-telegram-bot
- [ ] Implement command handlers
- [ ] Add bot commands to execute actions
- [ ] Test end-to-end
- [ ] Add stronger authentication (JWT)
- [ ] Deploy and setup auto-start
