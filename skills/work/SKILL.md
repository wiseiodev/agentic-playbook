---
name: work
description: Execute one scoped implementation slice end-to-end with the playbook's full trust loop. Use when the user invokes /work, asks to complete a Linear or GitHub work item, asks to implement one approved plan phase, or explicitly wants an agent-owned implementation slice. The command authorizes branch, implementation, gates, self-QA evidence, anti-overeng review, adversarial review, report, metrics sidecar, commit, push, and a Ready PR after all required gates pass.
---

# /work

Execute exactly one work item end-to-end. This is the playbook's default operating loop for agent-owned implementation.

Invoking `/work` is explicit authorization to create a branch, commit, push, and open a Ready PR after the required gates pass. It is not authorization to merge, close issues, force-push, bypass hooks, run destructive database or infrastructure commands, or expand scope.

Humans can waive gates. Agents cannot self-waive.

## Usage

```text
/work <prd-file> <plan-file> <phase>
/work <github-prd-issue> [<github-work-issue>]
/work <linear-issue>
/work <one-slice task description>
```

## 1. Resolve the work item

Classify the input before editing:

- **Plan phase**: read the PRD and plan, locate the exact phase, and execute only that phase.
- **GitHub issue**: read the PRD/work issue, comments, labels, linked issues, and blockers.
- **Linear issue**: read the issue, project/docs, comments, sibling issues, and blockers.
- **Direct task**: turn the request into one scoped slice; use the question tool if scope is ambiguous.

Extract:

- Work id and title
- Acceptance criteria
- Given/When/Then behaviors, or the facts needed to write them
- Scope boundaries and sibling work to avoid
- Blockers and external dependencies
- Repo instructions, ADRs, canonical examples, and quality gates

If a fact is discoverable from repo files or issue systems, discover it. If a decision needs the user, use the question tool.

## 2. Intake and branch

Before file edits:

1. Check `git status --porcelain`.
2. Stop if dirty state could be overwritten or confused with this work.
3. Create an isolated branch or worktree using repo convention.
4. For Linear work, use `linear issues branch <ISSUE-ID> --json` when available.
5. Report the branch/worktree path before implementation.

Work only on the resolved item. Do not start sibling phases or sibling issues.

## 3. Spec and plan

Ensure the slice has a spec with:

- Intent
- In scope
- Out of scope
- Behavior (Given/When/Then)
- Examples when data shape matters
- Constraints
- Files to touch
- Done criteria

Produce or confirm an implementation plan before coding. The plan must name:

- Files to add/modify
- Canonical example being mimicked
- What this slice will not do
- Any abstraction introduced and why it is required now
- Verification steps

If the plan needs more files, behavior, or abstraction than the spec permits, use the question tool before proceeding.

## 4. Implement

Follow the approved plan.

Rules:

- No files outside the spec/plan unless the user approves.
- No new abstractions unless justified by 3+ current callers, framework requirement, or explicit spec ask.
- No defensive code for impossible internal cases.
- No new dependencies unless approved.
- No hook bypasses.
- No sibling work.

If new evidence proves the plan wrong, stop and ask.

## 5. Quality gates

Discover repo-appropriate gates from package scripts, task runners, CI, README, AGENTS/CLAUDE files, and Makefiles.

Run all applicable gates with zero errors and zero warnings:

- Format/lint
- Typecheck/compile
- Unit tests
- Integration tests when touched code crosses module boundaries
- Build
- E2E/browser checks when UI behavior changed

Do not hard-code `pnpm checks` into repos that use another command. If a gate does not exist, record it as "not available." If a gate is too expensive for the current work, use the question tool before narrowing it.

## 6. Self-QA evidence

Create deterministic proof that the behavior works.

For UI/browser work, use the repo's browser test or Playwright pattern when available. Capture a screenshot, trace, recording, or concise notes that prove the visible behavior.

For non-UI work, create a fallback evidence note in `.reports/<work-id>-qa.md` or the repo's equivalent. Include commands, outputs, test names, DB snapshots, curl transcripts, or other concrete proof.

Evidence must map back to the Given/When/Then scenarios.

## 7. Anti-overeng review

Run `/review` or the anti-overeng reviewer on the diff.

Resolve every real flag before PR:

- Premature abstraction
- Defensive code without a documented failure mode
- Scope creep
- Unapproved files/dependencies/config
- Implementation-detail tests
- Custom wrappers around framework primitives

If you disagree with a flag and the spec/plan did not sanction it, use the question tool.

## 8. Adversarial review

Run adversarial review on the intended diff before commit.

Resolve all `critical` and `major` findings. Record remaining `minor` and `nitpick` findings in the report.

If review fixes change the diff, rerun affected gates and review as needed.

## 9. Report and metrics sidecar

Create a concise report in the repo's expected report location. If none exists, use `.reports/<work-id>.html` or `.reports/<work-id>.md`.

Include:

- Work id/title
- What shipped
- Dependencies discovered during intake
- Files changed or diff stat
- Gates run and status
- Self-QA evidence
- Anti-overeng result
- Adversarial review result
- Acceptance criteria status
- Commit SHA after commit

Also create `.reports/<work-id>.metrics.json` from `templates/work-metrics.template.json` before committing.

The sidecar is mandatory for `/work`. Fill every field that is known before commit/PR creation:

- Work id/title, repo, branch, runtime, model
- `started_at`
- Spec coverage counts and booleans
- Planned files, changed files, additions, deletions, dependencies added
- Gate command/status rows
- QA evidence type/path and scenario coverage status
- Anti-overeng and adversarial review statuses/finding counts
- Human-approved waivers only

Leave `commit_sha`, `ready_pr_at`, `pr_url`, and `post_merge` fields null/empty until those facts exist. After commit and PR creation, backfill `commit_sha`, `ready_pr_at`, and `pr_url`.

## 10. Commit, push, Ready PR

Only after gates, QA evidence, reviews, report, and metrics sidecar are complete:

1. Stage only the intended files with explicit paths.
2. Confirm staged diff is scoped to this work item.
3. Create one conventional commit without `--no-verify`.
4. Push the branch.
5. Open a Ready PR whose body mirrors the report.
6. Backfill the metrics sidecar with commit and PR facts if needed.

Never merge the PR. Human review and merge remain the final gate.

## Hard rules

- One work item only.
- `/work` authorizes branch, commit, push, and Ready PR; it does not authorize merge.
- Metrics sidecar creation is mandatory and cannot be self-waived.
- Never force-push.
- Never bypass hooks.
- Never run destructive database, infrastructure, or external-system commands unless the user explicitly approves.
- Never close GitHub or Linear issues unless the user explicitly asks.
- Never mark a Linear issue Done; use the repo's review-equivalent state when appropriate.
- Use the question tool for user input.
- Stop on blockers, dirty state, missing dependencies, out-of-scope failing gates, push failures, or review findings that cannot be resolved within scope.
