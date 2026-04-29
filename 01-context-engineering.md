# 01 — Context Engineering

The information the model sees, when it sees it, in what order, with what weight.
This is the single highest-leverage discipline in agentic engineering.

## Layered context architecture

Five layers, narrowest-scope to broadest. Each layer has a different rate of change.

```
┌─────────────────────────────────────────────┐
│  L5: Per-task spec  (BDD + constraints)     │  ← changes every task
│  L4: Plan          (model-authored, gated)  │  ← changes every task
│  L3: Per-area CLAUDE.md / CONTEXT.md        │  ← changes weekly
│  L2: Golden examples (live src/ files)      │  ← changes monthly
│  L1: Root CLAUDE.md + ADRs + skills         │  ← changes rarely
└─────────────────────────────────────────────┘
```

Rule: **the more often a layer changes, the more specific it should be**. Don't cram per-task detail into root CLAUDE.md; don't cram global rules into the per-task spec.

## Layer 1 — Root CLAUDE.md + ADRs + skills

**Root CLAUDE.md**: stable, small (<200 lines), high-signal. Contains:

- **Stack** — one paragraph, pinned versions
- **Commands** — exact bash to run tests/lint/types/dev/build
- **Constraints** — the canonical anti-overeng list (see [05](./05-anti-overengineering.md))
- **Workflow expectations** — when to ask, when to act, when to stop
- **Pointers** — paths to ADRs, golden examples, glossary

What does *not* go in root CLAUDE.md:

- Domain glossary (use `CONTEXT.md`)
- Architecture diagrams (link to a doc)
- Temporary state ("we're mid-migration")
- Per-area conventions (use per-area CLAUDE.md)

**ADRs** (`docs/adr/`): one decision per file, ~1 page. Format in `templates/adr.template.md`.
Write an ADR only when **all three**: hard to reverse + surprising without context + the result of a real trade-off.

**Skills** (`.claude/skills/`): procedural knowledge — how to do a recurring workflow. Trigger via `/<skill-name>`.

## Layer 2 — Golden examples in src/

**Live code, not extracted templates.** Templates drift; live code stays current because real users hit it.

Mark canonical files explicitly. Two ways:

1. **CLAUDE.md pointer**: `Canonical pattern: src/features/<X>. Mimic for new features of this shape.`
2. **Header comment**: at the top of the file, `// CANONICAL: study this before adding similar features.`

Both. Belt + suspenders. Models miss either alone.

Coverage target: 2-3 distinct shapes. See [04-greenfield-bootstrap](./04-greenfield-bootstrap.md).

## Layer 3 — Per-area CLAUDE.md / CONTEXT.md

When the repo grows past one cohesive area, add per-area files:

```
src/features/auth/CLAUDE.md           ← local conventions for auth
src/features/billing/CLAUDE.md        ← local conventions for billing
```

Local rules: which library patterns we use here, which files are the entry points, what's already abstracted vs. not.

`CONTEXT.md` (per-area or root): domain glossary. Terms that mean specific things in your domain. The model uses them correctly when defined; invents drift when not.

## Layer 4 — Plan (model-authored, gated)

The agent's plan **is** context for its own implementation phase.
Plan output goes into the impl agent's context. A bad plan = a bad impl.

Gate the plan with:

- "Does the plan cite a golden example?" (if no → reject, force pointer)
- "Does the plan introduce an abstraction not in the spec?" (if yes → reject)
- "Does the plan add files outside the spec's scope?" (if yes → reject)

See [06-workflow-loop](./06-workflow-loop.md) for the plan gate mechanics.

## Layer 5 — Per-task spec

Every task gets a spec. Format: BDD + constraints + examples.
See [02-spec-format](./02-spec-format.md) for the canonical shape.

The spec is the single highest-leverage place to prevent overengineering.
**Treat the spec as code.** Iterate it. Reuse phrases that worked.

## What the model sees, in what order

Roughly:

1. System prompt + Claude Code defaults
2. Root CLAUDE.md (always loaded)
3. Per-area CLAUDE.md (loaded when working in that area)
4. ADRs (loaded on demand or referenced)
5. Skill instructions (loaded when skill is invoked)
6. Memory (cross-session preferences and feedback)
7. The spec / user message
8. Tool results as the agent works

You can't change *order*, but you can change what's in each layer. Keep root CLAUDE.md tight so the spec gets attention.

## Anti-patterns

| Anti-pattern | Why it fails | Fix |
|---|---|---|
| 800-line CLAUDE.md | Model under-attends to specific rules; rules contradict | Split into layers; cap root at ~200 lines |
| Rules without examples | Models fit examples 5-10× better than abstract rules | Add a golden-example pointer to every rule that has one |
| Examples without rules | Drift; new patterns invented | Pair every canonical file with a 1-line "use this when X" rule |
| Per-task spec restates CLAUDE.md | Wastes context, dilutes signal | Spec only adds task-specific constraints; trust CLAUDE.md to load |
| ADRs as architecture wishlist | Rot, mislead | Only ADR real decisions made; archive obsolete ones |
| Glossary in CLAUDE.md | Bloats the always-loaded layer | Move to CONTEXT.md, reference on demand |

## Calibration

Measure context quality by **the rework rate of identical tasks across weeks**.
If the same shape of task overengineers twice in two weeks, the context is wrong, not the model.
Update CLAUDE.md or the spec template; don't yell at the agent.
