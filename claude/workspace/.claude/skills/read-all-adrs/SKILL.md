---
name: read-all-adrs
description: Read every ADR markdown file in the project's docs/adr/ folder so you have full context on past decisions. Use only when the user explicitly calls it.
disable-model-invocation: true
---

Read EVERY single ADR `.md` file in this project's `docs/adr/` folder, start to
finish. Not a skim, not the titles, not a sample. Every file, in full.

This is the whole point of the skill. Partially reading them and inferring the
rest defeats it, so do not summarize your way out of it.

If the repo has no `docs/adr/` folder, say so and stop rather than substituting
something else. Many repos do not have one; decision
history may live in `TICKETS.md`, the issue tracker, or the memory index. Ask the user
which of those they meant.
