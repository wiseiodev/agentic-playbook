# 11 — Monday Checklist

Your day-1 setup. Roughly 4 hours of human time. Pays back within the first week.

## Pre-Monday (Sunday night, 30 min)

- [ ] Read [00-philosophy](./00-philosophy.md) and [05-anti-overengineering](./05-anti-overengineering.md)
- [ ] Decide stack (you'll commit Monday morning)
- [ ] Skim [04-greenfield-bootstrap](./04-greenfield-bootstrap.md) to anticipate the 2-3 reference features

## Monday AM (3-4 hours)

### 1. Repo + base structure (~30 min)
- [ ] `gh repo create` — Github repo
- [ ] Decide monorepo vs single — commit
- [ ] `mkdir docs/adr/` — ADR home
- [ ] Empty src/ skeleton matching your stack's idiom

### 2. Drop in CLAUDE.md (~20 min)
- [ ] Copy `templates/CLAUDE.md.template` → `/CLAUDE.md`
- [ ] Fill stack section (which framework, which db, which test runner, which deploy)
- [ ] Fill commands section (`pnpm checks`, `pnpm dev`, etc.)
- [ ] Leave Constraints section as-is (canonical anti-overeng list)

### 3. Set up quality gates (~30-45 min)
- [ ] Run `/setup-quality` or follow [13-quality-gates](./13-quality-gates.md)
- [ ] Pin Node in `.nvmrc` and package manager in `packageManager`
- [ ] Add or confirm Biome, Vitest, and the canonical `checks`/`check` command
- [ ] Add Commitlint + Lefthook if commits should close Linear/GitHub work
- [ ] Add CI from `templates/quality/github-actions-pnpm-ci.yml` and verify pnpm version matching

### 4. Drop in subagents + skills + hooks (~30 min)
- [ ] Copy `subagents/` → `.claude/agents/`
- [ ] Copy `skills/` → `.claude/skills/`
- [ ] Copy `hooks/` → wire into `.claude/settings.json`
- [ ] Copy `templates/work-metrics.template.json` and `scripts/summarize-work-metrics.sh`

### 5. First two ADRs (~30 min)
- [ ] ADR-0001: stack choice + reasoning
- [ ] ADR-0002: state management / data layer choice
- Each ADR is 1 page max. Use `templates/adr.template.md`.

### 6. Hand-shape reference feature #1 (~90 min)
Pick the simplest representative slice (e.g., one CRUD entity end-to-end).
- [ ] Write spec yourself first (use spec template)
- [ ] Write code yourself or with very tight AI assist (you drive every choice)
- [ ] Tests + types + lint passing
- [ ] Add to CLAUDE.md: "Canonical pattern: src/features/<X>. Mimic for new features."

## Monday PM (2-3 hours)

### 7. Hand-shape reference feature #2 (~90 min)
Pick a different shape from #1 (e.g., if #1 was read-path, do write-path; if #1 was REST, do streaming).

### 8. First agent slice (~60 min)
Pick a simple #3 feature. **Hand it to an agent**, follow the workflow loop end-to-end:
- [ ] Author spec (Given/When/Then + constraints + examples)
- [ ] Worktree
- [ ] Plan-mode → review plan → approve
- [ ] Implement
- [ ] Self-QA + anti-overeng review subagent
- [ ] `.reports/<work-id>.metrics.json` created from the template
- [ ] PR
- [ ] You review → merge

This is your first calibration loop. Note where the agent overengineered or missed intent. Tighten the spec template or CLAUDE.md based on what you saw.

## Tuesday and beyond

- Add reference feature #3 if your codebase has a third distinct shape (async/AI-call, jobs, webhooks, etc.) — agent-led but you supervise tightly
- Begin running 2 concurrent worktrees. Resist 3+ for the first week
- Review the playbook again at end of week 1 — annotate what's working / not

## Red flags in the first week

If you see these, **stop and tighten** before scaling parallelism:

- 🚩 Agent adds an interface/factory/abstract class for a single caller → tighten spec + add to constraints
- 🚩 Agent wraps every external call in try/catch → strengthen "no defensive code" rule
- 🚩 Agent invents a new pattern instead of mimicking existing → CLAUDE.md pointer to canonical isn't strong enough
- 🚩 Plan looks good but impl drifts → add "implementer must follow the approved plan; deviations require asking" to spec template
- 🚩 You're rewriting more than reviewing → slices are too big OR specs are too loose

## Calibration cadence

- **End of week 1**: re-read playbook, edit anything that didn't hold up
- **End of week 2**: try 3 concurrent worktrees if rework, review load, and waivers are flat
- **End of month 1**: write team-onboarding doc (see [10-sharing-with-team](./10-sharing-with-team.md))
