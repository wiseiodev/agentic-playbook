---
name: implement
description: Run implementation phase against an approved plan. Use after /plan has been approved by the human. Triggers on /implement, "implement the plan", "code this up", "execute the plan".
---

# /implement

Implement the slice against the approved plan. The plan was gated; you follow it.

## When to use

- A plan exists (output of `/plan`) and the human approved it.
- A worktree + branch is set up for this slice.
- Self-QA tools are ready (`pnpm checks` or equivalent).

## Steps

1. Re-read the spec, the plan, the canonical example, and AGENTS.md / CLAUDE.md.
2. Implement strictly to the plan:
   - Files in plan's "Files to add/modify" only.
   - Mimic the canonical pattern.
   - No abstractions beyond what the plan justified.
   - No defensive code.
3. Mid-implementation, if you discover the plan is wrong:
   - **Stop.**
   - Summarize the issue.
   - Ask the user. Do not improvise.
4. After code is written, run self-QA:
   ```bash
   pnpm checks
   ```
   Fix any failures and re-run until green.
5. For UI changes, additionally:
   - Open in browser via Playwright skill if available
   - Walk happy path
   - Take screenshot
   - Verify no console errors
6. Once green, hand off to `/review`.

## Hard rules

- **Plan is the contract.** Don't expand scope, don't add files, don't add abstractions not in the plan.
- **No --no-verify** on commits.
- **Don't commit unless asked.** User will instruct.
- **Don't claim "done" without `pnpm checks` green.**
- **If you can't browser-test a UI change**, say so; don't claim it works.

## Next step

`/review` (anti-overengineering review subagent).
