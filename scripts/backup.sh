#!/bin/bash
# Simple nightly local-to-local rsync backup.
# Add to crontab to run nightly:  0 2 * * * /path/to/backup.sh
# DO NOT also redirect cron output to LOG — the script writes to LOG itself.

LOG="${BACKUP_LOG:-$HOME/backup.log}"
DEST="${BACKUP_DEST:-$HOME/Backups}"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

log() { echo "[$TIMESTAMP] $1" >> "$LOG"; }

mkdir -p "$DEST"
log "Backup started"

# Edit this list to whatever you want backed up.
# Each path is rsync'd into $DEST/ preserving its basename.
SOURCES=(
  "$HOME/Documents"
  "$HOME/Projects"
)

FAILED=0
for src in "${SOURCES[@]}"; do
  if [ -d "$src" ]; then
    log "Syncing $(basename "$src")..."
    rsync -a --delete \
      --exclude="*.pyc" \
      --exclude="__pycache__" \
      --exclude=".git" \
      --exclude="venv" \
      --exclude="node_modules" \
      "$src" "$DEST/" 2>>"$LOG" || { log "WARNING: rsync failed for $src"; FAILED=1; }
  fi
done

USED=$(du -sh "$DEST" 2>/dev/null | cut -f1)
log "Backup folder size: $USED"

[ $FAILED -eq 1 ] && log "COMPLETED WITH WARNINGS" || log "BACKUP COMPLETE"
