# 04 — Task Decomposition

Smaller slices have less surface for overengineering and parallelize cleanly. The unit is the **tracer bullet**.

## Tracer bullet — definition

The smallest end-to-end vertical slice that:

1. Adds user-visible value, **or** de-risks a real unknown
2. Touches every layer needed to ship the value (no "I'll wire it up later")
3. Is testable on its own
4. Takes 1-3 hours of equivalent human work

End-to-end = if it's web, the slice goes from request → DB → response → UI render. Even if degenerate (one row, one button).

## Why tracer bullets

| Effect | Reason |
|---|---|
| Less overengineering | Smaller surface = fewer plausible places to add abstractions |
| Faster review | You review 200 lines, not 2000 |
| Parallel-safe | Independent slices can run in parallel worktrees |
| Fast feedback | A bad direction costs 90 min, not 2 days |
| Forced design | Decomposing forces you to know the shape before coding |

## Slicing heuristics

### Slice by **value**, not by **layer**

| ❌ Bad slicing (by layer) | ✅ Good slicing (by value) |
|---|---|
| Slice 1: DB schema | Slice 1: Read-only list view (1 entity, 1 column, no filters) |
| Slice 2: API endpoints | Slice 2: Add a single filter |
| Slice 3: UI components | Slice 3: Add pagination |
| Slice 4: Wire up | Slice 4: Add CRUD: create |

By-layer slices don't ship value until all four merge. By-value slices each ship something testable.

### One concept per slice

A slice should require the user to learn at most **one new thing**.

If the spec sentence is "add filtering, sorting, and pagination" — that's three slices, not one.

### Independent if possible, sequential if necessary

For each slice, ask: "could another agent be working on this in parallel?"

- **Independent** = different files, no shared state changes → run in parallel worktrees
- **Sequential** = same files, depends on prior slice → queue, run serially

Annotate the dependency in the spec ("depends on slice #14 merged").

## Decomposition workflow

```
PRD (you-authored, ~1 page)
   ↓
Decomposer subagent → draft list of N tracer-bullet slices
   ↓
You: review, reorder, drop, split, merge
   ↓
For each slice → spec → plan → exec
```

The decomposer subagent is in [`subagents/decomposer.md`](./subagents/decomposer.md).

## PRD structure (input to decomposition)

```markdown
# <feature name>

## Why
1-2 sentences on the user pain or business goal.

## What
3-5 bullets describing the feature at user-experience level.

## Out of scope (this PRD)
- Adjacent things you considered and chose to defer

## Open questions
- Anything you don't know yet (decomposer flags these)

## Constraints
- Must use <existing pattern X>
- Must not change <existing thing Y>
```

PRD format in `templates/prd.template.md`.

## Decomposition checklist

When reviewing the decomposer's output:

- [ ] Each slice is 1-3 hours? (If 4+, split.)
- [ ] Each slice ships value end-to-end? (If layer-only, refactor.)
- [ ] Dependencies between slices noted?
- [ ] Slices that *could* run in parallel are flagged?
- [ ] First slice is intentionally minimal (degenerate "happy path") to validate the architecture?
- [ ] Out-of-scope items deferred to follow-on slices, not lost?

## Slice ordering

Default ordering:

1. **Tracer bullet** (smallest happy path, end-to-end) — proves architecture
2. **Riskiest unknown** next — fail fast on real unknowns
3. **Highest user value** next — ship something noticeable
4. **Polish, edge cases** last — only if truly needed

Don't start with auth/infra/CI as separate slices. Bake the minimum into slice 1; expand later.

## When decomposition isn't worth it

- One-line bug fix (no decomp needed)
- Pure rename / mechanical refactor
- Codemod (let it touch the world atomically)
- Hotfix under pressure

For everything else, decompose.

## Anti-patterns

| Anti-pattern | Symptom | Fix |
|---|---|---|
| "Big bang" slice | One PR, 1500+ lines, half-broken | Force split: any PR > 400 lines re-decomposed |
| Layer-by-layer | Many merged slices, no shipped value | Slice by user-visible behavior |
| Speculative slices | "Slice 5: add caching layer" with no metric proving need | YAGNI; only slice work that's actually needed |
| Overlapping slices | Two parallel slices touch the same files | Refactor decomposition; sequence them |
| Hidden dependencies | Slice 3 silently needs slice 2 | Annotate explicitly in spec |
