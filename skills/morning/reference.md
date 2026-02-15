# Morning Skill Reference

## File Locations

```
~/Documents/YOURNAME/plan.md                        # 10-year life vision
~/Documents/YOURNAME/journal/YYYY/goals.md          # Annual goals
~/Documents/YOURNAME/journal/YYYY/MM/YYYY-MM-DD.md  # Daily entries
~/Documents/YOURNAME/journal/YYYY/MM/week-WW.md     # Weekly reviews (optional)
~/Documents/YOURNAME/reference/values.md            # Core principles
~/Documents/YOURNAME/inbox.md                       # Quick capture
~/Documents/YOURNAME/decisions/                     # Decision records
~/Documents/YOURNAME/templates/                     # Templates
```

## Task Management (Plain Text)

All tasks are managed in plain text:

- **Personal backlog / quick capture:** `~/Documents/YOURNAME/inbox.md`
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
