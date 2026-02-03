#!/bin/bash
# Day Starter Cron Wrapper
# Handles environment setup and logging for cron execution

# Set up environment (cron doesn't have full env)
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin"
export HOME="/Users/bclawd"
export USER="bclawd"

# Log file for debugging
LOG_FILE="/Users/bclawd/.openclaw/workspace/day-starter/cron.log"
PID_FILE="/Users/bclawd/.openclaw/workspace/day-starter/daystarter.pid"
TIMEOUT_SECS=300  # 5 minutes

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Timeout function using background job (macOS compatible)
run_with_timeout() {
    local cmd="$1"
    local timeout="$2"
    
    # Run command in background
    eval "$cmd" &
    local cmd_pid=$!
    
    # Set up timeout killer
    (
        sleep "$timeout"
        if kill -0 $cmd_pid 2>/dev/null; then
            log "TIMEOUT: Killing process after ${timeout}s"
            kill -9 $cmd_pid 2>/dev/null
        fi
    ) &
    local killer_pid=$!
    
    # Wait for command to finish
    wait $cmd_pid 2>/dev/null
    local exit_code=$?
    
    # Cancel the killer if command finished
    kill $killer_pid 2>/dev/null
    wait $killer_pid 2>/dev/null
    
    return $exit_code
}

# Log start
log "=== Day Starter Cron Job Started ==="
log "PID: $$"
log "PATH: $PATH"
log "HOME: $HOME"
log "PWD: $(pwd)"

# Check if already running (prevent overlapping executions)
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    if ps -p "$OLD_PID" > /dev/null 2>&1; then
        log "ERROR: Day starter already running (PID: $OLD_PID)"
        exit 1
    fi
fi

# Write current PID
echo $$ > "$PID_FILE"

# Change to workspace directory
cd /Users/bclawd/.openclaw/workspace || {
    log "ERROR: Failed to change to workspace directory"
    exit 1
}

# Run daystarter with timeout and capture output
log "Executing daystarter..."

# Run with macOS-compatible timeout
OUTPUT_FILE=$(mktemp)
run_with_timeout "/Users/bclawd/.openclaw/workspace/day-starter/daystarter --non-interactive > '$OUTPUT_FILE' 2>&1" $TIMEOUT_SECS
EXIT_CODE=$?

# Log output
while IFS= read -r line; do
    log "OUTPUT: $line"
done < "$OUTPUT_FILE"
rm -f "$OUTPUT_FILE"

# Handle exit codes
case $EXIT_CODE in
    0)
        log "SUCCESS: Day starter completed normally"
        ;;
    137|9)
        log "ERROR: Day starter was killed (SIGKILL) - likely timeout or resource limit"
        ;;
    *)
        log "ERROR: Day starter exited with code $EXIT_CODE"
        ;;
esac

# Clean up PID file
rm -f "$PID_FILE"

log "=== Day Starter Cron Job Finished (Exit: $EXIT_CODE) ==="
log ""

exit $EXIT_CODE
