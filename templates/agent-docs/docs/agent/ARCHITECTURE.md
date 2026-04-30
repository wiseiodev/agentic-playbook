# Architecture And Domain

Use this file for stable project context, ADR pointers, domain language, and canonical examples.

## Project Shape

<Short description of the app architecture, package layout, and main runtime surfaces. Avoid long file trees that will drift.>

## ADRs

See `docs/adr/` for decisions. Important current decisions:

- ADR-0001: <decision>
- ADR-0002: <decision>

## Domain Language

Use `CONTEXT.md` for glossary-level domain terms. Do not redefine domain language in this file unless it is needed for every implementation task in this area.

## Canonical Examples

When adding a new feature, mimic the file matching its shape:

- Read-path features: `<path>`
- Write-path features: `<path>`
- Async/job features: `<path>`
- External integration features: `<path>`
- AI-call features: `<path>`

Mimic structure, naming, error posture, and test layout. Do not invent new patterns when a canonical example exists.
