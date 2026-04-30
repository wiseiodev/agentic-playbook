---
name: plan
description: Generate an implementation plan from a locked per-task spec, gated by human approval before any code is written. Use after the spec exists and before implementation. Triggers on /plan, "make a plan", "draft a plan for this spec".
---

# /plan

Invoke the **planner** subagent against the current per-task spec to produce an implementation plan for human approval (gate 1 of the workflow loop).

## When to use

- A per-task spec exists (in `docs/specs/<feature>/<NN>-<slug>.md` or similar).
- No code has been written yet for this slice.
- You want to gate the agent before implementation.

## Steps

1. Identify the spec file. Ask the user if ambiguous.
2. Read the spec, AGENTS.md / CLAUDE.md, and the canonical example the spec cites.
3. Spawn the `planner` subagent with the spec path. Pass it:
   - The spec file path
   - The AGENTS.md / CLAUDE.md path
   - The canonical example path (extracted from spec's Constraints)
4. The planner produces a plan to stdout (or writes to `<spec>.plan.md`).
5. **STOP.** Show the plan to the user. Do not proceed to implementation.

## Output

A plan with the structure defined in `agentic-playbook/subagents/planner.md`:

- Approach (prose)
- Files to add/modify
- Canonical pattern being mimicked
- What this slice will NOT do
- Abstractions introduced (with justification)
- Risks
- Done check

## Hard rules

- The plan is the deliverable. **Do not start implementing.**
- If the user pushes back on the plan, revise the plan and re-show. Do not jump to code.
- If the spec is broken (missing constraints, ambiguous, contradictory), stop and ask before drafting a plan.

## Next step after plan is approved

Use `/implement`.
