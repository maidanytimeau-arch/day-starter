# Jarvis's Kanban Board

A transparent view of what I'm working on for Bob.

---

## 📋 To Do
- [ ] Create Telegram bot with python-telegram-bot
  - [ ] Implement command handlers (/dash, /status, /stocks, /tasks, /memo, /calendar)
  - [ ] Add bot commands to execute Jarvis actions
  - [ ] Test end-to-end integration
  - [ ] Deploy bot to production
- [ ] Improve Day Starter news filtering (better TMT/finance relevance)
- [ ] Create task management CLI for Bob
- [ ] Add habit tracking to Day Starter
- [ ] Create visual task dashboard (web-based kanban)
- [ ] Add market index summary (Dow, S&P, Nasdaq) to Day Starter

## 🔄 In Progress

### 🍼 LittleBites - Baby Food Tracker (IN PROGRESS)
- [ ] **Phase 1: MVP Development** (2-3 weeks)
  - [x] Create UI mockups and design system ✅
  - [x] Initialize Flutter project (iOS + Android) ✅
  - [x] Install dependencies (Firebase, Riverpod, UI) ✅
  - [x] Build core data models (Food, Log, Reaction, Profile) ✅
  - [ ] Configure Firebase project (waiting for Bob)
  - [ ] Implement Firebase Auth
  - [ ] Implement Firebase Firestore
  - [ ] Build app navigation structure
  - [ ] Build Home screen
  - [ ] Build Add Meal screen
  - [ ] Implement food logging feature
  - [ ] Implement allergen auto-tagging system
  - [ ] Implement reaction tracking (severity 1-5)
  - [ ] Implement poop tracking feature
  - [ ] Build Food History screen
  - [ ] Build Log Reaction screen
  - [ ] Build Poop Log screen
  - [ ] Build Profiles/Family screen
  - [ ] Build Settings screen
  - [ ] Add real-time sync testing
  - [ ] Implement offline support
  - [ ] Add data export (PDF/CSV)
  - [ ] Add dark mode
  - [ ] Bug fixes and beta testing

- [ ] **Phase 2: Production Launch** (1-2 weeks)
  - [ ] Set up App Store Connect (iOS)
  - [ ] Set up Google Play Console (Android)
  - [ ] Create privacy policy and terms of service
  - [ ] Design app screenshots and descriptions
  - [ ] Beta testing with family/friends
  - [ ] Configure Firebase Analytics
  - [ ] Submit to App Store (review 1-3 days)
  - [ ] Submit to Google Play (review <1 day)
  - [ ] Launch marketing campaign

**Project Location:** `/Users/bclawd/.openclaw/workspace/baby-tracker/`
**Documentation:** [PROJECT_PLAN.md](./baby-tracker/PROJECT_PLAN.md) | [README.md](./baby-tracker/README.md)
**Tech Stack:** Flutter + Firebase
**Timeline:** 4-5 weeks to MVP

### 📱 Discord Integration for Jarvis Remote Dashboard
- [ ] Determine integration approach (new bot vs existing channel)
- [ ] Implement Discord commands (/dash, /stocks, /tasks, /news, /memo, /calendar)
- [ ] Add rich embeds and interactive buttons
- [ ] Test end-to-end
- [ ] Deploy to production

## ✅ Done
- [x] **Jarvis Remote Dashboard Web Server** - Flask web server with API endpoints
  - [x] Created Flask web server (remote_dashboard.py)
  - [x] Added API endpoints: /status, /dash, /stocks, /kanban, /memo, /calendar
  - [x] Tested endpoints working
  - [x] Created jarvis-server wrapper script
  - [x] Authentication token system (X-Auth-Token: jarvis-2026)
  - [x] Documentation created (REMOTE_DASHBOARD_README.md)
  - [x] Pushed to GitHub
  - [x] **Cloudflare tunnel working** - Free secure tunnel for mobile access
  - [x] Created start-jarvis.sh - Improved startup script that starts tunnel and web server
  - [x] Created get_local_ip.py - Helper to find Mac's local IP
  - [x] Tunnel URL active: https://graduates-enquiry-construction-novel.trycloudflare.com
  - [x] Pushed to GitHub

- [x] **Jarvis Dashboard** - Visual kanban board and project tracking
  - [x] HTML dashboard with real-time data from KANBAN.md and memory files
  - [x] Quick stats (tasks completed, in progress, to do)
  - [x] Visual kanban board (4 columns)
  - [x] Active project progress bars
  - [x] Recent activity log
  - [x] Auto-refresh every 5 minutes
  - [x] Opens in browser automatically
  - [x] Location: `~/.openclaw/workspace/DASHBOARD.html`
  - [x] Command: `dashboard`
  - [x] Pushed to GitHub

- [x] **Day Starter v6** - Added stock price summary
  - [x] Installed yfinance library for free stock data
  - [x] Created stock_prices.py script
  - [x] Integrated stock prices into Day Starter
  - [x] Shows 11 major tech/TMT stocks with daily changes
  - [x] Pushed to GitHub

- [x] **NewsAPI Setup** - Configured API key and categories for TMT/finance news
  - [x] API Key: 5c2c34de0cdd48ee969ad3c693378c0d
  - [x] Categories: business, technology
  - [x] Filtered for finance/tech/telco content

- [x] **Location Update** - Set weather and timezone to Sydney
  - [x] Weather source: wttr.in (Sydney)
  - [x] Timezone: Australia/Sydney

- [x] **Automated Daily Briefings** - Scheduled cron job for 7:30 AM Sydney time daily
  - [x] Cron job created and active
  - [x] Sends: weather, calendar, reminders, news, stocks
  - [x] Automated at 7:30 AM daily

- [x] **GitHub repository setup** - Complete
  - [x] SSH keys generated ✅
  - [x] Git CLI installed ✅
  - [x] GitHub CLI installed ✅
  - [x] GitHub CLI authenticated ✅
  - [x] Repository created ✅
  - [x] Day Starter code pushed ✅
  - [x] Dashboard code pushed ✅
  - [x] All code pushed to https://github.com/maidanytimeau-arch/day-starter

- [x] **Day Starter application** - Complete CLI dashboard
  - [x] Weather integration (Sydney)
  - [x] Calendar integration (macOS)
  - [x] Reminders integration (Apple Reminders)
  - [x] News integration (NewsAPI + Hacker News)
  - [x] Daily planning notes (auto-generated)
  - [x] Stock price summary (yfinance)
  - [x] Location: Sydney, Australia
  - [x] Timezone: Australia/Sydney
  - [x] Daily briefings: 7:30 AM Sydney time

## ⏸️ Blocked / Waiting
- None currently

---

**Last Updated:** 2026-01-31

*This board is updated as I work on tasks for Bob. Feel free to check anytime!*
