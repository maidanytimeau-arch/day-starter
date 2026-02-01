#!/usr/bin/env python3
"""
Day Starter CLI - Your daily command center
Shows weather, calendar, reminders, and overnight news
"""

import json
import os
import subprocess
import sys
from datetime import datetime
from pathlib import Path

# Import config
try:
    import config
except ImportError:
    # Create minimal config if not exists
    class Config:
        NEWS_API_KEY = ""
        NEWS_CATEGORIES = ["business", "technology"]
        ARTICLES_PER_CATEGORY = 10
        MAX_ARTICLES = 10
        FINANCE_KEYWORDS = [
            "stock", "market", "earnings", "share", "price", "nasdaq", "dow",
            "trading", "investment", "investor", "fund", "ipo",
            "apple", "google", "microsoft", "amazon", "meta", "tesla", "nvidia",
            "telecom", "telco", "5g", "verizon", "at&t", "vodafone",
            "disney", "netflix", "acquisition", "merger", "revenue", "profit"
        ]
    config = Config()

# Config paths
CONFIG_DIR = Path.home() / ".config" / "daystarter"
NOTES_DIR = Path.home() / "Documents" / "DayStarters"

def ensure_dirs():
    """Create necessary directories"""
    CONFIG_DIR.mkdir(parents=True, exist_ok=True)
    NOTES_DIR.mkdir(parents=True, exist_ok=True)

def get_weather():
    """Get weather from wttr.in (no API key needed)"""
    try:
        # Use curl for compatibility - specify Sydney
        result = subprocess.run(
            ["curl", "-s", "wttr.in/Sydney?format=%l:+%c+%t+%w"],
            capture_output=True,
            text=True,
            timeout=5
        )
        if result.returncode == 0 and result.stdout:
            return result.stdout.strip()
    except:
        pass
    return "Weather unavailable"

def get_calendar_events():
    """Get today's calendar events from macOS Calendar (works with Google Calendar)"""
    try:
        # Use AppleScript to query all calendars
        script = """
        tell application "Calendar"
            set todayDate to current date
            set time of todayDate to 0
            set tomorrowDate to todayDate + (1 * days)

            set eventList to ""

            repeat with cal in every calendar
                try
                    set calEvents to every event of cal whose start date ≥ todayDate and start date < tomorrowDate
                    repeat with currentEvent in calEvents
                        set eventTitle to summary of currentEvent
                        set eventStart to start date of currentEvent
                        set eventTime to time string of eventStart
                        set eventList to eventList & eventTime & "\t" & eventTitle & "\n"
                    end repeat
                end try
            end repeat

            return eventList
        end tell
        """

        result = subprocess.run(
            ["osascript", "-e", script],
            capture_output=True,
            text=True,
            timeout=10
        )

        if result.returncode == 0 and result.stdout.strip():
            events = []
            for line in result.stdout.strip().split('\n'):
                if '\t' in line:
                    parts = line.split('\t')
                    if len(parts) >= 2:
                        time = parts[0]
                        event = parts[1]
                        events.append((time, event))
            return events
    except Exception as e:
        pass
    return None

def format_calendar(events):
    """Format calendar events for display"""
    lines = ["\n📅 Today's Calendar:"]
    if not events:
        lines.append("  No events today")
    else:
        for time, event in events:
            lines.append(f"  🕐 {time} - {event}")
    return "\n".join(lines)

def get_newsapi_news():
    """Fetch news from NewsAPI.org"""
    news_items = []

    if not hasattr(config, 'NEWS_API_KEY') or not config.NEWS_API_KEY:
        return None

    categories = getattr(config, 'NEWS_CATEGORIES', ['business', 'technology'])
    max_articles = getattr(config, 'MAX_ARTICLES', 10)
    keywords = getattr(config, 'FINANCE_KEYWORDS', [])

    for category in categories:
        try:
            url = f"https://newsapi.org/v2/top-headlines?category={category}&language=en&apiKey={config.NEWS_API_KEY}"
            result = subprocess.run(
                ["curl", "-s", "--max-time", "10", url],
                capture_output=True,
                text=True,
                timeout=15
            )

            if result.returncode == 0 and result.stdout:
                data = json.loads(result.stdout)

                if data.get("status") == "ok" and "articles" in data:
                    for article in data["articles"]:
                        title = article.get("title", "")
                        source = article.get("source", {}).get("name", "News")
                        description = article.get("description", "")

                        # Combine title and description for better filtering
                        full_text = f"{title} {description}".lower()

                        # Filter for finance/tech/telco content
                        if title and any(kw.lower() in full_text for kw in keywords):
                            news_items.append((source, title))
                            if len(news_items) >= max_articles:
                                break
                if len(news_items) >= max_articles:
                    break
        except Exception as e:
            continue

    return news_items if news_items else None

def get_overnight_news():
    """Get overnight finance/tech/telco news from various sources"""

    # Primary: Try NewsAPI first (more comprehensive financial news)
    newsapi_news = get_newsapi_news()
    if newsapi_news:
        return newsapi_news

    # Fallback: Get business/finance stories from Hacker News
    news_items = []

    try:
        result = subprocess.run(
            ["curl", "-s", "--max-time", "5", "https://hacker-news.firebaseio.com/v0/topstories.json"],
            capture_output=True,
            text=True,
            timeout=10
        )

        if result.returncode == 0 and result.stdout:
            story_ids = json.loads(result.stdout)[:50]
            for story_id in story_ids:
                story_result = subprocess.run(
                    ["curl", "-s", "--max-time", "3", f"https://hacker-news.firebaseio.com/v0/item/{story_id}.json"],
                    capture_output=True,
                    text=True,
                    timeout=5
                )
                if story_result.returncode == 0 and story_result.stdout:
                    story = json.loads(story_result.stdout)
                    title = story.get("title", "")

                    # Filter for finance/business-related tech content
                    biz_keywords = [
                        # Market/Trading
                        "earnings", "stock", "share", "price", "market", "nasdaq", "dow", "ipo", "trading",
                        # Investment
                        "investment", "investor", "funding", "venture", "startup", "acquisition", "merger",
                        "buyback", "dividend", "portfolio", "fund",
                        # Company financials
                        "revenue", "profit", "loss", "quarterly", "annual", "report",
                        # Big tech
                        "apple", "google", "microsoft", "amazon", "meta", "tesla", "nvidia", "intel", "amd",
                        # Telecom
                        "telecom", "telco", "5g", "verizon", "at&t", "vodafone", "bt",
                        # Media
                        "disney", "netflix", "warner", "paramount", "comcast",
                        # Financial events
                        "wall street", "premarket", "after hours", "sec filing"
                    ]
                    if title and any(kw.lower() in title.lower() for kw in biz_keywords):
                        news_items.append(("Market News", title))
                        if len(news_items) >= 8:
                            break
    except Exception as e:
        pass

    # Fallback: Get general tech news if not enough financial news
    if len(news_items) < 4:
        try:
            result = subprocess.run(
                ["curl", "-s", "--max-time", "5", "https://hacker-news.firebaseio.com/v0/topstories.json"],
                capture_output=True,
                text=True,
                timeout=10
            )

            if result.returncode == 0 and result.stdout:
                story_ids = json.loads(result.stdout)[:30]
                for story_id in story_ids:
                    story_result = subprocess.run(
                        ["curl", "-s", "--max-time", "3", f"https://hacker-news.firebaseio.com/v0/item/{story_id}.json"],
                        capture_output=True,
                        text=True,
                        timeout=5
                    )
                    if story_result.returncode == 0 and story_result.stdout:
                        story = json.loads(story_result.stdout)
                        title = story.get("title", "")
                        # Avoid duplicates
                        if title and not any(title == item[1] for item in news_items):
                            news_items.append(("Hacker News", title))
                            if len(news_items) >= 8:
                                break
        except Exception as e:
            pass

    # Return news if we have any
    if news_items:
        return news_items[:10]

    # Fallback if no news found
    return [("Note", "No news available - check your internet connection")]

def format_news(news_items):
    """Format news items for display"""
    lines = ["\n📰 Overnight Finance & Tech News (US/UK):"]
    if not news_items:
        lines.append("  Unable to fetch news")
    else:
        for source, title in news_items:
            lines.append(f"  • [{source}] {title}")
    return "\n".join(lines)

def get_reminders():
    """Get today's reminders from Apple Reminders"""
    try:
        result = subprocess.run(
            ["remindctl", "list", "--today", "--json"],
            capture_output=True,
            text=True,
            timeout=5
        )
        if result.returncode == 0 and result.stdout:
            reminders = json.loads(result.stdout)
            if reminders:
                return reminders
    except:
        pass
    return None

def format_reminders(reminders):
    """Format reminders for display"""
    lines = ["\n📋 Today's Reminders:"]
    for r in reminders:
        status = "✅" if r.get("completed") else "⬜"
        list_name = r.get("list", "Inbox")
        name = r.get("name", "Untitled")
        due = r.get("due", "")
        lines.append(f"  {status} [{list_name}] {name}" + (f" (due: {due})" if due else ""))
    return "\n".join(lines)

def get_daily_note():
    """Get or create today's planning note"""
    today = datetime.now().strftime("%Y-%m-%d")
    note_path = NOTES_DIR / f"{today}.md"

    if not note_path.exists():
        template = f"""# Day Plan - {today}

## 🎯 Top 3 Priorities
1.
2.
3.

## 📝 Notes & Thoughts

## 💡 One Thing to Remember
"""
        note_path.write_text(template)

    return note_path

def display_menu(note_path):
    """Show action menu"""
    print(f"\n📝 Planning note: {note_path}")
    print("\nActions:")
    print("  [o] Open today's note")
    print("  [n] Quick note (type then press Enter)")
    print("  [q] Quit")

def get_sydney_time():
    """Get current time in Sydney"""
    try:
        # Using date command to get Sydney time
        result = subprocess.run(
            ["TZ='Australia/Sydney'", "date", "+%Y-%m-%d %H:%M"],
            capture_output=True,
            text=True,
            shell=True,
            timeout=5
        )
        if result.returncode == 0 and result.stdout:
            dt_str = result.stdout.strip()
            dt = datetime.strptime(dt_str, "%Y-%m-%d %H:%M")
            return dt.strftime("%A, %B %d, %Y")
    except:
        pass
    return datetime.now().strftime("%A, %B %d, %Y")

def main():
    ensure_dirs()

    # Header
    print("=" * 50)
    today = get_sydney_time()
    print(f"🌅 Good morning, Bob!")
    print(f"📅 {today}")
    print("=" * 50)

    # Weather
    weather = get_weather()
    print(f"\n🌤️  {weather}")

    # Calendar
    events = get_calendar_events()
    if events:
        print(format_calendar(events))
    else:
        print("\n📅 Today's Calendar:\n  No events today")

    # Reminders
    reminders = get_reminders()
    if reminders:
        print(format_reminders(reminders))
    else:
        print("\n📋 No reminders for today")

    # News
    news = get_overnight_news()
    if news:
        print(format_news(news))
    else:
        print("\n📰 Overnight News:\n  Unable to fetch news")

    # Daily note
    note_path = get_daily_note()
    display_menu(note_path)

    # Interactive mode
    try:
        while True:
            choice = input("\n> ").strip().lower()

            if choice == "q":
                print("Have a great day! 🚀")
                break
            elif choice == "o":
                subprocess.run(["open", "-a", "TextEdit", str(note_path)])
                break
            elif choice == "n":
                note = input("Quick note: ").strip()
                if note:
                    with open(note_path, "a") as f:
                        f.write(f"\n- {note}")
                    print("✓ Note saved")
                    display_menu(note_path)
                else:
                    display_menu(note_path)
            else:
                print("Unknown option")
                display_menu(note_path)
    except KeyboardInterrupt:
        print("\n\nHave a great day! 🚀")

if __name__ == "__main__":
    main()
