# Day Starter 🌅

Your daily command center — a quick dashboard to start your day organized and focused.

## What It Does

When you run `daystarter`, you get:
- **Weather** for your location (via wttr.in)
- **Calendar events** from Google Calendar
- **Today's reminders** from Apple Reminders
- **Overnight news** focused on finance, tech, and telco (US/UK markets)
- **Daily planning note** automatically created for today
- **Quick actions** to capture notes or open your plan

## Requirements

- macOS (uses Apple Calendar and Reminders integration)
- `remindctl` CLI (install via: `brew install remindctl`)
- `curl` (usually pre-installed)
- Python 3 (usually pre-installed)

## Setup

### 1. Install Reminders Tool

```bash
brew install remindctl
```

### 2. Calendar Setup (Optional)

**No setup required!** The tool uses your existing macOS Calendar app.

If you have Google Calendar synced to your Mac (via System Settings → Internet Accounts), your events will appear automatically in Day Starter.

To add Google Calendar:
1. Open System Settings → Internet Accounts
2. Click "+" → Google
3. Sign in with your Google account
4. Enable "Calendars"

### 3. Add to PATH

Add to your path in `~/.zshrc` or `~/.bash_profile`:

```bash
export PATH="$PATH:/Users/bclawd/.openclaw/workspace/day-starter"
```

Then reload your shell:
```bash
source ~/.zshrc
```

## Installation

1. Add to your PATH (add this to `~/.zshrc` or `~/.bash_profile`):

```bash
export PATH="$PATH:/Users/bclawd/.openclaw/workspace/day-starter"
```

2. Reload your shell:
```bash
source ~/.zshrc
```

## Usage

### Start Your Day
```bash
daystarter
```

### What You'll See
```
==================================================
🌅 Good morning, Bob!
📅 Saturday, February 1, 2026
==================================================

🌤️  San Francisco: ☀️ +15°C ↑10km/h

📅 Today's Calendar:
  🕐 09:00 - Team standup
  🕐 14:00 - Client presentation
  🕐 16:00 - 1:1 with manager

📋 Today's Reminders:
  ⬜ [Personal] Buy groceries
  ⬜ [Work] Review proposal
  ⬜ [Finance] Check portfolio

📰 Overnight Finance & Tech News (US/UK):
  • [Hacker News] Apple stock surges on earnings beat
  • [Hacker News] Verizon announces 5G network expansion
  • [Hacker News] Tech startup raises $50M in Series B
  • [Hacker News] FCC approves new broadband regulations

📝 Planning note: /Users/bclawd/Documents/DayStarters/2026-02-01.md

Actions:
  [o] Open today's note
  [n] Quick note (type then press Enter)
  [q] Quit
```

### Daily Notes

Your daily planning notes are stored in:
```
~/Documents/DayStarters/YYYY-MM-DD.md
```

Each note includes:
- Top 3 priorities
- Notes & thoughts section
- One thing to remember

### Quick Actions

- **[o]** Opens today's note in TextEdit
- **[n]** Quick capture — type a note and it appends to today's file
- **[q]** Quit and start your day

## Customization

### Edit `daystarter.py` to:

- **Change greeting**: Modify the "Good morning, Bob!" message
- **Modify note template**: Update the `template` string in `get_daily_note()`
- **Adjust news keywords**: Modify the `biz_keywords` list in `get_overnight_news()` to add/remove topics
- **Add more news sources**: Extend the news fetching to include additional RSS feeds or APIs
- **Change layout**: Reorder sections or add new data sources

### News Sources

Currently uses:
- **Hacker News API** - Free, no authentication required
- Filters for market, earnings, stocks, investment, funding, acquisitions, big tech, telecom, media, and financial events

**Note:** RSS feeds from major financial news sources (Reuters, Bloomberg, Yahoo Finance) are blocked by captchas. For comprehensive financial news including overnight stock moves and detailed TMT sector coverage, consider:

1. **NewsAPI.org** - Free tier available, requires API key
2. **Alpha Vantage** - Free tier for financial data
3. **Yahoo Finance API** - Requires API key
4. **Financial Modeling Prep** - Free tier available

To add a news API:
1. Sign up and get an API key
2. Add the key to `daystarter.py` (store in config file for security)
3. Modify `get_overnight_news()` to query the API
4. Parse results and add to `news_items` list

## Why I Built This

Starting your day with intention matters. Instead of opening 5 different apps (weather, calendar, reminders, news, notes), you get a unified view. The daily note template guides you to set priorities, and quick capture means you never lose a fleeting thought.

Built to be fast, simple, and frictionless. 🚀
