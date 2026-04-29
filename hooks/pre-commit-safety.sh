#!/usr/bin/env bash
# Pre-tool hook: block dangerous git operations unless explicitly approved.
# Wire into PreToolUse hook on Bash tool calls.
#
# Reads the proposed command from stdin (Claude Code provides it as JSON).
# Returns exit code 0 to allow, exit code 2 (with stderr) to block.
#
# For a maintained version, use the published `git-guardrails-claude-code` skill.

set -euo pipefail

# Read JSON from stdin
INPUT=$(cat)

# Extract the command (depends on Claude Code's hook input format)
# Adjust JQ paths as needed for your Claude Code version.
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if [ -z "$COMMAND" ]; then
    exit 0  # not a Bash command, allow
fi

# Patterns to block (require explicit user OK)
DANGEROUS_PATTERNS=(
    'git push.*--force[^-]'              # force push (--force, -f)
    'git push.*-f([^-]|$)'
    'git push.*--no-verify'              # bypass hooks
    'git commit.*--no-verify'
    'git reset.*--hard'                  # destroy local changes
    'git clean.*-[fdx]'                  # delete untracked files
    'git branch.*-D'                     # force-delete branch
    'git checkout\s+\.'                  # discard all changes
    'git restore\s+\.'                   # discard all changes
    'rm\s+-rf\s+/'                       # rm -rf /...
    'gh pr merge'                        # merging PRs (externally visible)
    'gh pr close'
    'gh issue close'
)

for pattern in "${DANGEROUS_PATTERNS[@]}"; do
    if echo "$COMMAND" | grep -qE "$pattern"; then
        cat >&2 <<EOF
pre-commit-safety: BLOCKED — dangerous command detected.

Command: $COMMAND
Pattern: $pattern

This action is irrecoverable or externally-visible. To proceed:
1. Confirm with the user explicitly that this is intended.
2. Re-issue the command with user approval (the user can manually confirm).
EOF
        exit 2
    fi
done

# Allow
exit 0
