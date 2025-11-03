#!/bin/bash
# =====================================================
# Automated Backup System
# Author: Yaswanth
# Date: 2025-11-03
# Description:
#   Creates automated backups with verification, cleanup,
#   configuration, logging, and dry-run support.
# =====================================================

# --- Configuration ---
CONFIG_FILE="./backup.config"
LOG_FILE="./backup.log"
LOCK_FILE="/tmp/backup.lock"

# --- Load Config ---
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "❌ Error: Config file not found at $CONFIG_FILE"
    exit 1
fi

# --- Logging Function ---
log() {
    local LEVEL="$1"
    local MESSAGE="$2"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $LEVEL: $MESSAGE" | tee -a "$LOG_FILE"
}

# --- Error Exit ---
error_exit() {
    log "ERROR" "$1"
    release_lock
    exit 1
}

# --- Lock Mechanism ---
acquire_lock() {
    if [ -f "$LOCK_FILE" ]; then
        error_exit "Another backup process is already running."
    fi
    touch "$LOCK_FILE"
}

release_lock() {
    rm -f "$LOCK_FILE"
}

# --- Check Disk Space ---
check_disk_space() {
    local REQ_SPACE_MB=100
    local AVAILABLE=$(df "$BACKUP_DESTINATION" | awk 'NR==2 {print $4}')
    if [ "$AVAILABLE" -lt $((REQ_SPACE_MB * 1024)) ]; then
        error_exit "Not enough disk space in $BACKUP_DESTINATION"
    fi
}

# --- Verify Backup ---
verify_backup() {
    local BACKUP_PATH="$1"
    local CHECKSUM_FILE="$BACKUP_PATH.sha256"

    log "INFO" "Verifying checksum..."
    sha256sum -c "$CHECKSUM_FILE" >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        error_exit "Checksum verification failed for $BACKUP_PATH"
    fi

    log "INFO" "Testing archive integrity..."
    tar -tzf "$BACKUP_PATH" >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        error_exit "Backup archive is corrupted!"
    fi

    log "SUCCESS" "Backup verification passed for $BACKUP_PATH"
}

# --- Delete Old Backups ---
delete_old_backups() {
    log "INFO" "Cleaning up old backups..."

    cd "$BACKUP_DESTINATION" || return

    # Sort backups by modification time (newest first)
    BACKUPS=( $(ls -t backup-*.tar.gz 2>/dev/null) )

    # Keep daily, weekly, monthly backups
    if [ "${#BACKUPS[@]}" -gt 0 ]; then
        for i in "${!BACKUPS[@]}"; do
            FILE=${BACKUPS[$i]}
            if [ "$i" -ge "$DAILY_KEEP" ] && [ "$i" -lt "$(($DAILY_KEEP + $WEEKLY_KEEP))" ]; then
                continue
            elif [ "$i" -ge "$(($DAILY_KEEP + $WEEKLY_KEEP))" ] && [ "$i" -lt "$(($DAILY_KEEP + $WEEKLY_KEEP + $MONTHLY_KEEP))" ]; then
                continue
            else
                if [ "$DRY_RUN" = true ]; then
                    log "DRYRUN" "Would delete old backup: $FILE"
                else
                    log "INFO" "Deleting old backup: $FILE"
                    rm -f "$FILE" "$FILE.sha256"
                fi
            fi
        done
    else
        log "INFO" "No old backups to delete."
    fi
}

# --- Create Backup ---
create_backup() {
    local SOURCE_DIR="$1"

    if [ ! -d "$SOURCE_DIR" ]; then
        error_exit "Source folder not found: $SOURCE_DIR"
    fi

    mkdir -p "$BACKUP_DESTINATION"
    check_disk_space

    local TIMESTAMP=$(date +%Y-%m-%d-%H%M)
    local BACKUP_NAME="backup-$TIMESTAMP.tar.gz"
    local BACKUP_PATH="$BACKUP_DESTINATION/$BACKUP_NAME"

    # Build exclude patterns
    IFS=',' read -r -a EXCLUDES <<< "$EXCLUDE_PATTERNS"
    EXCLUDE_ARGS=()
    for pattern in "${EXCLUDES[@]}"; do
        EXCLUDE_ARGS+=(--exclude="$pattern")
    done

    if [ "$DRY_RUN" = true ]; then
        log "DRYRUN" "Would create backup: $BACKUP_PATH"
        return
    fi

    log "INFO" "Starting backup of $SOURCE_DIR to $BACKUP_PATH"
    tar -czf "$BACKUP_PATH" "${EXCLUDE_ARGS[@]}" "$SOURCE_DIR"
    if [ $? -ne 0 ]; then
        error_exit "Backup creation failed"
    fi

    log "INFO" "Generating checksum..."
    sha256sum "$BACKUP_PATH" > "$BACKUP_PATH.sha256"

    verify_backup "$BACKUP_PATH"

    log "SUCCESS" "Backup created successfully: $BACKUP_PATH"

    delete_old_backups
}

# --- Restore Backup ---
restore_backup() {
    local BACKUP_FILE="$1"
    local RESTORE_DIR="$2"

    if [ ! -f "$BACKUP_DESTINATION/$BACKUP_FILE" ]; then
        error_exit "Backup file not found: $BACKUP_FILE"
    fi

    mkdir -p "$RESTORE_DIR"

    log "INFO" "Restoring $BACKUP_FILE to $RESTORE_DIR"

    if [ "$DRY_RUN" = true ]; then
        log "DRYRUN" "Would restore backup: $BACKUP_FILE"
        return
    fi

    tar -xzf "$BACKUP_DESTINATION/$BACKUP_FILE" -C "$RESTORE_DIR"
    if [ $? -ne 0 ]; then
        error_exit "Restore failed"
    fi

    log "SUCCESS" "Restored $BACKUP_FILE to $RESTORE_DIR"
}

# --- List Backups ---
list_backups() {
    log "INFO" "Listing available backups:"
    ls -lh "$BACKUP_DESTINATION"/backup-*.tar.gz 2>/dev/null || log "INFO" "No backups found."
}

# --- MAIN LOGIC ---
DRY_RUN=false

if [[ "$1" == "--dry-run" ]]; then
    DRY_RUN=true
    shift
fi

acquire_lock

case "$1" in
    --list)
        list_backups
        ;;
    --restore)
        restore_backup "$2" "$4"
        ;;
    *)
        SOURCE_DIR="$1"
        if [ -z "$SOURCE_DIR" ]; then
            error_exit "Usage: ./backup.sh [--dry-run] <source_folder> | --list | --restore <backup.tar.gz> --to <path>"
        fi
        create_backup "$SOURCE_DIR"
        ;;
esac

release_lock
exit 0
