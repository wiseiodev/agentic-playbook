# 13 - Quality Gates

The preferred quality stack is boring on purpose: pinned Node and pnpm, Biome, Vitest, Turbo when the repo is a monorepo, Commitlint for issue-linked history, Lefthook for local muscle memory, and CI that proves it is using the same package-manager version as the repo.

This is a default for TypeScript/Node projects. If a repo uses another stack, copy the shape, not the commands.

## The Baseline

For Node/TypeScript repos:

- Pin Node in `.nvmrc`.
- Pin pnpm in `packageManager`.
- Use Biome for formatting, linting, and import organization.
- Use Vitest for unit and integration tests.
- Use Turbo only when there are multiple packages or apps to coordinate.
- Use Commitlint when commits should close Linear/GitHub work items.
- Use Lefthook for local pre-commit, commit-msg, and pre-push gates.
- Use GitHub Actions for the non-writing version of the same gates.

The goal is not maximal coverage. The goal is one obvious command agents can run before claiming done, plus hooks that catch common misses before they leave the machine.

## Script Shape

### Single Repo

Use this shape when one package owns the app:

```json
{
  "scripts": {
    "lint": "biome check .",
    "lint:fix": "biome check --write .",
    "format": "biome format --write .",
    "typecheck": "tsc --noEmit",
    "test": "vitest run",
    "test:watch": "vitest",
    "build": "next build",
    "checks": "pnpm lint && pnpm typecheck && pnpm test && pnpm build",
    "checks:fix": "pnpm lint:fix && pnpm typecheck && pnpm test && pnpm build"
  }
}
```

Adjust `build` for the framework. Add E2E to `checks` only when the repo has stable local E2E prerequisites.

### Monorepo

Use this shape when Turbo coordinates apps/packages:

```json
{
  "scripts": {
    "dev": "turbo run dev --ui tui",
    "build": "turbo run build",
    "typecheck": "turbo run typecheck",
    "test": "turbo run test",
    "lint": "biome check --write",
    "format": "biome check --write",
    "check": "pnpm lint && turbo run check",
    "checks": "pnpm check"
  }
}
```

Root Biome runs once. Package-level `check` scripts should focus on package-local typecheck/test/build work and should not repeat root lint.

## Biome Preferences

Start from [templates/quality/biome.node-react.jsonc](./templates/quality/biome.node-react.jsonc).

Preferred defaults:

- Git-aware file discovery with `.gitignore`.
- Ignore generated output: `node_modules`, `.next`, `dist`, `build`, coverage, Playwright reports, test results, local agent/tool folders.
- 2-space indentation.
- Single quotes for JS/TS and JSX.
- Organize imports.
- `recommended` rules on.
- `noExplicitAny` and `noNonNullAssertion` as errors.
- Safe cleanup for unused imports.
- Node import protocol enforced for Node built-ins.
- React/Next domains enabled when relevant.
- Tailwind directives parsed; CSS linting disabled when Tailwind/PostCSS makes Biome noisy.

Use `biome check --write` locally when you want format, lint fixes, and import organization to settle in one pass. CI should use non-writing checks.

## Vitest Preferences

Use [templates/quality/vitest.node.config.ts](./templates/quality/vitest.node.config.ts) for Node packages and [templates/quality/vitest.react.config.ts](./templates/quality/vitest.react.config.ts) for React/Next apps.

Preferred defaults:

- Explicit test globs.
- `node` environment for server/package tests.
- `jsdom` environment for React UI tests.
- `@` alias to `src` when the repo uses that convention.
- Setup files when tests need DOM matchers, DB setup, or framework mocks.
- Split unit and integration projects only when the repo actually has different setup/runtime needs.

## Commitlint And Lefthook

Use [templates/quality/commitlint.config.cjs](./templates/quality/commitlint.config.cjs) when commits should close tracked work. It requires conventional commits and exactly one Linear magic-word footer, for example:

```text
feat(workflow): add quality setup

Completes REV-123
```

Use [templates/quality/lefthook.yml](./templates/quality/lefthook.yml) for local hooks:

- Pre-commit: run Biome on staged files and restage fixed files.
- Commit-msg: run Commitlint.
- Pre-push: run typecheck, tests, and build.

Do not use `--no-verify` to get around these hooks. If hooks fail, fix the cause or ask the human for an explicit waiver.

## CI Preferences

Use [templates/quality/github-actions-pnpm-ci.yml](./templates/quality/github-actions-pnpm-ci.yml) as the starting point.

Preferred defaults:

- `actions/checkout@v6`
- `pnpm/action-setup@v6` with `package_json_file: package.json`
- `actions/setup-node@v6` using `.nvmrc`
- `pnpm install --frozen-lockfile`
- Verify `pnpm --version` equals `packageManager` in `package.json`
- Run lint, typecheck, tests, and build as separate steps for readable failures
- Add local services, migrations, DB health checks, Playwright install, and E2E only when the repo has those gates

For pnpm 10 temporary CLIs, avoid adding dev dependencies just to quiet ignored-build errors. Prefer the narrow command fix, such as `pnpm dlx --allow-build=esbuild <tool>@<version> ...`, when that is the actual failure.

## Version Hygiene

- Pin `packageManager` in `package.json`.
- Keep `.nvmrc` in the repo and use it in CI.
- Prefer exact versions for toolchain packages when reproducibility matters.
- Use `pnpm.onlyBuiltDependencies`, `pnpm-workspace.yaml` `onlyBuiltDependencies`, or `allowBuilds` intentionally for tools with native postinstall steps.
- Use `pnpm.overrides` for deliberate security/runtime patches, not as a dumping ground.
- If `package.json` and `pnpm-lock.yaml` drift, regenerate the lockfile with `pnpm install --lockfile-only`, then rerun gates.

## Agent Rules

Agents setting up or tightening quality gates should use `/setup-quality`.

Hard rules:

- Inspect the repo first. Do not paste templates blindly.
- Preserve existing package manager and task runner unless the human asks to change them.
- Prefer the repo's existing script names when they are already working.
- Add missing gates in the smallest conventional shape.
- Use the question tool for ambiguous choices, especially adding Commitlint/Lefthook or E2E.
- Record the canonical command in `CLAUDE.md` or the repo instruction file.
- Run the non-writing verification path before claiming done.

Quality gates are not taste enforcement. They make the mechanical path obvious so `/work` can spend human attention on scope, behavior, evidence, and overengineering.
