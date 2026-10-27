---
name: git-worktree
description: Create, bootstrap, and tear down git worktrees so parallel agents work on one repo without collisions. Covers what a fresh worktree is missing (env files, deps, containers, ports) and the git state that is SHARED across worktrees and will bite you. Use when starting a ticket in a shared repo, or for "worktree", "parallel agents", "agents overwriting each other". Manual-only, invoked as /git-worktree.
disable-model-invocation: true
---

# Git Worktrees

Adapted from davidondrej/skills (MIT), with workspace gotchas added.

## Start here

Detect where you are before touching anything:

```bash
[ "$(git rev-parse --path-format=absolute --git-dir)" = "$(git rev-parse --path-format=absolute --git-common-dir)" ] \
  && echo "primary checkout" || echo "worktree"
```

- **Primary checkout**: do not edit here. Create a worktree named after the
  ticket, bootstrap it, `cd` in, and do all work there.
- **Worktree**: proceed.

## The working model

- One ticket, one worktree, one agent session. Never two agents in one directory.
- The primary checkout is the integration point. It stays on the tracking branch
  and is used only to review and merge.
- Nothing auto-merges. A human reviews each diff.
- Worktree branches are local until an MR is opened. Only push branch names that
  follow `<TICKET>-<desc>`. Never push to `main`.

## Creating and removing

Workspace convention is a sibling directory suffixed `-wt`:

```bash
rtk git worktree add ../proj-123-form-scope -b PROJ-123-form-scope main
rtk git worktree list
rtk git worktree remove ../proj-123-form-scope
rtk git worktree prune
```

A branch can only be checked out in ONE worktree at a time, `main` included.

## Bootstrapping: a fresh worktree has ONLY tracked files

Everything gitignored is missing. An agent dropped into a bare worktree fails
confusingly. Replicate, in this order:

1. **Env files.** Copy `.env`, `.env.local`, `api.env` and friends from the
   primary checkout. Copy, never symlink. An agent editing a symlinked env file
   corrupts the original.
2. **Dependencies.** Run the real install (`uv sync`, `pip install`, `npm ci`,
   `composer install`). Never symlink `node_modules` from the primary checkout.
   Bundlers resolve it to a path outside the worktree and refuse to build.
3. **Containers.** Set a top-level `name:` in the compose file. Without it the
   Compose project name comes from the directory name, so every worktree starts
   its OWN stack and they fight over the same host ports.
4. **Ports.** The local stack binds fixed host ports (API, frontend, database).
   Two worktrees running at once collide. Either run one at a time or override the port per worktree.
5. **Generated files.** Rebuild in the worktree. Build output and generated
   API clients are gitignored and will not be there.

## Shared git state: the part that bites

Worktrees isolate FILES, not git state. These are shared across every worktree of
the repo:

- **`.git/config`, so repo-level `user.name` and `user.email`.** This can
  cause a real incident: a test identity set at repo level authored commits
  in every worktree at once. Verify before committing:
  ```bash
  rtk git config user.email && rtk git config user.name
  ```
- **`core.hooksPath` and hook scripts.** Confirm no hook assumes the primary
  checkout's absolute path.
- **One stash list, one refs namespace.** A `git stash` in one worktree is
  visible from all of them.

## Automating the bootstrap

Keep a `scripts/setup-worktree.sh` in the repo and run it as the first command in
any new worktree. Inside a worktree, the primary checkout is:

```bash
dirname "$(git rev-parse --path-format=absolute --git-common-dir)"
```

## Merging back

Work goes to `main` through an MR, never a local merge. From the worktree:

```bash
rtk git push -u origin PROJ-123-form-scope
rtk glab mr create --fill
```

After the MR merges, clean up from the primary checkout:

```bash
rtk git worktree remove ../proj-123-form-scope
rtk git branch -d PROJ-123-form-scope
```

## Gotchas

- Missing gitignored files is the number one failure. Bootstrap before the agent
  starts, not after it errors.
- Uncommitted work in a removed worktree is gone. Commit early; commits survive
  in the shared repo even after the folder is deleted.
- Long-lived worktrees rot. If a ticket stalls, rebase onto `main` or restart it.
  Stale `*-wt` directories pile up.
- Disk: each worktree duplicates the working files plus its own dependencies.
  Remove merged ones.
