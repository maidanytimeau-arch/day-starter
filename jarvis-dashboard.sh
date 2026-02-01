#!/bin/bash
# Start Jarvis Remote Dashboard with Cloudflare tunnel
# Uses proper tunnel configuration for better reliability

# Kill any existing cloudflared
pkill -f cloudflared

# Start tunnel with simple configuration
# Using http for better compatibility
cloudflared tunnel --url http://localhost:5000 --loglevel info

echo ""
echo "🌐 Jarvis Remote Dashboard"
echo ""
echo "Starting Cloudflare tunnel..."
echo ""
echo "Follow these steps:"
echo "1. Check terminal output above for tunnel URL"
echo "2. Or visit: https://dash.cloudflare.com"
echo "3. Use the tunnel URL on your phone"
echo ""
