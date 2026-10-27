# Rules

Rules are modular instruction files that Claude loads automatically. They extend `CLAUDE.md` without bloating it.

- `alwaysApply: true`. Loaded every session, regardless of what files are open. Costs tokens every turn, so keep it tight.
- `paths: [...]`. Loaded only when working with files matching the glob patterns. Free until you're near matched files.

Budget convention for `alwaysApply` rules: under 30 lines each. Push everything that doesn't actively change Claude's behavior into a path-scoped rule, into an agent, or out entirely.

## Available rules

### code-quality.md
**Scope**: Always. ~22 lines.

The 4-phase debugging protocol, then anti-defaults that counter common Claude tendencies (no premature abstraction, no scope expansion, no surrounding refactors, WHY-not-WHAT comments). Plus git and ticket discipline, naming conventions, code markers (TODO, FIXME, HACK, NOTE), and file organization.

### clean-code-hygiene.md
**Scope**: Always. ~12 lines.

Cross-language clean-code + repo-hygiene: short concise why-comments, never committing throwaway test/debug scripts or scratch artifacts, never committing secrets (load from a secret store), and continuous refactoring to prevent tech debt. Cross-references `code-quality.md` and `security.md`.

### writing-style.md
**Scope**: Always. ~12 lines.

User-facing prose style: no em-dashes or en-dashes (with substitution guidance), direct and concise, no AI-sounding words or padding, bullets and tables over walls of text in HTML plans and docs.

### testing.md
**Scope**: Always. ~10 lines.

Six terse principles: verify behavior, run the specific test file, fix or delete flaky tests, prefer real implementations, one assertion per test, no empty assertions. Comprehensive test writing is handled by the `test-writer` skill.

### working-rules.md
**Scope**: Always. ~26 lines.

Grounding over guessing (verify every cause, path, flag, or API before stating it, and say how), investigate and reproduce before diagnosing, surgical minimal diffs in the existing style, and proving the change with tests plus an honest report of what was not verified.

### plain-english.md (global, in `~/.claude/rules/`)
**Scope**: Always, in every project. ~12 lines.

Chat replies in plain English the user understands on the first read: answer first, short sentences, everyday words, explain any needed technical term, summarize logs and code instead of pasting them, and state the next step for the user.

### aws.md
**Scope**: Always.

AWS CLI safety guidance: profile prefixing, SSO login, SSM sessions and commands, and always passing an explicit region. Profiles and accounts are added after joining the project.

### debugging.md
**Scope**: Always.

Check Docker or container logs first when the application or its services break, and make no destructive changes while investigating.

### orchestration.md
**Scope**: Always.

Which agent and model runs each step (Opus thinks, Sonnet builds, Haiku only behind the gate), plus the plan-file and approval flow.

### security.md
**Scope**: Path-scoped (`src/api/**`, `src/auth/**`, `src/middleware/**`, `**/routes/**`, `**/controllers/**`, `**/views/**`, `**/serializers.py`, `**/permissions.py`, `**/tofu/**`, `**/*.tf`)

Always loads. Compliance and sensitive-data controls, `.env` protection, input validation, parameterized queries, XSS prevention, token handling, secret logging, constant-time comparison, security headers, rate limiting.

### error-handling.md
**Scope**: Path-scoped (`src/api/**`, `src/services/**`, `**/controllers/**`, `**/routes/**`, `**/handlers/**`)

Loads near backend code. Typed error classes, no swallowing, no floating promises, consistent HTTP error shapes, no stack-trace leaks, retry policy.

### database.md
**Scope**: Path-scoped (`**/migrations/**`, `**/alembic/**`, `**/models/**`, `**/models.py`, `**/serializers.py`, `**/querysets.py`, etc.)

Loads near migrations, models, and serializers. Migration safety (never edit an existing migration, reversible, never `--fake`, indexes in their own migration), Django and Laravel N+1 query discipline, transactions, and schema conventions.

### frontend.md
**Scope**: Path-scoped (`**/*.tsx`, `**/*.jsx`, `**/*.vue`, `**/*.svelte`, `**/*.css`, `**/*.scss`, `**/*.html`, `**/components/**`, `**/pages/**`, etc.)

Loads when touching frontend files. Design token requirements, design principle pick-list, component framework options, layout rules, accessibility (WCAG 2.1 AA), performance.

## Adding your own

Create a new `.md` file in this directory:

```yaml
---
alwaysApply: true
---

# Your Rule Name

- Your instructions here
```

Or path-scoped:

```yaml
---
paths:
  - "src/your-area/**"
---

# Your Rule Name

- Instructions that only apply when touching these files
```

See [Claude Code docs](https://code.claude.com/docs/en/memory#path-specific-rules) for glob pattern syntax.
