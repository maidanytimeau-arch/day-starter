#!/usr/bin/env python3
"""
Equity Research News Fetcher
Fetches and summarizes news for ASX coverage stocks
"""

import json
import sys
from datetime import datetime, timedelta

# Load tickers
def load_tickers():
    with open('/Users/bclawd/.openclaw/workspace/equity-research/tickers.json', 'r') as f:
        data = json.load(f)
    return data['coverage']

# Search news for a ticker
def search_news(ticker, company):
    """
    Search for recent news on a stock.
    Returns a list of news items with title, source, url, and snippet.
    """
    # This would call web_search in practice
    # For now, return placeholder
    return []

# Filter significant news
def is_significant(news_item):
    """
    Determine if news is significant enough to alert.
    Significant: earnings, M&A, guidance changes, management changes, regulatory issues
    """
    significant_keywords = [
        'earnings', 'profit', 'loss', 'revenue', 'result',
        'acquisition', 'merger', 'takeover', 'buyout',
        'guidance', 'outlook', 'forecast', 'upgrade', 'downgrade',
        'ceo', 'chief executive', 'director', 'management',
        'regulatory', 'asic', 'investigation', 'fine',
        'capital raising', 'placement', 'rights issue',
        'suspension', 'trading halt'
    ]

    text = news_item.get('title', '') + ' ' + news_item.get('snippet', '')
    text = text.lower()

    return any(keyword in text for keyword in significant_keywords)

# Format briefing
def format_briefing(all_news):
    """
    Format the morning briefing
    """
    briefing = []

    # Header
    briefing.append("# 📊 Equity Research Morning Briefing")
    briefing.append(f"**Date:** {datetime.now().strftime('%Y-%m-%d')} | **Time:** {datetime.now().strftime('%H:%M')} AEDT")
    briefing.append("")
    briefing.append("---")

    # Summary section
    briefing.append("## 📰 Key Developments")
    briefing.append("")

    if not all_news:
        briefing.append("*No significant news in the last 24 hours.*")
    else:
        for item in all_news:
            briefing.append(f"**{item['ticker']} - {item['company']}**")
            briefing.append(f"{item['title']}")
            briefing.append(f"> {item['snippet']}")
            briefing.append("")

    briefing.append("---")
    briefing.append("## 📋 Coverage List (17 ASX stocks)")
    briefing.append("")
    briefing.append("Tech & Telecom: ABB, MP1, NXT, SLC, TNE, TPG, TLS")
    briefing.append("Marketplaces: CAR, REA, SEK, XYZ")
    briefing.append("Education: IEL")
    briefing.append("Media: NWS")
    briefing.append("Logistics: WTC")
    briefing.append("Fintech: LIF, ZIP")

    return "\n".join(briefing)

# Format news alert
def format_alert(news_items):
    """
    Format a breaking news alert
    """
    if not news_items:
        return None

    alert = []
    alert.append("🚨 **BREAKING NEWS ALERT**")
    alert.append("")

    for item in news_items:
        alert.append(f"**{item['ticker']} - {item['company']}**")
        alert.append(f"{item['title']}")
        alert.append(f"> {item['snippet']}")
        alert.append("")

    return "\n".join(alert)

if __name__ == "__main__":
    tickers = load_tickers()
    print(f"Loaded {len(tickers)} tickers")
