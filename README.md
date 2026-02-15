# Life System Starter Kit

A personal life operating system powered by Claude Code. Inspired by Carmack's .plan files and Franklin's systematic self-improvement.

## What This Is

A plain-text system for life planning, daily journaling, decision-making, and task capture — with Claude Code as your thinking partner. No apps, no subscriptions. Just markdown files, a terminal, and an AI that pushes back.

## What You Get

- **Life plan** — 10-year vision, life chapters, what you're optimizing for
- **Annual goals** — Yearly bets, anti-goals, who you're becoming
- **Daily journal** — Franklin's morning question + Carmack-style timestamped log + evening reflection
- **Decision records** — Structured docs for important decisions so you can trace your reasoning later
- **Inbox** — Quick capture for tasks, ideas, and things to process later
- **Values & habits** — Your principles and daily routines, written down so Claude can hold you to them

## Setup

### 1. Install Claude Code

```bash
npm install -g @anthropic-ai/claude-code
```

### 2. Copy the CLAUDE.md

Copy `CLAUDE.md` from this directory to `~/.claude/CLAUDE.md`. This is the global instructions file that tells Claude how to work with you.

```bash
cp CLAUDE.md ~/.claude/CLAUDE.md
```

Then **edit it** — replace the placeholders with your own name, projects, paths, and preferences. The whole point is that it's yours.

### 3. Install the morning skill

The `/morning` skill is what powers the daily routine. Copy it into your Claude Code skills directory:

```bash
mkdir -p ~/.claude/skills
cp -r skills/morning ~/.claude/skills/morning
```

Then **edit the skill files** — replace `YOURNAME` with your name in both `SKILL.md` and `reference.md`.

### 4. Install the journal script

The `jrn` command creates today's journal from the template, backfills any missing days (carrying forward uncompleted todos and active decisions), pulls in calendar events, and opens the file in your editor.

```bash
mkdir -p ~/.scripts
cp scripts/journal.sh ~/.scripts/journal.sh
chmod +x ~/.scripts/journal.sh
```

Edit `~/.scripts/journal.sh` — update `JOURNAL_DIR`, `TEMPLATE`, and `EDITOR_CMD` at the top to match your paths and preferred editor.

Then add the alias to your shell config (`~/.zshrc` or `~/.bashrc`):

```bash
echo "alias jrn='~/.scripts/journal.sh'" >> ~/.zshrc
source ~/.zshrc
```

Now just type `jrn` to open today's journal.

### 5. Set up your life directory

Copy the starter files to wherever you want your life system to live. The default assumes `~/Documents/[yourname]/`:

```bash
# Copy starter files
cp -r plan.md journal/ reference/ decisions/ templates/ inbox.md ~/Documents/yourname/
```

Update the paths in your `CLAUDE.md` to match wherever you put these.

### 6. Initialize git (optional but recommended)

```bash
cd ~/Documents/yourname
git init
git add -A
git commit -m "Initial life system setup"
```

This gives you version history on your life plan, goals, and decisions.

### 7. Start using it

```bash
cd ~/Documents/yourname
claude
```

Say "morning" or "let's plan the day" and Claude will walk you through the morning routine — reviewing yesterday, setting today's priorities, and checking that your daily actions connect to your annual goals and life plan.

## How It Works Day-to-Day

### Morning
Open Claude Code in your life directory. Say "morning" or "let's plan today." Claude will:
- Review yesterday's journal
- Create today's journal from the template
- Ask you Franklin's question: "What good shall I do this day?"
- Challenge your priorities against your annual goals

### During the Day
- **Auto-logging**: Claude adds timestamped entries to your journal as you work together
- **Inbox capture**: Quick tasks and ideas go to `inbox.md` for processing later
- **Decision records**: When facing a significant decision, Claude helps you think through it and creates a decision doc in `decisions/`

### Evening
- Franklin's question: "What good have I done today?"
- Brief reflection on what happened vs. what was planned

## The Key Insight

The system works because Claude reads your plan, goals, and values before every session. It holds you accountable to what you said matters. When your daily actions drift from your annual goals, it names it. When your goals drift from your life plan, it names that too.

The files are the source of truth. Claude is the accountability partner who never forgets what you wrote.

## Customizing

Everything is a starting point. Delete what doesn't resonate, add what does:

- Don't care about Franklin's questions? Remove them from the template.
- Want weekly reviews? Add a `week-WW.md` template.
- Have a different morning routine? Update `reference/habits.md`.
- The CLAUDE.md philosophy section is where you define the relationship. Make it yours.

## Optional: QMD for Search

If you accumulate lots of journal entries and decision docs, install [QMD](https://github.com/jclosure/qmd) to get keyword and semantic search across all your markdown files. Add the QMD MCP server to Claude Code and it can search your entire life system.
