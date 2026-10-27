---
name: signal-from-expert
description: 'Review a corpus of the user''s raw, unfiltered thinking (daily files, journaling, dictation) against a world-class expert''s body of work on that topic, and surface the few passages that hit his exact situation plus at least one gap where he is wrong or missing something. Manual-only. Use when the user runs /signal-from-expert with a corpus, an expert and a topic. Differentiator: pairs his own words with the expert''s exact words and file:line pointers; not a summary of the essays, not generic research.'
disable-model-invocation: true
---

# Signal from Expert

Two ingredients make this work. Both are required:

1. **Volume of the user's honest, unfiltered thinking**, it exposes exactly how they see something and their current level of understanding.
2. **A world-class expert's body of work**, several essays, articles or transcripts, read in full, reviewed against all of his thinking.

The output is relevance and clarity: the expert's exact words, mapped onto the user's exact situation, including where they are wrong.

## Inputs

The user's message names three things. If one is missing, ask for it in one plain-text question.

- **Corpus**, the files or folders of the user's own thinking to analyze (e.g. `journal/2026-08-29.md`, or `daily/` last 14 days). Read exactly that. Nothing more.
- **Expert + topic**, e.g. "Paul Graham on what to build", "Bezos on decision making".
- **URLs (optional)**, specific pieces he wants included.

## Workflow

### 1. Read the corpus in full

`cat -n` every named file. Do not skim. Do not read other files to "add context", the corpus is the corpus.

### 2. Build the source list

```bash
ls <repo>/essays/<expert-slug>/ 2>/dev/null   # reuse what is already saved
```

Then find more with DeepAPI (load the `deepapi` skill; `source ~/.deepapi/env` if the key is not set). Run 5+ separate `POST /v1/search/web` calls with different phrasings of `<expert> <topic>` (essay, talk transcript, interview, "best essays on", specific sub-questions). Pick the 5-8 pieces most relevant to the topic. Merge with the user's URLs and anything already saved.

Show the list (title + URL, one line each) and ask "go?". Do not scrape before the user answers.

### 3. Scrape and save the sources

```bash
python3 scripts/fetch-sources.py --expert "Paul Graham" --out <repo>/essays/paul-graham \
  https://paulgraham.com/startupideas.html https://paulgraham.com/schlep.html
```

One DeepAPI call for all URLs. Writes `NN-slug.md` per page (header + verbatim text, site layout junk stripped) and prints a head/tail preview per file. Check every preview: the text must start at the real first line and end at the real last line. Fix leftovers by hand; never edit the prose itself.

If `<repo>/essays/AGENTS.md` does not exist, copy `assets/essays-AGENTS.md` there and add the `CLAUDE.md` symlink.

### 4. Read every source in full

`cat -n` each saved file so you can cite `file:line` ranges. Read all of them before writing anything.

### 5. Write the analysis

Default 4 numbered items. Format, exactly:

```
# DD-MM-YYYY, Signal from <Expert>

Corpus: <files>. Sources: `essays/<expert-slug>/` (N pieces). Agent analysis, not the user's words.

---

Read all N. Here are the K that hit your exact situation, each with <Expert>'s own words and the file:line for the full passage.

## 1. <Short, plain-English claim>

<One or two lines: what the user said in the corpus, and why this passage hits it.>

> "<Exact quote, 1-4 sentences>"

Full section: `essays/<expert-slug>/NN-slug.md:START-END`

## 2. ...

**Co-founder read:** <One paragraph. What the items say together and what to do next.>
```

Rules for the items:

- **At least one item must be a gap**, a place where the expert's writing shows the user is wrong, or missing something. Mark it: `## 2. Gap: ...`. Back it with a quote like every other item.
- Quotes are the expert's exact words, short. Never long excerpts, the full text is in the saved file, the `file:line` range points to it.
- Quote the user's own corpus words when calling out a pattern or gap. Never paraphrase their reasoning.
- One claim per item. Plain English. No hedging.
- Skip anything in the corpus that is private personal life rather than the topic at hand.

### 6. Save and show

Save to `<corpus folder>/signal-<expert-slug>.md` (if the corpus is one file, its parent folder). Print the full analysis in chat. Do not commit.

## Failure modes

- **`Unknown field "url"`**, the scrape body uses `urls` (array). The script does this right.
- **Python `IncompleteRead` on DeepAPI responses**, the sandbox proxy truncates chunked responses to urllib. The script uses curl for that reason; do the same for any ad-hoc calls.
- **Page shows `truncated: true`**, re-run with a higher `--max-chars`.
- **Search returns junk**, ask the user for URLs instead of guessing.
- **Fewer than 3 sources found**, say so and ask; do not pad with weak pieces.
