# 01 — Workflow Loop

The default path for agent-owned implementation is `/work`: one scoped work item, full ceremony, Ready PR. The lower-level skills still exist, but `/work` is the operating contract when you want an agent to carry the slice end-to-end.

## Default loop

```
Idea / PRD / issue / approved plan
  ↓
/linearize <idea> (when Linear Project + issues do not exist yet)
  ↓
/work <one work item>
  ↓
Intake: source docs, blockers, dependencies, acceptance criteria
  ↓
Spec: Given/When/Then + scope + constraints + files-to-touch
  ↓
Branch / worktree isolation
  ↓
Plan gate: human approves direction
  ↓
Implementation
  ↓
Self-QA: repo gates + behavior evidence
  ↓
Anti-overeng review
  ↓
Adversarial review
  ↓
Report: what shipped, gates, evidence, remaining risk
  ↓
Metrics sidecar: local JSON receipt
  ↓
Commit + push + Ready PR
  ↓
Human review and merge
  ↓
Cleanup
```

Invoking `/work` is explicit authorization for the agent to branch, commit, push, and open a Ready PR after the required gates pass. It is not authorization to merge, close issues, run destructive infrastructure commands, force-push, bypass hooks, or expand scope.

Humans can waive gates. Agents cannot self-waive.

## Lower-level commands

Use the smaller skills when you want to stay in control of a phase:

| Skill | Use when |
|---|---|
| `/linearize` | Turn an idea into a Linear Project-as-PRD and approved issue queue |
| `/decompose` | Turn a PRD into ordered tracer-bullet specs |
| `/spec` | Create or polish one per-task spec |
| `/plan` | Produce an implementation plan for human approval |
| `/implement` | Code against an already-approved plan |
| `/review` | Run the anti-overengineering review |
| `/pr` | Draft/open a PR after gates are clean |
| `/worktree` | Create isolated worktree/branch for a slice |
| `/cleanup-worktree` | Remove merged worktree and branch |

The lower-level skills remain conservative. For example, `/pr` may ask before opening a PR; `/work` already has that authorization because the command itself is the contract.

## Phase details

### Phase 0 — Source of work

Input can be a PRD, GitHub issue, Linear issue, approved plan phase, or a directly stated one-slice task. If the input is still only an idea and the work should live in Linear, run `/linearize` first to create the Project and issue queue.

The agent extracts:

- Work id and title
- Acceptance criteria
- Scope boundaries and sibling work to avoid
- Dependencies and blockers
- Repo conventions, commands, ADRs, and canonical examples

If the source is ambiguous, the agent uses the question tool. If the answer is discoverable from files, issues, or repo conventions, the agent explores instead of asking.

### Phase 1 — Spec

Every non-trivial slice gets a spec using [03-spec-format](./03-spec-format.md).

The behavior section is mandatory:

```markdown
## Behavior (Given/When/Then)
- **Scenario: happy path**
  **Given** ..., **when** ..., **then** ...
```

This is planning language, not a requirement to install Cucumber. The goal is to constrain observable behavior before implementation starts.

### Phase 2 — Branch / worktree

Use isolated branch state for agent-owned work.

For normal feature work:

```bash
git worktree add ../myproject.<slice-id> -b feat/<slice-id>
```

For Linear work, use the canonical Linear branch name when available:

```bash
linear issues branch <ISSUE-ID> --json
```

Do not reuse a worktree across slices. Do not work from dirty state unless the user explicitly decides how to handle it.

### Phase 3 — Plan gate

The plan must name:

- Files to add or modify
- Canonical example being mimicked
- What the slice will not do
- Any abstraction introduced and why it is needed now
- Risks and verification steps

The human approves the plan or pushes back. If the agent later discovers the plan is wrong, it stops and uses the question tool rather than improvising.

### Phase 4 — Implement

Implementation follows the approved plan and the spec.

Hard boundaries:

- No sibling issues or phases
- No files outside the plan/spec unless the user approves
- No new abstractions unless sanctioned by the plan
- No defensive code for impossible internal cases
- No hook bypasses

### Phase 5 — Self-QA

Run the repo's actual quality gates. Discover them from package scripts, task runners, README, AGENTS/CLAUDE guidance, CI, or Makefiles. Do not hard-code `pnpm checks` into a repo that uses another gate.

Required categories when available:

- Format/lint
- Typecheck/compile
- Unit tests
- Integration tests when touched code crosses module boundaries
- Build
- E2E/browser checks when UI behavior changed

For UI work, capture behavior evidence: browser check, screenshot, recording, or a concise fallback proof when recording is not useful.

### Phase 6 — Anti-overeng review

The anti-overeng reviewer reads the diff, spec, plan, and constraints. It only flags overengineering:

- Premature abstractions
- Defensive code without a real failure mode
- Scope creep
- New files or dependencies not approved
- Custom wrappers around framework primitives
- Implementation-detail tests

Zero unresolved flags before PR unless the human explicitly overrides.

### Phase 7 — Adversarial review

Run adversarial review on the intended diff before commit when using `/work`.

Resolve every critical and major finding. Minor/nitpick findings may remain only if recorded in the report.

This is separate from anti-overeng review: anti-overeng protects simplicity; adversarial review protects correctness, security, and design misses.

### Phase 8 — Report

The report is the agent's human-readable audit trail. Keep it concise, but include:

- Work id/title
- What shipped
- Dependencies found during intake
- Files changed or diff stat
- Tests and gates run
- Self-QA evidence
- Anti-overeng review result
- Adversarial review result
- Acceptance criteria status
- Commit SHA once committed

Use an existing repo report template if present. Otherwise create a small `.reports/<work-id>.html` or `.reports/<work-id>.md` with the same sections.

Create the machine-readable metrics sidecar beside the report:

```text
.reports/<work-id>.metrics.json
```

Use [templates/work-metrics.template.json](./templates/work-metrics.template.json). The sidecar records the same facts in a stable shape: spec coverage, planned vs changed files, gates, QA evidence, review findings, waivers, commit, and PR URL when available. It is the source for local weekly summaries; raw agent logs are optional enrichment, not the contract.

### Phase 9 — Commit, push, Ready PR

Only after gates, self-QA, anti-overeng review, adversarial review, report, and metrics sidecar are complete:

1. Stage the exact intended files.
2. Commit once with a conventional message and appropriate issue footer.
3. Push the branch.
4. Open a Ready PR whose body mirrors the report.
5. Backfill `commit_sha`, `ready_pr_at`, and `pr_url` in the metrics sidecar if they were not known before commit/PR creation.

Do not merge. Human review remains the final gate.

## When to use less ceremony

The agent does not decide to skip gates. The human can waive them.

Reasonable human waivers:

- Typo or wording-only docs edit
- One-line config fix with no runtime behavior
- Read-only investigation
- Throwaway spike that will not be merged
- Emergency hotfix where the human explicitly accepts a narrower gate

If a waiver is given, record it in the handoff or report. Also record it in the metrics sidecar. Agents may record human waivers; they may not create waivers for themselves.

## Failure modes of the loop

| Failure | Symptom | Fix |
|---|---|---|
| Spec too loose | Correct-looking code solves the wrong thing | Add Given/When/Then scenarios and out-of-scope |
| Plan gate too lenient | Overeng reaches diff | Require files, examples, non-goals, abstractions |
| Self-QA weak | Bugs reach PR review | Strengthen repo gates or add targeted QA evidence |
| Anti-overeng misses | You catch cleverness in review | Add the pattern to the reviewer checklist |
| Adversarial review skipped | Correctness issues survive | Keep `/work` strict; only human can waive |
| Agent self-waives | "Small change" bypasses contract | Treat as trust break; update skill/hook instructions |
| Metrics missing | Weekly readout becomes vibes | Require `.reports/<work-id>.metrics.json` before Ready PR |
