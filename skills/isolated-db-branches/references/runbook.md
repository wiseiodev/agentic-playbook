# Isolated DB Branches Runbook

Use this when production migration or branch database automation fails.

## Production Migration Failed

1. Open the `migration-failed` issue created by the workflow.
2. Follow the workflow run link and identify the failing step.
3. Check whether the generated migration is wrong, the production data violates the migration, or infrastructure/auth failed.
4. Fix the root cause in a new PR.
5. After the fix lands, run:

```bash
pnpm db:migrate:retry
```

6. If retry succeeds, update `prod-migration-state` to success and redeploy if the workflow did not do it automatically.

## Feature Branch Push Failed

1. Confirm the PR's Neon branch exists.
2. Confirm `NEON_API_KEY`, `NEON_PROJECT_ID`, and `NEON_PARENT_BRANCH` are available.
3. Run `pnpm db:doctor`.
4. If the branch schema is disposable, run `pnpm db:reset --soft` and then `pnpm db:push`.
5. Use `--hard` only when deleting and recreating the branch is acceptable.

## Migration File Lint Failed

Delete generated migration files from the feature branch. Keep hand-authored data migrations only in the configured data-migration directory.

Then run:

```bash
pnpm db:push
```

## GitHub Actions YAML Failed

Parse the workflow locally. Quote complex `if:` expressions, especially expressions with colons or nested string matching.
