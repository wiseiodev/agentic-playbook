---
name: setup-quality
description: Set up or tighten a repo's preferred quality-gate toolchain. Use when the user invokes /setup-quality, asks to add Biome, Vitest, Commitlint, Lefthook, pnpm scripts, Turbo quality gates, GitHub Actions CI, or wants the preferred quality setup applied to a project.
---

# /setup-quality

Set up the repo's quality gates in the smallest conventional shape. Preserve existing conventions first; apply the playbook defaults only where the repo is missing a decision.

Reference: `agentic-playbook/13-quality-gates.md`. Templates live in `agentic-playbook/templates/quality/`.

## 1. Inspect first

Read before editing:

- `package.json`, `.nvmrc`, `pnpm-workspace.yaml`, lockfile
- `biome.json` / `biome.jsonc`
- `vitest.config.*` / `vitest.workspace.*`
- `turbo.json`
- `commitlint.config.*`
- `lefthook.yml` / `lefthook.yaml`
- `.github/workflows/*`
- `CLAUDE.md`, `AGENTS.md`, README, Makefile, or equivalent repo instructions

If the repo is not Node/TypeScript, keep the same workflow shape but use the repo's actual formatter, typechecker, test runner, and package manager.

## 2. Decide the shape

Use the question tool for choices that are not discoverable:

- Single repo vs monorepo if the file layout is ambiguous.
- Whether Commitlint should require Linear/GitHub magic-word footers.
- Whether Lefthook should be installed locally.
- Whether CI should include DB services, migrations, browser setup, or E2E.
- Whether an existing nonstandard script name should be preserved.

Default choices when the repo is Node/TypeScript:

- pnpm pinned in `packageManager`.
- Node pinned in `.nvmrc`.
- Biome for lint/format/import organization.
- Vitest for unit/integration tests.
- Turbo only for multi-package repos.
- Commitlint and Lefthook when the repo uses issue-linked commits.
- GitHub Actions runs non-writing gates.

## 3. Apply the minimum setup

Prefer adapting existing files over replacing them.

For a single-package repo, converge on:

```json
{
  "scripts": {
    "lint": "biome check .",
    "lint:fix": "biome check --write .",
    "format": "biome format --write .",
    "typecheck": "tsc --noEmit",
    "test": "vitest run",
    "build": "<framework build>",
    "checks": "pnpm lint && pnpm typecheck && pnpm test && pnpm build",
    "checks:fix": "pnpm lint:fix && pnpm typecheck && pnpm test && pnpm build"
  }
}
```

For a Turbo monorepo:

- Root Biome runs once.
- Root `check` or `checks` runs root Biome plus Turbo package gates.
- Package `check` scripts do not repeat root lint.
- `dev` can use `turbo run dev --ui tui` when Turbo supports it.

## 4. Preferred files

Use these templates as starting points:

- Biome: `templates/quality/biome.node-react.jsonc`
- Vitest Node: `templates/quality/vitest.node.config.ts`
- Vitest React: `templates/quality/vitest.react.config.ts`
- Commitlint: `templates/quality/commitlint.config.cjs`
- Lefthook: `templates/quality/lefthook.yml`
- GitHub Actions: `templates/quality/github-actions-pnpm-ci.yml`

Tune includes, aliases, setup files, package names, and build commands to the repo. Do not copy generated folders, personal paths, or one repo's unrelated dependencies.

## 5. Verify

Run the repo's non-writing gate set. For Node/pnpm repos, usually:

```bash
pnpm install --frozen-lockfile
pnpm lint
pnpm typecheck
pnpm test
pnpm build
```

Also run whichever checks match the files changed:

- `pnpm checks` or `pnpm check` when present.
- `pnpm exec commitlint --edit <message-file>` with a temporary valid and invalid message when adding Commitlint.
- `lefthook run pre-commit --all-files` only if the repo already supports it without surprising side effects.
- CI YAML parse check when adding workflow files.

If a gate is unavailable, record it as unavailable. If a gate is too expensive or requires secrets/services, use the question tool before narrowing verification.

## Hard rules

- Do not change package managers unless the human explicitly asks.
- Do not add E2E, DB services, or browser setup to CI unless the repo already has those tests or the human asks.
- Do not add hooks that block normal non-dangerous work.
- Do not bypass hooks with `--no-verify`.
- Do not add a custom installer framework.
- Keep repo instruction docs updated with the canonical quality command.
