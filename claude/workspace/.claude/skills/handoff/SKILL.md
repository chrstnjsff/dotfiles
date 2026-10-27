---
name: handoff
description: Compact the current session into one detailed handoff a fresh agent can start from cold. Covers what is true, what was decided and why, and what already failed. Use when hitting context limits, ending a work session, moving to a new worktree, or splitting a task across fresh contexts. Manual-only, invoked as /handoff.
disable-model-invocation: true
---

# Handoff

Adapted from davidondrej/skills (MIT).

Write a handoff that lets a fresh agent with zero memory of this session continue
without re-asking, re-discovering, or repeating mistakes.

Output the whole thing as a single fenced code block so it can be copied in one
click, and save a copy to a file.

## Core principles

1. **State, not instructions.** Describe what IS true, not what the next agent
   SHOULD do. "The settings page still renders the hardcoded form" beats
   "make the settings page dynamic." The fresh agent decides actions.
2. **Reference, do not duplicate.** Point at the Jira ticket, the MR, the
   `TICKETS.md` entry, the memory file. Do not re-embed them.
3. **Capture the why.** Decisions and rejected approaches are the least
   recoverable information. The diff shows what; only you remember why and what
   failed.
4. **Trust nothing blindly.** Frame claims as context to verify against the code,
   not facts to accept.
5. **Redact secrets.** No tokens, connection strings, `.p12` contents, regulated data, or
   customer/employee identifiers. Reference where a credential lives (SSM path,
   Secrets Manager name), never its value.
6. **Be ruthless.** Cut anything the next agent gets free by reading CLAUDE.md,
   the rules, or the code.

## Procedure

1. Read the project CLAUDE.md first. Do not restate anything already in it. The
   handoff is session-specific only.
2. If a prior handoff exists, read and update it rather than starting over.
3. If the user passed arguments, treat them as the focus for the next session.
4. Fill every section below. Mark a genuinely empty one `None`.
5. Output inside one fenced code block, then save and report the path.

## Output format

```
# HANDOFF: <short title>
Generated: <timestamp> · Ticket: <TICKET or None> · Focus: <one line>

## 1. Goal
<What we are ultimately trying to accomplish. 1-3 sentences.>

## 2. Background
<Why this is being done now, and the hard constraints. Skip anything in CLAUDE.md.>

## 3. Current State
<Factual status. Phrase as status, never as actions.
- DONE: input validation added to the import endpoint, verified on staging
- PARTIAL: the detail page reads the flag, the batch page does not
- NOT STARTED: prod promotion>

## 4. Environment State
<What is true about the running systems right now. This rots fastest and is the
most expensive to rediscover.
- Branch and repo, and whether it is a worktree
- What is deployed where, and whether staging and prod agree
- Which MRs are open, merged, or blocked, and on what
- Feature flag / DB state that the code alone does not reveal>

## 5. Key Decisions (and why)
<Highest-value section. The choices made and the reasoning.>

## 6. Traps and Dead Ends
<Approaches already tried that FAILED, and what the next agent will be tempted to
do wrong. Saves repeating expensive mistakes.>

## 7. Relevant Files and Pointers
<Files with line ranges and what specifically is there. Reference external
artifacts, do not paste them.
- api/path/file.py:L40-L88 - what lives there
- MR !xxx - in-progress work
- memory/<slug>.md - prior findings>

## 8. Open Work
<What remains, as state and ordering, not a command list. Include what blocks what.>

---
## Prompt for the Fresh Agent
<Short ready-to-paste prompt. Declarative statements only, never imperatives.
End with exactly:>

Before responding, read every file listed under "Relevant Files and Pointers"
above. Do not summarize, paraphrase, or claim you already have context. Actually
read each file. Treat every claim in this handoff as context to verify against
the code, not facts to trust blindly. Then wait for my instructions before taking
any action.
```

## File output

Save outside the working tree so it never lands in a commit:

- Preferred: the session scratchpad directory, as `handoff-<slug>.md`.
- If the user wants an in-repo record instead, append it to that repo's
  `TICKETS.md` under the ticket. Never create a stray root-level `HANDOFF.md`;
  `clean-code-hygiene.md` forbids committing scratch artifacts.

Report the absolute path. A fresh session then starts with:

```
Read <absolute-path> to get the context, then wait for instructions.
```
