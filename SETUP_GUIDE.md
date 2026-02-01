# Jarvis Remote Dashboard - Setup Guide

## Current Status

✅ **Web Server** — Running on http://localhost:5000
✅ **API Endpoints** — All tested and working
✅ **Cloudflare Tunnel** — Active and ready

### 🌐 Remote Access URL

**Your Jarvis Dashboard is accessible at:**
```
https://allied-wright-scene-governments.trycloudflare.com
```

Open this URL on your phone to access Jarvis Dashboard!

---

## Features

### 📱 Telegram Bot Commands (Coming Soon)

```
/dash      → View Jarvis Dashboard (screenshot)
/status     → Current Jarvis status
/tasks      → Kanban board summary
/news       → Run Day Starter and send briefing
/stocks     → Get stock prices
/memo        → Quick capture note
/calendar    → Today's calendar events
```

### 🌐 Web Dashboard

Access via browser at your Cloudflare URL:
```
https://allied-wright-scene-governments.trycloudflare.com
```

Shows:
- Jarvis Kanban Board (live)
- Quick stats (tasks completed, in progress, to do)
- Active projects with progress
- Recent activity log
- Day Starter output (weather, calendar, news, stocks)

### 🔐 Security

- **Tunnel:** Cloudflare (HTTPS, secure)
- **No account required**
- **No tokens to manage**
- **Simple setup**

### 📡 API Endpoints

```
GET  /              → Dashboard HTML
GET  /api/status    → Jarvis status (kanban data)
GET  /api/dash      → Generate fresh dashboard
GET  /api/stocks    → Stock prices
GET  /api/kanban    → Kanban board (JSON)
POST /api/memo      → Quick capture note
GET  /api/calendar  → Calendar events
```

## Usage

### On Your Mac

**Start the server:**
```bash
jarvis-server
```

### On Your Phone

**Access dashboard:**
1. Open browser
2. Go to: `https://allied-wright-scene-governments.trycloudflare.com`
3. Full Jarvis Dashboard and control from anywhere!

### Stop Server

```bash
# Kill the background cloudflared process
pkill -f cloudflared

# Or kill specific tunnel
# Visit https://dash.cloudflare.com to manage your tunnels
```

## Auto-Start (Optional)

To have Jarvis Remote Dashboard start automatically when you boot:

### Create launch agent (macOS)

Create file: `~/Library/LaunchAgents/jarvis-dashboard.plist`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>Jarvis Remote Dashboard</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Users/bclawd/.openclaw/workspace/jarvis-server</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
```

Then in terminal:
```bash
launchctl load ~/Library/LaunchAgents/jarvis-dashboard.plist
```

To unload:
```bash
launchctl unload ~/Library/LaunchAgents/jarvis-dashboard.plist
```

## Tech Stack

- **Flask** — Lightweight web framework
- **Cloudflare Tunnel** — Secure remote access (no account needed)
- **Existing Dashboard.py** — HTML generator
- **Existing stock_prices.py** — Stock data
- **Existing daystarter.py** — Daily briefing

## Files

- `remote_dashboard.py` — Flask web server
- `jarvis-server` — Shell wrapper
- `cloudflared` — Tunnel tool (installed via Homebrew)
- `DASHBOARD.html` — Generated dashboard
- All pushed to GitHub: https://github.com/maidanytimeau-arch/day-starter

## Your Remote Access URL

🌐 **https://allied-wright-scene-governments.trycloudflare.com**

---

**Open this on your phone to control Jarvis from anywhere!** 📱
