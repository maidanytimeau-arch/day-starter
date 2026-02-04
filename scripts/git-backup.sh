#!/bin/bash
# Auto-backup script for Git repository
# Commits and pushes changes to GitHub

set -e

WORKSPACE="/Users/bclawd/.openclaw/workspace"
LOG_FILE="$WORKSPACE/scripts/git-backup.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Function to log messages
log() {
    echo "[$TIMESTAMP] $1" | tee -a "$LOG_FILE"
}

log "=== Starting Git Backup ==="

# Change to workspace directory
cd "$WORKSPACE" || {
    log "ERROR: Failed to change to workspace directory"
    exit 1
}

# Check if there are changes
if git diff-index --quiet HEAD --; then
    log "No changes to commit"
    exit 0
fi

# Add all changes
log "Adding changes..."
git add -A 2>&1 | tee -a "$LOG_FILE" || {
    log "ERROR: git add failed"
    exit 1
}

# Commit with automatic message
log "Committing changes..."
COMMIT_MSG="Auto-backup $(date '+%Y-%m-%d %H:%M:%S') - $(git diff --cached --name-only | head -5 | tr '\n' ' ')"
git commit -m "$COMMIT_MSG" 2>&1 | tee -a "$LOG_FILE" || {
    log "ERROR: git commit failed"
    exit 1
}

# Push to GitHub
log "Pushing to GitHub..."
git push origin main 2>&1 | tee -a "$LOG_FILE" || {
    log "ERROR: git push failed"
    exit 1
}

log "=== Git Backup Completed Successfully ==="
