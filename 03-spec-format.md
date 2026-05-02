# 03 — Spec Format

The single most leveraged document in your workflow. The spec is what stops a smart model from inventing factories you didn't ask for.

For non-trivial work, Given/When/Then is the canonical spine. Use it as planning language and acceptance criteria, not as a mandate to install Cucumber or build an executable acceptance-test framework.

## Canonical structure

```markdown
# <slice title>

## Intent
<1-2 sentences. What user-visible value does this slice add?>

## In scope
- Bullet 1
- Bullet 2

## Out of scope
- Bullet 1 (explicitly NOT this task)
- Bullet 2

## Behavior (Given/When/Then)
- **Scenario: <short behavior name>**
  **Given** <state>, **when** <action>, **then** <observable outcome>
- **Scenario: <short behavior name>**
  **Given** ..., **when** ..., **then** ...

## Examples
**Input:**
```
<concrete data>
```
**Expected output:**
```
<concrete data>
```

## Constraints
- No new abstractions (factories, interfaces, generic helpers) unless the spec explicitly asks.
- No defensive code (try/catch, null guards) for cases that can't actually happen.
- No new files unless listed under "Files to touch."
- Mimic the canonical pattern at <src/path/to/golden-example>.
- <task-specific constraints>

## Files to touch
- src/features/<X>/foo.ts
- src/features/<X>/foo.test.ts

## Done when
- [ ] Every Given/When/Then scenario is verified by a test or QA evidence
- [ ] `pnpm checks` passes
- [ ] No new files outside the list above
- [ ] Anti-overeng review subagent: no flags
```

## Why each section earns its place

| Section | What it prevents |
|---|---|
| **Intent** | Slice that's technically right but solves the wrong problem |
| **In scope** | Anchor for the agent — explicit list of what counts |
| **Out of scope** | Scope creep ("while we're here, I refactored the helper") |
| **Behavior (Given/When/Then)** | Misunderstanding intent; ambiguity on observable outcomes |
| **Examples** | Misinterpreting types/shapes; gives the model a target to mimic |
| **Constraints** | Premature abstraction, defensive code — the top failure modes |
| **Files to touch** | New file/folder explosion; surgical impl |
| **Done when** | Premature "done" claim; forces self-QA |

## Constraint phrasing — what works

The exact phrasing matters. Phrases that work:

- "**Do not** add interfaces or abstract classes."
- "**Do not** wrap calls in try/catch unless an explicit failure mode is documented."
- "**Mimic** `src/features/<X>/foo.ts` for layout and naming."
- "**Maximum** 1 new file. If you need more, stop and ask."
- "**No** new dependencies."
- "**No** changes to files outside the list above."

Phrases that don't work (too soft):

- "Try to keep it simple."
- "Don't overengineer."
- "Be pragmatic."

The model needs **specific bans + specific pointers**, not vibes.

## Spec authoring workflow

You don't write the spec from scratch. The agent does.

```
1. You: 1-paragraph idea + a pointer to the canonical example
2. Decomposer subagent: produces draft spec in this format
3. You: edit constraints + scope (10-30 sec, not 5 min)
4. Locked spec → plan phase
```

The agent drafting the spec is fine because:
- The format is structured
- You edit the slots that matter (behavior, out-of-scope, constraints)
- The decomposer subagent has AGENTS.md / CLAUDE.md context

See [`subagents/decomposer.md`](./subagents/decomposer.md) for the subagent definition.

## Spec sizing

A spec that produces a tracer-bullet slice (1-3hr) is usually:

- ~50-150 lines of markdown
- 3-7 Given/When/Then scenarios
- 1-3 examples
- 4-8 constraints
- 2-6 files in "Files to touch"

If the spec exceeds 200 lines, the slice is probably too big. Decompose.
If the spec is <30 lines, the slice is either trivial or under-specified. Either ship it fast or expand the constraints.

## Constraint inheritance

Don't repeat global constraints (no defensive code, no premature abstraction) in every spec — they're in `docs/agent/ANTI_OVERENGINEERING.md`, linked from AGENTS.md / CLAUDE.md.
The spec's Constraints section adds **task-specific** bans:

- "Do not add a database migration; we're using existing schema only."
- "Do not modify the auth middleware; this is read-only."
- "Reuse the existing `<X>` helper rather than writing a new one."

## Examples block — be concrete

Vague example ("a list of users"):
- Model invents shape, often wrong

Concrete example:
```ts
// Expected response:
{
  users: [
    { id: "u_01", email: "ada@example.com", role: "admin" },
    { id: "u_02", email: "linus@example.com", role: "viewer" }
  ],
  cursor: "page_2"
}
```
Model has nothing to invent.

## "Done when" — the merge gate

Every checkbox in "Done when" should be **mechanically verifiable** by the agent:

- ✅ Every Given/When/Then scenario has a test or QA evidence (mechanical)
- ✅ `pnpm checks` passes (mechanical)
- ✅ No new files outside list (mechanical, agent diffs the list)
- ✅ Anti-overeng review: no flags (mechanical, subagent runs)
- ❌ "Code is clean" (subjective, useless)
- ❌ "Tests are good" (subjective)

Mechanical = verifiable = the agent can self-confirm before handing off.

## Question-tool policy

If the agent needs user input for a clarification, tradeoff, confirmation, or scope decision, it must use the question tool when the environment provides one. Do not bury decisions in prose and hope they survive the session.

If no question tool exists, ask directly and record the answer in the spec before implementation continues.

## Iterating the spec template

Treat the template like code. When a class of failure happens twice:

1. Add a constraint to the relevant progressive-disclosure doc
2. Or add a slot to the spec template

Example: if agents keep adding `console.log` debug statements, add to template:

> **Constraints:** No `console.log` / `print` debug statements.
