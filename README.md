# Agentic Engineering Playbook

A reference for hitting **2-3x individual productivity** with coding agents, then ramping a team onto the same model.

Optimized for solo eng running multiple Claude Code sessions in parallel, on greenfield projects, where the dominant pain is **smart-model overengineering**.

## Read order

1. [00-philosophy](./00-philosophy.md) — what 2-3x looks like, the four laws
2. [01-context-engineering](./01-context-engineering.md) — layered context: CLAUDE.md, ADRs, golden examples
3. [02-spec-format](./02-spec-format.md) — BDD + constraints + examples (the canonical per-task spec)
4. [03-task-decomposition](./03-task-decomposition.md) — tracer bullets, 1-3hr slices
5. [04-greenfield-bootstrap](./04-greenfield-bootstrap.md) — hand-shape 2-3 reference features before agents take over
6. [05-anti-overengineering](./05-anti-overengineering.md) — canonical constraints list, drop-in for CLAUDE.md
7. [06-workflow-loop](./06-workflow-loop.md) — PRD → spec → plan → exec → review → merge
8. [07-parallelization](./07-parallelization.md) — git worktrees, 2-3 concurrent slots, conflict mgmt
9. [08-trust-and-verification](./08-trust-and-verification.md) — gates, self-QA, recoverability
10. [09-tooling-stack](./09-tooling-stack.md) — subagents + hooks + skills + CLIs (no MCP unless required)
11. [10-sharing-with-team](./10-sharing-with-team.md) — onboarding ramp, adoption pattern
12. [11-monday-checklist](./11-monday-checklist.md) — your day-1 setup checklist

## Drop-in artifacts

- [templates/](./templates/) — CLAUDE.md, spec, ADR, PRD, story
- [subagents/](./subagents/) — planner, anti-overeng-reviewer, decomposer, pr-author
- [skills/](./skills/) — `/plan`, `/implement`, `/review`, `/decompose`, `/bootstrap`
- [hooks/](./hooks/) — stop-hook checks, pre-commit safety

## Core thesis

Quality at speed comes from **upstream constraints**, not downstream rework.
Smart models with high thinking overengineer in inverse proportion to how constrained the task is.
The cure is: **tight specs + small slices + golden examples + plan gate + anti-overeng review**.

Process is the lever. Don't downgrade the model.
