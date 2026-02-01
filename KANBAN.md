# Jarvis's Kanban Board

A transparent view of what I'm working on for Bob.

---

## 📋 To Do
- [ ] Improve Day Starter news filtering (better TMT/finance relevance)
- [ ] Create task management CLI for Bob
- [ ] Add habit tracking to Day Starter
- [ ] Create visual task dashboard (web-based kanban)
- [ ] Add market index summary (Dow, S&P, Nasdaq) to Day Starter

## 🔄 In Progress
- [ ] Create Telegram bot with python-telegram-bot
  - [ ] Implement command handlers
  - [ ] Add bot commands to execute actions
  - [ ] Test end-to-end
  - [ ] Deploy and setup auto-start

## ✅ Done
- [x] **Jarvis Remote Dashboard Web Server** - Flask web server with API endpoints
  - [x] Created Flask web server (remote_dashboard.py)
  - [x] Added API endpoints: /status, /dash, /stocks, /kanban, /memo, /calendar
  - [x] Tested endpoints working
  - [x] Created jarvis-server wrapper script
  - [x] Authentication token system (X-Auth-Token: jarvis-2026)
  - [x] Documentation created (REMOTE_DASHBOARD_README.md)
  - [x] Pushed to GitHub

## ✅ Done
- [x] **Jarvis Dashboard** - Visual kanban board and project tracking
  - [x] HTML dashboard with real-time data from KANBAN.md and memory files
  - [x] Quick stats (tasks completed, in progress, to do)
  - [x] Visual kanban board (4 columns)
  - [x] Active project progress bars
  - [x] Recent activity log
  - [x] Auto-refresh every 5 minutes

- [x] GitHub repository setup ✅ Complete
  - [x] SSH keys generated ✅
  - [x] Git CLI installed ✅
  - [x] GitHub CLI installed ✅
  - [x] GitHub CLI authenticated ✅
  - [x] Repository created ✅
  - [x] Day Starter code pushed ✅

- [x] Day Starter application ✅ Complete
  - [x] Weather integration (Sydney)
  - [x] Calendar integration (macOS)
  - [x] Reminders integration (Apple Reminders)
  - [x] News integration (NewsAPI + Hacker News)
  - [x] Daily planning notes (auto-generated)

## ⏸️ Blocked / Waiting
- None currently

## ✅ Done
- [x] **Day Starter v1** - Basic CLI with weather, reminders, and notes
- [x] **Day Starter v2** - Added Google Calendar integration (via gcalcli, later switched to macOS Calendar)
- [x] **Day Starter v3** - Added overnight news from Hacker News
- [x] **Day Starter v4** - Enhanced news filtering for finance/tech/telco
- [x] **Day Starter v5** - Added NewsAPI integration for comprehensive financial news
- [x] **Day Starter v6** - Added stock price summary
  - [x] Installed yfinance library for free stock data
  - [x] Created stock_prices.py script
  - [x] Integrated stock prices into Day Starter
  - [x] Shows 11 major tech/TMT stocks with daily changes
- [x] **NewsAPI Setup** - Configured API key and categories for TMT/finance news
- [x] **Location Update** - Set weather and timezone to Sydney
- [x] **Automated Daily Briefings** - Scheduled cron job for 7:30 AM Sydney time daily
- [x] **GitHub repository setup** ✅ Complete
  - [x] SSH keys generated ✅
  - [x] Git CLI installed ✅
  - [x] GitHub CLI installed ✅
  - [x] GitHub CLI authenticated ✅
  - [x] Repository created ✅
  - [x] All code pushed ✅

---

**Last Updated:** 2026-01-31

*This board is updated as I work on tasks for Bob. Feel free to check anytime!*
