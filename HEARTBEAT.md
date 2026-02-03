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

## Fix Applied
1. **Timeout issue:** `/usr/bin/timeout` doesn't exist on macOS. The wrapper script was updated to use a POSIX-compatible timeout mechanism.
2. **News fetching:** Replaced slow NewsAPI with fast RSS feed parsing (Reuters, Bloomberg, CNBC, TechCrunch, Ars Technica, The Verge) + Hacker News fallback. No API keys needed, 4-second timeout per feed.
