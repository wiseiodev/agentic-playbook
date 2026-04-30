---
name: pr
description: Draft the PR body via the pr-author subagent and open the PR via gh. Use after self-QA + anti-overeng review are clean. Triggers on /pr, "open the PR", "draft the PR body".
---

# /pr

Spawn the **pr-author** subagent to write the PR body, then open the PR via `gh`.

## When to use

- Self-QA (`pnpm checks`) is green.
- Anti-overeng review found zero flags.
- You're ready to push and open the PR.

## Steps

1. Verify CI gates locally:
   ```bash
   pnpm checks
   ```
   If broken, abort. Do not open a PR with red checks.
2. Push the branch:
   ```bash
   git push -u origin HEAD
   ```
3. Spawn the `pr-author` subagent. Pass it:
   - The spec file path
   - The plan file path
   - The reviewer output (or note that it ran clean)
4. Subagent writes `pr-body.md` and outputs the suggested `gh pr create` invocation.
5. Show the suggested command to the user. **Wait for confirmation** before running unless this is being run inside `/work`, where PR creation was authorized by the `/work` invocation.
6. If confirmation is required, wait for it. Then run:
   ```bash
   gh pr create --title "<title>" --body "$(cat pr-body.md)"
   ```
7. Print the PR URL.

## Hard rules

- **Always confirm before opening the PR** unless running inside `/work`. PR creation is externally visible, and `/work` is the pre-authorization path.
- **Don't bypass `pnpm checks`** even if "the user said it was fine."
- **Title under 70 characters.** Body holds the detail.
- **Conventional commit format** for the title (`feat(scope): subject` etc.).

## Next step

User reviews the PR and merges (gate 4). Then `/cleanup-worktree`.
