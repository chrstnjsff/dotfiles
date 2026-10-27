# Skills

Skills are slash commands you invoke with `/name`. They run in the main conversation context, so they see all loaded rules and `CLAUDE.md`.

- `disable-model-invocation: true` means manual only. You type `/name` to trigger.
- Without that flag, Claude can also trigger the skill automatically when relevant.

## Available skills

### /setupdotclaude
**Trigger**: Manual only

Bootstrap and customize dotclaude in any project. If `.claude/` is missing, the skill copies the bundled template in (rules, hooks, settings, agents, skills, `CLAUDE.md`). Then it scans the codebase to detect language, framework, package manager, test runner, linter, and architecture, and customizes every config file to match. Confirms every change before applying. Run this once after installing the plugin or after copying dotclaude into a new project.

### /debug-fix [issue, error, or description] [--fast]
**Trigger**: Manual only

Find and fix a bug. Default is the careful path: understand, reproduce, investigate, fix, verify, commit. Add `--fast` for emergency production mode: creates a `hotfix/` branch from production, makes the smallest correct change (no refactoring), runs only critical tests, and ships a `[HOTFIX]` PR. Warns if the fix is too complex for fast mode.

### /ship [optional message]
**Trigger**: Manual only

Full shipping workflow with confirmation at every step: scan changes, stage and commit, push, create PR. Proposes commit messages and PR descriptions. Blocks secrets, force-push, and push to main.

### /pr-review [PR number | staged | file path]
**Trigger**: Manual only

Reviews code changes by delegating to specialist agents (`@code-reviewer`, `@security-reviewer`, `@performance-reviewer`, `@doc-reviewer`). When given a PR number (or auto-detected from branch), also checks PR title, description quality, CI status, unresolved comments, and size. Ends with a clear merge or needs-changes verdict. Also works on staged changes or specific files for pre-PR review.

### /tdd [feature description]
**Trigger**: Manual only

Strict Test-Driven Development loop. Red: write a failing test for the smallest next behavior. Green: write the minimum code to pass. Refactor: clean up without changing behavior. Repeat. Commits after each green-plus-refactor cycle.

### /explain [file, function, or concept]
**Trigger**: Manual only

Explains code with a one-sentence summary, a mental model analogy, an ASCII diagram, key details, and a modification guide.

### /refactor [target]
**Trigger**: Manual only

Safe refactoring with tests as a safety net. Writes tests first if none exist, makes changes in small testable steps, verifies no behavior change.

### /test-writer
**Trigger**: Automatic (when new features are added)

Writes comprehensive tests covering every code path: happy path, edge cases, nulls, type boundaries, error paths, concurrency, state transitions. Covers API endpoints, UI components, database operations, and async. Verifies tests actually catch bugs by breaking the code.

### /context-budget [--api]
**Trigger**: Manual only

Estimates the per-turn token cost of this project's `.claude/` configuration and `CLAUDE.md`. Reports always-loaded files (rules with `alwaysApply` plus `CLAUDE.md`), path-scoped rules, and invoked-only agents and skills. Ranks the top contributors and flags entries over budget. Default uses Anthropic's documented `chars/4` heuristic. Add `--api` to call Anthropic's `count_tokens` endpoint for exact counts (requires `$ANTHROPIC_API_KEY`).

### /risky-changes
**Trigger**: Automatic (before implementing a change resting on an unverified assumption)

Verification discipline for changes where being wrong is expensive or tenant-visible: tenant and region scoping, feature flag flips, signing or approval flows, seed reconciliation, migrations that backfill or rescope, money totals, email routing, cloud sizing, CI template pins. Tests prove the code does what you coded, not that the change is a good idea. Requires naming assumptions, verifying them against Context7 and real call sites, measuring real prod and staging row counts read-only, and recording the numbers in `docs/evals/`.

### /handoff
**Trigger**: Manual only

Compacts the session into one cold-start briefing for a fresh agent: goal, environment state (what is deployed where, which MRs are blocked and on what, flag state the code does not reveal), decisions and why, dead ends already tried, files with line ranges, and open work with dependencies. States facts, never instructions. Saves to the scratchpad, not the repo.

### /git-worktree
**Trigger**: Manual only

Create, bootstrap, and tear down worktrees for parallel work. Covers what a fresh worktree is missing (env files, dependencies, the compose top-level `name:` that stops worktrees fighting over ports) and the git state that is SHARED across every worktree, including repo-level `user.email`, which can mis-author commits across all worktrees at once.

### /codex-subagent
**Trigger**: Manual only

Launch Codex CLI non-interactively for a self-contained task or a genuinely independent review pass. Codex inherits none of the conversation, so it will not inherit Claude's assumptions. Covers the mandatory `</dev/null`, the gpt-5.6-sol plus high-effort flags, one worktree per parallel run, and the project constraints to write into every prompt.

### /decisions
**Trigger**: Manual only

Lists the choices made during the current work that Claude is NOT confident about, with the alternative and why. Stays silent on decisions it stands behind. Always surfaces anything touching sensitive-data handling, tenant scoping, signing or approval flows, migrations, or cloud cost. Retrospective.

### /next-decision
**Trigger**: Automatic

Drills open decisions one at a time: the most important unresolved choice, the top options, a recommendation, then waits. Forward-looking counterpart to `/decisions`.

### /before-building
**Trigger**: Manual only

Instant, no-tools response naming the 1 to 3 consequential choices hidden in a build proposal, before any research or code. Biased toward the ones that recur: one-off versus maintained, contained versus cross-product, and what already-live behavior it could break.

### /skill-authoring
**Trigger**: Manual only

Reference for writing skills: progressive disclosure, description-as-routing-contract, capability versus process primitives, anti-patterns, testing, security, and a ship checklist. Adapted from davidondrej/skills (MIT).

## Imported: thinking and docs

From davidondrej/skills (MIT), adapted: personal name references genericised,
personal repo paths made resolvable, dash style matched to `writing-style.md`.

| Skill | Trigger | What it does |
|---|---|---|
| `/ask-then-build` | auto | Asks 3 to 6 pointed questions one at a time (options A-D, states a preference, waits), then delivers one paragraph prompt another agent can build from. |
| `/brain-to-docs` | auto | Q&A loop that extracts project vision and decisions into `README.md` plus `docs/adr/`. Updates docs after every answer. |
| `/file-tree` | `/file-tree` | Prints a high-level file tree of the thing under discussion, in a code block. |
| `/image-prompt` | auto | Turns an idea into 4 ready-to-paste prompts for image models. Writes prompt text only. |
| `/level-up` | auto | Seven adaptive questions to gauge knowledge, logs answers, grows a learning plan from the gaps. Pairs with `/teach`. |
| `/prompt-me` | `/prompt-me` | Interviews you to surface priorities, what you are avoiding, and what only looks important. Rewritten here; upstream shipped an unfinished stub. |
| `/read-all-adrs` | `/read-all-adrs` | Reads every ADR in `docs/adr/` in full. Stops and asks if the repo has no ADR folder, which many repos lack. |
| `/remind` | `/remind` | Rewrites the last response shorter, prefixed with a 3-5 sentence TLDR and the original first message of the conversation. |
| `/save-idea` | auto | Appends an idea to a bucket file in your ideas repo. Resolves `$IDEAS_REPO`, then `~/code/ideas`, then asks. Never writes into a work repo. |
| `/short` | `/short` | Rewrites the last response shorter and simpler. Nothing else. |
| `/signal-from-expert` | `/signal-from-expert` | Reviews a corpus of your own raw thinking against an expert's body of work and surfaces the passages that hit your situation, plus at least one gap. Bundles `scripts/fetch-sources.py`. |
| `/stop-overthinking` | `/stop-overthinking` | Forces a short practical call: real blockers, or good to proceed, plus next steps. |
| `/teach` | auto | Teaches a concept in-workspace using mission, glossary, resources, and learning-record formats. |

## Imported: research and web

Same source and adaptations.
**Six of these call DeepAPI and need a key** (`DEEPAPI_API_KEY`, loaded from the environment or `~/.deepapi/env`).
Without one, those skills stop and tell you to get a key at deepapi.co.
The `deepapi` umbrella skill is installed globally, not in this folder.

| Skill | Trigger | Needs key | What it does |
|---|---|---|---|
| `/browser-use` | auto | no | The tool for local stack browser checks and E2E tests: screenshots, mobile widths, click-throughs. Staging and prod checks use Claude in Chrome. Lives at user level (`~/.claude/skills/browser-use`) so sub-repo sessions get it too. Runs a separate headless test Chrome via `scripts/bu.sh`. |
| `/deep-research` | auto | yes | Fires a source-backed deep research run and saves a cited markdown report. |
| `/fireflies-transcript` | auto | separate key | Pulls meeting transcripts from Fireflies.ai via GraphQL. |
| `/online-shopping` | auto | yes | Price checks, best deals, shop trust. Research only, never orders. |
| `/pi-web-search` | auto | yes | Pi Agent only. Inert under Claude Code. |
| `/research-prompt` | auto | no | Writes one tight paragraph research brief for a human or AI researcher. Pure prompt work. |
| `/twitter-alpha` | auto | yes | Pulls tweet-level signal from a person or company's circle on X. |
| `/who-is-this` | `/who-is-this` | yes | Background check across X, LinkedIn, GitHub, and the open web. |
| `/youtube-transcript` | auto | yes | Video transcripts. Falls back to local `yt-dlp` when DeepAPI is unavailable. |

## Adding your own

Create a directory with a `SKILL.md` file:

```
your-skill/
└── SKILL.md
```

```yaml
---
name: your-skill
description: What it does and when to use it
disable-model-invocation: true
---

Your instructions here. Use $ARGUMENTS for user input.
```

See [Claude Code docs](https://code.claude.com/docs/en/skills) for all frontmatter options.
