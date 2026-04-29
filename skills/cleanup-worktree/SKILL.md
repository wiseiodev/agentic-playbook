---
name: cleanup-worktree
description: Remove a merged slice's worktree and delete its branch. Run from the main checkout after a PR is merged. Triggers on /cleanup-worktree, "clean up the worktree", "remove the merged worktree".
---

# /cleanup-worktree

Remove the worktree + branch for a slice that has been merged.

## When to use

- A slice's PR has been merged to main.
- You're back in the main checkout (not the worktree itself).

## Steps

1. Identify which worktree to clean up. Ask the user if ambiguous.
   - List existing worktrees: `git worktree list`
2. Verify the branch is merged:
   ```bash
   git fetch origin
   git branch --merged origin/main | grep "<branch-name>"
   ```
   If not merged, **stop** and ask the user. Do not delete unmerged work.
3. Remove the worktree:
   ```bash
   git worktree remove "<path-to-worktree>"
   ```
4. Delete the branch:
   ```bash
   git branch -d "<branch-name>"
   # if -d refuses (claims unmerged), do NOT use -D without explicit user OK
   ```
5. Prune stale remote refs:
   ```bash
   git fetch --prune origin
   ```

## Hard rules

- **Never delete an unmerged branch** without explicit user OK. `-d` (safe) is the default; `-D` (force) is a destructive op.
- **Don't run from inside the worktree** you're trying to remove. Switch to the main checkout first.
- **Don't bulk-delete worktrees**. One at a time, verified each.

## Side benefits

- Frees disk
- Reduces visual clutter in `git worktree list`
- Prevents stale state from confusing future slices
