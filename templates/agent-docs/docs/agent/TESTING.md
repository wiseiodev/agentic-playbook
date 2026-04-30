# Testing

Use this file for testing patterns, fixtures, and evidence expectations.

## Principles

- Test behavior, not implementation.
- Prefer real boundaries when practical.
- Keep tests aligned to Given/When/Then scenarios from the spec.
- Do not add tests for trivial getters, setters, or pass-through wrappers.

## Test Commands

- Unit tests: `<command>`
- Integration tests: `<command>`
- E2E tests: `<command or not available>`

## Evidence

For UI/browser work, capture a browser check, screenshot, trace, recording, or concise notes proving the visible behavior.

For non-UI work, record concrete evidence: command output, test names, DB snapshots, curl transcripts, or report notes.

Weak artifacts that do not prove the current slice should not be kept.
