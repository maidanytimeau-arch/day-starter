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

## Memory Maintenance (Periodic - Every Few Days)

As part of heartbeats, periodically review recent memory files and update long-term memory:

1. Read recent `memory/YYYY-MM-DD.md` files (last 2-7 days)
2. Identify significant events, lessons, or insights worth keeping
3. Update `MEMORY.md` with distilled learnings
4. Update `NOW.md` with current context and active tasks
5. Remove outdated info from MEMORY.md that's no longer relevant

Think of it like reviewing a journal and updating mental models. Daily files are raw notes; MEMORY.md is curated wisdom; NOW.md is "where am I right now?"

## Fix Applied
1. **Timeout issue:** `/usr/bin/timeout` doesn't exist on macOS. The wrapper script was updated to use a POSIX-compatible timeout mechanism.
2. **News fetching:** Replaced slow NewsAPI with fast RSS feed parsing (Reuters, Bloomberg, CNBC, TechCrunch, Ars Technica, The Verge) + Hacker News fallback. No API keys needed, 4-second timeout per feed.
