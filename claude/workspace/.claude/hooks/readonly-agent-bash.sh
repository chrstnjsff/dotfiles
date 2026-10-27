#!/usr/bin/env bash
# Blocks shell-side mutations for advisory and review agents.
# This script is attached only to agents that must remain read-only.

set -euo pipefail

deny() {
  local reason="${1//\"/\\\"}"
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s"}}\n' "$reason"
  exit 2
}

if ! command -v jq >/dev/null 2>&1; then
  deny "jq is required for the read-only Bash guard."
fi

input=$(cat)
command=$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null || true)
[ -z "$command" ] && exit 0

contains() {
  printf '%s' "$command" | grep -qiE "$1"
}

# File writes, VCS mutations, dependency changes, deployments, and state changes
# are never valid evidence-gathering actions for a read-only specialist.
if contains '(^|[;&|()[:space:]])(rm|mv|cp|touch|mkdir|chmod|chown|ln|install|patch|rsync|scp|sftp|dd|mkfs)([[:space:]]|$)' \
  || contains '(^|[;&|()[:space:]])(sed[[:space:]]+-i|perl[[:space:]]+-pi|tee)([[:space:]]|$)' \
  || contains '(^|[;&|()[:space:]])([^[:space:]]*/)?git[[:space:]]+(add|am|apply|branch|checkout|cherry-pick|clean|commit|config|merge|pull|push|rebase|reset|restore|revert|stash|switch|tag|update-ref|worktree)([[:space:]]|$)' \
  || contains '(^|[;&|()[:space:]])([^[:space:]]*/)?git[[:space:]]+.*--output(=|[[:space:]])' \
  || contains '(^|[;&|()[:space:]])(npm|pnpm|yarn|bun)[[:space:]]+(install|add|remove|update|publish)([[:space:]]|$)' \
  || contains '(^|[;&|()[:space:]])(pip|pip3)[[:space:]]+(install|uninstall)([[:space:]]|$)' \
  || contains '(^|[;&|()[:space:]])(poetry[[:space:]]+(add|remove|update)|composer[[:space:]]+(install|update|require|remove))([[:space:]]|$)' \
  || contains '(^|[;&|()[:space:]])(tofu|terraform|aws)([[:space:]]|$)' \
  || contains '(^|[;&|()[:space:]])(docker[[:space:]]+compose[[:space:]]+(up|down|run|rm|restart)|docker[[:space:]]+(rm|rmi|restart|kill|prune)|podman)([[:space:]]|$)' \
  || contains 'python[[:space:]]+manage\.py[[:space:]]+(makemigrations|migrate|flush|dbshell|shell)([[:space:]]|$)' \
  || contains 'php[[:space:]]+artisan[[:space:]]+(migrate|migrate:|db:|tinker|horizon:terminate)([[:space:]]|$)' \
  || contains '(^|[;&|()[:space:]])([^[:space:]]*/)?(bash|sh|zsh|fish|dash)[[:space:]]+-c([[:space:]]|$)' \
  || contains '(^|[;&|()[:space:]])([^[:space:]]*/)?(python|python3|node|ruby|perl)([[:space:]]|$)' \
  || contains '(^|[;&|()[:space:]])([^[:space:]]*/)?php[[:space:]]+(-c|-e|-r)([[:space:]]|$)' \
  || contains '(^|[^0-9&])>>?[[:space:]]*[^&]' \
  || contains '(^|[[:space:]])(curl[[:space:]].*(--output|-o|-O)[[:space:]]|wget([[:space:]]|$)|tar[[:space:]]+(-?[a-zA-Z]*x[a-zA-Z]*|--extract)|unzip([[:space:]]|$)|gunzip([[:space:]]|$)|bunzip2([[:space:]]|$)|7z[[:space:]]+x)([[:space:]]|$)'; then
  deny "Read-only agent: blocked a command that can modify code, dependencies, infrastructure, containers, databases, or files. Return evidence and a handoff instead."
fi

# The investigator may read Horizon status through the application container.
# Other PHP execution can mutate application or database state and is not
# appropriate for an advisory agent.
if contains '(^|[;&|()[:space:]])([^[:space:]]*/)?php([[:space:]]|$)' \
  && ! contains 'php[[:space:]]+artisan[[:space:]]+horizon:status([[:space:]]|$)'; then
  deny "Read-only agent: blocked PHP execution outside the approved Horizon status check."
fi

exit 0
