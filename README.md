# dotfiles

My Mac setup: shell, terminal, editor, window manager, and a Claude Code agent setup I take from job to job.

## New Mac

```bash
git clone https://github.com/chrstnjsff/dotfiles.git ~/dotfiles
cd ~/dotfiles
claude
```

Then paste:

> Install my dotfiles by following INSTALL.md. My workspace folder is ~/work.

Claude installs the tools, links the configs, copies the Claude Code setup, and backs up anything it replaces.
There is no install script on purpose: Claude follows [INSTALL.md](INSTALL.md) step by step and stops to ask when something fails.

## What is here

| Folder | What | Installs to |
| --- | --- | --- |
| `zsh/` | zsh, Oh My Zsh, Powerlevel10k, fzf key bindings, fzf-git | `~/.zshrc`, `~/.zprofile`, `~/.p10k.zsh`, `~/.zsh/` |
| `git/` | git identity, includes `~/.gitconfig.local` | `~/.gitconfig` |
| `tmux/` | tmux with TPM plugins | `~/.config/tmux/` |
| `nvim/` | Neovim on LazyVim | `~/.config/nvim` |
| `ghostty/` | Ghostty terminal | `~/.config/ghostty/config` |
| `herdr/` | herdr agent multiplexer | `~/.config/herdr/config.toml` |
| `yabai/`, `skhd/` | tiling window manager and hotkeys | `~/.config/yabai/`, `~/.config/skhd/` |
| `btop/`, `thefuck/` | small tool configs | `~/.config/` |
| `karabiner/`, `mise/`, `oh-my-posh/` | older configs, not linked by the installer | - |
| `Brewfile` | every CLI tool, app and font | `brew bundle` |
| `claude/global/` | personal Claude Code rules, hooks, status line, skills, settings template | `~/.claude/` |
| `claude/workspace/` | the agent team, rules, hooks and skills for a company workspace | the workspace folder |

Dotfiles are symlinked, so edits on the Mac show up here as git changes.
The Claude Code files are copied, because Claude Code and some installers write into them.

## Claude Code setup

`claude/global/` is how I want Claude to work everywhere: plain-English replies, plan first, the model routing, the herdr and humanizer hooks, the status line, and the design skill pack.

`claude/workspace/` is the team I drop into each new company's workspace:

- `CLAUDE.md`: working rules, with a "Project constraints" section to fill in after reading the codebase.
- `.claude/agents/`: investigator, architect, planner, coder, tester, reviewers (code, adversarial, security, performance, docs), refactor, simplifier, AI debt cleaner, frontend designer, CI/CD and IaC specialists.
- `.claude/rules/`: code quality, testing, security, database, frontend, cloud, orchestration (Opus plans and reviews, Sonnet builds, Haiku only behind a gate).
- `.claude/hooks/`: blocks dangerous commands, protects sensitive files, scans for secrets, formats on save, with tests in `hooks/tests/`.
- `.claude/skills/`: day-to-day skills such as ship, pr-review, tdd, debug-fix, handoff, git-worktree.

The agents are written for any stack.
After joining a company, read the codebases, fill in `CLAUDE.md`, and tune the agents to the real stack.

## Secrets

Nothing secret lives here.
Tokens and work-only aliases go in `~/.zshrc.local`, the work git identity in `~/.gitconfig.local`, and API keys in `~/.claude/settings.json`.
None of those files are in this repo.

## Updating

- Dotfiles: edit on the Mac, then commit here.
- Claude Code: copy changed files from `~/.claude` or the workspace back into `claude/`, check them for company names and secrets, then commit.
