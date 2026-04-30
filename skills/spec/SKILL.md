---
name: spec
description: Open a per-task spec scaffold from the canonical template, prefilled with reasonable defaults. Use when starting a new slice that needs a spec written. Triggers on /spec, "draft a spec", "spec this slice".
---

# /spec

Create or open a per-task spec from the canonical template.

## When to use

- You have an idea for a slice but haven't written the spec yet.
- A slice was decomposed but needs polish on its constraints / examples.

## Steps

1. Ask the user (if not provided):
   - Slice title
   - Target file path (default: `docs/specs/<feature>/<NN>-<slug>.md`)
2. Copy `agentic-playbook/templates/spec.template.md` to the target path.
3. Prefill known sections from context:
   - **Constraints**: include the canonical pattern pointer extracted from CLAUDE.md if known.
4. Open the file for the user to edit.

## What to leave empty

- **Intent** — user authors
- **In scope / Out of scope** — user authors
- **Behavior (Given/When/Then)** — user authors
- **Examples** — user authors
- **Files to touch** — user authors (planner refines later)

The user fills these manually. The skill just scaffolds.

## Hard rules

- **Don't pre-fill behavior or examples** with guesses. Empty is better than misleading.
- **Don't generate a spec from a vague description without asking**. If the user's request is unclear, ask 1-2 clarifying questions first.
- **Don't promote spec to plan automatically.** That's `/plan`.

## Next step

User edits the spec, then runs `/plan`.
