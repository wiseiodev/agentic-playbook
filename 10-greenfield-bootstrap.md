# 10 — Greenfield Bootstrap

Greenfield is where smart models overengineer the most — there's no existing code to imitate, so the model invents from training data which favors enterprise/Java patterns. The cure is a **deliberate scaffolding investment by you, the human, in the first 1-2 days**.

## The hypothesis

> Models follow examples in the repo more reliably than rules in AGENTS.md or CLAUDE.md.

If the repo has 3 features all written as straight-line modules with no abstractions, the 4th feature will be written that way too.
If the repo has 0 features and an instruction file saying "no abstractions," the model will add an abstraction.

Examples beat rules. Therefore: **build the examples by hand, before agents see the codebase.**

## What to hand-shape

**2-3 reference features**, each representing a distinct *shape* of work that will recur in the codebase. Pick shapes the model will encounter most often.

Common shapes (pick the 2-3 most relevant for your project):

| Shape | What it teaches |
|---|---|
| Read-path feature | List/detail views; query patterns; serialization |
| Write-path feature | Form/mutation; validation at boundary; success/error states |
| Async / job feature | Background work; idempotency; retry posture |
| AI-call feature | Prompt structure, tool use, streaming, evals |
| External-integration feature | API client, error handling, rate limiting |
| Auth-flow feature | Session handling, permission checks |

**You don't need all of them.** Pick 2-3 that cover the dominant work in the next 1-3 months.

## How to hand-shape (~90 min each)

For each reference feature:

1. **Write the spec yourself** in the canonical format ([03-spec-format](./03-spec-format.md)). This is also a chance to refine the spec template.
2. **Write the code yourself** — or use Claude as a typing assistant under tight rein. You drive every architectural choice.
3. **No premature abstraction.** Even if you "know" you'll need a helper later, write it inline first. Three callers later, refactor.
4. **No defensive code.** Errors propagate. Don't catch what you don't have a plan for.
5. **Tight tests** that exercise behavior, not implementation.
6. **Add a header comment** marking the file canonical.
7. **Update `docs/agent/ARCHITECTURE.md`** with a pointer.

### Header comment pattern

```ts
/**
 * CANONICAL — read-path feature.
 * Mimic this file's structure for new read-path features.
 * Do not introduce abstractions; this is intentionally straight-line.
 */
```

### Agent-doc pointer pattern

```markdown
## Canonical patterns

When adding a new feature, study the file matching its shape:

- **Read-path features**: `src/features/users/list.ts`
- **Write-path features**: `src/features/users/create.ts`
- **AI-call features**: `src/features/tutor/respond.ts`

Mimic structure, naming, error posture, and test layout. Do not invent new patterns.
```

Both pointers (header + linked agent doc). Models miss either alone.

## Constraints when hand-shaping

You are deliberately resisting your own instinct to abstract. Some self-rules:

- **Inline over extract.** Three callers of similar code? Still inline. Five? Extract.
- **Single file over five.** A small feature lives in one file unless the parts are genuinely independent.
- **No "utils.ts".** Utilities accrete; they're a graveyard. Live with co-located helpers until a real seam appears.
- **No premature config.** Hard-code values. Pull into config when a second consumer needs them.
- **No premature error handling.** Let it crash; deal with errors at boundaries (request handler, job runner) only.

These are the same rules the model should follow; you're modeling them.

## When to refresh examples

Update or replace canonical files when:

- The pattern genuinely needs to change (e.g., switched ORM)
- A new shape becomes dominant (add a 4th canonical)
- The example accumulated cruft and no longer reads as exemplary

Otherwise: leave them alone. Stability is a feature.

## What NOT to scaffold

Resist the urge to scaffold:

- Plugin systems / extension points
- Generic CRUD framework
- "Service layer" abstractions
- Event bus / pubsub before there's a second producer/consumer
- Custom router / DI container

You're trying to set the precedent that we don't reach for these unless forced. Don't seed them yourself.

## The first agent slice — calibration

After 2-3 hand-shaped features, **hand a 4th feature to an agent** with the standard workflow. This is your first calibration:

- Did the agent mimic the canonical pattern?
- Did it add abstractions you didn't ask for?
- Did it write defensive code?
- Did it follow the spec's "Files to touch"?

For each "yes" to a failure, **adjust upstream**:

- Tighter constraint in the spec template
- Stronger pointer in `docs/agent/ARCHITECTURE.md`
- Add the header comment if missing
- Strengthen the anti-overeng review subagent's checklist

This is the agentic-engineering loop. The agent is a probe; the codebase + context is the lever.

## Time investment table

| Phase | Time | Output |
|---|---|---|
| Repo skeleton + AGENTS/CLAUDE + ADRs | ~1 hour | repo, root context |
| Reference feature #1 | ~90 min | one canonical pattern |
| Reference feature #2 | ~90 min | second pattern |
| Reference feature #3 (optional) | ~90 min | third pattern |
| First agent slice + calibration | ~60 min | feedback into context |
| **Total upfront** | **~5-6 hours** | a repo where agents mimic instead of invent |

Pays back within the first week of agentic work.

## Anti-patterns

| Anti-pattern | Why it fails |
|---|---|
| Skip scaffolding, "let the agent figure it out" | Agent invents enterprise patterns; you spend the saved time fixing |
| Use a starter template | Generic, doesn't represent your domain shapes |
| Write one canonical only | Model treats it as one-off, not a pattern |
| Write 5+ canonicals before any real feature | Premature; you're guessing at shapes that haven't materialized |
| Make canonicals too elaborate | Model mimics elaboration; defeats anti-overeng |
| Forget the agent-doc pointer | Canonicals exist but aren't surfaced; agent doesn't know to mimic |
