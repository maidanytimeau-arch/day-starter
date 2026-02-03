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
    """Get weather from multiple sources with robust fallbacks"""
    errors = []

    # Try 1: Full format with wttr.in (primary)
    try:
        result = subprocess.run(
            ["curl", "-s", "--max-time", "5", "wttr.in/Sydney?format=%l:+%c+%t+%w"],
            capture_output=True,
            text=True,
            timeout=6
        )
        if result.returncode == 0 and result.stdout:
            weather = result.stdout.strip()
            if weather and "Unknown" not in weather and len(weather) > 3:
                return weather
        else:
            errors.append("wttr.in: no data returned")
    except Exception as e:
        errors.append(f"wttr.in (full): {str(e)[:50]}")

    # Try 2: Simple format with wttr.in (fallback 1)
    try:
        result = subprocess.run(
            ["curl", "-s", "--max-time", "4", "wttr.in/Sydney?format=%C+%t"],
            capture_output=True,
            text=True,
            timeout=5
        )
        if result.returncode == 0 and result.stdout:
            weather = result.stdout.strip()
            if weather and "Unknown" not in weather and len(weather) > 3:
                return f"Sydney: {weather}"
        else:
            errors.append("wttr.in (simple): no data returned")
    except Exception as e:
        errors.append(f"wttr.in (simple): {str(e)[:50]}")

    # Try 3: Open-Meteo as backup (fallback 2)
    try:
        # Sydney coordinates
        result = subprocess.run(
            ["curl", "-s", "--max-time", "4",
             "https://api.open-meteo.com/v1/forecast?latitude=-33.87&longitude=151.21&current_weather=true"],
            capture_output=True,
            text=True,
            timeout=5
        )
        if result.returncode == 0 and result.stdout:
            import json
            data = json.loads(result.stdout)
            if "current_weather" in data:
                cw = data["current_weather"]
                temp = cw.get("temperature", "?")
                wind = cw.get("windspeed", "?")
                # Map weather codes to simple conditions
                code = cw.get("weathercode", 0)
                condition = "☀️"
                if code >= 1 and code <= 3:
                    condition = "🌤️"
                elif code >= 45:
                    condition = "🌫️"
                elif code >= 51:
                    condition = "🌧️"
                elif code >= 71:
                    condition = "❄️"
                return f"Sydney: {condition} {temp}°C ↓{wind}km/h"
        else:
            errors.append("open-meteo: no data returned")
    except Exception as e:
        errors.append(f"open-meteo: {str(e)[:50]}")

    # All sources failed - return helpful error
    error_summary = " | ".join(errors[:2])
    return f"Weather unavailable ({error_summary})"

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
            timeout=8
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
    except subprocess.TimeoutExpired:
        return None  # Timeout is handled gracefully
    except Exception as e:
        # Silent failure - return None and let caller handle display
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
    max_articles = getattr(config, 'MAX_ARTICLES', 5)
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
    """Get overnight finance/tech/telco news via RSS - fast and reliable with fallbacks"""

    # RSS feeds for US/UK finance and tech news (overnight for Sydney)
    rss_feeds = [
        ("Reuters", "https://www.reutersagency.com/feed/?taxonomy=markets&post_type=reuters-best"),
        ("Bloomberg", "https://feeds.bloomberg.com/markets/news.rss"),
        ("CNBC", "https://www.cnbc.com/id/10000664/device/rss/rss.html"),  # Markets
        ("TechCrunch", "https://techcrunch.com/feed/"),
        ("Ars Technica", "https://feeds.arstechnica.com/arstechnica/technology"),
        ("The Verge", "https://www.theverge.com/rss/index.xml"),
    ]

    keywords = [
        "stock", "market", "earnings", "trade", "nasdaq", "dow", "s&p",
        "investment", "ipo", "merger", "acquisition", "revenue", "profit",
        "apple", "google", "microsoft", "amazon", "meta", "tesla", "nvidia",
        "ai", "artificial intelligence", "tech", "startup", "funding",
        "fed", "federal reserve", "interest rate", "inflation", "economy"
    ]

    news_items = []
    seen_titles = set()
    feed_errors = []

    for source, url in rss_feeds:
        if len(news_items) >= 8:
            break

        try:
            # Quick fetch with short timeout
            result = subprocess.run(
                ["curl", "-s", "-L", "--max-time", "4", "-A", "DayStarter/1.0", url],
                capture_output=True,
                text=True,
                timeout=5
            )

            if result.returncode != 0:
                feed_errors.append(f"{source}: fetch failed")
                continue

            if not result.stdout or len(result.stdout) < 100:
                feed_errors.append(f"{source}: empty response")
                continue

            # Parse RSS XML
            import xml.etree.ElementTree as ET
            root = ET.fromstring(result.stdout)

            # Handle RSS 2.0 and Atom formats
            items = root.findall('.//item') or root.findall('.//{http://www.w3.org/2005/Atom}entry')

            if not items:
                feed_errors.append(f"{source}: no items")
                continue

            for item in items[:5]:  # Check first 5 items from each feed
                if len(news_items) >= 8:
                    break

                # Get title
                title_elem = item.find('title')
                if title_elem is None:
                    title_elem = item.find('.//{http://www.w3.org/2005/Atom}title')
                if title_elem is None or title_elem.text is None:
                    continue

                title = title_elem.text.strip()

                # Skip duplicates
                title_lower = title.lower()
                if any(title_lower in seen or seen in title_lower for seen in seen_titles):
                    continue

                # Check for relevant keywords
                title_words = title_lower.split()
                if any(kw in title_lower or any(kw in word for word in title_words) for kw in keywords):
                    # Clean up title
                    title = title.replace('<![CDATA[', '').replace(']]>', '').strip()
                    # Decode HTML entities
                    import html
                    title = html.unescape(title)
                    if title and len(title) > 15:  # Skip very short titles
                        news_items.append((source, title))
                        seen_titles.add(title_lower)

        except Exception as e:
            feed_errors.append(f"{source}: {str(e)[:30]}")
            continue

    # If we got nothing from RSS, try a quick web scrape of Hacker News
    if not news_items:
        try:
            result = subprocess.run(
                ["curl", "-s", "--max-time", "3", "https://hacker-news.firebaseio.com/v0/topstories.json"],
                capture_output=True,
                text=True,
                timeout=4
            )
            if result.returncode == 0 and result.stdout:
                import json
                story_ids = json.loads(result.stdout)[:5]
                for story_id in story_ids:
                    try:
                        story_result = subprocess.run(
                            ["curl", "-s", "--max-time", "2",
                             f"https://hacker-news.firebaseio.com/v0/item/{story_id}.json"],
                            capture_output=True,
                            text=True,
                            timeout=3
                        )
                        if story_result.returncode == 0 and story_result.stdout:
                            story = json.loads(story_result.stdout)
                            title = story.get('title', '')
                            if title and any(kw in title.lower() for kw in keywords):
                                news_items.append(("Hacker News", title))
                                if len(news_items) >= 5:
                                    break
                    except:
                        continue
        except:
            pass

    # Return news or helpful error message
    if news_items:
        return news_items
    elif feed_errors:
        error_summary = feed_errors[0] if feed_errors else "Unknown error"
        return [("Note", f"News unavailable ({error_summary})")]
    else:
        return [("Note", "News feeds temporarily unavailable")]

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
            timeout=8
        )
        if result.returncode == 0 and result.stdout:
            reminders = json.loads(result.stdout)
            if reminders:
                return reminders
    except subprocess.TimeoutExpired:
        return None  # Timeout is handled gracefully
    except json.JSONDecodeError:
        return None  # Invalid JSON, handle gracefully
    except FileNotFoundError:
        return None  # remindctl not installed, that's OK
    except Exception:
        return None  # Any other error, fail silently
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

def get_stock_prices():
    """Get stock prices for major tech/TMT companies"""
    stock_script = Path.home() / ".openclaw" / "workspace" / "stock_prices.py"

    if not stock_script.exists():
        return None

    try:
        result = subprocess.run(
            ["python3", str(stock_script)],
            capture_output=True,
            text=True,
            timeout=30
        )

        if result.returncode == 0 and result.stdout:
            return result.stdout
    except Exception as e:
        pass

    return None

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
    import sys

    ensure_dirs()

    # Check for non-interactive mode
    non_interactive = "--non-interactive" in sys.argv

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

    # Stock Prices (skip - takes too long)
    #stocks = get_stock_prices()
    #if stocks:
    #    print(stocks)
    #else:
    #    print("\n💹 Stock Prices:\n  Unable to fetch")

    # Daily note
    note_path = get_daily_note()
    display_menu(note_path)

    # Interactive mode
    if not non_interactive:
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
    else:
        # Non-interactive mode - just exit after printing
        print("\n✓ Briefing complete")
        sys.exit(0)

if __name__ == "__main__":
    main()
