#!/bin/bash

# Journal quick-open script
# Opens today's journal, creating from template if needed
# Backfills any missing days with calendar events and carried-over todos
#
# Setup:
#   1. Edit LIFE_DIR below to match your path (should match CLAUDE.md Settings)
#   2. chmod +x this file
#   3. Add to your shell: alias jrn='~/.scripts/journal.sh'
#   4. (Optional, macOS) Install icalBuddy for calendar integration: brew install ical-buddy

LIFE_DIR="$HOME/Documents/hahagood"
JOURNAL_DIR="$LIFE_DIR/journal"
TEMPLATE="$LIFE_DIR/templates/daily-journal.md"

# Editor command — change to your preference (e.g., "cursor", "vim", "open -a Obsidian")
EDITOR_CMD="code"

# Calendar names to include (only used if icalBuddy is installed)
CALENDAR_NAMES="Work,Personal,Family"

# --- Cross-platform date helpers ---

# Detect platform once
if [[ "$(uname)" == "Darwin" ]]; then
    IS_MACOS=true
else
    IS_MACOS=false
fi

# date_offset_days N  — prints date N days ago as YYYY-MM-DD
date_offset_days() {
    local DAYS="$1"
    if $IS_MACOS; then
        date -v-${DAYS}d +%Y-%m-%d
    else
        date -d "$TODAY - ${DAYS} days" +%Y-%m-%d
    fi
}

# date_part FORMAT DATE  — extract part of a date (e.g. %Y, %m)
date_part() {
    local FMT="$1"
    local D="$2"
    if $IS_MACOS; then
        date -j -f "%Y-%m-%d" "$D" +"$FMT"
    else
        date -d "$D" +"$FMT"
    fi
}

# days_between START END  — number of days from START to END
days_between() {
    local START_DATE="$1"
    local END_DATE="$2"
    if $IS_MACOS; then
        local START_SEC=$(date -j -f "%Y-%m-%d" "$START_DATE" "+%s")
        local END_SEC=$(date -j -f "%Y-%m-%d" "$END_DATE" "+%s")
    else
        local START_SEC=$(date -d "$START_DATE" "+%s")
        local END_SEC=$(date -d "$END_DATE" "+%s")
    fi
    echo $(( (END_SEC - START_SEC) / 86400 ))
}

# --- End date helpers ---

# Get today's date
TODAY=$(date +%Y-%m-%d)

# Find most recent journal entry (looking back up to 60 days)
find_most_recent_journal_date() {
    for i in $(seq 1 60); do
        PAST_DATE=$(date_offset_days "$i")
        PAST_YEAR=$(date_part "%Y" "$PAST_DATE")
        PAST_MONTH=$(date_part "%m" "$PAST_DATE")
        PAST_FILE="$JOURNAL_DIR/$PAST_YEAR/$PAST_MONTH/$PAST_DATE.md"
        if [ -f "$PAST_FILE" ]; then
            echo "$PAST_DATE"
            return
        fi
    done
}

# Get calendar events for a specific date (macOS only, requires icalBuddy)
get_calendar_events() {
    local TARGET_DATE="$1"
    if command -v icalBuddy &> /dev/null; then
        icalBuddy -nc -nrd -ic "$CALENDAR_NAMES" -eep "notes,location,url,attendees" -tf "%H:%M" -df "" eventsFrom:"$TARGET_DATE" to:"$TARGET_DATE" 2>/dev/null | python3 -c "
import sys
import re

lines = sys.stdin.read().strip().split('\n')
results = []
i = 0
while i < len(lines):
    line = lines[i].strip()
    if line.startswith('• '):
        title = line[2:]
        i += 1
        if i < len(lines):
            time_line = lines[i].strip()
            match = re.match(r'(\d{2}:\d{2}) - (\d{2}:\d{2})', time_line)
            if match:
                start, end = match.groups()
                sh, sm = map(int, start.split(':'))
                eh, em = map(int, end.split(':'))
                dur = (eh * 60 + em) - (sh * 60 + sm)
                if dur >= 60:
                    h, m = divmod(dur, 60)
                    dur_str = f'{h}h {m}m' if m else f'{h}h'
                else:
                    dur_str = f'{dur}m'
                results.append(f'- {start} - {title} ({dur_str})')
    i += 1
print('\n'.join(results))
" 2>/dev/null
    fi
}

# Get incomplete todos from a journal file
get_incomplete_todos() {
    local FILE="$1"
    if [ -f "$FILE" ]; then
        grep -E '^\s*- \[ \]' "$FILE" 2>/dev/null | head -n 20 || true
    fi
}

# Get active (unresolved) decisions from a journal file
get_active_decisions() {
    local FILE="$1"
    if [ -f "$FILE" ]; then
        sed -n '/^## Active Decisions/,/^## /p' "$FILE" 2>/dev/null | \
            grep -E '^\s*- \[ \]' 2>/dev/null || true
    fi
}

# Create a journal entry for a specific date
create_journal_entry() {
    local TARGET_DATE="$1"
    local PREV_FILE="$2"

    local TARGET_YEAR=$(echo "$TARGET_DATE" | cut -d'-' -f1)
    local TARGET_MONTH=$(echo "$TARGET_DATE" | cut -d'-' -f2)
    local TARGET_FILE="$JOURNAL_DIR/$TARGET_YEAR/$TARGET_MONTH/$TARGET_DATE.md"

    # Skip if already exists
    if [ -f "$TARGET_FILE" ]; then
        echo "$TARGET_FILE"
        return
    fi

    # Ensure directory exists
    mkdir -p "$(dirname "$TARGET_FILE")"

    # Get todos from previous file
    local PAST_TODOS=""
    if [ -n "$PREV_FILE" ]; then
        PAST_TODOS=$(get_incomplete_todos "$PREV_FILE")
    fi

    # Get active decisions from previous file
    local PAST_DECISIONS=""
    if [ -n "$PREV_FILE" ]; then
        PAST_DECISIONS=$(get_active_decisions "$PREV_FILE")
    fi

    # Get calendar events for this date
    local CALENDAR_EVENTS=$(get_calendar_events "$TARGET_DATE")

    # Read template and replace placeholders
    if [ -f "$TEMPLATE" ]; then
        local CONTENT=$(cat "$TEMPLATE")
        CONTENT="${CONTENT//\{\{DATE\}\}/$TARGET_DATE}"

        if [ -n "$PAST_TODOS" ]; then
            CONTENT="${CONTENT//\{\{PAST_TODOS\}\}/$PAST_TODOS}"
        else
            CONTENT="${CONTENT//\{\{PAST_TODOS\}\}/}"
        fi

        if [ -n "$CALENDAR_EVENTS" ]; then
            CONTENT="${CONTENT//\{\{CALENDAR\}\}/$CALENDAR_EVENTS}"
        else
            CONTENT="${CONTENT//\{\{CALENDAR\}\}/}"
        fi

        if [ -n "$PAST_DECISIONS" ]; then
            CONTENT="${CONTENT//\{\{PAST_DECISIONS\}\}/$PAST_DECISIONS}"
        else
            CONTENT="${CONTENT//\{\{PAST_DECISIONS\}\}/}"
        fi

        echo "$CONTENT" > "$TARGET_FILE"
    fi

    echo "$TARGET_FILE"
}

# Main logic
MOST_RECENT_DATE=$(find_most_recent_journal_date)

if [ -n "$MOST_RECENT_DATE" ]; then
    DAYS_MISSING=$(days_between "$MOST_RECENT_DATE" "$TODAY")

    if [ "$DAYS_MISSING" -gt 0 ]; then
        MOST_RECENT_YEAR=$(date_part "%Y" "$MOST_RECENT_DATE")
        MOST_RECENT_MONTH=$(date_part "%m" "$MOST_RECENT_DATE")
        PREV_FILE="$JOURNAL_DIR/$MOST_RECENT_YEAR/$MOST_RECENT_MONTH/$MOST_RECENT_DATE.md"

        # Create entries for each missing day (starting from day after most recent)
        for i in $(seq $((DAYS_MISSING - 1)) -1 0); do
            TARGET_DATE=$(date_offset_days "$i")
            PREV_FILE=$(create_journal_entry "$TARGET_DATE" "$PREV_FILE")
        done
    fi
else
    # No previous journal found, just create today
    create_journal_entry "$TODAY" ""
fi

# Build today's file path and open
TODAY_YEAR=$(date +%Y)
TODAY_MONTH=$(date +%m)
TODAY_FILE="$JOURNAL_DIR/$TODAY_YEAR/$TODAY_MONTH/$TODAY.md"

$EDITOR_CMD "$TODAY_FILE"
