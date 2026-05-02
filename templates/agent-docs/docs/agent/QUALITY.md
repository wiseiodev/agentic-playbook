# Quality Gates

Use this file for package manager, scripts, CI, and local hook guidance.

## Commands

- Install: `<command>`
- Quality gate: `<command>`
- Typecheck: `<command>`
- Test: `<command>`
- Build: `<command>`
- Format/lint fix: `<command>`

## Preferred Node/TypeScript Setup

If this repo is Node/TypeScript, follow `agentic-playbook/05-quality-gates.md`:

- Pin Node in `.nvmrc`.
- Pin pnpm in `packageManager`.
- Use Biome for lint, format, and import organization.
- Use Vitest for tests.
- Use Turbo only for multi-package repos.
- Use Commitlint and Lefthook when commits should close tracked work.
- CI should verify the pinned pnpm version before installing.

## Gate Rules

- Run the canonical quality gate before claiming done.
- Use non-writing gates in CI.
- Local hooks may auto-fix staged formatting.
- If a gate is unavailable, record it as unavailable.
- If a gate requires secrets or expensive external services, ask before narrowing verification.
