#!/usr/bin/env bash
# Blocks dangerous shell commands: push to protected branches, force push,
# destructive operations. PreToolUse hook for Bash operations.
# Exit 2 = block. Exit 0 = allow.
#
# Configurable via env:
#   CLAUDE_PROTECTED_BRANCHES  comma list (default: derived from git + main,master)

set -uo pipefail

emit_deny() {
  # Emit a JSON deny decision and exit 2.
  local reason="${1//\"/\\\"}"
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s"}}\n' "$reason"
  exit 2
}

if ! command -v jq >/dev/null 2>&1; then
  emit_deny "jq is required for command protection hooks but is not installed."
fi

INPUT=$(cat)
COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null || true)
[ -z "$COMMAND" ] && exit 0

# ── Protected branch list ────────────────────────────────────────────────
DEFAULT_BRANCHES="main,master"
if GIT_DEFAULT=$(git config --get init.defaultBranch 2>/dev/null) && [ -n "$GIT_DEFAULT" ]; then
  DEFAULT_BRANCHES="$DEFAULT_BRANCHES,$GIT_DEFAULT"
fi
PROTECTED_BRANCHES="${CLAUDE_PROTECTED_BRANCHES:-$DEFAULT_BRANCHES}"
# Build a regex alternation: main|master|develop|...
BR_REGEX=$(printf '%s' "$PROTECTED_BRANCHES" | tr ',' '\n' | awk 'NF{printf "%s%s",sep,$0; sep="|"}')

contains_cmd() { printf '%s' "$COMMAND" | grep -qE "$1"; }
contains_icmd() { printf '%s' "$COMMAND" | grep -qiE "$1"; }

# ── Git push protections ────────────────────────────────────────────────
if contains_cmd '(^|[;&|()]+[[:space:]]*)git[[:space:]]+push'; then
  # Explicit refspec to a protected branch (origin main, :main, HEAD:main, remote branch)
  if contains_cmd "git[[:space:]]+push[[:space:]]+[^[:space:]]+[[:space:]]+([^[:space:]]*:)?($BR_REGEX)(\$|[[:space:]])"; then
    MATCHED_BRANCH=$(printf '%s' "$COMMAND" | grep -oE "($BR_REGEX)(\$|[[:space:]])" | head -1 | tr -d '[:space:]')
    emit_deny "Blocked: push to protected branch '${MATCHED_BRANCH:-main}'. Use a feature branch and open a PR."
  fi
  if contains_cmd "git[[:space:]]+push.*:($BR_REGEX)(\$|[[:space:]])"; then
    MATCHED_BRANCH=$(printf '%s' "$COMMAND" | grep -oE ":($BR_REGEX)(\$|[[:space:]])" | head -1 | tr -d ': [:space:]')
    emit_deny "Blocked: push to protected branch '${MATCHED_BRANCH:-main}' via refspec. Use a feature branch and open a PR."
  fi
  # Bare `git push` while on protected branch
  if contains_cmd 'git[[:space:]]+push[[:space:]]*($|[;&|])'; then
    CURRENT=$(git branch --show-current 2>/dev/null || true)
    if [ -n "$CURRENT" ] && printf '%s' ",$PROTECTED_BRANCHES," | grep -q ",$CURRENT,"; then
      emit_deny "Blocked: you are on '$CURRENT' (a protected branch). Switch to a feature branch."
    fi
  fi
  # Force push (but allow --force-with-lease)
  if contains_cmd 'git[[:space:]]+push([[:space:]]+[^[:space:]]+)*[[:space:]]+(-[a-zA-Z]*f[a-zA-Z]*|--force)([[:space:]=]|$)' \
     && ! contains_cmd '\-\-force-with-lease'; then
    emit_deny "Blocked: force push is not allowed. Use --force-with-lease if you must overwrite remote."
  fi
fi

# ── Destructive filesystem operations ───────────────────────────────────
# rm -rf targeting root, home, $HOME, $VAR (any unresolved expansion), or parent traversal.
# We normalise quotes before matching so "my folder", '$HOME/trash', etc. Are all inspected.
CMD_NOQUOTE=$(printf '%s' "$COMMAND" | tr -d "'\"")
if printf '%s' "$CMD_NOQUOTE" | grep -qE 'rm[[:space:]]+(-[a-zA-Z]*[[:space:]]+)*-?[a-zA-Z]*r[a-zA-Z]*f[a-zA-Z]*[[:space:]]+(/([[:space:]]|\*|$)|~|\$HOME|\$[A-Za-z_][A-Za-z0-9_]*|\.\./\.\.)' ; then
  emit_deny "Blocked: recursive force-delete on /, ~, \$HOME, an unresolved \$VAR, or .../.. Path. Specify a concrete safe target."
fi
# rm -rf /usr, /etc, /var, /bin, etc.
if printf '%s' "$CMD_NOQUOTE" | grep -qE 'rm[[:space:]]+(-[a-zA-Z]+[[:space:]]+)*-?[a-zA-Z]*r[a-zA-Z]*f[a-zA-Z]*[[:space:]]+/(usr|etc|var|bin|sbin|lib|opt|root|boot)([[:space:]/]|$)'; then
  emit_deny "Blocked: recursive delete targeting a system directory."
fi

# ── Dangerous database operations ───────────────────────────────────────
# DROP TABLE|DATABASE|SCHEMA
if contains_icmd 'DROP[[:space:]]+(TABLE|DATABASE|SCHEMA)[[:space:]]+'; then
  emit_deny "Blocked: DROP TABLE/DATABASE/SCHEMA detected. Run manually if intended."
fi
# DELETE FROM without a WHERE on the SAME statement.
# Split on ';' so multi-statement inputs are analysed per-statement.
if printf '%s\n' "$COMMAND" | awk '
  BEGIN { IGNORECASE=1; RS=";" }
  /DELETE[[:space:]]+FROM[[:space:]]+[A-Za-z_][A-Za-z0-9_.]*/ {
    if ($0 !~ /WHERE/) { print "BAD"; exit }
  }
' | grep -q BAD; then
  emit_deny "Blocked: DELETE FROM without a WHERE clause. Add a WHERE or run manually."
fi
if contains_icmd 'TRUNCATE[[:space:]]+TABLE'; then
  emit_deny "Blocked: TRUNCATE TABLE detected. Run manually if intended."
fi

# ── Dangerous system commands ───────────────────────────────────────────
# chmod: any world-writable/universal mode (0?777 or a+rwx)
if contains_cmd 'chmod([[:space:]]+-[a-zA-Z]+)*[[:space:]]+0?777([[:space:]]|$)' \
  || contains_cmd 'chmod([[:space:]]+-[a-zA-Z]+)*[[:space:]]+a\+rwx([[:space:]]|$)'; then
  emit_deny "Blocked: chmod 777 / a+rwx grants everyone full access. Use restrictive perms."
fi

# curl/wget piped to a shell
if contains_cmd '(curl|wget)[[:space:]].*\|[[:space:]]*(sudo[[:space:]]+)?(bash|sh|zsh|ksh|fish|dash|csh)([[:space:]]|$)'; then
  emit_deny "Blocked: piping downloaded content directly to a shell is dangerous."
fi

# Disk / partition. Note: only REDIRECTIONS to /dev/ are destructive. `2>/dev/null` is not.
# Pattern matches: `>[ ]*/dev/<something>` but NOT `2>/dev/null` or `&>/dev/null` style for fd-null.
# Strategy: match `>` optionally with whitespace, followed by /dev/<name>, EXCLUDING /dev/null and /dev/stderr/stdout.
if printf '%s' "$COMMAND" | grep -qE '(^|[^0-9&])>[[:space:]]*/dev/[a-zA-Z][a-zA-Z0-9]*' \
   && ! printf '%s' "$COMMAND" | grep -qE '>[[:space:]]*/dev/(null|stdout|stderr|tty|zero|random|urandom)([[:space:]]|$)' ; then
  emit_deny "Blocked: redirection into a raw device file can destroy data."
fi
if contains_cmd '(^|[;&|[:space:]])(mkfs|mkfs\.[a-z0-9]+)([[:space:]]|$)' \
  || contains_cmd '(^|[;&|[:space:]])dd[[:space:]]+[^|]*(if|of)=/dev/[a-zA-Z]' ; then
  emit_deny "Blocked: mkfs/dd against a device node. Irreversible data loss."
fi

# ── AWS API Protections ──────────────────────────────────────────────────
if contains_cmd 'aws[[:space:]]+.*(delete-|remove-|terminate-|rm[[:space:]])'; then
  emit_deny "Blocked: AWS delete/remove/terminate operations are restricted. Ask the user for permission to proceed or ask them to run it manually."
fi

# ── Docker & Django Protections ──────────────────────────────────────────
# Restarting or deleting containers
if contains_cmd 'docker[[:space:]]+(rm|rmi|kill|prune|restart)([[:space:]]|$)' \
  || contains_cmd 'docker[[:space:]]+compose[[:space:]]+(rm|down|kill|restart)([[:space:]]|$)'; then
  emit_deny "Blocked: Docker remove/restart operations are restricted. Restarting is a last resort. Please ask the user for permission."
fi

# Django destructive commands
if contains_cmd 'python[[:space:]]+manage\.py[[:space:]]+(flush|sqlflush|dbshell)([[:space:]]|$)'; then
  emit_deny "Blocked: Django flush/dbshell commands are restricted. Ask the user."
fi

# Prevent interactive shells / arbitrary execution where logs should be used
if contains_cmd 'docker[[:space:]]+exec[[:space:]]+.*(bash|sh|zsh)([[:space:]]|$)' \
  || contains_cmd 'python[[:space:]]+manage\.py[[:space:]]+shell'; then
  emit_deny "Blocked: Interactive shells (Django shell / Docker bash) are restricted. You should only be checking logs. If you absolutely need to run this, ask the user."
fi

# ── Destructive git ─────────────────────────────────────────────────────
if contains_cmd 'git[[:space:]]+reset[[:space:]]+--hard'; then
  emit_deny "Blocked: git reset --hard discards uncommitted changes permanently."
fi
if contains_cmd 'git[[:space:]]+clean[[:space:]]+-[a-zA-Z]*f'; then
  emit_deny "Blocked: git clean -f permanently deletes untracked files."
fi

# ── Accidental package publishing ───────────────────────────────────────
# Allow --dry-run variants (npm publish --dry-run is safe and common in CI).
publish_patterns=(
  '(npm|yarn|pnpm|bun)[[:space:]]+publish'
  'cargo[[:space:]]+publish'
  'gem[[:space:]]+push'
  'twine[[:space:]]+upload'
)
for pat in "${publish_patterns[@]}"; do
  if contains_cmd "$pat" && ! contains_cmd '(^|[[:space:]])(--dry-run|-n)([[:space:]=]|$)'; then
    emit_deny "Blocked: publishing packages should run in CI or manually, not via Claude."
  fi
done

# ── Credential stores: password managers, OS keychain, GPG secret keys ──
# Agents must never read a secret out of a vault. Secrets come from SSM /
# Secrets Manager at runtime (see .claude/rules/clean-code-hygiene.md).
# `pass` and `op` are common words, so they only match at command position
# with a real subcommand.
if contains_cmd '(^|[;&|[:space:]])(bw|bws|lpass|keepassxc-cli|rbw|nordpass)([[:space:]]|$)' \
  || contains_cmd '(^|[;&|])[[:space:]]*pass[[:space:]]+[^[:space:]]' \
  || contains_cmd '(^|[;&|[:space:]])op[[:space:]]+(read|run|inject|item|document|vault|connect|service-account|events-api|signin)([[:space:]]|$)'; then
  emit_deny "Blocked: password-manager CLI access. Agents must not read secrets from a vault. Load them from SSM Parameter Store or Secrets Manager at runtime."
fi
if contains_cmd '(^|[;&|[:space:]])security[[:space:]]+((-[a-zA-Z]+|--[a-z-]+)[[:space:]]+)*(find-generic-password|find-internet-password|dump-keychain)([[:space:]]|$)'; then
  emit_deny "Blocked: macOS keychain secret extraction. Agents must not read credentials out of the keychain."
fi
if contains_cmd '\-\-export-secret-(keys?|subkeys)([[:space:]=]|$)'; then
  emit_deny "Blocked: GPG secret key export. Private keys must never leave the keyring via an agent."
fi
if contains_cmd '(~|\$HOME|\$\{HOME\}|/Users/[^/[:space:]"'"'"']+)/\.password-store' \
  || contains_cmd '(1Password|Bitwarden|NordPass|KeePassXC)\.app'; then
  emit_deny "Blocked: direct access to a password store or password-manager application bundle."
fi

# ── Shell writes into hook directories ──────────────────────────────────
# protect-files.sh guards .claude/hooks/ against Edit|Write, but not against
# shell writes, so an agent could route around it with cp/sed/python. Close
# that path here. Reading, grepping, diffing, and running hooks stay allowed.
if printf '%s' "$COMMAND" | grep -qE '(\.claude|\.codex)/hooks(/|[[:space:]]|$)' \
   && ( contains_cmd '>>?[[:space:]]*[^|&;]*(\.claude|\.codex)/hooks/' \
     || contains_cmd '(^|[;&|[:space:]])(cp|mv|rm|tee|truncate|install|rsync|ln|chmod|chown|dd)([[:space:]]|$)' \
     || contains_cmd 'sed[[:space:]]+[^|;&]*-i' \
     || contains_cmd '(^|[;&|[:space:]])(python3?|perl|ruby|node)([[:space:]]|$)' ); then
  emit_deny "Blocked: shell write into a hook directory. Hook scripts enforce security boundaries (see protect-files.sh, which covers Edit/Write only). Ask the user to make this change rather than routing around the guard."
fi

exit 0
