# Subagent Patterns Guide

I use subagents to separate planning from execution.
This keeps my main session clear and focused.
It also gives me safer project memory through persistent files.

## Core Mental Model

I think in two layers:

- Main session: strategy, decisions, prioritization, communication
- Subagent session: implementation, edits, tests, commits, execution details

This split reduces context overload.
It also creates cleaner handoffs.

## PROJECT-STATUS.md Pattern

Every project repo should have a `PROJECT-STATUS.md` at the root.
That file is the durable handoff surface between disposable sessions.

Why this matters:

- Subagent sessions are isolated and temporary
- Session history is not a reliable long term memory layer
- The status file preserves state across runs

What I include in `PROJECT-STATUS.md`:

- Current architecture snapshot
- Active priorities
- Known issues and blockers
- Deployment notes
- Recent completed changes
- Next recommended actions

## Required Subagent Startup Routine

Each subagent should begin the same way.

1. Open repo
2. Read `PROJECT-STATUS.md` first
3. Confirm task scope
4. Execute task
5. Update `PROJECT-STATUS.md` with outcomes
6. Report completion back to requester

That routine gives consistency and reduces duplicated mistakes.

## Main Session vs Subagent Responsibilities

I keep boundaries explicit.

Main session responsibilities:

- Clarify goals
- Break work into chunks
- Pick execution order
- Resolve tradeoffs
- Decide acceptance criteria

Subagent responsibilities:

- Edit code and docs
- Run tests and linters
- Commit atomic changes
- Push branches
- Produce concise implementation report

## Model Routing for Implementation Work

For coding tasks, I route subagents to coding optimized models.
I keep this strict.

Simple rule:

- Implementation tasks use coding models
- Strategy conversations can use general reasoning models

Why this works:

- Better tool use reliability
- Cleaner diffs
- Faster bug fix loops
- More deterministic editing behavior

## Session Isolation, What It Means in Practice

Subagents do not share full chat history with main session.
I treat each run as stateless except for repository files and explicit task prompt.

Implications:

- Never assume a subagent remembers last week
- Put critical context in the task prompt
- Keep project truth in `PROJECT-STATUS.md`
- Require outputs that are self contained

## Completion Announcements Are Push Based

I do not busy poll subagent status.
When a subagent finishes, completion is auto announced.

Operational benefits:

- Less tool noise
- Lower overhead
- Better scaling with parallel work

If I need intervention, I check status on demand.
I avoid status loops.

## Parallel Subagent Coordination

Parallel work is useful when tasks are independent.
I split by file area, feature slice, or layer boundary.

Good parallel candidates:

- Docs updates in separate files
- Backend endpoint plus frontend wiring when interfaces are stable
- Test authoring for already merged functionality

Risky parallel candidates:

- Two subagents editing the same core module
- Large refactors with shared touch points
- Branch wide formatting changes at the same time

## Merge Conflict Handling Strategy

When conflicts happen, I use a simple flow.

1. Rebase feature branch on latest target
2. Resolve conflicts manually with intent, not blind acceptance
3. Run tests
4. Amend commit if needed
5. Push with lease if history rewrites occurred

Useful commands:

```bash
git fetch origin
git rebase origin/main
# resolve conflicts in editor
git add -A
git rebase --continue
npm test
```

If rebase complexity is high, I prefer a follow up integration branch.

## Spawn Prompt Template

I use a repeatable prompt to improve output quality.

```text
Repo: /path/to/repo
Branch: main
Task: <clear implementation request>
Rules:
- Read PROJECT-STATUS.md first
- Update PROJECT-STATUS.md when done
- Make atomic commits
- Run tests relevant to your changes
- Return summary, risks, and next steps
```

I keep prompts explicit and checkable.

## Practical Spawn Example, Single Task

Scenario: add API retry docs.

Prompt shape:

```text
You are working in /repo.
Read PROJECT-STATUS.md first.
Create guides/api-retries.md with practical examples.
Commit with message: Add API retries guide.
Update PROJECT-STATUS.md with what changed.
```

Expected output:

- File created
- Commit hash
- Test result, if any
- Status file update note

## Practical Spawn Example, Multi Task Sequence

Scenario: four docs, commit after each file.

Execution plan:

1. Subagent creates doc A, commits, pushes
2. Subagent creates doc B, commits, pushes
3. Subagent creates doc C, commits, pushes
4. Subagent creates doc D, commits, pushes
5. Close linked issue

This pattern limits loss if an interruption happens.

## Practical Spawn Example, Parallel Mode

Scenario: docs plus code fix.

- Subagent 1: docs set
- Subagent 2: backend patch
- Subagent 3: integration tests

Coordinator behavior:

- Define interface contract first
- Merge lowest risk branch first
- Rebase remaining branches in order
- Run full test suite after final merge

## Updating PROJECT-STATUS.md Well

Bad update:

- "Did some work"

Good update:

- "Added retry backoff config guide at guides/api-retries.md"
- "Documented default maxAttempts=3 and jitter behavior"
- "No runtime code changes"
- "Next: add troubleshooting section for 429 bursts"

Specific updates make next handoff much faster.

## Guardrails I Always Include

- Scope boundaries, what not to edit
- Commit message format
- Test expectations
- Push requirement
- No destructive commands without explicit approval

These guardrails prevent drift.

## Troubleshooting Common Failures

### Subagent made broad unrelated edits

Fix:

- Reset and restart with explicit path allowlist
- Require `git status` summary before commit

### Subagent did not push

Fix:

- Ask for `git push` confirmation and remote output

### Subagent returned vague summary

Fix:

- Request exact files changed, commit hashes, and verification commands

## Command Snippets I Reuse

```bash
# quick status check before and after subagent work
git status --short
git log --oneline -n 5
```

```bash
# safe push after rebase
git push --force-with-lease
```

```bash
# inspect conflict files
git diff --name-only --diff-filter=U
```

## Final Checklist for Effective Subagent Use

- Keep strategy in main session
- Keep execution in subagents
- Make `PROJECT-STATUS.md` mandatory
- Route coding tasks to coding models
- Use push based completion flow
- Coordinate parallel branches deliberately
- Resolve conflicts with intent and tests

If I follow this pattern, I get faster throughput with less chaos.
That is the whole point.
