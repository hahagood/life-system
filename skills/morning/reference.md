# Morning Skill Reference

## File Locations

```
$LIFE_DIR/plan.md                        # 10-year life vision
$LIFE_DIR/journal/YYYY/goals.md          # Annual goals
$LIFE_DIR/journal/YYYY/MM/YYYY-MM-DD.md  # Daily entries
$LIFE_DIR/journal/YYYY/MM/week-WW.md     # Weekly reviews (optional)
$LIFE_DIR/reference/values.md            # Core principles
$LIFE_DIR/inbox.md                       # Quick capture
$LIFE_DIR/decisions/                     # Decision records
$LIFE_DIR/templates/                     # Templates
```

## Task Management (Plain Text)

All tasks are managed in plain text:

- **Personal backlog / quick capture:** `$LIFE_DIR/inbox.md`
- **Project tasks:** `plan.md` in each project's repo root
- **Daily to-dos:** In the morning section of the daily journal

## Optional: Calendar Integration (macOS)

If you use Apple Calendar, install `icalBuddy` to pull today's events into the morning routine:

```bash
brew install ical-buddy
```

Then add this to Step 3 of the morning skill to auto-populate the log with today's events:
```bash
icalBuddy -nc -nrd -eep "notes,location,url,attendees" -tf "%H:%M" -df "" eventsToday
```

You can filter to specific calendars with `-ic "Work,Personal"`.
