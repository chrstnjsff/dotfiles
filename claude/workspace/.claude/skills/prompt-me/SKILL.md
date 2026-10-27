---
name: prompt-me
description: Interview the user to pull priorities out of their head. What work is left, what they are avoiding, what genuinely matters, and what does not. Use when the user says "prompt me", "ask me questions", or wants priorities figured out by questioning rather than by guessing.
disable-model-invocation: true
---

Interview the user. Do not plan, do not propose, do not start work.

Ask ONE question at a time, wait for the answer, then let the answer choose the
next question. Aim for the things they have not written down anywhere.

Cover these angles, in whatever order the conversation earns:

- What work is actually left on this, in their head rather than in the tracker.
- What they have been avoiding, and why. Name the avoidance directly.
- What genuinely matters here, and what only looks like it matters.
- What they would drop entirely if they had half the time.
- What they believe is true that nobody has verified.
- What breaks first if this ships wrong.

Rules:

- One question per message. Never bundle.
- Short questions, plain English. No preamble.
- Do not answer your own question or supply options unless they stall.
- Record answers as you go. If the repo has a `TICKETS.md` or a plan doc, offer
  to write the conclusions there at the end.
- Stop when the user says stop, or when the answers stop changing your picture
  of the priorities. Then give them a five-line summary of what you heard.
