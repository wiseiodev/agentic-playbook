# <PROJECT NAME>

<One sentence: what this repo is, who it serves, and the kind of work it contains.>

This repo uses <pnpm workspaces | pnpm | npm | bun | other>.

## Commands

- Install: `<command>`
- Dev: `<command>`
- Quality gate: `<command>` (run before claiming done)
- Typecheck: `<command>`
- Test: `<command>`
- Build: `<command>`

## Start Here

- Workflow: [docs/agent/WORKFLOW.md](docs/agent/WORKFLOW.md)
- Quality gates: [docs/agent/QUALITY.md](docs/agent/QUALITY.md)
- Architecture and domain: [docs/agent/ARCHITECTURE.md](docs/agent/ARCHITECTURE.md)
- Testing: [docs/agent/TESTING.md](docs/agent/TESTING.md)
- Git and review: [docs/agent/GIT.md](docs/agent/GIT.md)
- Anti-overengineering: [docs/agent/ANTI_OVERENGINEERING.md](docs/agent/ANTI_OVERENGINEERING.md)

## Universal Rules

- Read the task source, repo instructions, and relevant linked docs before editing.
- Use the question tool for user decisions when available.
- Do not run destructive, irreversible, or externally visible actions without explicit approval.
- Do not bypass hooks with `--no-verify`.
