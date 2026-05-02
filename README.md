# Agentic Engineering Playbook

A me-first operating system for keeping top-tier coding agents bounded, useful, and trusted.

Optimized for a solo engineer running multiple agent sessions in parallel, where the dominant pain is **smart-model overengineering**: models that are capable enough to solve the problem, but too unconstrained to stop at the simple solution.

This starts as a personal workflow. Team sharing comes later, after the rules have earned their keep in real work.

## Read Order

1. [00-quick-start](./00-quick-start.md) — day-1 setup checklist
2. [01-workflow-loop](./01-workflow-loop.md) — `/work` default, lower-level gates, review, merge
3. [02-context-engineering](./02-context-engineering.md) — layered context: AGENTS.md/CLAUDE.md, ADRs, golden examples
4. [03-spec-format](./03-spec-format.md) — Given/When/Then + constraints + examples
5. [04-task-decomposition](./04-task-decomposition.md) — tracer bullets, 1-3hr slices
6. [05-quality-gates](./05-quality-gates.md) — preferred Biome, Vitest, Commitlint, Lefthook, pnpm, and CI setup
7. [06-tooling-stack](./06-tooling-stack.md) — skills, subagents, hooks, CLIs, and local settings
8. [07-parallelization](./07-parallelization.md) — git worktrees, 2-3 concurrent slots, conflict mgmt
9. [08-trust-and-verification](./08-trust-and-verification.md) — gates, self-QA, recoverability
10. [09-anti-overengineering](./09-anti-overengineering.md) — canonical constraints list, drop-in for progressive-disclosure agent docs
11. [10-greenfield-bootstrap](./10-greenfield-bootstrap.md) — hand-shape 2-3 reference features before agents take over
12. [11-isolated-db-branches](./11-isolated-db-branches.md) — Neon branch databases for parallel Drizzle schema work
13. [12-metrics-and-telemetry](./12-metrics-and-telemetry.md) — local success metrics, report sidecars, telemetry stance
14. [13-sharing-with-team](./13-sharing-with-team.md) — onboarding ramp, adoption pattern
15. [14-philosophy](./14-philosophy.md) — trust, bounded autonomy, and the five laws

## Drop-In Artifacts

- [templates/](./templates/) — AGENTS/CLAUDE, progressive agent docs, spec, ADR, PRD, PR body, metrics, quality-gate snippets
- [subagents/](./subagents/) — planner, anti-overeng-reviewer, decomposer, pr-author
- [skills/](./skills/) — installable skill directories for `/work`, `/setup-quality`, `/isolated-db-branches`, and the supporting workflow commands
- [hooks/](./hooks/) — stop-hook checks, dangerous-command guard, pre-tool safety examples
- [scripts/](./scripts/) — local report-sidecar summarizers

## Install Skills

Install a skill with:

```bash
npx skills add wiseiodev/agentic-playbook/skills/<skill>
```

Common starting set:

```bash
npx skills add wiseiodev/agentic-playbook/skills/work
npx skills add wiseiodev/agentic-playbook/skills/setup-quality
npx skills add wiseiodev/agentic-playbook/skills/isolated-db-branches
```

See [skills/README.md](./skills/README.md) for the full skill catalog and install commands.

## Give This To Your Agent

Use this prompt to incorporate the playbook into a repo:

```text
Please incorporate wiseiodev/agentic-playbook into this repo.

Read the playbook README first, then adapt the artifacts to this repo instead of copying blindly.

Do the following:
- Copy or adapt templates/agent-docs into AGENTS.md/CLAUDE.md and docs/agent/.
- Install only the relevant skills from skills/ using `npx skills add wiseiodev/agentic-playbook/skills/<skill>`.
- Set up or tighten quality gates using the repo's actual package manager, scripts, task runner, and CI shape.
- Add hooks only when they fit this repo's workflow and are not surprising.
- Preserve existing conventions unless the playbook explicitly fixes a gap.
- Report exactly what changed, which gates passed, and which recommendations were intentionally skipped.

Do not add a custom installer, dashboard, or extra process docs.
```

## Core Thesis

Quality at speed comes from **upstream constraints**, not downstream rework.
Smart models with high thinking overengineer in inverse proportion to how constrained the task is.
The cure is: **behavior specs + small slices + golden examples + full ceremony by default + anti-overeng review**.

Use the best model. Bound its cleverness.

For agent-owned implementation, `/work` is the default operating loop. Invoking `/work` authorizes the agent to branch, implement, run gates, self-QA, review, write the report and metrics sidecar, commit, push, and open a Ready PR after the required checks pass. Humans can waive gates. Agents cannot self-waive.

Success is measured from the audit trail the workflow already creates: reports, metrics sidecars, PRs, reviews, and follow-up fixes. Do not build a dashboard until the local JSON proves the metrics are worth keeping.
