#!/usr/bin/env python3
"""
Morning equity briefing for ASX coverage stocks
Fetches stock prices and recent news, sends summary to Discord
"""

import yfinance as yf
import json
from datetime import datetime

# Load tickers
with open('tickers.json', 'r') as f:
    config = json.load(f)

coverage = config['coverage']

print(f"📊 Equity Briefing - {datetime.now().strftime('%Y-%m-%d %H:%M')}")
print(f"📈 Fetching data for {len(coverage)} stocks\n")

briefing_lines = []
briefing_lines.append(f"# 📊 ASX Equity Briefing")
briefing_lines.append(f"**{datetime.now().strftime('%A, %d %B %Y')} @ {datetime.now().strftime('%H:%M')} AEDT**")
briefing_lines.append("---")
briefing_lines.append("")

# Fetch stock prices
briefing_lines.append("## 📈 Price Movements")
briefing_lines.append("")

for stock in coverage:
    ticker_symbol = f"{stock['ticker']}.AX"  # Add .AX for ASX
    try:
        ticker = yf.Ticker(ticker_symbol)
        hist = ticker.history(period="2d")

        if len(hist) >= 2:
            latest = hist.iloc[-1]
            previous = hist.iloc[-2]

            # Convert to float
            price = float(latest['Close'])
            prev_price = float(previous['Close'])

            change = price - prev_price
            change_pct = (change / prev_price) * 100

            price = round(price, 2)
            change = round(change, 2)
            change_pct = round(change_pct, 2)

            # Format movement emoji
            if change > 0:
                emoji = "🟢"
            elif change < 0:
                emoji = "🔴"
            else:
                emoji = "⚪"

            # Format change
            change_str = f"+{change:.2f}" if change > 0 else f"{change:.2f}"
            change_pct_str = f"+{change_pct:.2f}%" if change_pct > 0 else f"{change_pct:.2f}%"

            briefing_lines.append(f"{emoji} **{stock['ticker']}** {stock['company']}")
            briefing_lines.append(f"   ${price:7.2f} | {change_str:>8s} ({change_pct_str:>7s})")
            briefing_lines.append("")
        else:
            briefing_lines.append(f"⚪ **{stock['ticker']}** {stock['company']} | No data")
            briefing_lines.append("")
    except Exception as e:
        briefing_lines.append(f"⚠️ **{stock['ticker']}** {stock['company']} | Error: {str(e)[:60]}")
        briefing_lines.append("")

briefing_lines.append("---")
briefing_lines.append("")

# Search for news
briefing_lines.append("## 📰 Recent News")
briefing_lines.append("")
briefing_lines.append("*News fetching via web search - manual review required*")
briefing_lines.append("")

briefing_lines.append("---")
briefing_lines.append("")
briefing_lines.append(f"**Coverage:** {len(coverage)} stocks tracked")
briefing_lines.append("")

# Output briefing
briefing = "\n".join(briefing_lines)
print(briefing)

# Save to file
with open('/tmp/equity-briefing.md', 'w') as f:
    f.write(briefing)

print(f"\n✅ Saved to /tmp/equity-briefing.md")
