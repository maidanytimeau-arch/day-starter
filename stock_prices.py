#!/usr/bin/env python3
"""
Stock Price Fetcher - Get daily stock prices for major tech/TMT companies
Uses yfinance library (free, no API key required)
"""

import subprocess
import sys
from pathlib import Path

def install_yfinance():
    """Install yfinance if not present"""
    try:
        import yfinance
        return True
    except ImportError:
        print("Installing yfinance...")
        subprocess.run(
            [sys.executable, "-m", "pip", "install", "yfinance", "--quiet"],
            check=True
        )
        import yfinance
        return True

def get_stock_prices():
    """Fetch stock prices for major tech/TMT companies"""
    try:
        import yfinance as yf
    except ImportError:
        install_yfinance()
        import yfinance as yf

    # Major tech/TMT stocks to track
    stocks = [
        ("AAPL", "Apple"),
        ("GOOGL", "Google/Alphabet"),
        ("MSFT", "Microsoft"),
        ("AMZN", "Amazon"),
        ("META", "Meta"),
        ("TSLA", "Tesla"),
        ("NVDA", "Nvidia"),
        ("VZ", "Verizon"),
        ("T", "AT&T"),
        ("VOD", "Vodafone"),
        ("INTC", "Intel"),
    ]

    print("\n💹 Stock Prices (US Close)")
    print("-" * 50)

    for symbol, name in stocks:
        try:
            ticker = yf.Ticker(symbol)
            hist = ticker.history(period="2d")

            if len(hist) >= 2:
                yesterday_close = hist.iloc[-2]['Close']
                today_close = hist.iloc[-1]['Close']
                change = today_close - yesterday_close
                change_pct = (change / yesterday_close) * 100

                # Format with arrow
                arrow = "📈" if change > 0 else "📉"
                change_sign = "+" if change > 0 else ""

                print(f"{arrow} {symbol:6} | {name:15} | ${today_close:8.2f} | {change_sign}{change:+6.2f} ({change_sign}{change_pct:+5.2f}%)")
        except Exception as e:
            print(f"✗ {symbol:6} | {name:15} | Error fetching data")

    print("-" * 50)

if __name__ == "__main__":
    get_stock_prices()
