#!/usr/bin/env bash
# Inject a humanizer reminder when the prompt asks Claude to write a reply or message to someone.
prompt=$(jq -r '.prompt // empty' | tr '[:upper:]' '[:lower:]')
[ -z "$prompt" ] && exit 0

asks_for_reply='(craft|draft|write|compose|prepare|create|make|suggest|give me|help me with|rewrite|reword|polish)[^.?!]{0,40}(reply|replies|response|message|email|e-mail|dm|comment|text|note|follow[- ]?up|answer|announcement)'
reply_to_someone='(^|[^a-z])(reply|respond|answer|get back)( back)? to '
not_a_reply='(commit message|error message|log message|api response|http response|json response|response (body|code|schema|handler|time))'

echo "$prompt" | grep -Eq "$asks_for_reply|$reply_to_someone" || exit 0
echo "$prompt" | grep -Eq "$not_a_reply" && exit 0

jq -n '{hookSpecificOutput: {hookEventName: "UserPromptSubmit", additionalContext: "The user wants a reply, response, or message written for another person. Before giving the final text, invoke the humanizer:humanizer skill with the Skill tool and run your draft through it in embedded mode: return only the final humanized text, ready to paste. Keep the facts, names, and tone the user gave; add nothing new. If the user shared a sample of their own writing or the message being answered, match that voice."}}'
