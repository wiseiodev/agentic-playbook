---
name: review
description: Run anti-overengineering review on the current diff. Invoke after self-QA is green and before opening a PR. Triggers on /review, "review for overengineering", "check the diff for overeng".
---

# /review

Spawn the **anti-overeng-reviewer** subagent against the current diff. Gate 3 of the workflow loop.

## When to use

- Implementation is complete.
- `pnpm checks` is green.
- You haven't opened a PR yet.

## Steps

1. Verify the diff exists:
   ```bash
   git diff origin/main...HEAD
   ```
   If empty, abort — nothing to review.
2. Identify the spec and plan files (from spec dir, or as told by the user).
3. Spawn the `anti-overeng-reviewer` subagent with:
   - The diff (it will run `git diff` itself)
   - The spec file path
   - The plan file path
   - CLAUDE.md
4. Read the reviewer's output.
5. **If flags > 0**: address each flag. Usually means deleting code (inline, remove try/catch, remove abstraction). Re-run `/review` after fixes.
6. **If flags = 0**: hand off to `/pr`.

## Hard rules

- **Don't open a PR with flags > 0**, unless the user explicitly overrides.
- **Don't argue with flags**. The reviewer's job is to flag; if you disagree, ask the user. Don't ignore.
- **Sanctioned exceptions** in the plan are not flags.

## When the reviewer flags something correct-looking

If a flag seems wrong:

1. Check if the plan justified it (it should be in "Sanctioned exceptions" then).
2. If not justified but you believe it's correct, present the disagreement to the user. Don't auto-resolve.

The reviewer is independent for a reason. Take its output seriously.

## Next step

`/pr` to draft the PR body and open the PR.
