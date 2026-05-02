# 11 — Isolated DB Branches

Use this pattern when parallel agents or worktrees need to change a Drizzle schema without fighting over numbered migration files.

The rule is simple:

- Feature branches get their own Neon database branch.
- Feature branches push schema with `drizzle-kit push`.
- Feature branches do not generate or commit migration files.
- Main owns migration generation, production migration, and deployment.

This keeps development fast and parallel while preserving a real migration history for production.

## When To Use

Use isolated DB branches when the repo has most of these traits:

- Neon Postgres
- Drizzle ORM
- GitHub Actions
- A deploy pipeline that can be gated on database migration success
- Multiple agents, humans, or worktrees changing schema in parallel

Do not install this pattern blindly. If the repo has one developer, rare schema changes, or a non-Neon database, copy only the branch/dev vs main/release split that applies.

## Branch Workflow

At the start of work on a feature branch:

```bash
pnpm db:branch:create
```

That command should:

- Read the current git branch.
- Refuse to operate on the configured parent branch.
- Create or reuse a Neon branch with the same name.
- Write the branch connection string to the repo's local env file.

After editing the Drizzle schema:

```bash
pnpm db:push
```

Agents should not run `db:generate` or `db:migrate` on feature branches. A guard script should block user-facing `db:generate` unless the current git branch is the configured parent branch.

## Pull Request Gates

Use two PR checks:

- **Schema validation**: create or reuse the Neon branch for the PR head ref, then run `db:push` against it.
- **Migration lint**: fail if the PR adds generated migration files. Allow hand-authored data migrations only in the repo's chosen data-migration folder, such as `migrations/data/`.

The failure message should tell the agent exactly what to do: delete generated migration files and use `pnpm db:push` for branch schema changes.

## Main And Production Flow

When schema code lands on main:

1. Create a throwaway Neon branch cloned from production.
2. Generate migrations with an unguarded CI-only command such as `db:generate:ci`.
3. Apply the generated migration to the throwaway clone.
4. Open an automated migration PR back to main.
5. When that migration PR merges, apply the migration to production.
6. Run any hand-authored data migrations idempotently.
7. Deploy only after migration success.

The deploy step should be explicit for the hosting provider. In reusable templates, leave it as a placeholder. In the target repo, replace it with Vercel, Railway, Fly, AWS, or the actual production deploy command.

## Workflow Details

- CI should install pnpm with `package_json_file: package.json`.
- CI should verify `pnpm --version` matches `packageManager` before installing dependencies.
- Local CI tests can use a disposable `postgres:17` service instead of touching preview or production databases.
- If CI needs a temporary CLI through pnpm 10, diagnose ignored-build failures before changing package manager setup.
- Quote fragile GitHub Actions `if:` expressions when they contain colons or complex expressions.
- Keep provider-specific deploy commands out of generic templates until the target repo is known.

## Required Scripts

The reusable package script shape is:

```json
{
  "scripts": {
    "db:branch:create": "tsx scripts/db/branch.ts create",
    "db:branch:delete": "tsx scripts/db/branch.ts delete",
    "db:branch:list": "tsx scripts/db/branch.ts list",
    "db:branch:prune": "tsx scripts/db/branch.ts prune",
    "db:generate": "tsx scripts/db/guard-generate.ts && drizzle-kit generate",
    "db:generate:ci": "drizzle-kit generate",
    "db:migrate": "drizzle-kit migrate",
    "db:migrate:retry": "tsx scripts/db/migrate-retry.ts",
    "db:push": "drizzle-kit push",
    "db:reset": "tsx scripts/db/reset.ts",
    "db:doctor": "tsx scripts/db/doctor.ts"
  }
}
```

For monorepos, root scripts can delegate to the package that owns Drizzle.

## Required Secrets

GitHub Actions usually needs:

- `NEON_API_KEY`
- `NEON_PROJECT_ID`
- `MIGRATION_BOT_TOKEN`

Deploy-specific secrets depend on the provider. Do not add `VERCEL_TOKEN`, Railway tokens, or cloud credentials to the generic setup unless the target repo actually uses that deploy provider.

## Safety Rules

- The configured parent branch is never deleted or reset.
- `db:branch:create` is idempotent and reuses an existing Neon branch.
- `db:branch:delete` and hard reset refuse to run on the parent branch.
- `db:branch:prune` is dry-run by default and requires `--yes` to delete.
- Production migration failure should open a labeled issue and set a red status context such as `prod-migration-state`.

## Skill

Install the setup skill with:

```bash
npx skills add wiseiodev/agentic-playbook/skills/isolated-db-branches
```

The skill includes setup instructions, workflow templates, script templates, and a failure runbook.
