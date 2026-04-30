---
name: decompose
description: Break a PRD into ordered tracer-bullet slice specs. Use when a PRD exists and you need a queue of specs ready for plan-gate. Triggers on /decompose, "decompose this PRD", "break this into slices".
---

# /decompose

Spawn the **decomposer** subagent against a PRD to produce an ordered queue of slice specs.

## When to use

- A PRD exists (in `docs/prds/<feature>.md` or similar).
- You're starting a feature and need slices.

## Steps

1. Identify the PRD path. Ask the user if ambiguous.
2. Spawn the `decomposer` subagent with the PRD path.
3. The decomposer:
   - Reads the PRD, AGENTS.md / CLAUDE.md, ADRs.
   - Writes individual slice specs to `docs/specs/<feature>/<NN>-<slug>.md`.
   - Outputs a summary table to the conversation.
4. Show the user the summary table + open questions.
5. **Stop.** Don't start planning or implementing. The user reviews the queue first.

## What the user does next

- Edit the queue (drop, reorder, split, merge).
- Tighten constraints in individual specs.
- Pick the first slice to plan via `/plan`.

## Hard rules

- **Don't auto-promote slices to plan/implement.** Decomposition is its own gate.
- **Surface open questions**: anything ambiguous in the PRD must be flagged, not papered over.
- **Each slice 1-3 hours**. If the decomposer outputs longer slices, push back and ask it to split.

## Next step

User reviews the queue. Then `/plan` on the first chosen slice.
