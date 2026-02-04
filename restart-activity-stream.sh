#!/bin/bash
# Manual restart script for claw-activity-stream

echo "🔧 Killing old processes..."
pkill -f "node.*claw-activity" 2>/dev/null || true
pkill -f "node.*parser-enhanced" 2>/dev/null || true
pkill -f "node.*claw-activity-parser" 2>/dev/null || true

echo "⏳ Waiting 3 seconds..."
sleep 3

echo "🚀 Starting fresh instance..."
cd /Users/bclawd/.openclaw/workspace/claw-activity-stream
node src/index.js &
