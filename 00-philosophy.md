# 00 — Philosophy

## What 2-3x looks like

**Not** "I type faster." 2-3x means:

- **Throughput**: 2-3 slices in flight concurrently (worktrees), each in a fresh agent session
- **Architect-mode default**: you spend most of your time writing specs, reviewing plans, reviewing diffs — almost no typing of impl code
- **Quality at speed**: rework rate stays flat as throughput rises, because constraints live upstream of the code

If your rework rate climbs as you parallelize, you don't have 2-3x — you have 1x with extra steps.

## The four laws

### 1. Constraints upstream beat reviews downstream

Every minute spent tightening the spec saves ten minutes of review-and-redo.
Premature abstraction and defensive code are *invited* by vague specs. Don't review them out — *spec them out*.

### 2. Mimicry beats instruction

Models follow examples in the repo more reliably than rules in CLAUDE.md.
Three concrete patterns set the precedent. Any new feature mimics them, not the model's training-data Java enterprise instincts.

### 3. Smaller slices, less surface

A 3-hour tracer bullet has ~10% the abstraction-temptation of a 1-day feature.
Decompose aggressively. The unit is "smallest end-to-end slice that adds value or de-risks."

### 4. Process not model

Don't fix overengineering by switching Opus → Sonnet. Fix it by:

- tighter specs (constraints + out-of-scope)
- golden examples in the repo
- plan-gate before code
- anti-overengineering review subagent before PR

Same model, better process, better output.

## What you're optimizing for

> A solo engineer who can keep 2-3 agents productively building, reviewing, and merging — without the rework rate exceeding human capacity.

Anti-goals:

- Maximum autonomy ("agents merge themselves")
- Maximum parallelism (10+ concurrent agents)
- Zero supervision

These break before quality stays. Build the foundation first; ramp later.

## The bottleneck hierarchy

When parallelism rises, the bottleneck migrates:

| Slot count | Likely bottleneck | Lever |
|---|---|---|
| 1 | spec clarity | spec format, constraints |
| 2-3 | review throughput | gates, self-QA, anti-overeng subagent |
| 4-5 | triage / context-switch | task queue, decomposer subagent, reduced WIP |
| 6+ | trust / autonomy | evals, regression tests, observability |

**This playbook targets 2-3 slots.** Going beyond requires a different playbook.

## When this playbook does *not* apply

- Single-shot prototyping / spikes (skip the gate stack, just code)
- Production hotfixes under time pressure (skip the slice ceremony)
- Brownfield with strong existing conventions (use what's there; the bootstrap section is moot)
- Heavy ML training / research code (different cadence)

For everything else: follow it.
