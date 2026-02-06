# HEARTBEAT.md
# Daily morning briefing

## Status
✅ **ENABLED** - Fixed on 2026-02-04

## Schedule
- **Time:** 7:30 AM daily (Sydney/Australia)
- **Cron Job:** `Daily Daystarter at 7:30am`

## Manual Usage
To run the daystarter manually:
```bash
/Users/bclawd/.openclaw/workspace/day-starter/daystarter --non-interactive
```

## Memory Maintenance (Every 2-3 Days)

As part of heartbeats, periodically review recent memory files and update long-term memory.

**Frequency: Every 2-3 days** (or weekly during quiet periods)

**Trigger checks:**
- ✅ 2-3 daily files accumulated
- ✅ Last review was ≥2 days ago
- ✅ Major project/decision completed
- ✅ Something feels like it belongs in long-term memory

**Process:**
1. Read last 2-7 `memory/YYYY-MM-DD.md` files
2. Extract patterns, lessons, configurations, preferences
3. Update `MEMORY.md` with distilled learnings
4. Update `NOW.md` with current context and active tasks
5. Remove outdated info from MEMORY.md that's no longer relevant

Think of it like reviewing a journal and updating mental models. Daily files are raw notes; MEMORY.md is curated wisdom; NOW.md is "where am I right now?"

## Fix Applied
1. **Timeout issue:** `/usr/bin/timeout` doesn't exist on macOS. The wrapper script was updated to use a POSIX-compatible timeout mechanism.
2. **News fetching:** Replaced slow NewsAPI with fast RSS feed parsing (Reuters, Bloomberg, CNBC, TechCrunch, Ars Technica, The Verge) + Hacker News fallback. No API keys needed, 4-second timeout per feed.

## LittleBites Dev Agent - Heartbeat Integration

During heartbeat checks, the LittleBites dev agent (`agent:main:subagent:bd91...`) should report its status:

**What to report:**
1. **Current work** - What feature/feature are you actively working on?
2. **Last completion** - What did you complete in the last heartbeat check?
3. **Next steps** - What are you working on next?
4. **Blockers** - Anything preventing progress? (Firebase console access, missing API keys, etc.)

**How to report:**
Send a message to your main session (Jarvis) with a concise status update:
- If making progress: "Working on [feature] — [next steps]"
- If blocked: "BLOCKED: [issue] — waiting for [what you need]"
- If no significant updates: "No blockers, continuing [feature]"

**Purpose:** This creates visibility into autonomous development without disrupting main session flow. Helps detect if agent gets stuck for extended periods.

**Example:**
```
"Working on Firebase Authentication — wiring up Login/Signup screens, next: Real-Time Sync"
```
