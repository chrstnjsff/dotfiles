#!/bin/bash
# Claude Code status line, one line that drops detail to fit the terminal width:
#   🤖 model | 📁 dir 🌿 branch* | CTX bar pct% | ↻ session reset | WK bar pct% | ↻ weekly reset
#
# Context and rate limits come from the statusLine stdin JSON. When stdin has no
# rate_limits, falls back to the OAuth usage API. That call runs in the
# background and is cached in /tmp for 60s, so rendering never waits on the network.

input=$(cat)

BAR_WIDTH=12
BAR_WIDTH_NARROW=8
USAGE_URL="https://api.anthropic.com/api/oauth/usage"
USAGE_CACHE="/tmp/claude-statusline-usage-${UID}.json"
USAGE_CACHE_TTL=60
now=$(date +%s)

GREEN_RGB="154;205;104"; YELLOW_RGB="229;192;123"; RED_RGB="224;108;117"; TRACK_RGB="58;64;52"
RESET=$'\e[0m'
PARTIAL_BLOCKS=(▏ ▎ ▍ ▌ ▋ ▊ ▉)

# Solid bar of spaces on a truecolor background, so the cells draw with no gaps.
# The last filled cell is a left-block glyph on the track, for 1/8-cell precision.
# Fill: green < 60, yellow 60-85, red > 85.
render_bar() {
  local pct=$1 width=$2 rgb eighths full rem i bar
  if   (( pct > 85 )); then rgb=$RED_RGB
  elif (( pct >= 60 )); then rgb=$YELLOW_RGB
  else                       rgb=$GREEN_RGB
  fi
  (( pct < 0 )) && pct=0
  (( pct > 100 )) && pct=100
  eighths=$(( (pct * width * 8 + 50) / 100 ))
  full=$(( eighths / 8 )); rem=$(( eighths % 8 ))
  bar=$'\e[48;2;'"${rgb}m"
  for (( i = 0; i < full; i++ )); do bar+=" "; done
  bar+=$'\e[48;2;'"${TRACK_RGB}m"
  if (( rem > 0 )); then
    bar+=$'\e[38;2;'"${rgb}m${PARTIAL_BLOCKS[rem - 1]}"
    full=$(( full + 1 ))
  fi
  for (( i = full; i < width; i++ )); do bar+=" "; done
  printf '%s%s' "$bar" "$RESET"
}

# seconds -> H:MM:SS
fmt_hms() {
  printf '%d:%02d:%02d' $(( $1 / 3600 )) $(( ($1 % 3600) / 60 )) $(( $1 % 60 ))
}

# seconds -> "3d4h", "4h12m" or "12m"
fmt_dh() {
  local d=$(( $1 / 86400 )) h=$(( ($1 % 86400) / 3600 )) m=$(( ($1 % 3600) / 60 ))
  if   (( d > 0 )); then printf '%dd%dh' "$d" "$h"
  elif (( h > 0 )); then printf '%dh%dm' "$h" "$m"
  else                   printf '%dm' "$m"
  fi
}

oauth_token() {
  jq -r '.claudeAiOauth.accessToken // empty' "$HOME/.claude/.credentials.json" 2>/dev/null
}

# Writes the API response to the cache, or {} on any failure (shows "WEEK n/a").
# The token goes to curl on stdin so it never shows up in the process list.
refresh_usage_cache() {
  local tmp token
  tmp=$(mktemp "${USAGE_CACHE}.XXXXXX") || return
  token=$(oauth_token)
  if ! { [ -n "$token" ] \
      && printf 'Authorization: Bearer %s\n' "$token" \
         | curl -sf --connect-timeout 2 --max-time 5 -H @- \
             -H "anthropic-beta: oauth-2025-04-20" -o "$tmp" "$USAGE_URL" \
      && jq -e '.seven_day.utilization != null' "$tmp" >/dev/null 2>&1; }; then
    printf '{}' > "$tmp"
  fi
  mv -f "$tmp" "$USAGE_CACHE"
}

# Prints the cached usage JSON. A stale or missing cache starts a background
# refresh; touching the cache first stops parallel renders from fetching too.
usage_json() {
  local mtime=0
  if [ -f "$USAGE_CACHE" ]; then
    case $OSTYPE in
      darwin*) mtime=$(stat -f %m "$USAGE_CACHE" 2>/dev/null) ;;
      *)       mtime=$(stat -c %Y "$USAGE_CACHE" 2>/dev/null) ;;
    esac
  fi
  if (( now - ${mtime:-0} >= USAGE_CACHE_TTL )); then
    touch "$USAGE_CACHE"
    refresh_usage_cache </dev/null >/dev/null 2>&1 &
  fi
  cat "$USAGE_CACHE" 2>/dev/null
}

eval "$(printf '%s' "$input" | jq -r '
  def pct: if . == null then "" else round end;
  @sh "model=\(.model.display_name // .model.id // "")",
  @sh "model_id=\(.model.id // "")",
  @sh "cwd=\(.workspace.current_dir // .cwd // "")",
  @sh "transcript=\(.transcript_path // "")",
  @sh "ctx_max=\(.context_window.context_window_size // "")",
  @sh "ctx_used=\(.context_window.current_usage
        | if . == null then ""
          else (.input_tokens // 0) + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0)
          end)",
  @sh "five_reset=\(.rate_limits.five_hour.resets_at // "")",
  @sh "week_pct=\(.rate_limits.seven_day.used_percentage | pct)",
  @sh "week_reset=\(.rate_limits.seven_day.resets_at // "")"
' 2>/dev/null)"

[ -z "$cwd" ] && cwd=$PWD

case $cwd in
  "$HOME")   folder='~' ;;
  "$HOME"/*) folder="~${cwd#"$HOME"}" ;;
  *)         folder=$cwd ;;
esac

if [[ $model =~ ^(.*)\ \(([0-9.]+[KkMm])\ context\)$ ]]; then
  model="${BASH_REMATCH[1]} (${BASH_REMATCH[2]})"
fi

branch=$(git -C "$cwd" branch --show-current 2>/dev/null)
[ -z "$branch" ] && branch=$(git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
dirty=""
if [ -n "$branch" ] && [ -n "$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)" ]; then
  dirty="*"
fi

if [ -z "$ctx_used" ] && [ -f "$transcript" ]; then
  # The last main-chain assistant message's usage is the current context size.
  ctx_used=$(tail -n 200 "$transcript" 2>/dev/null | jq -r '
    select(.type == "assistant" and .isSidechain != true and .message.usage != null)
    | .message.usage
    | (.input_tokens // 0) + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0)
  ' 2>/dev/null | tail -n 1)
fi
[[ $ctx_used =~ ^[0-9]+$ ]] || ctx_used=0

if ! [[ $ctx_max =~ ^[0-9]+$ ]] || (( ctx_max == 0 )); then
  case $model_id in
    *1m*|*1M*) ctx_max=1000000 ;;
    *)         ctx_max=200000 ;;
  esac
fi
ctx_pct=$(( (ctx_used * 200 + ctx_max) / (2 * ctx_max) ))

if [ -z "$week_pct" ] || [ -z "$five_reset" ]; then
  eval "$(usage_json | jq -r '
    def epoch: if . == null then ""
               else sub("\\.[0-9]+"; "") | sub("\\+00:00$"; "Z") | try fromdateiso8601 catch "" end;
    def pct:   if . == null then "" else round end;
    @sh "api_week_pct=\(.seven_day.utilization | pct)",
    @sh "api_week_reset=\(.seven_day.resets_at | epoch)",
    @sh "api_five_reset=\(.five_hour.resets_at | epoch)"
  ' 2>/dev/null)"
  week_pct=${week_pct:-$api_week_pct}
  week_reset=${week_reset:-$api_week_reset}
  five_reset=${five_reset:-$api_five_reset}
fi
five_reset=${five_reset%%.*}
week_reset=${week_reset%%.*}

session_left=""; week_left=""
[[ $five_reset =~ ^[0-9]+$ ]] && (( five_reset > now )) && session_left=$(fmt_hms $(( five_reset - now )))
[[ $week_reset =~ ^[0-9]+$ ]] && (( week_reset > now )) && week_left=$(fmt_dh $(( week_reset - now )))
[[ $week_pct =~ ^[0-9]+$ ]] || week_pct=""

term_width=$(tput cols 2>/dev/null)
[[ $term_width =~ ^[0-9]+$ ]] && (( term_width > 0 )) || term_width=$COLUMNS
[[ $term_width =~ ^[0-9]+$ ]] && (( term_width > 0 )) || term_width=120

# Columns the line takes on screen: strip color codes, count characters, and
# add one extra column for each double-width emoji.
display_width() {
  local LC_ALL=en_US.UTF-8 s=$1 e n
  while [[ $s =~ $'\e'\[[0-9\;]*m ]]; do s=${s//"${BASH_REMATCH[0]}"/}; done
  n=${#s}
  for e in 🤖 📁 🌿; do [[ $s == *"$e"* ]] && (( n++ )); done
  printf '%d' "$n"
}

# Drop level: 1 narrow bars, 2 ctx pct, 3 session reset, 4 weekly reset, 5 dirty marker, 6 folder basename.
build_line() {
  local level=$1 width=$BAR_WIDTH line
  (( level >= 1 )) && width=$BAR_WIDTH_NARROW
  line="🤖 ${model} | 📁 "
  if (( level >= 6 )); then line+="${folder##*/}"; else line+="$folder"; fi
  if [ -n "$branch" ]; then
    line+=" 🌿 ${branch}"
    (( level < 5 )) && line+="$dirty"
  fi
  line+=" | CTX $(render_bar "$ctx_pct" "$width")"
  (( level < 2 )) && line+=" ${ctx_pct}%"
  (( level < 3 )) && [ -n "$session_left" ] && line+=" | ↻ ${session_left}"
  if [ -n "$week_pct" ]; then line+=" | WK $(render_bar "$week_pct" "$width") ${week_pct}%"; else line+=" | WK n/a"; fi
  (( level < 4 )) && [ -n "$week_left" ] && line+=" | ↻ ${week_left}"
  printf '%s' "$line"
}

for level in 0 1 2 3 4 5 6; do
  line=$(build_line "$level")
  (( $(display_width "$line") <= term_width )) && break
done

printf '%s\n' "$line"
