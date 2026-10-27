# Install guide for Claude

The user asked you to set up a new Mac from this repo.
Follow these steps in order.
After each step, tell the user in one short line what you did.

## Ground rules

- This is setup on the user's own machine: no ticket, no branch, no commit, no plan file.
- Copy and link files with the shell commands below, not with your file editing tools.
- Never delete the user's files.
  Every file this guide replaces is moved into `$BACKUP` first.
- Do not touch any file this guide does not name.
- Never print, read or ask the user to paste a secret into the chat.
  Keys go into `~/.zshrc.local` or `~/.claude/settings.json`, which the user edits.
- If a step fails, stop, explain the error in one or two sentences, and ask how to go on.

## 1. Set the folders

- `REPO` is this repo's folder (`git rev-parse --show-toplevel`), usually `~/dotfiles`.
- `WS` is the workspace: the folder that will hold the company's repos.
  Take it from the prompt.
  If the prompt has none, ask the user (for example `~/work`).
- `BACKUP` is where replaced files go.

Your shell may not keep variables between commands, so set all three again at the start of every command, with full paths:

```bash
REPO="/full/path/to/dotfiles"
WS="/full/path/to/workspace"
BACKUP="$HOME/.dotfiles-backup/<one timestamp for the whole install>"
```

## 2. Install the tools

```bash
xcode-select -p >/dev/null 2>&1 || xcode-select --install
command -v brew >/dev/null || echo "Homebrew missing"
```

If Xcode tools start installing, wait for the user to finish that dialog.
If Homebrew is missing, ask the user to install it from https://brew.sh (it needs their password), then go on.
The two third-party taps must be trusted before `brew bundle`, or yabai, skhd and rtk are skipped.

```bash
eval "$(/opt/homebrew/bin/brew shellenv)"
brew trust asmvik/formulae rtk-ai/tap
brew bundle --file="$REPO/Brewfile"
```

A formula that fails on its own is fine: name it to the user and go on.

Oh My Zsh, Powerlevel10k and the tmux plugin manager:

```bash
[ -d "$HOME/.oh-my-zsh" ] || RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
P10K="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
[ -d "$P10K" ] || git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K"
[ -d "$HOME/.config/tmux/plugins/tpm" ] || git clone https://github.com/tmux-plugins/tpm "$HOME/.config/tmux/plugins/tpm"
```

## 3. Link the dotfiles

Links point back into the repo, so later edits on this Mac land in the repo and can be committed.
The helper moves any existing file to `$BACKUP` before linking:

```bash
link() {
  src="$REPO/$1"; dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then return; fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    mkdir -p "$BACKUP/$(dirname "${dst#$HOME/}")"
    mv "$dst" "$BACKUP/${dst#$HOME/}"
  fi
  ln -s "$src" "$dst" && echo "linked $dst"
}
link zsh/.zshrc               "$HOME/.zshrc"
link zsh/.zprofile            "$HOME/.zprofile"
link zsh/.p10k.zsh            "$HOME/.p10k.zsh"
link zsh/key-bindings.zsh     "$HOME/.zsh/key-bindings.zsh"
link zsh/fzf-git.sh           "$HOME/.zsh/fzf-git.sh"
link git/gitconfig            "$HOME/.gitconfig"
link tmux/tmux.conf           "$HOME/.config/tmux/tmux.conf"
link tmux/tmux.reset.conf     "$HOME/.config/tmux/tmux.reset.conf"
link nvim                     "$HOME/.config/nvim"
link ghostty/config           "$HOME/.config/ghostty/config"
link herdr/config.toml        "$HOME/.config/herdr/config.toml"
link yabai/yabairc            "$HOME/.config/yabai/yabairc"
link skhd/skhdrc              "$HOME/.config/skhd/skhdrc"
link btop/btop.conf           "$HOME/.config/btop/btop.conf"
link thefuck/settings.py      "$HOME/.config/thefuck/settings.py"
```

Create the two local files the shell and git read, only if they are missing:

```bash
[ -e "$HOME/.zshrc.local" ] || printf '# Machine-only settings and secrets. Never commit this file.\n' > "$HOME/.zshrc.local"
[ -e "$HOME/.gitconfig.local" ] || printf '# Work identity and company git settings.\n# [user]\n#   email = you@company.com\n' > "$HOME/.gitconfig.local"
chmod 600 "$HOME/.zshrc.local"
```

Tell the user to set their work email in `~/.gitconfig.local`.

## 4. Install the global Claude Code setup

These are copied, not linked, because Claude Code and some installers write into them.

```bash
mkdir -p "$HOME/.claude"
rsync -a -c --backup --backup-dir="$BACKUP/claude" --exclude settings.json --exclude .DS_Store "$REPO/claude/global/" "$HOME/.claude/"
[ -e "$HOME/.claude/AGENTS.md" ] || ln -s CLAUDE.md "$HOME/.claude/AGENTS.md"
chmod +x "$HOME/.claude/hooks/"*.sh "$HOME/.claude/statusline-command.sh"
```

Settings:

- If `~/.claude/settings.json` does not exist, copy `$REPO/claude/global/settings.json` there.
- If it exists, back it up to `$BACKUP/claude/settings.json`, then add only what it lacks from the repo copy: `hooks`, `enabledPlugins`, `extraKnownMarketplaces`, `permissions` rules, `env` values, `statusLine`, `model`, `effortLevel`, `modelSettings`.
  Append missing permission rules to the end of each list.
  Do not sort or dedupe with `jq unique`, because rule order matters.
  Show the user what you merged.
- Set the memory folder to the workspace: `jq --arg d "$WS/memory" '.autoMemoryDirectory = $d'`.
- Check the result with `jq empty`.

```bash
mkdir -p "$WS/memory"
[ -e "$WS/memory/MEMORY.md" ] || : > "$WS/memory/MEMORY.md"
```

## 5. Install the workspace setup

```bash
mkdir -p "$WS"
rsync -a -c --backup --backup-dir="$BACKUP/workspace" --exclude .DS_Store "$REPO/claude/workspace/" "$WS/"
[ -e "$WS/AGENTS.md" ] || ln -s CLAUDE.md "$WS/AGENTS.md"
chmod +x "$WS/.claude/hooks/"*.sh
(cd "$WS" && bash .claude/hooks/tests/run-all.sh)
```

All hook tests must pass.
This adds and updates files and never deletes, so any agents, skills or rules already in the workspace stay.

## 6. Install rtk and the plugins

rtk shrinks command output before Claude reads it.
Its init adds the `rtk` hook to `~/.claude/settings.json`:

```bash
rtk init -g --auto-patch
rtk gain
```

If `rtk gain` fails, a different program called rtk is on the `PATH`.
Tell the user and skip the rest of rtk.

Plugins:

```bash
claude plugin marketplace add anthropics/claude-plugins-official
for m in latent-spaces/brag bradautomates/claude-video cathrynlavery/diagram-design jgraph/drawio-mcp blader/humanizer typesafe-ai/skills; do
  claude plugin marketplace add "$m"
done
for p in superpowers@claude-plugins-official context7@claude-plugins-official code-simplifier@claude-plugins-official swift-lsp@claude-plugins-official \
         brag@brag watch@claude-video diagram-design@diagram-design drawio@drawio humanizer@humanizer typesafe@typesafe-ai; do
  claude plugin install "$p"
done
```

A plugin or marketplace that is already installed is fine; move on.

## 7. Browser checks

The agents verify UI changes through the `browser-use` skill, which drives a headless Chrome:

```bash
uv tool install browser-use
browser-use --help >/dev/null && echo "browser-use ok"
```

## 8. First run of the editor and tmux

```bash
nvim --headless "+Lazy! sync" +qa
"$HOME/.config/tmux/plugins/tpm/bin/install_plugins"
```

## 9. Optional extras

Ask the user about each one; do nothing without a yes.

- **DeepAPI** (web search, research and scraping for the global rules).
  The user registers at https://deepapi.co for their own key.
  Download the installer, read it, back up `~/.claude/settings.json`, `~/.claude/CLAUDE.md` and `~/.zshrc.local`, then run the local copy with `DEEPAPI_SKIP_ONBOARDING_ANALYSIS=1` so it does not start a nested agent.
  The installer writes the key into `~/.claude/settings.json`; that file is never copied back into this repo.
  Without DeepAPI, Claude falls back to its built-in web tools.
- **yabai and skhd** (tiling window manager and hotkeys): `yabai --start-service` and `skhd --start-service`.
  macOS asks for Accessibility permission; the user grants it in System Settings.
- **Personal agent-status hook**: only if the user names a hook script they want on every Claude Code event.
  Add it as a command hook on each event in `~/.claude/settings.json`.

## 10. Finish

Tell the user:

- Open a new terminal so the shell config loads.
- Put tokens and work-only aliases in `~/.zshrc.local`, and the work git email in `~/.gitconfig.local`.
- Run `claude` inside the workspace, then fill in the "Project constraints" section of `$WS/CLAUDE.md` and adjust the agents in `$WS/.claude/agents/` once they have read the company's codebases.
- Backups of replaced files are in `$BACKUP`.
