# <slice title>

<!-- One slice = one tracer bullet, 1-3 hours. See agentic-playbook/02-spec-format.md. -->

## Intent

<1-2 sentences. What user-visible value does this slice add?>

## In scope

- <bullet>
- <bullet>

## Out of scope

- <explicitly NOT this task>
- <explicitly NOT this task>

## Behavior (Given/When/Then)

- **Given** <state>, **when** <action>, **then** <observable outcome>
- **Given** <state>, **when** <action>, **then** <observable outcome>

## Examples

**Input:**
```
<concrete data>
```

**Expected output:**
```
<concrete data>
```

## Constraints

<!-- Inherits global constraints from CLAUDE.md. Add task-specific bans here. -->

- Mimic the canonical pattern at `<src/path/to/canonical>`.
- Do not modify files outside the "Files to touch" list.
- <task-specific constraint>

## Files to touch

- `<src/path/to/file1.ts>`
- `<src/path/to/file1.test.ts>`

## Done when

- [ ] All Given/When/Then green
- [ ] `pnpm checks` passes
- [ ] No new files outside the list above
- [ ] Anti-overeng review subagent: no flags

## Dependencies

<!-- Other slices that must merge first; or "none" if parallel-safe. -->

- none
