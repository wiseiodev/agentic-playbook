# Agentic Engineering Playbook

A me-first operating system for keeping top-tier coding agents bounded, useful, and trusted.

Optimized for a solo engineer running multiple agent sessions in parallel, where the dominant pain is **smart-model overengineering**: models that are capable enough to solve the problem, but too unconstrained to stop at the simple solution.

This starts as a personal workflow. Team sharing comes later, after the rules have earned their keep in real work.

## Read order

1. [00-philosophy](./00-philosophy.md) — trust, bounded autonomy, and the five laws
2. [01-context-engineering](./01-context-engineering.md) — layered context: CLAUDE.md, ADRs, golden examples
3. [02-spec-format](./02-spec-format.md) — Given/When/Then + constraints + examples
4. [03-task-decomposition](./03-task-decomposition.md) — tracer bullets, 1-3hr slices
5. [04-greenfield-bootstrap](./04-greenfield-bootstrap.md) — hand-shape 2-3 reference features before agents take over
6. [05-anti-overengineering](./05-anti-overengineering.md) — canonical constraints list, drop-in for CLAUDE.md
7. [06-workflow-loop](./06-workflow-loop.md) — `/work` default, lower-level gates, review, merge
8. [07-parallelization](./07-parallelization.md) — git worktrees, 2-3 concurrent slots, conflict mgmt
9. [08-trust-and-verification](./08-trust-and-verification.md) — gates, self-QA, recoverability
10. [09-tooling-stack](./09-tooling-stack.md) — skills, subagents, hooks, CLIs, and local settings
11. [10-sharing-with-team](./10-sharing-with-team.md) — onboarding ramp, adoption pattern
12. [11-monday-checklist](./11-monday-checklist.md) — your day-1 setup checklist
13. [12-metrics-and-telemetry](./12-metrics-and-telemetry.md) — local success metrics, report sidecars, telemetry stance

## Drop-in artifacts

- [templates/](./templates/) — CLAUDE.md, spec, ADR, PRD, story
- [subagents/](./subagents/) — planner, anti-overeng-reviewer, decomposer, pr-author
- [skills/](./skills/) — `/linearize`, `/work`, `/plan`, `/implement`, `/review`, `/decompose`, `/bootstrap`, `/spec`, `/worktree`, `/cleanup-worktree`
- [hooks/](./hooks/) — stop-hook checks, dangerous-command guard, pre-tool safety examples
- [scripts/](./scripts/) — local report-sidecar summarizers

## Core thesis

Quality at speed comes from **upstream constraints**, not downstream rework.
Smart models with high thinking overengineer in inverse proportion to how constrained the task is.
The cure is: **behavior specs + small slices + golden examples + full ceremony by default + anti-overeng review**.

Use the best model. Bound its cleverness.

For agent-owned implementation, `/work` is the default operating loop. Invoking `/work` authorizes the agent to branch, implement, run gates, self-QA, review, write the report and metrics sidecar, commit, push, and open a Ready PR after the required checks pass. Humans can waive gates. Agents cannot self-waive.

Success is measured from the audit trail the workflow already creates: reports, metrics sidecars, PRs, reviews, and follow-up fixes. Do not build a dashboard until the local JSON proves the metrics are worth keeping.
