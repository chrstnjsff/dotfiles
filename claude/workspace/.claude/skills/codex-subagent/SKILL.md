---
name: codex-subagent
description: Launch OpenAI Codex CLI non-interactively as a subagent for a self-contained coding task, a second opinion, or an independent verification pass on work Claude just did. Uses ChatGPT subscription auth, never an API key. Manual-only, invoked as /codex-subagent.
disable-model-invocation: true
---

# Codex CLI as a Subagent

Adapted from davidondrej/skills (MIT).

`codex exec` runs Codex non-interactively: it works in a sandbox, streams progress
to stderr, and prints only the final message to stdout. Auth reuses the ChatGPT
subscription.

Use it when you want a genuinely independent reviewer. Codex sees none of this
conversation, so it will not inherit Claude's assumptions. That is the point.

## When to delegate

- A self-contained coding task with clear success criteria.
- An independent verification pass on a diff Claude just wrote.
- Genuinely independent parallel work, one worktree each.

Do not delegate anything that needs conversation context you cannot fully write
into the prompt.

## Preflight

```bash
codex --version
codex login status   # exit 0 plus "Logged in using ChatGPT" means ready
```

Not logged in: stop and tell the user to run `codex login`. Never read, print, or
copy `~/.codex/auth.json`.

## Launch

```bash
OUT=$(mktemp "${TMPDIR:-/tmp}/codex-out.XXXXXX")
codex exec \
  --cd <repo-or-worktree> \
  --model gpt-5.6-sol \
  --config model_reasoning_effort=high \
  --sandbox workspace-write \
  --output-last-message "$OUT" \
  "<full task prompt>" \
  </dev/null
```

- `</dev/null` is MANDATORY. Codex treats an open stdin as extra context and waits
  forever for EOF. A hang with no output is always this.
- Always pass `--model gpt-5.6-sol` and `model_reasoning_effort=high` explicitly.
- Long prompt: pipe it instead, `codex exec [flags] - < /tmp/task.md`.
- Runs take minutes with no built-in timeout. Background it.
- Never use `--dangerously-bypass-approvals-and-sandbox`.

## Writing the prompt

Codex inherits nothing. Put everything in the prompt:

- The goal and the definition of done.
- The exact paths it may touch, and the ones it may not.
- The project constraints that matter for this task: never commit to `main`, the
  commit message format, the infrastructure tool in use and what it may never run
  (for example `tofu apply`), never output or commit secrets, no AI-generated
  comments or docstrings.
- The verification command, for example the project's test runner invoked on a
  specific path.

For a review pass, stay neutral. Tell it what to review broadly, do not nudge it
toward a solution, and ask for a concise plain-English report on whether the code
is safe to merge and what is wrong if not. Show the user the reply verbatim, do
not rewrite it.

## Collect results

```bash
cat "$OUT"                                   # the deliverable
rtk git -C <repo-or-worktree> status --short # what it actually changed
rtk git -C <repo-or-worktree> diff           # review before trusting it
```

Follow up in the same session, run from the same cwd:

```bash
codex exec resume --last "<follow-up>" </dev/null
```

## Parallel runs

One worktree per run, never two in the same tree. See `/git-worktree` for
bootstrapping, and assign file ownership upfront so results merge cleanly.

## Failure modes

- Hangs forever with no output: stdin was left open. Kill it, relaunch with
  `</dev/null`.
- `codex login status` non-zero: the user must run `codex login`. Do not work
  around it.
- Rate limit on the ChatGPT plan: report it, never retry in a loop.
- "Not a git repo": add `--skip-git-repo-check`.
- Network is blocked inside the `workspace-write` sandbox. If the task genuinely
  needs it, add `-c sandbox_workspace_write.network_access=true`.

## Rules

- One task per launch. Split big jobs.
- Review Codex's diff yourself before declaring the task done. The workspace hook
  guard does not apply inside Codex's own sandbox run.
