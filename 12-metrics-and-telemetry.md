# 12 — Metrics and Telemetry

Measure whether the playbook is earning trust. Keep the first version local, boring, and tied to the audit trail the agent already creates.

Do not start with a dashboard. Start with `/work` sidecars.

## Source of truth

The durable success contract is:

```text
.reports/<work-id>.metrics.json
```

The sidecar lives beside the human-readable report and is created before commit/Ready PR. GitHub or Linear state can enrich it later, but raw agent runtime logs are not the source of truth.

Why:

- The report knows whether the spec, gates, QA, reviews, and waivers actually happened.
- GitHub knows PR review, merge, revert, and follow-up history.
- Runtime telemetry knows tool/cost/session behavior, but not whether the work was the right work.

## Metric families

### Outcome metrics

- **Rework rate**: slices with explicit follow-up rework / merged slices.
- **Revert rate**: merged PRs reverted within the review window / merged PRs.
- **Ready-to-merge rework**: PRs that required implementation changes after Ready PR / Ready PRs.
- **Defect escape notes**: bugs or regressions linked back to a slice.

Do not infer follow-up rework from prose. Use an explicit PR label, issue link, or body footer such as:

```text
Rework-of: #123
```

### Throughput metrics

- Ready PRs per week.
- Slices completed per week.
- Lead time from `/work` start to Ready PR.
- Concurrent active slices, if tracked by the operator.

Throughput only matters when outcome metrics stay healthy.

### Trust-loop metrics

- Spec present.
- Given/When/Then scenario count.
- Scenario coverage status.
- Out-of-scope section present.
- Examples present when data shape matters.
- Files-to-touch present.
- Gates run and pass/fail/waived status.
- QA evidence present.
- Anti-overeng review run.
- Adversarial review run.
- Human waivers recorded.

Waivers are allowed. Agent self-waivers are a trust break.

### Overengineering metrics

- Anti-overeng finding counts.
- Unresolved anti-overeng findings.
- Files changed outside the plan.
- Dependencies added.
- Abstractions added, when the report calls them out.
- Repeated failure shapes across similar tasks.

The goal is not "zero flags forever." The goal is that flags fall upstream over time: from PR review, to anti-overeng review, to plan gate, to spec wording.

### Economics metrics

- Agent runtime.
- Model.
- Start/end time.
- Optional token/cost totals when the runtime exposes them.
- Tool failures or permission blocks when available.

These explain cost and friction. They do not prove quality.

## Sidecar template

Use [templates/work-metrics.template.json](./templates/work-metrics.template.json).

Rules:

- Fill all known fields before commit.
- Use `null`, `[]`, or `"not_available"` for unavailable facts; do not invent values.
- Record only human-approved waivers.
- Backfill `commit_sha`, `ready_pr_at`, and `pr_url` after commit/PR creation.
- Leave `post_merge` fields empty until weekly review or a follow-up workflow updates them.

## Weekly summary

Run:

```bash
scripts/summarize-work-metrics.sh
```

The script reads `.reports/*.metrics.json` and prints a markdown summary. It must work offline from the sidecars alone. A later adapter may enrich the result from `gh`, but that is not required for v1.

Use the summary to ask:

- Did throughput rise without rework rising?
- Which gates are being waived?
- Which anti-overeng flags repeat?
- Which specs failed to constrain behavior?
- Which runtime is expensive or failure-prone for the same slice size?

## Telemetry stance

### Claude Code

Claude Code supports OpenTelemetry for operational data such as sessions, tokens, cost, active time, tool decisions, hooks, commits, PRs, and skill activation.

References: [Claude Code monitoring](https://code.claude.com/docs/en/monitoring-usage), [hooks](https://code.claude.com/docs/en/hooks), and [status line](https://code.claude.com/docs/en/statusline).

Safe default:

- Enable metrics/events only when you need operational visibility.
- Do not enable prompt logging, tool-content logging, or raw API body logging by default.
- Treat OTel as enrichment for cost and tooling behavior, not as the success contract.

### Codex App

Codex App has skills, automations, local session artifacts, hooks config, and shared CLI/app settings. It does not currently expose the same public OpenTelemetry-style contract in the official docs.

References: [Introducing the Codex app](https://openai.com/index/introducing-the-codex-app/) and [Codex settings](https://openai.com/academy/codex-settings/).

Use `/work` metrics sidecars as the stable contract. Treat local Codex session JSONL and hooks as best-effort diagnostics that may change shape.

## What not to build yet

- A dashboard.
- A database.
- A telemetry collector required for normal `/work`.
- A parser that depends on unstable raw session formats for success metrics.
- A scoring formula that hides the underlying evidence.

The first useful version is a stack of JSON receipts plus a weekly markdown table. If those receipts become annoying or useless, fix the workflow before adding infrastructure.
