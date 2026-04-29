# 06 — Workflow Loop

The end-to-end path from a PRD to a merged PR. Plan-first always. Multiple gates. Self-authored handoffs.

## Overview

```
PRD (you)
  ↓
Decompose (decomposer subagent + you edit) → ordered list of tracer-bullet slices
  ↓
[ for each slice, possibly in parallel worktrees ]
  ↓
Spec (decomposer drafts; you edit constraints) — see 02-spec-format
  ↓
Worktree + branch (git worktree add)
  ↓
Plan (planner subagent) ←──── GATE 1: you approve plan
  ↓
Implement (implementer agent)
  ↓
Self-QA (lint + types + tests + browser sanity if UI) ←── GATE 2: must be green
  ↓
Anti-overeng review (reviewer subagent on diff) ←── GATE 3: zero flags
  ↓
PR description (agent writes; spec + plan + diff context)
  ↓
PR open
  ↓
You: read PR, click merge ←──── GATE 4: human approval
  ↓
Merge → main
  ↓
Worktree cleanup (skill: /cleanup-worktree)
```

## Phase-by-phase

### Phase 0 — PRD (you)

Output: `docs/prds/<feature>.md` using `templates/prd.template.md`.
Time: 5-30 min. Don't over-specify implementation; describe user value + constraints.

### Phase 1 — Decompose

Invoke: `/decompose docs/prds/<feature>.md`
Output: ordered list of slice specs in `docs/specs/<feature>/01-*.md`, `02-*.md`, ...

You edit:
- Drop unnecessary slices
- Reorder for risk/value
- Mark independent slices as parallelizable
- Tighten constraints per slice

### Phase 2 — Worktree + branch

Per slice:
```bash
git worktree add ../myproject.<slice-id> -b feat/<slice-id>
cd ../myproject.<slice-id>
```

Each agent session opens in its own worktree. No `cd`-ing between worktrees in one session — confuses git state and CLAUDE.md loading.

### Phase 3 — Plan

Invoke: `/plan` (skill) → planner subagent runs.

Plan output (markdown) covers:
- Files to add/modify (must match spec's "Files to touch")
- Approach in prose
- Canonical example being mimicked
- What the slice will NOT do (echoes spec's "Out of scope")
- Any new abstraction + justification (per Rule of Three)

**GATE 1: You read the plan, approve or push back.**

Common pushbacks:
- "You're adding a helper file with one caller. Inline it."
- "You're wrapping the API call in try/catch. Don't."
- "You're modifying file X which is out-of-scope per spec."

If pushback comes, agent revises plan. Loop until approved.

Why this gate matters: it's the cheapest place to kill overengineering. Catching it in the plan costs 30 seconds; catching it in the diff costs 10 minutes.

### Phase 4 — Implement

Invoke: `/implement` after plan is locked.

The agent codes against the plan. Mid-implementation, if it discovers the plan is wrong, it stops and asks rather than improvising.

Common pause points:
- Spec is ambiguous on a behavior
- Discovered an existing helper that contradicts the plan's approach
- Test failure reveals a wrong assumption

Default response: agent stops, summarizes the issue, asks. You decide.

### Phase 5 — Self-QA

The agent runs:
```bash
pnpm checks   # lint + types + tests, project-specific
```

For UI changes, additionally:
- Open in browser (Playwright skill)
- Take screenshot
- Verify happy path interactively

**GATE 2: Self-QA must be green before next phase.**

If broken, the agent fixes and re-runs. Doesn't proceed to review until green.

### Phase 6 — Anti-overengineering review

Invoke (or auto-invoked by skill): anti-overeng-reviewer subagent.

Subagent reads:
- The diff
- The spec (constraints + out-of-scope)
- CLAUDE.md (canonical constraints list)
- The plan (sanctioned exceptions)

Output: list of flags (line numbers + reason) or "no flags."

**GATE 3: Zero flags before PR.**

For each flag, the implementing agent fixes (usually deletes/inlines) and re-runs the reviewer. Loop until clean.

### Phase 7 — PR description

The agent writes the PR body using `templates/pr-body.template.md`:

```markdown
## What
1-2 sentences.

## Why
Reference the PRD/spec.

## Scope
Confirms what's in and what's out (mirrors spec).

## How tested
- Self-QA: pnpm checks ✅
- Browser test (if UI): screenshot inline
- Anti-overeng review: no flags

## Notes for reviewer
Anything unusual about the diff.
```

The act of writing this forces the agent to articulate intent. Misalignment surfaces here.

### Phase 8 — PR open

```bash
gh pr create --title "<conventional-commit-style>" --body "$(cat pr-body.md)"
```

### Phase 9 — Human review (you)

**GATE 4: human eyes on the diff.**

You scan:
- Spec adherence (does the diff match what was asked?)
- Constraint violations the reviewer subagent missed
- Vibes: does this read like the canonical pattern?

For 2-3 concurrent slices, this is your main bottleneck. Keep slices small to keep this fast.

### Phase 10 — Merge + cleanup

```bash
gh pr merge --squash
```

Then in the original repo (not the worktree):
```bash
git worktree remove ../myproject.<slice-id>
git branch -d feat/<slice-id>
```

Skill `/cleanup-worktree` automates this.

## Loop cadence (target)

For a single slice, end-to-end:

| Phase | Duration |
|---|---|
| Spec edit | 1-3 min |
| Plan + your approval | 3-10 min |
| Implement | 20-90 min (mostly agent time) |
| Self-QA | 1-5 min |
| Anti-overeng review + fix | 1-10 min |
| PR description + open | 1-3 min |
| Your review + merge | 5-15 min |
| **Total** | **30-150 min** |

If a slice exceeds this, root cause is usually:
- Slice too big (re-decompose)
- Spec too vague (tighten)
- Plan was wrong (gate 1 too lenient)

## When to break the loop

Skip phases for:

- **Trivial fixes**: typo, one-line bug, dependency bump → straight to code + gate 4
- **Hotfix under pressure**: skip plan, run QA + reviewer minimum
- **Spike / exploration**: throw away the slice, no review, but **don't merge spike code**

For everything else, full loop.

## Loop variants

### Background-agent loop

For very-low-risk slices (codemod, mechanical refactor), run the agent in the background and check in later. Same gates, but you batch the gate-4 reviews.

### Pair-with-agent loop

For high-risk or learning-mode slices (you want to understand what's happening), keep the agent in foreground, watch every step, intervene early. Same gates but you're a constant participant.

Default: **non-pair, gates intact**.

## Failure modes of the loop

| Failure | Symptom | Fix |
|---|---|---|
| Plan-gate too lenient | Overeng reaches diff | Tighten what the planner subagent must include |
| Self-QA insufficient | Bugs reach human review | Expand `pnpm checks`, add Playwright steps |
| Reviewer misses flags | You catch overeng at gate 4 | Add the missed pattern to reviewer's checklist |
| You skip gate 4 | Bad code lands in main | Don't. Always read the diff. |
| Loop too slow | Throughput drops | Slice smaller, parallelize, sharpen specs |
