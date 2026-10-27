# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ──────────────────────────────────────────────────────────────────────────────
# Core Configuration
# ──────────────────────────────────────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"

# Powerlevel10k Theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Oh-My-Zsh
source "$ZSH/oh-my-zsh.sh"

# ──────────────────────────────────────────────────────────────────────────────
# FZF & History
# ──────────────────────────────────────────────────────────────────────────────
export FZF_DEFAULT_OPTS='--color=fg:#39ff14,bg:-1,hl:#39ff14 --color=fg+:#39ff14,bg+:#3b4261,hl+:#39ff14 --color=info:#39ff14,prompt:#39ff14,pointer:#39ff14 --color=marker:#39ff14,spinner:#39ff14,header:#565f89 --border --height=60% --layout=reverse --preview-window=right:50%'
export HISTSIZE=1000000
export SAVEHIST=1000000
export HISTFILE="$HOME/.zsh_history"

# Initialize fzf only once (avoid re-wrapping ZLE on re-source)
if [[ -z "${FZF_INIT_DONE}" ]]; then
  eval "$(fzf --zsh)"
  export FZF_INIT_DONE=1
fi

# Autosuggestions
source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# ──────────────────────────────────────────────────────────────────────────────
# PATH
# ──────────────────────────────────────────────────────────────────────────────
export PATH="/opt/homebrew/bin:$PATH"
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
export PATH="$(brew --prefix)/opt/python@3.11/bin:$PATH"
export PATH="$PATH:$HOME/.local/bin"
export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"

# ──────────────────────────────────────────────────────────────────────────────
# Extra tooling
# ──────────────────────────────────────────────────────────────────────────────
[[ -f "$HOME/.zsh/key-bindings.zsh" ]] && source "$HOME/.zsh/key-bindings.zsh"
[[ -f "$HOME/.zsh/fzf-git.sh" ]] && source "$HOME/.zsh/fzf-git.sh"

# pyenv
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"
fi

# zoxide
eval "$(zoxide init zsh)"

# thefuck
eval "$(thefuck --alias)"

# Bash completion support
autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/tofu tofu

# Rust/Cargo
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

# ──────────────────────────────────────────────────────────────────────────────
# Aliases
# ──────────────────────────────────────────────────────────────────────────────
alias c='clear'
alias v='nvim'
alias lg='lazygit'
alias cc='claude --permission-mode bypassPermissions'
if [[ -x "$HOME/.local/bin/codex-headroom" ]]; then
  alias codex='"$HOME/.local/bin/codex-headroom"'
  alias cx='"$HOME/.local/bin/codex-headroom"'
fi
# eza (overrides any earlier ls alias)
alias ls='eza --icons'
alias ll='eza -l --icons --group-directories-first'
alias la='eza -la --icons --group-directories-first'
alias tree='eza --tree'

# OpenTofu
alias tf='tofu'
alias tfp='tofu plan'
alias tfa='tofu apply -auto-approve -parallelism=30'
alias tfi='tofu init'
alias tfw='tofu workspace'
alias tfs='tofu show'
alias tfv='tofu validate'
alias tff='tofu fmt'
alias tfd='tofu destroy -auto-approve -parallelism=30'

# Git
alias gcob='git checkout $(git branch | fzf)'
alias gcobr='git checkout --track $(git branch -r | fzf)'
alias gco='git commit --amend'
alias gst='git status'
alias gpf='git push --force-with-lease'
alias git-resethard="git reset --hard origin/\$(git branch | grep '*' | cut -d ' ' -f2)"
alias git-difflast='git diff HEAD~1'
alias git-showlatesttag='git log --pretty=format:"%d" | grep "tag:" | head -n 1'
alias gc='git commit -m'
alias gp='git pull'
alias glog="git log --graph --topo-order --pretty='%w(100,0,6)%C(yellow)%h%C(bold)%C(black)%d %C(cyan)%ar %C(green)%an%n%C(bold)%C(white)%s %N' --abbrev-commit"
alias gdiff='git diff'
alias gb='git branch'
alias gba='git branch -a'
alias gadd='git add -u'
alias ga='git add -p'
alias gcoall='git checkout -- .'
alias gr='git remote'
alias gre='git reset'
alias gcm='git checkout main'
alias gfp='git fetch -p'
alias gfa='git fetch --all'
alias grb='git fetch -p && git rebase -i origin/main'
alias grm='git rebase main'


# Git helper
git-rebase-i() { local count=${1:-1}; git rebase -i HEAD~$count; }

# ──────────────────────────────────────────────────────────────────────────────
# Handy reloads
# ──────────────────────────────────────────────────────────────────────────────
alias reload='exec zsh'

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# glab wrapper — uses repo-local token from git config when available
glab() {
  local repo_token
  repo_token=$(git config --local glab.token 2>/dev/null)
  if [[ -n "$repo_token" ]]; then
    GITLAB_TOKEN="$repo_token" command glab "$@"
  else
    command glab "$@"
  fi
}

#xcode development
command -v fnm >/dev/null && eval "$(fnm env --use-on-cd)"
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator"
export JAVA_HOME="/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# opencode
export PATH="$HOME/.opencode/bin:$PATH"

# Claude Auto-Approve
alias ca="claude --permission-mode bypassPermissions"

# >>> BridgeSpace shell integration >>>
# v3: skip inside the primary BridgeSpace shell (its own integration.zsh
# emits these markers — running both double-emitted every prompt).
# v2: also emits the working directory (OSC 9;9) on every prompt and cd.
# BridgeSpace emits OSC 133 semantic prompt markers so its AI inline
# autocomplete can tell when you are typing vs when a command is
# running, plus OSC 9;9 so suggestions are scoped to the directory you
# are actually in. Safe to delete this block — it only adds
# precmd/preexec/chpwd hooks. Unset BRIDGESPACE_SHELL_INTEGRATION to
# disable at runtime.
if [[ -o interactive && "${BRIDGESPACE_SHELL_INTEGRATION:-1}" != "0" && -z "${BRIDGESPACE_INTEGRATION_DIR:-}" ]]; then
  __bridgespace_emit_cwd() { printf '\e]9;9;%s\a' "$PWD"; }
  __bridgespace_prompt_start() { __bridgespace_emit_cwd; printf '\e]133;A\a'; }
  __bridgespace_command_start() { printf '\e]133;C\a'; }
  autoload -Uz add-zsh-hook 2>/dev/null
  if (( ${+functions[add-zsh-hook]} )); then
    add-zsh-hook precmd __bridgespace_prompt_start 2>/dev/null
    add-zsh-hook preexec __bridgespace_command_start 2>/dev/null
    add-zsh-hook chpwd __bridgespace_emit_cwd 2>/dev/null
  fi
fi
# <<< BridgeSpace shell integration <<<

[ -f "$HOME/.deepapi/env" ] && source "$HOME/.deepapi/env"

# Machine-only settings and secrets (tokens, work aliases). Not in the repo.
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
