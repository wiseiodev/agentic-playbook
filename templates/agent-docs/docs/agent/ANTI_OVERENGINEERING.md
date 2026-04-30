# Anti-Overengineering

Use this file for concrete simplicity constraints and anti-overengineering review.

## Constraints

- Do not add features, refactors, or abstractions beyond the spec.
- Do not add error handling, fallbacks, or validation for cases that cannot happen.
- Validate only at system boundaries: user input, external APIs, persistence, and network edges.
- Do not add config flags or feature flags for fixed behavior.
- Do not add backwards-compat shims or deprecated paths unless explicitly required.
- Do not add shipping debug instrumentation.

## Rule Of Three

- First instance: write it inline.
- Second instance: tolerate duplication.
- Third instance: consider a co-located helper.
- Cross-module helpers, interfaces, or generics need a real current caller set.

## Files

- Do not add new files unless the spec or plan lists them.
- Avoid `utils.ts`, `helpers.ts`, and `common.ts`.
- Split files only when the parts have genuinely separate consumers or lifecycle.

## Review Checklist

Flag:

- Premature abstractions
- Defensive code without a documented failure mode
- Scope creep
- Unapproved files or dependencies
- Custom wrappers around framework primitives
- Implementation-detail tests
