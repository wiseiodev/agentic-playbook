# Agent Workflow

Use this file for instructions that matter to implementation workflow, not coding style.

## Default Loop

For agent-owned implementation, use `/work` as the default loop. It authorizes a scoped branch, implementation, quality gates, self-QA evidence, reviews, report, metrics sidecar, commit, push, and Ready PR after all required gates pass.

`/work` does not authorize merge, force-push, issue closure, hook bypass, destructive database actions, or destructive infrastructure actions.

## Manual Phase Control

Use these when the human wants to control a phase:

- `/linearize` for idea to Linear Project and approved issue queue
- `/plan` before non-trivial implementation
- `/implement` after the plan is approved
- `/review` for anti-overengineering review
- `/pr` after gates and report are ready
- `/cleanup-worktree` after merge

## Planning Rules

- For non-trivial work, produce an implementation plan before editing.
- The plan must name files to add/modify, the canonical example to mimic, non-goals, abstractions introduced, and verification steps.
- If the plan requires files, behavior, or abstraction beyond the spec, ask before proceeding.

## Reports

For `/work`, create the repo's expected report plus `.reports/<work-id>.metrics.json` before commit/Ready PR.
