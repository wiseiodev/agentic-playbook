# 06 — Tooling Stack

Agent-side primitives that make the workflow loop work. Defaults: **skills + subagents + hooks + CLIs**. MCP servers only when no CLI exists.

This is curated from the local setup that has actually paid rent. Do not bundle every personal setting into every repo. Extract the pattern, then let each project tune it.

## Why CLIs over MCP

- CLIs are simpler to debug (`gh pr view 123` shows you what happened)
- CLIs are portable (any Claude Code project can use `gh`)
- MCP servers add a process to manage and a contract to maintain
- Most external systems have first-class CLIs already (gh, linear, vercel, stripe, npm, etc.)

Only reach for MCP when:

- The CLI doesn't exist (rare)
- The CLI exists but lacks the capability (e.g., browser automation needs MCP for live page state)
- The CLI is so awkward to script that the friction outweighs the MCP cost

For everything else: bash + CLI.

## Subagents

Specialized agents the main agent invokes for specific phases. Each has a tight role and a short system prompt.

### The four core subagents

| Subagent | Role | When invoked | File |
|---|---|---|---|
| **Decomposer** | PRD → ordered slice specs | After PRD lands | [`subagents/decomposer.md`](./subagents/decomposer.md) |
| **Planner** | Spec → impl plan | After spec locked | [`subagents/planner.md`](./subagents/planner.md) |
| **Anti-overeng reviewer** | Diff → flag list | After self-QA green | [`subagents/anti-overeng-reviewer.md`](./subagents/anti-overeng-reviewer.md) |
| **PR author** | Diff + spec + plan → PR body | Before opening PR | [`subagents/pr-author.md`](./subagents/pr-author.md) |

### Why subagents (not the main agent doing everything)

- **Isolated context** — reviewer doesn't see the implementer's reasoning, only the diff. Independent eye.
- **Tight role** — short system prompt, less drift, more reliable behavior.
- **Composable** — reuse across slices, projects, teams.
- **Auditable** — subagent output is small and reviewable.

### Subagent design rules

- **One concern per subagent.** Don't merge planner + reviewer.
- **Short prompt.** <100 lines. Long prompts dilute focus.
- **Explicit output shape.** Reviewer outputs a list of flags; planner outputs a markdown plan; etc.
- **No tools they don't need.** Reviewer needs Read + Bash (for `git diff`); not Write.

## Hooks

Mechanical enforcement that runs without model judgment. Cheap, reliable, and intentionally narrow.

Hooks block danger. They do not enforce taste. Overengineering is handled by specs, golden examples, anti-overeng review, adversarial review, and human review.

### Four categories

#### Stop-hook: run checks at task end

When the agent stops (or you `/stop`), run:

```bash
pnpm checks
```

If broken, the hook surfaces it. The agent then knows to fix before claiming done.

Definition: see [`hooks/stop-hook-checks.sh`](./hooks/stop-hook-checks.sh).

#### Dangerous-command guard: block irreversible actions

Block or require explicit confirmation for:

- `git reset --hard`
- `git clean -fd`
- `git branch -D`
- `git checkout .` / `git restore .` for many files
- `git push --force`
- `--no-verify`
- database reset/drop/truncate commands
- write SQL against shared databases
- `gh pr merge`, `gh pr close`, `gh issue close`

Definition: see [`hooks/block-dangerous-commands.sh`](./hooks/block-dangerous-commands.sh).

Tune this per repo. A throwaway local database can allow more than a production-connected project. The important invariant is that agents do not run destructive or externally visible operations by accident.

#### Pre-tool: confirm irrecoverable actions

Hook on `gh pr merge`, `gh pr close`, `gh issue close` to require user confirmation before running.

This is belt-and-suspenders alongside AGENTS.md / CLAUDE.md's "ask before irrecoverable actions" rule.

#### Status / notification hooks

Optional hooks can show context usage, cost, or notify you when an agent stops. Keep these personal and lightweight. They are useful for operator awareness, not required for the playbook contract.

Hooks may append raw event logs for later diagnosis, but the playbook's success metrics do not depend on raw hook logs. The durable contract is the `/work` report sidecar.

### Hook anti-patterns

- Hooks that run for >30s — break flow, destroy `pnpm checks` cache benefits
- Hooks that auto-amend commits silently
- Hooks that auto-fix code (the agent should self-correct via reviewer subagent, not invisibly)
- Hooks that block non-dangerous actions (frustration → users disable hooks)

## Skills

Slash commands that bundle a workflow. Loaded on demand.

### Core skills for the playbook

| Skill | What it does |
|---|---|
| `/linearize` | Turn an idea into a Linear Project-as-PRD and approved issue queue |
| `/work` | Execute one scoped implementation slice end-to-end with full ceremony |
| `/setup-quality` | Add or tighten preferred quality-gate tooling in a repo |
| `/isolated-db-branches` | Add per-feature Neon DB branches for parallel Drizzle schema work |
| `/plan` | Invoke planner subagent against current spec |
| `/implement` | Run implementation phase (after plan approved) |
| `/review` | Run anti-overeng reviewer on current diff |
| `/pr` | Draft or open a PR after gates and report are ready |
| `/decompose <prd>` | Run decomposer subagent on a PRD |
| `/bootstrap` | Hand-shape a reference feature (interactive guide) |
| `/worktree <slice>` | Create worktree with naming convention |
| `/cleanup-worktree` | Remove merged worktree + branch |
| `/spec` | Open per-task spec template, prefilled |

Definitions and install commands are in [`skills/`](./skills/) and [`skills/README.md`](./skills/README.md).

`/work` is the operational core. It authorizes branch, commit, push, and Ready PR after gates pass. The other skills remain composable building blocks when you want to run a phase manually.

`/setup-quality` is the tooling setup path. Use it during day-1 bootstrap or when a repo's gates are inconsistent. It inspects the repo before editing, then adapts the preferred Biome, Vitest, Commitlint, Lefthook, pnpm, Turbo, and CI patterns from [05-quality-gates](./05-quality-gates.md).

`/isolated-db-branches` is the database isolation path for Drizzle + Neon repos where parallel branches would otherwise fight over generated migration files. See [11-isolated-db-branches](./11-isolated-db-branches.md).

Install a skill with:

```bash
npx skills add wiseiodev/agentic-playbook/skills/<skill>
```

### Skill source of truth

Keep user-level skills in one source directory, then expose them to each agent runtime with symlinks or explicit installation. On this machine, the durable pattern is:

```text
~/.agents/skills        # source of truth
~/.claude/skills        # symlinks into ~/.agents/skills
```

Avoid duplicate copies. Duplicates drift, and agents end up following stale workflow text.

### Skill design rules

- **Composable** — `/plan` should work whether or not you used `/spec` first
- **Narrow scope** — one skill, one workflow phase
- **Documented in AGENTS.md / CLAUDE.md** — point at the skill list so the agent (and you) know what's available
- **Keyboard-accessible** — short names, no special chars

## CLIs the playbook depends on

Install on Monday alongside everything else:

| CLI | Why | Notes |
|---|---|---|
| `gh` (GitHub) | PR creation, review, merge | Primary git-ops surface |
| `pnpm` (or your equivalent) | `pnpm checks` etc. | Match the project's package manager |
| `linear` (if Linear) | Issue lookup, status update | See `linear-cli` skill |
| `vercel` (if Vercel) | Deploy + logs | See `vercel-cli` skill |
| `psql` / DB CLI | Schema introspection | For agents to verify migrations |

Each gets an AGENTS.md / CLAUDE.md mention so the agent knows it's available and prefers it over MCP equivalents.

## Quality-gate stack

For Node/TypeScript projects, the preferred local stack is:

- Node pinned in `.nvmrc`
- pnpm pinned in `packageManager`
- Biome for lint, format, and import organization
- Vitest for tests
- Turbo for monorepo orchestration only when it earns its keep
- Commitlint for conventional commits plus issue-closing footers
- Lefthook for pre-commit, commit-msg, and pre-push checks
- GitHub Actions that verify the pinned pnpm version before installing

The templates live in [`templates/quality/`](./templates/quality/), and the full guidance lives in [05-quality-gates](./05-quality-gates.md).

Keep this repo-adaptive. A Rust, Python, or Bun repo should still expose one obvious quality command, but it should use its own formatter, typechecker, test runner, and package manager.

## Metrics and telemetry

V1 metrics are local files, not a dashboard.

Every `/work` slice writes:

```text
.reports/<work-id>.metrics.json
```

Then [`scripts/summarize-work-metrics.sh`](./scripts/summarize-work-metrics.sh) turns those sidecars into a weekly markdown readout. This keeps the truth source close to the work: spec coverage, gates, QA evidence, review findings, waivers, commit, and PR.

### Runtime telemetry stance

Claude Code has first-class OpenTelemetry support for operational data such as sessions, cost, tokens, tool decisions, skill activation, hook execution, commits, and PRs. Use it as optional enrichment. Safe default: enable metrics/events only, and do not enable prompt, tool-content, or raw API body logging unless you intentionally want that data exported.

Codex App does not currently have an equivalent public OpenTelemetry-style contract in the official docs. Treat local Codex session JSONL and hook data as best-effort diagnostics. Do not make success metrics depend on those formats.

The split is intentional:

- **Outcome truth**: `/work` metrics sidecars + GitHub/Linear state.
- **Operational detail**: Claude OTel, Codex session logs, hooks, status lines.
- **Human judgment**: explicit review findings, labels, and waivers.

## Question tool

When an agent needs user input, it must use the question tool if the environment provides one. This applies to clarifications, tradeoffs, confirmations, destructive-action approvals, and scope decisions.

Plain prose is fine for status updates. Decisions should be structured and captured.

If no question tool exists, ask directly and record the answer in the spec, plan, issue, or report before proceeding.

## Local settings

Use settings files to encode capability and safety, not product taste.

Good candidates:

- Default reasoning/model preference
- Trusted project roots
- Enabled plugins/connectors
- PreToolUse dangerous-command hooks
- Statusline or notification hooks
- Project-specific command denies, such as blocking known-bad test invocations

Bad candidates:

- Long product context
- Temporary implementation plans
- Generic coding style that belongs in repo instructions
- Overengineering taste rules that need human/context judgment

Settings are examples, not a portable bundle. Copy the pattern, not the whole machine.

## When to add an MCP server

Decision rule:

```
Is there a CLI that does the job?
├── Yes → use the CLI. Stop.
└── No → consider MCP.
       Is the capability essential to this project?
       ├── Yes → add MCP, document its role
       └── No → skip; reassess later
```

Real cases where MCP earns its place:

- **Browser automation** (live page state, no equivalent CLI for interactive flows)
- **Internal tools** (your company's bespoke API, no CLI exists)
- **High-frequency external calls** (CLI process spawn cost matters)

Otherwise, bash + CLI.

## Memory system

Claude Code's auto memory is on by default. Use it for:

- Cross-session **feedback** ("user prefers X over Y")
- Cross-session **user profile** (role, expertise, preferences)
- Cross-session **references** (where docs live, where alerts fire)

Don't use it for:

- Project-specific state — that's AGENTS.md / ADRs
- In-flight work — that's tasks / plans
- Code patterns — those live in golden examples

Memory ≠ docs. Memory is *what doesn't fit in repos*.

## What NOT to build

Resist:

- A custom dashboard for agent status (a markdown file is enough)
- A telemetry collector before local metrics prove useful
- A custom CLI wrapping `gh` (use `gh` directly)
- A "framework" for skills (skills are markdown; YAGNI)
- A bespoke MCP server before exhausting CLIs
- A homegrown scheduler (use `/loop` or external cron if needed)

The playbook itself is small infrastructure. Most of the leverage is in **discipline**, not tooling.

## Stack summary

```
┌──────────────────────────────────────────────────────┐
│  Skills        — composable slash workflows          │
│  Subagents     — isolated specialized agents         │
│  Hooks         — mechanical enforcement              │
│  CLIs          — gh, pnpm, linear, vercel, ...       │
│  MCP (sparingly)  — only when no CLI exists          │
│  Memory        — cross-session prefs / feedback      │
└──────────────────────────────────────────────────────┘
```
