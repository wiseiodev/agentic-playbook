# 07 — Parallelization

Target: **2-3 concurrent active slices** as a solo eng. Beyond that, review burden eats throughput. Each slice runs in its own git worktree with its own Claude Code session.

## Why git worktrees

A git worktree is a separate working directory backed by the same repo. Branches are isolated. Files can't collide. You `git worktree remove` to clean up.

```bash
# from the main checkout
git worktree add ../myproject.slice-42 -b feat/slice-42

# now you have two physical directories sharing one .git
# main checkout: ~/dev/myproject
# worktree:      ~/dev/myproject.slice-42
```

**Open one Claude Code session per worktree.** Each session has its own context, its own scrollback, its own task list. No accidental cross-contamination.

## Naming convention

```
~/dev/<project>                       ← main checkout, your default
~/dev/<project>.<slice-id-or-name>    ← worktrees, ephemeral
```

`.` separator is fine; some prefer `-` or directory nesting. Pick one and stick with it. Skill `/worktree` automates creation with the convention.

## Slot model

You hold 2-3 "slots." Each slot is one slice in flight:

| Slot | Status |
|---|---|
| 1 | Implementing |
| 2 | In your gate-4 review |
| 3 | Plan being authored |

The slots cycle. As soon as one merges, the freed slot is filled with the next slice from the decomposed PRD queue.

**Going over 3 slots** for a solo eng:
- Reviews queue up; agents go idle waiting
- Cognitive load on you (which spec is what?) climbs nonlinearly
- The gain is illusory: 4 slots → effective throughput often drops

Default to 2. Push to 3 only when slices are trivial.

## Independence requirement

Slices in concurrent slots **must be independent** — different files, no shared schema/migration, no shared API surface change.

If two slices need the same file, sequence them. The decomposer subagent should flag dependencies; you confirm.

Common dependency patterns:

- Same migration / schema → sequence
- Same shared component → first one merges, second rebases
- Same config / env var → sequence
- Different features in different files → parallel-safe

## Conflict management

Even with independence rules, conflicts happen. Rebase strategy:

```bash
# in worktree, before opening PR
git fetch origin main
git rebase origin/main
# resolve any conflicts
git push --force-with-lease
```

If conflicts are non-trivial, **stop the agent and resolve them yourself**. Agents are bad at multi-way merge intent.

`--force-with-lease` not `--force` — protects against overwriting concurrent pushes.

## Triage discipline

With 2-3 slots, you spend most of your time on:

1. **Spec-editing** for upcoming slices (~30%)
2. **Plan-gate review** (~20%)
3. **PR review** (~30%)
4. **Architecting / writing reference code by hand** (~20%)

If any of these crowd out the others, slot count is wrong or specs are wrong.

Symptoms and fixes:

| Symptom | Cause | Fix |
|---|---|---|
| You're always reviewing PRs, never speccing | Slices too big | Smaller slices |
| Specs sit unfinished | Decomposer not used | Use the decomposer subagent |
| Plans take forever to read | Plan format too verbose | Trim plan template |
| You're queuing 5+ slices waiting on review | Slot count too high | Drop to 2 |

## WIP limits

Hard limit: **3 concurrent slots**. Don't open a 4th worktree even if you "have time."
The cost shows up later: a forgotten worktree, a stale branch, a missed conflict.

## Visibility / dashboard

Keep a 1-line status of each slot somewhere visible:

```
Slot 1 [feat/users-list]    : implementing
Slot 2 [feat/users-create]  : awaiting gate-4 (your review)
Slot 3 [feat/users-update]  : plan drafted, gate-1 pending
```

A `/slots` skill or even a markdown file in `~/dev/agentic-playbook/STATUS.md` works.

## Worktree cleanup

After merge:

```bash
# in main checkout
git worktree remove ../myproject.<slice-id>
git branch -d feat/<slice-id>
git fetch --prune origin
```

Skill `/cleanup-worktree` does this. Run it on every merge — leftover worktrees hide stale state.

## When to NOT parallelize

- Pre-bootstrap: while you're hand-shaping the 2-3 reference features, run sequentially. You're calibrating, not scaling.
- New stack / new pattern: first slice in an unfamiliar shape, run alone. Learn from it.
- High-risk migration: serialize so you can debug each step.
- When tests are flaky: fix the flake first, parallelism amplifies flakes.

## Anti-patterns

| Anti-pattern | Why it fails |
|---|---|
| Single working dir, switch branches | Effectively serial; CLAUDE.md state confused; tests share build artifacts |
| 5+ worktrees | Review backlog, missed conflicts, stale branches |
| Worktrees inside the main checkout | git gets confused, pathing breaks |
| Forgetting `--force-with-lease` | Overwriting collaborator pushes |
| Ignoring stale worktrees | Hidden state, surprising merges weeks later |
