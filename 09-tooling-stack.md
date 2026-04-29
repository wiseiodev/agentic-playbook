# 09 — Tooling Stack

Agent-side primitives that make the workflow loop work. Defaults: **subagents + hooks + skills + CLIs**. MCP servers only when no CLI exists.

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

Mechanical enforcement that runs without model judgment. Cheap, reliable.

### Three categories

#### Stop-hook: run checks at task end

When the agent stops (or you `/stop`), run:

```bash
pnpm checks
```

If broken, the hook surfaces it. The agent then knows to fix before claiming done.

Definition: see [`hooks/stop-hook-checks.sh`](./hooks/stop-hook-checks.sh).

#### Pre-commit safety: block dangerous git

Block (require explicit confirmation for):

- `git push --force` to any branch
- `git reset --hard`
- `git clean -fd`
- `git branch -D`
- `git checkout .` / `git restore .` for many files
- Commit messages with `--no-verify`

Definition: see [`hooks/pre-commit-safety.sh`](./hooks/pre-commit-safety.sh).

There's a published skill for this — `git-guardrails-claude-code` — recommended over rolling your own.

#### Pre-tool: confirm irrecoverable actions

Hook on `gh pr merge`, `gh pr close`, `gh issue close` to require user confirmation before running.

This is belt-and-suspenders alongside CLAUDE.md's "ask before irrecoverable actions" rule.

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
| `/plan` | Invoke planner subagent against current spec |
| `/implement` | Run implementation phase (after plan approved) |
| `/review` | Run anti-overeng reviewer on current diff |
| `/decompose <prd>` | Run decomposer subagent on a PRD |
| `/bootstrap` | Hand-shape a reference feature (interactive guide) |
| `/worktree <slice>` | Create worktree with naming convention |
| `/cleanup-worktree` | Remove merged worktree + branch |
| `/spec` | Open per-task spec template, prefilled |

Definitions in [`skills/`](./skills/).

### Skill design rules

- **Composable** — `/plan` should work whether or not you used `/spec` first
- **Narrow scope** — one skill, one workflow phase
- **Documented in CLAUDE.md** — point at the skill list so the agent (and you) know what's available
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

Each gets a CLAUDE.md mention so the agent knows it's available and prefers it over MCP equivalents.

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

- Project-specific state — that's CLAUDE.md / ADRs
- In-flight work — that's tasks / plans
- Code patterns — those live in golden examples

Memory ≠ docs. Memory is *what doesn't fit in repos*.

## What NOT to build

Resist:

- A custom dashboard for agent status (a markdown file is enough)
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
