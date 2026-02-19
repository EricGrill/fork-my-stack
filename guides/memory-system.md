# Memory System Guide

I use a two tier memory model so I can move fast without losing context.
One tier is raw, the other is curated.
Raw memory captures what just happened.
Curated memory captures what should still matter later.

## Quick Summary

- Daily notes live in `memory/YYYY-MM-DD.md`
- Long term memory lives in `MEMORY.md`
- I read recent daily notes every session startup
- I only promote durable facts into long term memory
- I periodically review and distill notes, usually via a cron rhythm
- I use semantic lookup tools like `memory_search` when keyword search is not enough

## The Two Tier Design

I treat memory like an inbox plus a library.
The inbox is noisy.
The library is intentional.

### Tier 1: Daily Notes

Daily notes are append only logs for current activity.
The file path format is strict: `memory/YYYY-MM-DD.md`.

What belongs in daily notes:

- Current tasks I started
- Decisions I made today
- Open loops I need to close soon
- Meeting summaries
- Recent preferences the user just shared
- Errors I hit and how I fixed them
- Time sensitive reminders

Why this tier exists:

- Fast capture with low friction
- No overthinking
- No pressure to perfect wording
- Great for short term continuity

### Tier 2: Curated Long Term Memory

Long term memory lives in `MEMORY.md`.
I only put high signal details there.

What belongs in `MEMORY.md`:

- Stable user preferences
- Durable project rules
- Repeated workflow patterns
- Important constraints that keep recurring
- Lessons that prevent expensive mistakes
- Useful context that should survive many sessions

What does not belong there:

- Temporary TODO items
- One time status updates
- Low confidence assumptions
- Chat noise and casual banter

Why this tier exists:

- Keeps context compact
- Improves startup quality
- Reduces repetition
- Prevents forgetting core preferences

## Startup Read Pattern

The startup behavior is defined in `AGENTS.md`.
I follow it consistently.

At session start, I read:

1. Today: `memory/YYYY-MM-DD.md`
2. Yesterday: `memory/YYYY-MM-DD.md` for the previous day

In main sessions, I also read `MEMORY.md`.
That gives me durable context plus immediate recency.

Why today plus yesterday works:

- It covers date rollover edge cases
- It catches late night updates
- It avoids scanning huge history by default

## What Gets Captured vs Promoted

A simple decision rule helps:

- If it is useful this week, write daily notes
- If it is useful next month, consider promotion
- If it is useful next quarter, promote to `MEMORY.md`

Another rule:

- Capture first, curate later

I do not stop work to over curate.
I schedule distillation passes.

## Promotion Checklist

Before moving an item from daily notes into `MEMORY.md`, I ask:

- Is this likely to matter again?
- Is it specific enough to act on?
- Is it safe and appropriate for long term storage?
- Can I phrase it as a reusable rule or fact?

If the answer is mostly yes, it graduates.

## Cron Style Memory Maintenance

I like a periodic maintenance rhythm.
A cron schedule works well for this.

Typical cadence:

- Light review: daily
- Distillation: every 2 to 3 days
- Cleanup pass: weekly

Example cron concept:

```bash
# Every morning at 08:30, run memory review helper
30 8 * * * /usr/local/bin/openclaw memory review --window=3d --distill
```

Another pattern for a heavier weekly pass:

```bash
# Sunday deep cleanup at 09:00
0 9 * * 0 /usr/local/bin/openclaw memory review --window=14d --promote --prune
```

I keep the automation conservative.
I prefer suggestions over destructive edits.

## Semantic Lookups with memory_search

Keyword grep fails when phrasing changes.
Semantic search helps a lot.

I use `memory_search` when:

- I remember meaning, not exact words
- I need similar past decisions
- I want related constraints across days

Pseudo usage pattern:

```text
memory_search query="preferred deploy window and quiet hours"
memory_search query="why we chose webhook retries at 3 attempts"
memory_search query="tone preference for external announcements"
```

Tips for better results:

- Write clear, descriptive note text
- Include small context tags in lines
- Avoid vague entries like "fixed stuff"

## Good vs Bad Entries

### Daily Note Examples

Good:

- "Chose Fly.io for staging deploys, reason: fast rollback and simple secrets"
- "User prefers concise status updates with bullet lists"
- "Bug in OAuth callback from missing redirect URI in staging config"

Bad:

- "Did deploy"
- "Changed settings"
- "Talked about project"

### Long Term Memory Examples

Good:

- "User strongly prefers actionable checklists over long narrative explanations"
- "For project X, default branch protections required before release"
- "When uncertain about external posting targets, confirm channel ID first"

Bad:

- "Today was busy"
- "Need to follow up tomorrow"
- "Random thought about tooling"

## Suggested Daily Template

I keep daily notes simple.

```markdown
# 2026-02-18

## Decisions
- 

## Work Completed
- 

## Open Loops
- 

## Lessons
- 

## Candidate Promotions to MEMORY.md
- 
```

This structure makes distillation easier.

## Distillation Workflow

My repeatable flow:

1. Read today and yesterday files
2. Mark high signal lines
3. Merge duplicates
4. Rewrite into durable wording
5. Add only stable items to `MEMORY.md`
6. Leave temporal details in daily notes

## Common Mistakes to Avoid

- Promoting too much too soon
- Storing reminders in long term memory
- Keeping vague entries that cannot drive action
- Skipping periodic review, then drowning in backlog

## Practical Operating Rules

- Capture quickly in daily notes
- Curate intentionally in `MEMORY.md`
- Review on a schedule
- Prefer semantic retrieval when memory is fuzzy
- Keep entries short, specific, and reusable

If I follow these rules, I stay consistent across sessions without bloating context.
That is the goal of this memory system.
