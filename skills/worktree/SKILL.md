---
name: worktree
description: Create a git worktree + branch for a slice using the project naming convention. Use when starting a new slice that should run in parallel with others. Triggers on /worktree, "make a worktree", "new worktree for this slice".
---

# /worktree

Create a git worktree at `../<repo>.<slice-id>` with branch `feat/<slice-id>` (or appropriate type).

## When to use

- You're starting a slice and want parallel-safe isolation.
- You're running 2-3 concurrent slices and need to spawn another.

## Steps

1. Determine the project root (current repo's main checkout).
2. Ask the user (if not provided):
   - Slice ID or short name (e.g. `users-list`)
   - Branch type (`feat`, `fix`, `chore`)
3. Run:
   ```bash
   PROJECT_NAME=$(basename $(git rev-parse --show-toplevel))
   git worktree add "../${PROJECT_NAME}.${SLICE_ID}" -b "${TYPE}/${SLICE_ID}"
   ```
4. Print the absolute path to the new worktree.
5. **Tell the user** to open a new Claude Code session in that worktree (don't try to switch contexts mid-session).

## Hard rules

- **One worktree per slice.** Don't reuse worktrees across slices.
- **Naming convention**: `../<repo>.<slice-id>` with a `.` separator.
- **Don't `cd` into the worktree** in the current session. CLAUDE.md and tool state get confused. Open a fresh session there.
- **Hard cap: 3 concurrent worktrees.** If 3 already exist, push back and ask the user to merge or abandon one first.

## Cleanup

After the slice merges, run `/cleanup-worktree` from the main checkout.
