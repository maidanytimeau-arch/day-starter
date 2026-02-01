#!/bin/bash
# Start Jarvis Remote Dashboard with Cloudflare tunnel

echo "🌐 Jarvis Remote Dashboard"
echo ""
echo "Starting Cloudflare tunnel and web server..."
echo ""

# Start cloudflare tunnel (background)
cloudflared tunnel --url http://localhost:5000 --loglevel info > /dev/null 2>&1 &
CLOUDFLARE_PID=$!

# Wait for tunnel to be ready
echo "Waiting for tunnel to start..."
sleep 5

# Get tunnel URL from cloudflared output
TUNNEL_URL=$(timeout 10 cloudflared tunnel --url http://localhost:5000 --loglevel info 2>&1 | grep -oE "https://.*trycloudflare.com" | head -1)

if [ -n "$TUNNEL_URL" ]; then
    echo ""
    echo "✅ Tunnel is ready!"
    echo ""
    echo "🌐 Your Remote Access URL:"
    echo ""
    echo "   $TUNNEL_URL"
    echo ""
    echo "Open this URL on your phone to access Jarvis Dashboard"
    echo ""
    echo "💡 Note: This URL may change if tunnel restarts"
else
    echo ""
    echo "❌ Tunnel URL not found"
    echo ""
    echo "Check cloudflared output above or visit: https://dash.cloudflare.com"
fi

# Start Flask web server (background)
python3 /Users/bclawd/.openclaw/workspace/remote_dashboard.py > /dev/null 2>&1 &
FLASK_PID=$!

echo ""
echo "✅ Web server running"
echo "✅ Cloudflare tunnel running"
echo ""
echo "📊 Services:"
echo "   - Web Dashboard: http://localhost:5000"
echo "   - Tunnel: $TUNNEL_URL"
echo "   - Flask PID: $FLASK_PID"
echo "   - Cloudflare PID: $CLOUDFLARE_PID"
echo ""
echo "To stop services:"
echo "   kill $FLASK_PID $CLOUDFLARE_PID"
