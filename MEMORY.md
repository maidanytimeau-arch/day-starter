# MEMORY.md - Long-Term Memory

Curated wisdom distilled from daily logs. This is what matters.

---

## Bob's Profile

**Name:** Bob  
**Pronouns:** he/him  
**Location:** Sydney, Australia (Timezone: Australia/Sydney)  
**Role:** Financial/TMT sector professional (investor/analyst vibes)

**What Bob cares about:**
- Finance, tech, and telecommunications (TMT) news
- Stock market trends and performance
- Quick, actionable information (no fluff)
- Transparency and visibility into what I'm doing
- Mobile-friendly tools and dashboards
- Automation that just works

**Bob's workflow preferences:**
- Uses Discord for messaging (primary channel)
- GitHub for code tracking (maidanytimeau-arch)
- Wants to see progress, not just "it's done"
- Likes kanban boards for project tracking
- Values reliability over experimental features

---

## Technical Knowledge

### Chutes.AI Model Configuration

**Working pattern (verified 2026-02-03):**

- **Provider:** `chutesai` (NOT `chutes`)
- **Model IDs:** WITHOUT `chutes/` prefix (e.g., `deepseek-ai/DeepSeek-V3`)
- **Full reference:** `provider/modelId` (e.g., `chutesai/deepseek-ai/DeepSeek-V3`)

**Model Aliases (use in config):**
- `GLM-4.7` → `zai/glm-4.7` (primary workhorse, unlimited)
- `Kimi-K2.5` → `chutesai/moonshotai/Kimi-K2.5-TEE` (deep thinking preference)

**Model Selection Strategy:**

**GLM-4.7 (zai unlimited) - Use for 90% of tasks:**
- Main session orchestration
- Complex reasoning and analysis
- Web searches, coding, research
- Parallel subagent spawning
- No cost concerns (unlimited tokens)

**Kimi-K2.5 - Use for:**
- Deep thinking and complex reasoning
- Long-form analysis and planning
- Tasks where thinking depth > token efficiency
- User preference: "I like kimi-2.5 for deeper thinking"

**Config files:**
- `/Users/bclawd/.openclaw/openclaw.json`
- `/Users/bclawd/.openclaw/agents/main/agent/models.json`

### PM2 Process Management

**Key patterns:**

When running shell commands with pipes through PM2, use direct commands with `--interpreter none`:
```bash
# Good - bypasses npm, runs shell command directly
pm2 start "tail -f ~/.openclaw/logs/gateway.err.log | node /path/to/parser.js" \
  --name parser-service --interpreter none

# Bad - npm looks in wrong directory
pm2 start npm -- run parser-dev  # ❌ Fails to find package.json
```

**Useful PM2 commands:**
```bash
pm2 status                    # View all services
pm2 logs <name>               # View logs
pm2 restart <name>            # Restart service
pm2 stop <name>               # Stop service
pm2 delete <name>             # Remove service
pm2 save                      # Persist PM2 configuration
pm2 startup                   # Auto-start on boot
```

### macOS Integration

**Calendar access without OAuth:**
- Use AppleScript (`osascript`) to query macOS Calendar directly
- macOS Calendar syncs with Google Calendar via System Settings → Internet Accounts
- No need for gcalcli or complex OAuth setups

**Reminders access:**
- Use `remindctl` CLI (install via Homebrew)
- Provides list, add, edit, complete, delete operations
- Supports lists, date filters, JSON/plain output

**Apple Notes access:**
- Use `memo` CLI (install via npm/Homebrew)
- Provides create, view, edit, delete, search, move, export operations

### News APIs

**Best sources tested:**
- **NewsAPI.org** - Comprehensive, requires API key, good for business/tech
  - Key: `5c2c34de0cdd48ee969ad3c693378c0d`
  - Categories: business, technology
  - Filter with keywords: finance, tech, telco, TMT
- **Hacker News** - Free, no key, tech-focused, great fallback
- **RSS feeds** - Fast, reliable, no keys needed
  - Reuters, Bloomberg, CNBC, TechCrunch, Ars Technica, The Verge

**Weather:**
- wttr.in API - Free, no authentication, format: `curl wttr.in/Sydney?format=3`

### Stock Data

**Free source:**
- Yahoo Finance via `yfinance` Python library
- No API key required for basic data
- Provides daily prices, changes, market cap

**ASX News Alerts:**
- Coverage stocks: LIF, ABB, CAR, IEL, MP1, NWS, NXT, REA, SEK, SLC, TLS, TNE, TPG, WTC, XRO, XYZ, ZIP
- Send to Discord channel: `146846460040238429` (Bob's alerts channel)
- Alert criteria: earnings, M&A, guidance changes, management changes, regulatory issues

---

## Architecture Patterns

### Three-Layer Memory Stack

**Convergent architecture used by 10+ AI agents:**

1. **Layer 1: Daily logs** (`memory/YYYY-MM-DD.md`)
   - Raw timeline of what happened
   - Written continuously, not just at session end
   - Don't worry about redundancy or noise
   - Just capture it

2. **Layer 2: Long-term memory** (`MEMORY.md`)
   - Curated wisdom distilled from daily logs
   - Not everything — just what matters
   - Patterns, lessons, configurations, preferences
   - Updated during heartbeats

3. **Layer 3: Operational state** (`NOW.md`)
   - Current context, active tasks, "if I wake up confused, read this first"
   - What am I working on right now?
   - What projects are in flight?
   - What was the last thing I did?

**Why it works:**
- Layer 1: Don't lose anything
- Layer 2: Actually use what you learned
- Layer 3: Resume where you left off

### Subagent Strategy

**Pattern: Main + Parallel Workers (unlimited GLM-4.7 makes this cost-free)**

```
Main Session (GLM-4.7 - orchestrator)
    ↓ spawns parallel
    ├─ Subagent A (GLM-4.7): Research stock X
    ├─ Subagent B (GLM-4.7): Analyze logs Y
    ├─ Subagent C (GLM-4.7): Write script Z
    └─ Subagent D (GLM-4.7): Summarize findings

All report back
    ↓
Main (GLM-4.7): Synthesize and respond
```

**When to use:**
- Multiple stocks to research
- Multiple files to process
- Independent web searches
- Separate analyses needed

**Key insight:** With unlimited tokens, subagents become free. Spawn as many as needed - no cost penalty.

### Discord Bot Integration

**Pattern for streaming activity to Discord:**

```
Log Source (gateway.err.log)
    ↓
Tail + Parser (JavaScript/Node)
    ↓
Webhook (POST to localhost)
    ↓
Discord Bot (discord.js)
    ↓
Discord Channel (embeds)
```

**Key components:**
- **Log parser:** Watch log file with `tail -f`, parse patterns, send webhooks
- **Webhook server:** Express/Fastify endpoint, validate with secret key
- **Discord bot:** discord.js, create embeds, handle slash commands
- **PM2:** Run both services as background processes

**Event types:**
- `tool_call` - Tool execution failures
- `process` - Process updates (Discord events, agent activity)
- `error` - Errors (tool failures, lane errors)
- `info` - Info messages (session memory hooks)

### Flask/Python Web Services

**Pattern for mobile-accessible dashboards:**

```
Python Script (Flask)
    ↓
Local Server (localhost:5000)
    ↓
Cloudflare Tunnel (HTTPS)
    ↓
Mobile/Remote Access
```

**Key components:**
- **Flask app:** RESTful API endpoints
- **Authentication:** Token header (`X-Auth-Token: jarvis-2026`)
- **Cloudflare tunnel:** Free HTTPS access, no account needed
- **PM2:** Run as background service

**Endpoints:**
- `GET /` - HTML dashboard
- `GET /api/status` - Status data (JSON)
- `GET /api/<endpoint>` - Action endpoints
- `POST /api/<endpoint>` - Action endpoints with data

---

## Key Projects & Locations

### Day Starter
**Location:** `/Users/bclawd/.openclaw/workspace/day-starter/`
**Purpose:** Daily briefing CLI for Bob
**Features:**
- Weather (Sydney via wttr.in)
- Calendar (macOS via AppleScript)
- Reminders (Apple Reminders via remindctl)
- News (NewsAPI + Hacker News fallback)
- Stock prices (Yahoo Finance via yfinance)
- Daily planning notes (markdown files)

**Usage:**
```bash
daystarter  # Interactive mode
daystarter --non-interactive  # Output only, no prompts
```

**Cron job:** 7:30 AM Sydney time daily

### Jarvis Remote Dashboard
**Location:** `/Users/bclawd/.openclaw/workspace/`
**Purpose:** Mobile-accessible web dashboard + API
**Key files:**
- `remote_dashboard.py` - Flask web server
- `jarvis-dashboard.sh` - Start script with Cloudflare tunnel
- `DASHBOARD.html` - Visual kanban dashboard

**Tunnel URL:** https://graduates-enquiry-construction-novel.trycloudflare.com

**API endpoints (requires `X-Auth-Token: jarvis-2026` header):**
- `GET /` - Dashboard HTML
- `GET /api/status` - Jarvis status
- `GET /api/dash` - Generate fresh dashboard
- `GET /api/stocks` - Stock prices
- `GET /api/kanban` - Kanban board (JSON)
- `POST /api/memo` - Quick capture note
- `GET /api/calendar` - Calendar events

### Claw Activity Stream
**Location:** `/Users/bclawd/.openclaw/workspace/claw-activity-stream/`
**Purpose:** Stream OpenClaw activity to Discord
**Key files:**
- `src/index.js` - Discord bot (listens on `/webhook/activity`)
- `parser.js` - Log parser (PM2 uses this one)
- `parser-claw.js` - Alternative parser (not used)
- `.env` - Configuration (bot token, webhook secret)

**PM2 services:**
- `claw-activity-stream` - Discord bot (port 3000)
- `claw-activity-parser` - Log parser (uses `parser-full.js`)

**Webhook endpoint:** `http://localhost:3000/webhook/activity`

**Known Issues & Fixes (2026-02-05):**

**Issue 1 - Webhook URL Mismatch:**
- **Problem:** `parser.js` had wrong webhook URL (`/webhook` instead of `/webhook/activity`)
- **Symptoms:** HTTP 404 errors, no activity posting to Discord
- **Fix:** Updated line 16 in `parser.js` to use correct endpoint

**Issue 2 - Authentication Failure:**
- **Problem:** Parser wasn't sending `X-Webhook-Secret` header
- **Symptoms:** HTTP 401 Unauthorized errors
- **Fixes:**
  1. Added `WEBHOOK_SECRET` constant to parser.js
  2. Added `'X-Webhook-Secret': WEBHOOK_SECRET` to request headers
  3. Fixed payload structure (removed wrapper layers, mapped to bot's expected format)

**Payload format:**
- Bot expects: `{ type, tool, result/error, timestamp }`
- Parser now sends: Simple object without `type: 'activity'` wrapper

**Verification:**
- Check `pm2 logs claw-activity-parser` for errors
- Manual test: `curl -X POST http://localhost:3000/webhook/activity -H "X-Webhook-Secret: ..." -d '{...}'`
- Parser uses `tail -F -n 0` so restarts don't replay old logs

**Issue 3 - Missing User Messages & Reasoning (2026-02-05):**
- **Problem:** Parser only watched `gateway.err.log`, which doesn't contain user messages or reasoning blocks
- **Root cause:** User messages and reasoning live in session files (`~/.openclaw/agents/main/sessions/*.jsonl`)
- **Symptoms:** Activity stream showed only errors and slow listeners, not what Bob sent or what agent was thinking
- **Fix:** Created `parser-full.js` which:
  1. Tails `gateway.err.log` for system events (errors, slow listeners, tools, lane events, gateway errors, reloads, telegram events)
  2. Polls session directory every 2 seconds for active session file
  3. Parses JSONL lines for:
     - User messages (role: "user") → `type: "info"`, message: "👤 User: ..."
     - Reasoning blocks (type: "thinking") → `type: "reasoning"`
     - Assistant responses (role: "assistant") → `type: "info"`, message: "🤖: ..."

**Event types now captured:**
- ✅ User messages (what Bob sends)
- ✅ Reasoning blocks (agent thinking with 🧠 icon)
- ✅ Assistant responses
- ✅ Tool calls (success/fail)
- ✅ Errors, lane waits, slow listeners, gateway errors, reloads, telegram events

### Equity Research
**Location:** `/Users/bclawd/.openclaw/workspace/equity-research/`
**Purpose:** Daily equity briefing for ASX coverage stocks

**Coverage (17 stocks):**
- LIF (Life360), ABB (Aussie Broadband), CAR (CAR Group), IEL (IDP Education)
- MP1 (Megaport), NWS (News Corp), NXT (NEXTDC), REA (REA Group)
- SEK (SEEK), SLC (Superloop), TLS (Telstra), TNE (Technology One)
- TPG (TPG Telecom), WTC (WiseTech), XRO (Xero), XYZ (Block), ZIP (Zip Co)

**Key files:**
- `tickers.json` - Coverage stock list
- `morning_briefing.py` - Python script to fetch prices and news
- `news_fetcher.py` - News fetching (placeholder)
- `morning-briefing.sh` - Shell script wrapper (placeholder)

**Data sources:**
- Yahoo Finance via `yfinance` Python library (no API key required)
- Web search for recent news (Brave Search API)

**Morning briefing script (`morning_briefing.py`):**
```bash
cd /Users/bclawd/.openclaw/workspace/equity-research
python3 morning_briefing.py
```

**Features:**
- Fetches 2-day price history for all coverage stocks
- Calculates daily change and percentage
- Formats movement emoji (🟢 up, 🔴 down, ⚪ flat)
- Saves briefing to `/tmp/equity-briefing.md`
- Posts to Discord channel `bclawdaudit`

**Discord alerts channel:** `146846460040238429` (Bob's alerts)

**Alert criteria:** Earnings, M&A, guidance changes, management changes, regulatory issues

### GitHub Repository
**URL:** https://github.com/maidanytimeau-arch/day-starter
**Contains:** Day Starter, Jarvis Dashboard, Remote Dashboard scripts
**Branch:** main (active development)

---

## Important Commands & Scripts

**Workspace management:**
```bash
cd /Users/bclawd/.openclaw/workspace  # Workspace directory
```

**PM2 management:**
```bash
pm2 status              # All services
pm2 logs                # All logs
pm2 logs <name>         # Specific service logs
pm2 restart <name>      # Restart service
pm2 save                # Persist configuration
```

**Dashboard:**
```bash
dashboard               # Open visual dashboard
jarvis-dashboard.sh     # Start web server + tunnel
```

**Day Starter:**
```bash
daystarter              # Daily briefing
daystarter --non-interactive  # Automated mode
```

**Day Starter notes:**
```bash
ls ~/Documents/DayStarters/  # Daily planning notes
```

---

## Lessons Learned

**Do:**
- Write down everything important. "Mental notes" don't survive session restarts.
- Use files for memory — they persist, brains don't.
- When debugging: add logging, test end-to-end, verify each layer.
- For complex tools: create wrappers and scripts that just work.
- When running shell commands via PM2: use direct commands with `--interpreter none`.

**Don't:**
- Trust npm to look in the right directory when running via PM2.
- Assume "it's working" without testing the full flow.
- Use OAuth when macOS Calendar has AppleScript access.
- Run PM2 with npm scripts that depend on current directory.

**When in doubt:**
- Add logging
- Test each component independently
- Check the actual error messages
- Use direct shell commands instead of npm wrappers

---

## Configuration Secrets

**NewsAPI Key:** `5c2c34de0cdd48ee969ad3c693378c0d`
**Dashboard Auth Token:** `jarvis-2026`
**Discord Webhook Secret:** `claw-secret-key-change-in-production-2024`

---

*Last updated: 2026-02-06*

## LittleBites - Baby Food Tracker Project (2026-02-04)

**Project Overview:**
- **Location:** `/Users/bclawd/.openclaw/workspace/baby-tracker/`
- **Status:** Firebase Integration In Progress - 5/7 screens refactored with real-time sync
- **Tech Stack:** Flutter + Firebase (Firestore, Auth configured) + Riverpod
- **Dev Time:** ~2 hours (MVP) + ongoing Firebase integration

**What We Built:**
1. Complete planning (PROJECT_PLAN.md, UI_MOCKUPS.md, DATA_MODELS.md)
2. Flutter project structure (models, screens, services, widgets, providers, routes)
3. 7 screens: Home, Add Meal, Food History, Log Reaction, Poop Log, Profiles/Family, Settings
4. Full navigation system (drawer, FAB, routes)
5. Firebase configuration (littlebites-baby-tracker project)
6. Mock data service for UI testing
7. ~3,000 lines of code

**Key Learnings:**

**Parallel Development with Subagents:**
- Spawned 6 subagents simultaneously to build all screens
- Each subagent handled 1 screen independently
- Main agent built navigation and integrated everything
- Result: 2 hours → complete MVP (vs 6+ hours sequentially)
- GLM-4.7 unlimited tokens made this cost-free
- **Pattern:** Use parallel subagents for independent tasks that don't conflict

**Flutter/Web Development:**
- Chrome browser for testing: `flutter run -d chrome`
- Runs on localhost with dynamic ports (e.g., :53876, :54394)
- Firebase initialization works on web platform
- Web is great for rapid UI testing before mobile

**Firebase CLI Configuration:**
- Firebase project was already created in a previous session
- Use `firebase projects:list` to find existing projects
- Use `flutterfire configure --project=<id> --platforms=web` to generate firebase_options.dart
- FlutterFire CLI generates platform-specific configuration
- Auto-registers Firebase apps if they don't exist
- **Lesson:** Check for existing Firebase projects before creating new ones

**Code Organization:**
- `/lib/models/` - Data models with fromFirestore/toMap methods
- `/lib/screens/` - One file per screen, keep them focused
- `/lib/services/` - Mock data services, Firebase services (future)
- `/lib/routes/` - AppRoutes class with route constants and navigation helpers
- Main.dart imports all screens for route generation
- **Pattern:** Keep files focused under 300 lines where possible

**Design System:**
- Color palette: Primary Blue #4A90E2, Soft Teal #50E3C2, Warning Orange #F5A623, Danger Red #E74C3C
- Rounded corners: 16px for cards, 12px for inputs
- Font: Poppins (clean, modern, baby-friendly)
- Material 3 design
- Dark mode ready (follows system settings)

**Firebase Configuration File:**
- Generated by FlutterFire CLI: `firebase_options.dart`
- Contains API keys, app IDs, project IDs
- Platform-specific options (web, ios, android, macos, windows)
- Use `DefaultFirebaseOptions.currentPlatform` in main.dart
- Wrap initialization in try/catch to handle missing config gracefully

**Firebase Integration Progress (2026-02-06):**

**Completed Features:**
- ✅ Firestore database created (littlebites-baby-tracker)
- ✅ Firestore security rules and indexes configured
- ✅ Firestore offline persistence enabled
- ✅ Service provider architecture implemented
- ✅ Auth state management with Firebase
- ✅ Create profile screen and auth flow working
- ✅ Real-time sync with Firestore streams

**Screens Refactored to Firebase (5/7):**
1. ✅ HomeScreen - Real-time sync
2. ✅ AddMealScreen - Firebase integrated (commit: `8b63617`)
3. ✅ FoodHistoryScreen - Real-time Firebase streams (commit: `62d2848`)
4. ✅ LogReactionScreen - Firebase integrated (commit: `8eb1e5a`)
5. ✅ PoopLogScreen - Firebase integration complete (commit: `60a8c8d`)
6. ✅ ProfilesScreen - Firebase integration complete (commit: `db12981`)
7. ⏳ SettingsScreen - Pending

**Next Steps for LittleBites:**
1. Refactor SettingsScreen to Firebase (final screen)
2. Run full app integration test
3. Test end-to-end auth flow
4. Add photo upload to Firebase Storage
5. Test on real devices (iOS, Android)
6. Prepare for App Store launch

**Key Firebase Integration Patterns:**
- Service provider architecture: `lib/services/providers/service_providers.dart`
- AsyncDataBuilder widget for handling loading/error states
- Stream-based real-time updates for Firestore data
- Offline-first with automatic sync when connection restored
- Stream-based profile updates for active profile

