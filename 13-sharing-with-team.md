# 13 — Sharing with Team

The playbook starts as your solo system. It becomes the team's standard as you hire. This doc is the adoption ramp.

## Adoption stages

```
You solo (Mon-Day-30)
   ↓
Hire #1 — pair-mode onboarding (Day-30 to Day-45)
   ↓
Hire #2-3 — playbook is the default (Day-45 to Day-90)
   ↓
Team (4+) — playbook is documented + governed (Day-90+)
```

Each stage has different leverage points. Don't jump stages.

## Stage 1: Solo (Mon-Day-30)

Goals:

- Calibrate the playbook on real work
- Identify which constraints actually fire
- Identify which subagents pull weight vs. ceremony
- Don't ossify too early — iterate aggressively

What to write down:

- Update `09-anti-overengineering.md` with new failure modes you saw
- Update `03-spec-format.md` if you added/removed slots
- Update AGENTS/CLAUDE templates with rules that proved out
- Note in `STATUS.md` or a journal: "this week's biggest learning"

Don't yet:

- Polish for outsiders
- Add dashboards
- Codify rules that haven't been tested

Do collect the local `/work` metrics sidecars. They are part of the audit trail, not a team process rollout.

## Stage 2: Hire #1 — pair-mode onboarding (~2 weeks)

Goal: hire #1 internalizes the playbook by doing, with you watching.

### First week

- Day 1: walk through the playbook docs together. ~2 hours.
- Day 2: watch you run a slice end-to-end (you live-narrate).
- Day 3: hire runs a slice with you over the shoulder. You catch overrides in real-time.
- Days 4-5: hire runs slices solo, you review every PR carefully.

Calibrate gates harder for the first 5 PRs from a new teammate. False positives are cheap; missed overengineering is expensive.

### Second week

- Hire runs at 1 slot. You run at 2. Total 3 slots in flight across the team.
- End-of-week 1:1 — what felt fluid, what felt like ceremony.
- Edit the playbook based on real feedback. New eng eyes catch what solo eyes miss.

### Onboarding artifacts

Add to the playbook:

- `ONBOARDING.md` — first-week checklist (variant of `00-quick-start`)
- A shared Linear/Asana template for spec authoring
- A "first slice" task that's deliberately shaped for learning

## Stage 3: Hires #2-3 — playbook is the default (~6 weeks)

Goal: a standard the team follows by default, not because you enforce it.

### What changes

- You stop being the only reviewer at gate 4. Other engineers review each other's PRs.
- Subagents are configured at the project level (`.claude/agents/`), checked in.
- Hooks are checked in.
- AGENTS.md is checked in, with CLAUDE.md symlinked or copied for Claude Code.

### What stays the same

- Slot counts: still 2-3 per engineer
- Plan-first
- Anti-overeng review
- Tracer bullets

### Risks at this stage

- Cargo-culting: people follow the playbook without understanding why → reflexively skip gates
- Drift: each engineer has slightly different conventions → constraints get reinterpreted
- Tooling rot: subagents/hooks get stale, no one updates

Mitigate:

- Monthly playbook retro (15 min) — what's still working, what's drifting
- Pair on the first slice in any new shape (auth, billing, AI flow) so the canonical pattern is shared
- Pair-review of root AGENTS.md / CLAUDE.md changes before merge

## Stage 4: Team of 4+ — documented + governed

Goal: the playbook is institutional knowledge, not your personal habit.

### What to add

- **Owners** — each section of the playbook has an owner (you, by default, until delegated)
- **Change process** — playbook PRs need 1+ reviewer; large changes need team discussion
- **Retros** — monthly team retro on "what failure shape should we add to the constraints list"
- **Metrics (lightweight)** — summarize `/work` sidecars weekly, then enrich with PR review/revert/follow-up state; flag if rework exceeds capacity or waivers become routine

Don't add:

- Heavy approval workflows
- Mandatory training
- Compliance gates that don't catch real failures

The playbook works because it's lean. Bureaucracy kills it.

## Sharing the playbook itself

Two options:

### Option A: per-repo
Copy `agentic-playbook/` into each repo. Each repo evolves its own copy.
- Pro: project-specific tuning easy
- Con: drift between repos; updates don't propagate

### Option B: company-shared
Single `agentic-playbook/` repo, referenced by each project's `AGENTS.md` / `CLAUDE.md` ("read X for our standards").
- Pro: one source of truth, updates propagate
- Con: changes need coordination; project specifics live elsewhere

**Recommended: hybrid.**
- Shared playbook repo for principles, templates, subagents, skills, hooks
- Per-project AGENTS.md for package manager, commands, and links to progressive-disclosure docs
- Per-project ADRs for project decisions

## Communicating the *why*

When sharing with new hires, the order matters. Lead with the *why*, not the *what*.

Bad opener: "Here's our 12-section playbook, please read."

Good opener:

> "We hit 2-3x throughput by treating the spec and the plan as more important than the code. The cure for overengineering isn't reviewing harder — it's specifying tighter. Everything in this playbook is downstream of that."

Then point at `14-philosophy.md` and `09-anti-overengineering.md`. Other sections come up as the work demands.

## Resistance you'll hit

| Pushback | Reframe |
|---|---|
| "All these gates slow me down" | They slow individual slices but raise effective throughput because rework drops |
| "Specs are extra work" | Specs replace the rework cycle; net less work |
| "Plan-first kills creativity" | Plan IS the creative phase; impl is mechanical |
| "Anti-overeng is overly strict" | Show 3 examples of where it caught real issues |
| "I prefer my own setup" | Fine for solo; but shared standard cuts the team's review load |

For senior hires, the pushback usually settles after they ship one full slice through the loop and feel the leverage. Don't argue; demonstrate.

## When the playbook is wrong

Treat the playbook like code. If a rule produces friction with no payoff, kill the rule. Don't ossify. Sentinel question:

> "If we removed this rule, what specific failure would happen?"

If you can name a recent example, keep the rule. If you can't, drop it.

## Anti-patterns of team adoption

| Anti-pattern | Why it fails |
|---|---|
| Mandate before validation | Team resents process that wasn't proven on solo work |
| Skip pair-mode onboarding | Hire follows letter, misses spirit; reverts to old habits |
| Freeze the playbook | Drift between codebase and rules; team stops trusting it |
| Add gates without dropping any | Process bloat; gates become rituals |
| Measure adoption instead of outcomes | Compliance theater; no real productivity gain |
| Infer quality from agent logs | Runtime activity looks productive even when the PR caused rework |
