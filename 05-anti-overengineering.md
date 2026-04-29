# 05 — Anti-Overengineering

Your top failure modes: **premature abstraction** and **defensive code**.
Both are avoidable upstream. This doc gives you the canonical constraints list (drop into CLAUDE.md) and the anti-overengineering review subagent.

## Why high-thinking models overengineer

Claude Opus with high thinking is *encouraged* to consider edge cases, future flexibility, error modes, and refactoring opportunities. In a brownfield repo with strong conventions, that thinking attenuates against existing code. In a greenfield repo with none, it manifests as:

- Interfaces for one caller ("might have multiple later")
- Try/catch around every async call ("might fail")
- Config flags for fixed behavior ("might want to toggle")
- New file per concept ("separation of concerns")
- Validation for inputs that can't actually be invalid ("defense in depth")

The model isn't wrong — these are *plausible* future needs. They're just not **this slice's** needs.

The cure: tell the model what NOT to do, with examples, and gate the diff.

## Canonical constraints list (drop into CLAUDE.md)

Copy this verbatim into the root CLAUDE.md `## Constraints` section. Tune over time.

```markdown
## Constraints

### Don't add what isn't asked for

- Don't add features, refactors, or abstractions beyond what the spec requires.
- Don't add error handling, fallbacks, or validation for cases that can't happen.
  Trust internal code and framework guarantees. Validate only at system
  boundaries (user input, external APIs).
- Don't add config flags / feature flags for fixed behavior. Hard-code values
  until a real second consumer appears.
- Don't add backwards-compat shims, deprecated paths, or `// removed` comments.
  Delete dead code outright.
- Don't add `console.log` / `print` / debug instrumentation for shipping code.

### Rule of three for abstractions

- The first instance: write it inline.
- The second instance: copy-paste; resist the urge to extract.
- The third instance: extract a helper, ideally co-located.
- Cross-module helpers / interfaces / generics: only when 3+ modules need them.

### Files

- Don't add new files unless the spec lists them under "Files to touch."
- One feature usually lives in one file. Split only when parts are genuinely
  independent (different consumers, different lifecycle).
- No `utils.ts`, `helpers.ts`, `common.ts`. Co-locate; or live with duplication
  until a real seam appears.

### Comments

- Default to writing no comments.
- Add a comment only when the WHY is non-obvious (a hidden invariant, a
  workaround for a specific bug, a constraint a reader would not infer).
- Don't explain WHAT the code does — names do that.
- Don't reference the current task or PR ("added for issue #123").

### Tests

- Test behavior, not implementation.
- One assertion per test where reasonable.
- No tests for getters/setters / trivial wrappers.
- Don't mock what you can run real (DBs in tests, etc.) unless explicitly noted.

### Plan-first

- For any non-trivial slice, produce an implementation plan and wait for
  approval before writing code. The plan must:
  - Cite the canonical example to mimic
  - List exact files to add/modify
  - List what the slice will NOT do
  - Note any abstraction the slice introduces and justify why it's needed now
```

## The anti-overengineering review subagent

After implementation, before PR, the agent runs a review subagent that **only** checks anti-overengineering. Definition in [`subagents/anti-overeng-reviewer.md`](./subagents/anti-overeng-reviewer.md).

The reviewer reads the diff and flags violations against this checklist:

```
□ New abstraction (interface, abstract class, factory, generic helper) with <3 callers?
□ try/catch around code with no documented failure mode?
□ null/undefined guard for a value that can't actually be null/undefined?
□ Validation for input from an internal call site?
□ New file not listed in spec's "Files to touch"?
□ New dependency not approved?
□ New config option / flag without justification?
□ Backwards-compat shim, // removed comment, or unused export kept "just in case"?
□ Comment explaining WHAT instead of WHY?
□ console.log / print debug statements?
□ Helper extracted on first or second use (rule-of-three violation)?
□ Test asserts implementation detail rather than behavior?
□ Defensive default values that mask bugs?
```

For each flag: **line number + suggested fix** (usually "delete and inline").

The implementing agent must address every flag before opening the PR.

## "Justified" exceptions

If the agent genuinely needs an abstraction now, the spec or plan must justify it. Acceptable justifications:

- "Three call sites already exist in this slice" (rule of three met)
- "Required by the framework / library shape"
- "Spec explicitly asked for it"

Unacceptable:

- "Will be reused later"
- "More flexible"
- "Best practice"
- "Future-proofing"

If a flag is contested, the model writes the rationale; you make the call.

## Defensive-code anti-patterns — examples

```ts
// ❌ Defensive (can't actually be undefined)
function getName(user: User): string {
  if (!user) return "";
  if (!user.name) return "";
  return user.name.toString();
}

// ✅ Trust the type
function getName(user: User): string {
  return user.name;
}
```

```ts
// ❌ Try/catch that hides bugs
async function fetchUser(id: string) {
  try {
    return await db.users.findOne({ id });
  } catch (e) {
    console.error(e);
    return null;
  }
}

// ✅ Let it propagate; handle at the boundary
async function fetchUser(id: string) {
  return db.users.findOne({ id });
}
```

```ts
// ❌ Premature abstraction (one caller)
interface UserRepository {
  findById(id: string): Promise<User>;
  save(user: User): Promise<void>;
}
class PostgresUserRepository implements UserRepository { ... }

// ✅ Direct (extract when 3rd caller arrives)
async function findUserById(id: string) {
  return db.users.findOne({ id });
}
```

These exact examples can go into a "do/don't" appendix linked from CLAUDE.md.

## Calibration: when to update the constraints

Track recurring flags. When the same flag class appears 3+ times in a week:

- Tighten phrasing in the constraint
- Add an example to the constraints list
- Make the reviewer subagent's check more specific

The constraints list is alive. Iterate it like code.

## When to relax constraints

Some slices genuinely need abstraction or defensive code:

- Building a new module that 3+ existing modules will consume → abstract upfront
- Public API surface (validation at the boundary is correct)
- Untrusted external input → defensive parse + validate is correct
- Framework integration where the framework expects a specific shape

When relaxing, **the spec must say so explicitly**, and the reviewer subagent gets the spec as context so it doesn't flag what was sanctioned.
