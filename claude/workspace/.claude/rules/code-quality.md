---
alwaysApply: true
---

# Code Quality

## 4-Phase Debugging Protocol (mandatory before any bug fix)

Before writing a single line of fix code, run through all four phases in order.
Do not skip phases or merge them.

### Phase 1 - Investigate

1. Read the project's known-bugs document, if one exists.
   If the symptom matches a documented issue, follow that resolution.
2. Identify the exact failure point: file, line, function, and the incorrect value or behavior.
3. State your hypothesis explicitly: "I believe the bug is X because Y."
4. Grep for related patterns across every affected app and repository before assuming the issue is isolated.

### Phase 2 - Reproduce

1. Construct the minimal reproduction case: the smallest input or state that triggers the failure.
2. Confirm the bug is reproducible in the local development environment.
3. Do not proceed to Phase 3 until you can reproduce it reliably.

### Phase 3 - Fix

1. Apply the narrowest possible change.
   Do not refactor adjacent code or add unrelated improvements.
2. Fix the root cause, not the symptom.
3. Never bypass safety mechanisms (migrations, auth checks, permissions) to make the test pass.
4. If the fix requires a database migration, follow the migration rules in `database.md`.

### Phase 4 - Verify

1. Run the relevant test suite (for example `pytest` for Django, `php artisan test` for Laravel).
2. Check that no adjacent tests regressed.
3. If the bug was complex or non-obvious, offer to document it in the project's known-bugs document and create a Known Issue (KI).

## Anti-defaults

- No premature abstractions. Three similar lines beats a helper used once.
- Don't add features or improvements beyond what was asked.
- Don't refactor adjacent code while fixing a bug (Phase 3 rule above).
- No dead code or commented-out blocks. Git has history.
- WHY comments only. If code needs a "what" comment, rename instead.
- API docs at module boundaries only, not every internal function.

## Git and Ticket Discipline

- Create a ticket before starting any work, in the project the tracker conventions name.
- Every ticket has a Priority and sits under a parent epic where the tracker supports it.
  Bugs need Environment, Steps to Reproduce, Expected, Actual, Evidence.
  Do not hand-move a ticket past a step the automation owns.
- Estimate tickets before they enter a sprint, in the unit the project uses.
- Branch naming: `<TICKET>-<short-desc>` (e.g. `PROJ-48-bulk-export`).
- Commit messages: `<TICKET>: <description>` (e.g. `PROJ-48: add bulk export endpoint`).
- No direct commits to `main`. Use MRs. Rebase before completing work.
- Always run the infrastructure `plan` first.

## Naming

- Files: PascalCase for components and classes (`UserProfile.tsx`), kebab-case for utilities and directories (`date-utils.ts`).
- Python: `snake_case` for functions, variables, and modules. `PascalCase` for classes.
- PHP/Laravel: `camelCase` for methods, `PascalCase` for classes, `snake_case` for database columns.
- Booleans: `is` / `has` / `should` / `can` prefix. Functions: verb-first (`get_user`). Handlers: `handle_*`.
- Constants: `SCREAMING_SNAKE`. Abbreviations only when universally known (`id`, `url`, `api`, `db`, `auth`).

## Code Markers

`TODO(author): desc (#TICKET)` for planned work.
`FIXME(author): desc (#TICKET)` for known bugs.
`HACK(author): desc (#TICKET)` for ugly workarounds (explain the proper fix).
`NOTE: desc` for non-obvious context.
Owner and ticket required.
Never `XXX`, `TEMP`, `REMOVEME`.

## File Organization

- Imports: builtins, external, internal, relative, types. Blank line between groups.
- Python: follow PEP 8 import ordering. Use `isort` conventions.
- Exports: named over default. One component or class per file.
- Function order: public API first, then helpers in call order.
