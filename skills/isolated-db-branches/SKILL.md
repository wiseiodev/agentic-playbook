---
name: isolated-db-branches
description: Set up or operate per-feature Neon database branches for Drizzle projects. Use when schema-changing branches, agents, or worktrees need isolated databases, branch work should use db:push, feature branches must not commit generated migrations, and production migrations should be generated and applied only after merge.
---

# Isolated DB Branches

Install a branch-isolated Drizzle + Neon workflow. The core split is: branch/dev databases use `db:push`; main/release owns `db:generate`, `db:migrate`, and production deploy.

## Inspect First

Read before editing:

- `package.json`, workspace files, lockfile, and package manager pin
- Drizzle config and schema path
- existing migration directory and data-migration conventions
- `.github/workflows/*`
- deployment setup and provider
- repo instruction files such as `AGENTS.md`, `CLAUDE.md`, and README

If the repo does not use Neon or Drizzle, stop and propose only the parts that still apply.

## Setup Steps

1. Detect tools: `gh`, `git`, package manager, `neonctl`, and `tsx`.
2. Gather or discover:
   - `NEON_API_KEY`
   - `NEON_PROJECT_ID`
   - `NEON_PARENT_BRANCH` (default to the actual Neon production branch, often `production` or `main`)
   - schema path
   - migrations directory
   - package or workspace that owns Drizzle
   - deploy provider and command
3. Add scripts from `templates/scripts/` to the repo's DB script directory.
4. Add adapted workflows from `templates/workflows/` to `.github/workflows/`.
5. Update package scripts:
   - `db:branch:create`
   - `db:branch:delete`
   - `db:branch:list`
   - `db:branch:prune`
   - `db:generate` guarded by `guard-generate.ts`
   - `db:generate:ci` unguarded
   - `db:push`
   - `db:migrate`
   - `db:migrate:retry`
   - `db:reset`
   - `db:doctor`
6. Add GitHub secrets with `gh secret set`.
7. Configure branch protection to require `prod-migration-state` after the production migration workflow is active.
8. Update README and repo agent docs with daily commands and hard rules.
9. Verify with `db:doctor`, YAML parsing, and the repo's normal gates.

## Daily Commands

```bash
pnpm db:branch:create
pnpm db:push
pnpm db:reset --soft
pnpm db:reset --hard
pnpm db:branch:list
pnpm db:branch:delete
pnpm db:branch:prune
pnpm db:doctor
pnpm db:migrate:retry
```

Adapt `pnpm` to the repo's actual package manager.

## Workflow Shape

- `db-validate-pr`: on schema-changing PRs, create or reuse a Neon branch named from the PR head ref, then run `db:push`.
- `pr-lint-no-migrations`: fail feature PRs that add generated migration files.
- `db-validate-and-prepare`: on main schema changes, generate migrations against a throwaway prod clone and open an automated migration PR.
- `db-migrate-and-deploy`: after the automated migration PR merges, apply migrations to prod, run data migrations, set `prod-migration-state`, then deploy.
- `code-only-deploy`: deploy main changes that do not include schema or migration changes.
- `cleanup-neon-branch`: delete the Neon branch when a PR closes.

## Hard Rules

- Never run user-facing `db:generate` on feature branches.
- Never commit generated migration files from feature branches.
- Never delete, reset, or push schema directly to the configured parent branch from branch automation.
- Keep deploy provider commands explicit and repo-specific.
- In GitHub Actions, install pnpm with `package_json_file: package.json` and verify it matches `packageManager`.
- For failure handling, read `references/runbook.md`.
