---
name: linearize
description: Turn an idea or conversation context into a Linear Project-as-PRD, then into approved Linear issues with Given/When/Then mini-specs. Use when the user wants to create a Linear project from an idea, shape a PRD in Linear, draft behavior slice specs, or publish an approved issue queue to Linear before running /work.
---

# /linearize

Turn an idea into a Linear Project-as-PRD and an approved queue of Linear issues.

This is the upstream Linear-first path before `/work`. It does not create local `docs/specs/` files by default. Linear is the source of truth.

## Usage

```text
/linearize <idea or conversation context>
/linearize <linear issue/project/document/url>
/linearize <local notes path>
```

## Authority

Publishing Linear Projects, documents, and issues is externally visible.

Two gates are mandatory:

1. **Project gate**: user approves the Project-as-PRD before `linear projects create`.
2. **Issue gate**: user approves the slice queue before `linear documents create` and `linear issues create`.

Do not create, update, delete, close, or move Linear artifacts before the relevant gate.

## 1. Gather context

Work from the conversation and any provided source:

- Local files, repo docs, README, `CLAUDE.md`, `AGENTS.md`, `CONTEXT.md`, and relevant ADRs.
- Linear source issue, project, or document if the user provided one.
- Existing Linear team/project state when needed.

Use the project's domain vocabulary. If a fact is discoverable from repo or Linear, discover it instead of asking.

Determine the Linear team:

- If a source Linear item has a team, use that team.
- If the repo or user request clearly implies a team key, use it.
- Otherwise use the question tool if available; if not, ask directly.

Prefer the team's Todo/unstarted state for created issues when available. Do not add a `needs-triage` label unless the team already uses one for approved work.

## 2. Draft the Project-as-PRD

Draft the Project brief in chat first. Do not create the Project yet.

Use this structure:

```markdown
# <Project name>

## Problem
<problem from the user's perspective>

## Solution
<solution from the user's perspective>

## User stories
1. As a <actor>, I want <capability>, so that <benefit>.

## In scope
- ...

## Out of scope
- ...

## Behavior themes
- <major behavior area>

## Constraints
- <product or implementation constraint>

## Examples and canonical patterns
- <example data, workflow, or code pattern pointer>

## Success criteria
- [ ] ...

## Open questions
- ...
```

Show the draft and ask for approval. Use the question tool when available for approval and high-impact tradeoffs.

## 3. Create the Linear Project

Only after Project gate approval:

1. Write a temporary JSON payload outside the repo or in an ignored temp location.
2. Create the Project:

```bash
linear projects create --input-file <project-payload.json> --json
```

Payload shape:

```json
{
  "name": "<Project name>",
  "description": "<one-paragraph summary>",
  "content": "<full Project-as-PRD markdown>"
}
```

Include `teamId` or `teamIds` only if the local Linear CLI/API requires it in this workspace. If the command fails because a team field is required, fetch teams with `linear teams list --json`, choose the resolved team, and retry with the required team field.

Capture the Project `id` and `url`.

## 4. Draft the slice queue

Draft tracer-bullet issues from the approved Project brief.

Each slice must be:

- End-to-end and user-visible or risk-reducing.
- Small enough for a 1-3 hour equivalent implementation.
- One concept only.
- Marked **AFK** when `/work` can execute it after issue approval.
- Marked **HITL** when it needs a human decision, design review, access, or external setup.

For each proposed issue, show:

- **Title**
- **Type**: AFK or HITL
- **Depends on**
- **User stories covered**
- **Behavior (Given/When/Then)**
- **Examples**
- **Constraints**
- **Files to touch** best guess
- **Done criteria**

Ask the user to approve, split, merge, reorder, or retag slices. Iterate until approved.

## 5. Create the Project document and issues

Only after Issue gate approval:

1. Create a Linear project document containing the full approved slice queue:

```bash
linear documents create --input-file <document-payload.json> --json
```

Document payload:

```json
{
  "title": "<Project name> approved issue queue",
  "content": "<full approved queue markdown>",
  "projectId": "<project-id>"
}
```

2. Create issues in dependency order, blockers first:

```bash
linear issues create --input-file <issue-payload.json> --json
```

Issue payload:

```json
{
  "teamId": "<team-id>",
  "projectId": "<project-id>",
  "stateId": "<todo-or-unstarted-state-id>",
  "title": "<issue title>",
  "description": "<issue body markdown>",
  "priority": 3
}
```

If the team has no Todo/unstarted state, omit `stateId` and let Linear use its default.

Issue body template:

```markdown
## Parent project

<Project URL>

## Type

AFK | HITL

## What to build

<one narrow end-to-end behavior>

## User stories covered

- <story reference>

## Behavior (Given/When/Then)

- **Scenario: <name>**
  **Given** <state>, **when** <action>, **then** <observable outcome>

## Examples

<concrete input/output, workflow, or fixture>

## Constraints

- <task-specific constraint>

## Files to touch

- <best guess path or "Planner determines">

## Done when

- [ ] Every Given/When/Then scenario has test or QA evidence
- [ ] Repo gates pass
- [ ] No files outside the approved scope unless user approves
- [ ] Anti-overeng review has no unresolved flags

## Blocked by

<issue ids/urls, or "None - can start immediately">
```

When creating later issues, reference the real blocker IDs that were already created. Do not close or mark any issue Done.

## 6. Final response

Report:

- Linear Project URL
- Project document URL
- Created issue IDs and URLs in dependency order
- HITL vs AFK summary
- Recommended first `/work <issue-id>`

## Hard rules

- Do not publish Linear artifacts before the matching approval gate.
- Do not create local spec files unless the user explicitly asks.
- Do not create horizontal layer-only issues.
- Do not bury behavior in the Project only; repeat each mini-spec in its issue body.
- Do not infer team, state, or label when multiple plausible choices exist; use the question tool.
- Do not close, delete, or mark Linear issues Done.
