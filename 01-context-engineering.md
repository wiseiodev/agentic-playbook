# 01 — Context Engineering

The information the model sees, when it sees it, in what order, with what weight.
This is the single highest-leverage discipline in agentic engineering.

## Layered context architecture

Five layers, narrowest-scope to broadest. Each layer has a different rate of change.

```
┌─────────────────────────────────────────────┐
│  L5: Per-task spec  (Given/When/Then + constraints) │  ← changes every task
│  L4: Plan          (model-authored, gated)  │  ← changes every task
│  L3: Per-area AGENTS.md / CONTEXT.md        │  ← changes weekly
│  L2: Golden examples (live src/ files)      │  ← changes monthly
│  L1: Root AGENTS.md + ADRs + skills         │  ← changes rarely
└─────────────────────────────────────────────┘
```

Rule: **the more often a layer changes, the more specific it should be**. Don't cram per-task detail into root `AGENTS.md`; don't cram global rules into the per-task spec.

## Layer 1 — Root AGENTS.md + ADRs + skills

`AGENTS.md` is the repo-level instruction file. Claude Code reads `CLAUDE.md`, so keep `CLAUDE.md` as a symlink or copy of `AGENTS.md` unless the repo has a strong reason to diverge:

```bash
ln -s AGENTS.md CLAUDE.md
```

**Root AGENTS.md**: stable, tiny, high-signal. Target <50 lines. Contains only:

- **One-sentence project description** — what this repo is and who it serves
- **Package manager** — only if not npm, or if the repo uses workspaces
- **Non-standard commands** — exact build/typecheck/test command names when they are not obvious
- **Universal pointers** — links to docs the agent can open when relevant

What does *not* go in root `AGENTS.md`:

- Long coding-style lists
- Test-runner details
- Git workflow ceremony
- Domain glossary
- Architecture diagrams
- Temporary state ("we're mid-migration")
- Per-area conventions
- The entire anti-overengineering checklist

Put those in separate docs and link them. Use [templates/agent-docs/AGENTS.md](./templates/agent-docs/AGENTS.md) as the root shape.

### Suggested progressive-disclosure tree

```text
AGENTS.md                  # tiny root, universal context only
CLAUDE.md -> AGENTS.md     # symlink for Claude Code
docs/agent/
  WORKFLOW.md              # /work, plan gate, question tool, reports
  QUALITY.md               # package manager, lint/typecheck/test/build
  ARCHITECTURE.md          # ADRs, glossary, canonical examples
  TESTING.md               # behavior tests, fixtures, E2E policy
  GIT.md                   # commits, PRs, reviews, irrecoverable actions
  ANTI_OVERENGINEERING.md  # concrete bans and review checklist
```

Only load the detail doc when the task needs it. A CSS-only change should not pay for TypeScript, Git, database, and anti-overengineering instructions up front.

**ADRs** (`docs/adr/`): one decision per file, ~1 page. Format in `templates/adr.template.md`.
Write an ADR only when **all three**: hard to reverse + surprising without context + the result of a real trade-off.

**Skills** (`.claude/skills/`): procedural knowledge — how to do a recurring workflow. Trigger via `/<skill-name>`.

## Layer 2 — Golden examples in src/

**Live code, not extracted templates.** Templates drift; live code stays current because real users hit it.

Mark canonical files explicitly. Two ways:

1. **AGENTS.md or `docs/agent/ARCHITECTURE.md` pointer**: `Canonical pattern: src/features/<X>. Mimic for new features of this shape.`
2. **Header comment**: at the top of the file, `// CANONICAL: study this before adding similar features.`

Both. Belt + suspenders. Models miss either alone.

Coverage target: 2-3 distinct shapes. See [04-greenfield-bootstrap](./04-greenfield-bootstrap.md).

## Layer 3 — Per-area AGENTS.md / CONTEXT.md

When the repo grows past one cohesive area, add per-area files:

```
src/features/auth/AGENTS.md           ← local conventions for auth
src/features/billing/AGENTS.md        ← local conventions for billing
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

Every non-trivial task gets a spec. Format: Given/When/Then + constraints + examples.
See [02-spec-format](./02-spec-format.md) for the canonical shape.

The spec is the single highest-leverage place to prevent overengineering.
**Treat the spec as code.** Iterate it. Reuse phrases that worked.

## What the model sees, in what order

Roughly:

1. System prompt + Claude Code defaults
2. Root `AGENTS.md` / `CLAUDE.md` (always loaded)
3. Per-area `AGENTS.md` / `CLAUDE.md` (loaded when working in that area)
4. ADRs (loaded on demand or referenced)
5. Skill instructions (loaded when skill is invoked)
6. Memory (cross-session preferences and feedback)
7. The spec / user message
8. Tool results as the agent works

You can't change *order*, but you can change what's in each layer. Keep root `AGENTS.md` tight so the spec gets attention.

## Refactoring a bloated root file

Use this audit before editing:

1. **Find contradictions.** If two instructions conflict, ask the human which one wins.
2. **Identify essentials.** Keep only the one-sentence description, package manager, non-standard commands, and truly universal instructions in root.
3. **Group the rest.** Move related instructions to `docs/agent/*.md`.
4. **Create breadcrumbs.** Root `AGENTS.md` links to the detail docs; detail docs link to each other only when useful.
5. **Flag deletions.** Remove instructions that are redundant, vague, or obvious.

Common deletion candidates:

- "Write clean code"
- "Use best practices"
- "Be careful"
- "Add tests where appropriate"
- Framework defaults the agent already knows
- Long file trees that will drift
- Stale temporary migration notes

## Anti-patterns

| Anti-pattern | Why it fails | Fix |
|---|---|---|
| 800-line AGENTS.md | Model under-attends to specific rules; rules contradict | Split into linked docs; cap root at ~50 lines |
| Rules without examples | Models fit examples 5-10× better than abstract rules | Add a golden-example pointer to every rule that has one |
| Examples without rules | Drift; new patterns invented | Pair every canonical file with a 1-line "use this when X" rule |
| Per-task spec restates AGENTS.md | Wastes context, dilutes signal | Spec only adds task-specific constraints; trust root instructions to load |
| ADRs as architecture wishlist | Rot, mislead | Only ADR real decisions made; archive obsolete ones |
| Glossary in AGENTS.md | Bloats the always-loaded layer | Move to CONTEXT.md, reference on demand |

## Calibration

Measure context quality by **rework rate, repeated anti-overeng flags, and plan/spec violations across similar tasks**.
If the same shape of task overengineers twice in two weeks, the context is wrong, not the model.
Update the smallest relevant doc or the spec template; don't yell at the agent.
