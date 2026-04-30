# Git And Review

Use this file for git, PR, review, and externally visible action rules.

## Branches And Worktrees

- Use isolated branch/worktree state for agent-owned work.
- Do not reuse a worktree across unrelated slices.
- Stop if dirty state could be overwritten or confused with the current task.

## Commits

- Use conventional commits.
- Include the required issue footer when the repo enforces one, for example `Completes ABC-123`.
- Do not stage or commit unless the user asked for it or `/work` authorizes it.
- Never use `--no-verify`.

## Pull Requests

`/work` authorizes pushing the scoped branch and opening a Ready PR after gates, QA evidence, reviews, report, and metrics sidecar are complete.

It does not authorize merging.

## Confirm First

Ask before:

- `git push --force`
- `gh pr merge`
- `gh pr close` / `gh issue close`
- DB migrations against shared or production environments
- Posting to external systems
- Deleting branches, worktrees, or files outside the slice
