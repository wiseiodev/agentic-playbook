#!/usr/bin/env bash
# PreToolUse hook: block destructive git/database/external commands.
#
# Wire into Claude Code's Bash PreToolUse hook. The hook expects Claude's
# hook JSON on stdin and exits 2 to block a command.
#
# Tune this file per project. Hooks block danger; they do not enforce taste.

set -euo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null || true)

if [ -z "$COMMAND" ]; then
  exit 0
fi

BLOCK_PATTERNS=(
  # Destructive git / hook bypass
  '(^|[[:space:]])git[[:space:]]+reset[[:space:]].*--hard'
  '(^|[[:space:]])git[[:space:]]+clean[[:space:]].*-[^[:space:]]*[fdx]'
  '(^|[[:space:]])git[[:space:]]+branch[[:space:]].*-D'
  '(^|[[:space:]])git[[:space:]]+checkout[[:space:]]+\.([[:space:]]|$)'
  '(^|[[:space:]])git[[:space:]]+restore[[:space:]]+\.([[:space:]]|$)'
  '(^|[[:space:]])git[[:space:]]+push[[:space:]].*(--force|-f)([[:space:]]|$)'
  '(^|[[:space:]])git[[:space:]]+commit[[:space:]].*--no-verify'
  '(^|[[:space:]])git[[:space:]]+push[[:space:]].*--no-verify'
  '(^|[[:space:]])rm[[:space:]]+-rf[[:space:]]+/'

  # Destructive database commands
  '(^|[[:space:]])pnpm[[:space:]]+[^;&|]*db:(reset|clear|drop|wipe)'
  '(^|[[:space:]])npm[[:space:]]+run[[:space:]]+[^;&|]*db:(reset|clear|drop|wipe)'
  '(^|[[:space:]])yarn[[:space:]]+[^;&|]*db:(reset|clear|drop|wipe)'
  '(^|[[:space:]])bun[[:space:]]+[^;&|]*db:(reset|clear|drop|wipe)'
  'drizzle-kit[[:space:]]+drop'
  '(^|[[:space:]])psql[^;&|]*(-c|--command)[^;&|]*(DROP[[:space:]]+(SCHEMA|TABLE|DATABASE)|TRUNCATE[[:space:]]+|DELETE[[:space:]]+FROM[[:space:]]+|UPDATE[[:space:]]+[^[:space:]]+[[:space:]]+SET[[:space:]]+|ALTER[[:space:]]+TABLE[[:space:]]+)'

  # Externally visible / irreversible collaboration actions
  '(^|[[:space:]])gh[[:space:]]+pr[[:space:]]+merge([[:space:]]|$)'
  '(^|[[:space:]])gh[[:space:]]+pr[[:space:]]+close([[:space:]]|$)'
  '(^|[[:space:]])gh[[:space:]]+issue[[:space:]]+close([[:space:]]|$)'
)

for pattern in "${BLOCK_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qiE "$pattern"; then
    cat >&2 <<EOF
block-dangerous-commands: BLOCKED

Command:
$COMMAND

Matched pattern:
$pattern

This command is destructive, bypasses safety checks, or is externally visible.
Ask the user for explicit approval or use a safer project-specific workflow.
EOF
    exit 2
  fi
done

exit 0
