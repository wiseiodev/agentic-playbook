# 14 — Philosophy

This playbook is a personal operating system first. It is not trying to be a generic public framework on day one. It exists to let you trust strong models with real implementation work without spending the rest of the day cleaning up cleverness.

The model stays strong. The work unit gets tighter.

## What 2-3x looks like

**Not** "I type faster." 2-3x means:

- **Throughput**: 2-3 slices in flight concurrently (worktrees), each in a fresh agent session
- **Architect-mode default**: you spend most of your time shaping specs, approving plans, reviewing evidence, and reading diffs
- **Quality at speed**: rework rate, review burden, and waiver rate stay flat as throughput rises, because constraints live upstream of the code
- **Bounded autonomy**: agents can carry a slice through the boring parts, but only inside a contract you already approved

If your rework rate climbs as you parallelize, you don't have 2-3x — you have 1x with extra steps.

## The five laws

### 1. Constraints upstream beat reviews downstream

Every minute spent tightening the spec saves ten minutes of review-and-redo.
Premature abstraction and defensive code are *invited* by vague specs. Don't review them out — *spec them out*.

### 2. Mimicry beats instruction

Models follow examples in the repo more reliably than rules in AGENTS.md / CLAUDE.md.
Three concrete patterns set the precedent. Any new feature mimics them, not the model's training-data Java enterprise instincts.

### 3. Smaller slices, less surface

A 3-hour tracer bullet has ~10% the abstraction-temptation of a 1-day feature.
Decompose aggressively. The unit is "smallest end-to-end slice that adds value or de-risks."

### 4. Full ceremony is the default contract

For agent-owned implementation, `/work` is the default. It includes intake, branch isolation, implementation, quality gates, self-QA evidence, anti-overeng review, adversarial review, report, metrics sidecar, commit, push, and a Ready PR.

The human can waive gates. The agent cannot self-waive gates.

This matters because the ceremony is what turns "I hope the agent did it right" into "I can inspect the path it took."

The metrics sidecar is part of that inspection path. It is not a dashboard project. It is the tiny structured receipt that lets you answer: did this loop reduce rework, or just produce more ceremony?

### 5. Process not model

Don't fix overengineering by switching Opus → Sonnet. Fix it by:

- tighter specs (constraints + out-of-scope)
- golden examples in the repo
- plan-gate before code
- strict `/work` for agent-owned slices
- anti-overengineering review subagent before PR

Same model, better process, better output.

## What you're optimizing for

> A solo engineer who can keep 2-3 agents productively building, reviewing, and merging — without rework, review load, or trust waivers exceeding human capacity.

Anti-goals:

- Maximum autonomy ("agents merge themselves")
- Maximum parallelism (10+ concurrent agents)
- Zero supervision
- Public-polished process before personal proof

These break before quality stays. Build the foundation first; ramp later.

## Authorization model

Agents need crisp authority boundaries.

- `/work` means: execute this one scoped work item end-to-end, including branch, commit, push, and Ready PR after gates pass.
- Lower-level skills (`/plan`, `/implement`, `/review`, `/pr`) remain conservative and composable.
- Human decisions must be captured through the question tool when available.
- Mechanical hooks block dangerous actions. They do not enforce taste.
- Taste is enforced by specs, golden examples, review subagents, adversarial review, and human review.
- Success is measured from `/work` reports, metrics sidecars, PR/review state, and explicit follow-up labels. Do not infer quality from raw agent runtime logs.

## The bottleneck hierarchy

When parallelism rises, the bottleneck migrates:

| Slot count | Likely bottleneck | Lever |
|---|---|---|
| 1 | spec clarity | spec format, constraints |
| 2-3 | review throughput | gates, self-QA, anti-overeng subagent |
| 4-5 | triage / context-switch | task queue, decomposer subagent, reduced WIP |
| 6+ | trust / autonomy | metrics sidecars, evals, regression tests, observability |

**This playbook targets 2-3 slots.** Going beyond requires a different playbook.

## When this playbook does *not* apply

- Single-shot prototyping / spikes (skip the gate stack, just code)
- Production hotfixes under time pressure (skip the slice ceremony)
- Brownfield with strong existing conventions (use what's there; the bootstrap section is moot)
- Heavy ML training / research code (different cadence)

For everything else: follow it.
