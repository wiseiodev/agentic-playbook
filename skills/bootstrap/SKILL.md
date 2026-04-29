---
name: bootstrap
description: Interactive guide for hand-shaping a reference feature in a greenfield repo. Use on day 1 of a new project to seed canonical patterns before agents take over. Triggers on /bootstrap, "bootstrap a reference feature", "scaffold a canonical pattern".
---

# /bootstrap

Walk the user through hand-shaping a reference feature. The agent acts as a **typing assistant**, not a designer — the user drives every architectural choice.

## When to use

- Greenfield repo, day 1.
- You want to seed 2-3 canonical patterns before letting agents loose.
- See `agentic-playbook/04-greenfield-bootstrap.md` for context.

## Steps

1. Ask the user:
   - Which shape is this reference feature? (read-path, write-path, async, AI-call, integration, auth)
   - What's the simplest concrete instance? (e.g. "list users" for read-path)
   - File path it should live at (e.g. `src/features/users/list.ts`)
2. Walk through code construction interactively:
   - Propose minimal structure (one file, no abstractions, inline helpers).
   - **Do NOT extract anything.** This is deliberately straight-line.
   - **Do NOT add error handling** beyond boundary validation.
   - **Do NOT add config/options** for "future flexibility."
3. Add the canonical header comment:
   ```ts
   /**
    * CANONICAL — <shape> feature.
    * Mimic this file's structure for new <shape> features.
    * Do not introduce abstractions; this is intentionally straight-line.
    */
   ```
4. Add a corresponding test file. Test behavior, not implementation.
5. Run `pnpm checks` to confirm it's clean.
6. Update CLAUDE.md's "Canonical patterns" section:
   ```markdown
   - **<shape> features**: `<path>`
   ```
7. Suggest the user commit (don't auto-commit; user controls commits).

## Hard rules

- **The user drives.** You suggest the simplest path; the user approves or modifies.
- **No abstractions, period.** Even "obvious" helpers — inline them.
- **No defensive code.** Errors propagate to the boundary.
- **No comments explaining what code does.** Names do that.
- **Header comment + CLAUDE.md pointer**, both. Belt + suspenders.

## After bootstrapping 2-3 features

- Recommend the user run a first agent slice (a 4th feature, agent-led) and observe whether it mimics the canonicals.
- If it doesn't, the canonicals or CLAUDE.md pointers need strengthening.

## Anti-patterns to avoid

- **Premature framework**: don't seed router abstractions, DI containers, plugin systems.
- **Premature observability**: don't seed log wrappers, metrics helpers.
- **Premature config**: hard-code values, don't pre-build config layers.
- **Multi-file features**: one file unless parts are genuinely independent.
