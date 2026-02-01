# Jarvis Remote Dashboard - Complete Setup Guide

## 🎉 Done! Your Jarvis Remote Dashboard is Ready!

---

## 🌐 Your Remote Access URL

```
https://graduates-enquiry-construction-novel.trycloudflare.com
```

**Open this URL on your phone** to access Jarvis Dashboard from anywhere!

---

## 📱 How to Find Your Mac's Local IP

**Method 1: System Settings (Easiest)**
1. Open: System Settings → Network
2. Look for: "Wi-Fi address" or "Your local IP"
3. It will look like: `192.168.x.x`

**Method 2: Check Tunnel Output**
Run the startup script:
```bash
./start-jarvis.sh
```
The script will display the tunnel URL after it's ready.

**Using Same WiFi Network:**
If your phone is on the same WiFi as your Mac, use the local IP:
```
http://192.168.64.2:5000
```

---

### 🎯 Note About Tunnel Stability

Free Cloudflare tunnels with random hostnames may occasionally change:
- If URL becomes inaccessible, re-run: `jarvis-dashboard.sh`
- The tunnel may expire after inactivity
- Bookmark this URL for easy access

## What's Included

### 📊 Web Dashboard
- Jarvis Kanban Board (live)
- Quick stats (tasks completed, in progress, to do)
- Active projects with progress
- Recent activity log
- Day Starter output (weather, calendar, news, stocks)

### 🔐 Security
- **Cloudflare Tunnel** — Free, secure HTTPS
- **No account required**
- **No auth tokens to manage**
- **Simple setup**

### 📡 API Endpoints
All accessible with header: `X-Auth-Token: jarvis-2026`

```
GET  /              → Dashboard HTML
GET  /api/status    → Jarvis status
GET  /api/dash      → Generate fresh dashboard
GET  /api/stocks    → Stock prices
GET  /api/kanban    → Kanban board (JSON)
POST /api/memo      → Quick capture note
GET  /api/calendar  → Calendar events
```

---

## Usage

### On Your Mac

**Start the server (if not running):**
```bash
/Users/bclawd/.openclaw/workspace/jarvis-server
```

**Or start with Cloudflare tunnel:**
```bash
cloudflared tunnel --url http://localhost:5000
```

**Check what tunnels are active:**
Visit: https://dash.cloudflare.com

### On Your Phone

1. Open browser
2. Go to: `https://allied-wright-scene-governments.trycloudflare.com`
3. Control Jarvis from anywhere!

---

## Auto-Start at Boot

To have Jarvis start automatically:

```bash
# Create LaunchAgent
mkdir -p ~/Library/LaunchAgents
cat > ~/Library/LaunchAgents/jarvis-dashboard.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>Jarvis Remote Dashboard</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Users/bclawd/.openclaw/workspace/remote_dashboard.py</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
EOF

# Load it
launchctl load ~/Library/LaunchAgents/jarvis-dashboard.plist
```

To auto-start with tunnel (create a combined script):
```bash
cat > ~/Library/LaunchAgents/jarvis-dashboard-with-tunnel.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>Jarvis Dashboard + Tunnel</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Users/bclawd/.openclaw/workspace/jarvis-server</string>
    </array>
    <key>WorkingDirectory</key>
    <string>/Users/bclawd/.openclaw/workspace</string>
    <key>EnvironmentVariables</key>
    <dict>
        <key>TUNNEL_URL</key>
        <string>http://localhost:5000</string>
    </dict>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
EOF
```

---

## Files Created

- `remote_dashboard.py` — Flask web server
- `jarvis-server` — Shell wrapper
- `SETUP_GUIDE.md` — Complete documentation
- All pushed to GitHub

---

## Next: Telegram Bot (Coming)

Commands I'll implement:
- `/dash` → View dashboard
- `/status` → What's Jarvis working on?
- `/stocks` → Get stock prices
- `/tasks` → Kanban board

---

**Open this URL on your phone now:**
🌐 **https://allied-wright-scene-governments.trycloudflare.com**

**Control Jarvis from anywhere!** 📱🚀
