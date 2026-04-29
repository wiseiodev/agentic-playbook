# 08 — Trust and Verification

Trust the agent enough to run autonomously through the gates; verify enough that bad code doesn't ship. The gates make trust *cheap*.

## Trust hierarchy

Each level requires the level below to be sound.

```
L4 — Merge to main           ← human approval (you, gate 4)
L3 — Anti-overeng review     ← reviewer subagent (gate 3)
L2 — Self-QA (checks green)  ← mechanical (gate 2)
L1 — Plan approved           ← human approval (you, gate 1)
L0 — Spec locked             ← human + decomposer
```

**Don't skip levels to go faster.** Each level catches a different class of failure. Skipping a level pushes that failure class into the next level (or production).

## What each gate catches

| Gate | Catches | Misses |
|---|---|---|
| L0 spec | Vague intent, scope creep, missing constraints | Implementation choices |
| L1 plan | Wrong direction, premature abstraction, files-out-of-scope | Mistakes in actual code |
| L2 self-QA | Type errors, lint, broken tests, runtime crashes (in tests) | Behavior not covered by tests; subtle correctness; UX issues |
| L3 anti-overeng | Premature abstraction, defensive code, scope creep in code | Subtle bugs, design flaws, missed requirements |
| L4 human | Anything the prior gates missed | Whatever escapes your eye |

A single failure mode (say, premature abstraction) gets multiple shots at being caught: spec constraints prevent it, plan-gate catches the planned ones, anti-overeng review catches the slipped ones, you catch the residue.

## Self-QA — what counts as "green"

Mechanical checks the agent must run before claiming done:

```bash
pnpm checks   # canonical: lint + types + tests + format
```

Project-specific equivalents: `npm run validate`, `cargo check && cargo test`, `make ci`.

**Add to CLAUDE.md the exact command** so every agent uses the same one.

For UI changes, add:
- Open in browser via Playwright
- Walk the happy path
- Take a screenshot
- Verify no console errors

The self-QA doesn't have to be all of CI — but it has to be enough that "green" means "won't immediately fail on push."

## Recoverability

You will sometimes ship something bad. The playbook minimizes the cost of recovery:

- **Small slices** = small reverts. `gh pr revert <PR>` undoes one tracer bullet, not a feature.
- **Worktrees** = isolated state. Delete the worktree, reset the slice.
- **No force-push to main** (CLAUDE.md rule). History stays linear.
- **No --no-verify**. Hooks ran for a reason; if they fail, fix the cause.
- **Conventional commits** = readable history. `git revert <sha>` with a clean message.

Recovery cost = revert PR + 5 min retro. Cheap enough that the gates can be permissive on edge cases.

## Permissive vs. strict

Where to be **strict**:

- Anti-overengineering review (premature abstraction is asymmetrically painful)
- Spec scope (out-of-scope items always rejected; queue them)
- Force-push to main (never)
- Skipping hooks (never without your explicit OK)

Where to be **permissive**:

- Code style nits the linter doesn't catch (don't relitigate; ship)
- Test naming (let the agent name; don't bikeshed)
- Comment placement (rarely matters)
- Choice between two equivalent helpers if both meet constraints

Pick your battles. Strictness on the few things that scale; permissiveness on noise.

## Recoverable vs. irrecoverable actions

Agent should run **recoverable** actions freely:

- Edit local files
- Run tests
- Make commits in a feature branch
- Open PRs (they don't ship anything)
- Run read-only CLI calls (`gh pr list`, `gh issue view`)

Agent must **ask before** running irrecoverable actions:

- `git push --force` (any branch)
- `gh pr merge` (lands code)
- `gh issue close` / `gh pr close` (visible to others)
- DB migrations against shared / production
- Posting to Slack / GitHub / external systems
- Deleting branches / worktrees / files outside the slice

Default in CLAUDE.md:

> Never run irrecoverable or externally-visible actions without confirmation. Recoverable, local actions are free.

## Observability — what to log

Even with gates, you'll want to introspect. Useful surfaces:

- **PR descriptions** = the agent's own summary. If they're consistently inaccurate, gate 4 catches drift.
- **Plan files** kept in the spec directory = audit trail of what was approved.
- **Reviewer subagent output** kept as PR comment = record of flags caught.
- **CLAUDE.md changelog** when you tighten constraints = pattern of failures over time.

Don't build dashboards. The above is enough for solo. When team scales, see [10-sharing-with-team](./10-sharing-with-team.md).

## When trust is broken

If a gate fails (overeng reaches main, bug ships, plan-impl drift):

1. **Postmortem in 5 minutes** — what gate should have caught this?
2. **Tighten that gate** — add to checklist, add to constraints, add to spec template
3. **Don't punish the agent** — fix the system

Recurring failures of the same shape = system flaw, not agent flaw. Update the constraints/templates/subagents.

## Anti-patterns

| Anti-pattern | Why it fails |
|---|---|
| Skipping plan gate ("agent knows what to do") | Overeng reaches diff; review burden up |
| Skipping anti-overeng review | Constraints become aspirational, not enforced |
| Auto-merging passing PRs | Gate 4 was your only chance to catch what subagents missed |
| Letting agent --no-verify | Hooks exist for reasons; bypass = invisible debt |
| "It's a small change, skip the gates" | Small changes that break are still broken |
| Adding a 5th gate | Diminishing returns; tighten existing gates instead |
