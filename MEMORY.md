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
- `DS-V3` → `chutesai/deepseek-ai/DeepSeek-V3`
- `DS-R1` → `chutesai/deepseek-ai/DeepSeek-R1-TEE`
- `Kimi-K2` → `chutesai/moonshotai/Kimi-K2-Instruct-0905`
- `Kimi-K2.5` → `chutesai/moonshotai/Kimi-K2.5-TEE` (current default)
- `Qwen3` → `chutesai/Qwen/Qwen3-235B-A22B-Instruct-2507-TEE`

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
- `src/index.js` - Discord bot
- `parser-claw.js` - Log parser
- `.env` - Configuration (bot token, webhook secret)

**PM2 services:**
- `claw-activity-stream` - Discord bot (port 3000)
- `claw-activity-parser` - Log parser (watches gateway.err.log)

**Webhook endpoint:** `http://localhost:3000/webhook/activity`

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

*Last updated: 2026-02-04*
