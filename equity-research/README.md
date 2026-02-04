# Equity Research Automation

Automated news monitoring and morning briefings for your ASX coverage universe.

## Coverage Stocks (17)

**Tech & Telecom:**
- ABB - Aussie Broadband
- MP1 - Megaport Ltd
- NXT - NEXTDC Ltd
- SLC - Superloop Ltd
- TNE - Technology One
- TPG - TPG Telecom Ltd
- TLS - Telstra Group Ltd

**Marketplaces:**
- CAR - CAR Group Ltd
- REA - REA Group Ltd
- SEK - SEEK Ltd
- XYZ - Block Inc

**Education:**
- IEL - IDP Education Ltd

**Media:**
- NWS - News Corp

**Logistics:**
- WTC - WiseTech Global

**Fintech:**
- LIF - Life360 Inc
- ZIP - Zip Co Ltd

## Scheduled Jobs

### 1. Morning Briefing 📊
- **Time:** 8:00 AM AEDT (Sydney time)
- **Days:** Monday - Friday
- **What it does:**
  - Fetches recent news on all 17 coverage stocks
  - Checks price movements
  - Summarizes key developments
  - Sends formatted briefing to Discord

### 2. News Alerts 📰
- **Time:** Every 30 minutes during ASX trading hours (10:00 AM - 4:00 PM AEDT)
- **Days:** Monday - Friday
- **What it does:**
  - Monitors for breaking news on coverage stocks
  - Only alerts on significant news (earnings, M&A, guidance changes, management changes, regulatory issues)
  - Sends alerts to Discord if found

## How It Works

When a cron job triggers:
1. Sends a systemEvent to the main OpenClaw session
2. Session fetches news using web search
3. Filters for relevance and significance
4. Formats output
5. Sends to Discord via the message tool

## Files

- `tickers.json` - Coverage list
- `news_fetcher.py` - News fetching and formatting logic
- `README.md` - This file

## Managing the Jobs

To list all cron jobs:
```
openclaw cron list
```

To disable a job:
```
openclaw cron update <jobId> '{"enabled": false}'
```

To remove a job:
```
openclaw cron remove <jobId>'
```

## Customization

**Add new stocks:**
Edit `tickers.json` and add entries:
```json
{"ticker": "XXX", "company": "Company Name", "exchange": "ASX"}
```

**Change briefing time:**
Use `openclaw cron update` to modify the schedule expression.

**Adjust alert frequency:**
Modify the cron expression for the "Equity News Alerts" job.

---

*Last updated: 2026-02-04*
