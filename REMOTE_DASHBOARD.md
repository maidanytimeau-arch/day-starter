# Jarvis Remote Dashboard

## Overview
A web-based dashboard and Telegram bot for accessing Jarvis from mobile devices.

## Features (Planned)

### 📱 Telegram Bot Commands
- `/dash` → View Jarvis Dashboard (screenshot)
- `/status` → What's Jarvis working on?
- `/tasks` → Kanban board summary
- `/news` → Run Day Starter and send briefing
- `/stocks` → Get stock prices
- `/memo` → Quick capture note
- `/calendar` → Today's calendar events

### 🌐 Web Dashboard
- Visual kanban board
- Quick stats
- Active projects with progress
- Recent activity log
- Day Starter output (weather, calendar, news, stocks)
- Remote command execution

### 🔐 Security
- Token-based authentication for web dashboard
- Telegram bot only responds to authorized user
- HTTPS only (can use self-signed cert for local)
- IP whitelist option

## Tech Stack
- **Flask** — Lightweight web framework
- **python-telegram-bot** — Telegram bot library
- **Existing Dashboard.py** — HTML generator
- **Existing stock_prices.py** — Stock data
- **Existing daystarter.py** — Daily briefing

## API Endpoints

```
GET  /              → Dashboard HTML
GET  /api/status    → Current Jarvis status (from kanban)
GET  /api/dash      → Generate and return dashboard
POST /api/dash      → Trigger daystarter and return output
GET  /api/stocks    → Get stock prices
GET  /api/kanban    → Get kanban data (JSON)
GET  /api/memo      → Quick capture note
GET  /api/calendar  → Today's calendar events
```

## Setup Requirements

1. Telegram Bot Token (create at @BotFather)
2. Flask web server
3. Python dependencies (flask, python-telegram-bot)
4. Self-signed HTTPS certificate (for secure access) or local network access

## Next Steps

1. Create Flask app with dashboard serving
2. Create Telegram bot with command handlers
3. Integrate with existing Jarvis tools
4. Add authentication layer
5. Test end-to-end
6. Document setup instructions
7. Deploy (self-hosted)
