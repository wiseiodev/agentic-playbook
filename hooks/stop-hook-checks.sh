#!/usr/bin/env bash
# Stop-hook: run `pnpm checks` (or equivalent) when an agent stops or claims done.
# Surfaces failures so the agent knows to fix before claiming the task complete.
#
# Wire into ~/.claude/settings.json or .claude/settings.json under hooks.Stop.
# See settings.json.example.

set -euo pipefail

# Detect package manager
if [ -f "pnpm-lock.yaml" ]; then
    CMD="pnpm checks"
elif [ -f "package-lock.json" ]; then
    CMD="npm run checks"
elif [ -f "yarn.lock" ]; then
    CMD="yarn checks"
elif [ -f "Cargo.toml" ]; then
    CMD="cargo check && cargo test --quiet"
elif [ -f "pyproject.toml" ]; then
    CMD="ruff check . && pytest -q"
else
    # No recognized project — exit silently
    exit 0
fi

# Skip if no checks script defined for the chosen package manager
if [[ "$CMD" == *"checks"* ]]; then
    if ! grep -q '"checks"' package.json 2>/dev/null; then
        echo "stop-hook: no 'checks' script defined in package.json; skipping"
        exit 0
    fi
fi

echo "stop-hook: running '$CMD'..."
if eval "$CMD"; then
    echo "stop-hook: ✓ checks passed"
    exit 0
else
    echo "stop-hook: ✗ CHECKS FAILED — fix before claiming done"
    exit 2  # exit 2 surfaces failure to Claude Code
fi
