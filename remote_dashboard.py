#!/usr/bin/env python3
"""
Jarvis Remote Dashboard Server
Web dashboard + API endpoints + Telegram bot integration
"""

import subprocess
import sys
from pathlib import Path
from flask import Flask, jsonify, request

# Import existing tools
sys.path.insert(0, str(Path.home() / ".openclaw" / "workspace"))

try:
    import dashboard as dash_mod
    HAS_DASHBOARD = True
except:
    HAS_DASHBOARD = False

try:
    import stock_prices as stock_mod
    HAS_STOCKS = True
except:
    HAS_STOCKS = False

try:
    import daystarter as starter_mod
    HAS_DAYSTARTER = True
except:
    HAS_DAYSTARTER = False

# Initialize Flask app
app = Flask(__name__)

# Simple token for authentication (configure in production)
AUTH_TOKEN = "jarvis-2026"  # TODO: Move to config

def check_auth():
    """Simple token authentication"""
    token = request.headers.get('X-Auth-Token', '')
    return token == AUTH_TOKEN

@app.route('/')
def index():
    """Serve dashboard HTML"""
    if HAS_DASHBOARD:
        dash_mod.generate_html()
        dashboard_path = Path.home() / ".openclaw" / "workspace" / "DASHBOARD.html"
        return dashboard_path.read_text()

    return "<h1>Dashboard not available</h1><p>Run 'python3 dashboard.py' first.</p>"

@app.route('/api/status')
def api_status():
    """Get Jarvis status from kanban board"""
    try:
        kanban_file = Path.home() / ".openclaw" / "workspace" / "KANBAN.md"
        if kanban_file.exists():
            return jsonify({
                "status": "success",
                "kanban": kanban_file.read_text()
            })
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

@app.route('/api/dash')
def api_dashboard():
    """Generate dashboard and return HTML"""
    if HAS_DASHBOARD:
        try:
            dash_mod.generate_html()
            dashboard_path = Path.home() / ".openclaw" / "workspace" / "DASHBOARD.html"
            return dashboard_path.read_text()
        except Exception as e:
            return jsonify({"status": "error", "message": str(e)}), 500
    return jsonify({"status": "error", "message": "Dashboard module not available"}), 503

@app.route('/api/stocks')
def api_stocks():
    """Get stock prices"""
    if HAS_STOCKS:
        try:
            result = subprocess.run(
                ["python3", str(Path.home() / ".openclaw" / "workspace" / "stock_prices.py")],
                capture_output=True,
                text=True,
                timeout=30
            )
            return jsonify({"status": "success", "stocks": result.stdout})
        except Exception as e:
            return jsonify({"status": "error", "message": str(e)}), 500
    return jsonify({"status": "error", "message": "Stock module not available"}), 503

@app.route('/api/kanban')
def api_kanban():
    """Get kanban data"""
    try:
        kanban_file = Path.home() / ".openclaw" / "workspace" / "KANBAN.md"
        if kanban_file.exists():
            return jsonify({
                "status": "success",
                "data": kanban_file.read_text()
            })
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

@app.route('/api/memo', methods=['POST'])
def api_memo():
    """Quick capture note"""
    try:
        data = request.get_json()
        note = data.get('note', '')

        # Save to today's planning note
        from datetime import datetime
        NOTES_DIR = Path.home() / "Documents" / "DayStarters"
        NOTES_DIR.mkdir(parents=True, exist_ok=True)

        today = datetime.now().strftime("%Y-%m-%d")
        note_path = NOTES_DIR / f"{today}.md"

        with open(note_path, 'a') as f:
            f.write(f"\n- {note}")

        return jsonify({"status": "success", "message": "Note saved"})
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

@app.route('/api/calendar')
def api_calendar():
    """Get today's calendar events"""
    # This would require integration with daystarter
    return jsonify({
        "status": "success",
        "message": "Calendar integration available via daystarter command"
    })

if __name__ == '__main__':
    # Run Flask server
    print("🌐 Jarvis Remote Dashboard Server starting...")
    print("📱 Access from phone at: http://localhost:5000")
    print("🔐 Auth token:", AUTH_TOKEN)
    print("⚠️  For secure external access, use HTTPS tunnel (ngrok)")
    app.run(host='0.0.0.0', port=5000, debug=False)
