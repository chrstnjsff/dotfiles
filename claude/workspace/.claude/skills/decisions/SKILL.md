---
name: decisions
description: List the choices you made during the current work that you are NOT confident about, so the user can review them before the change ships. Manual-only, invoked as /decisions. Retrospective; for choices not yet made use /next-decision.
disable-model-invocation: true
---

While working on this, which decisions did you make that you are not confident about?

Reason through every consequential choice, then ask whether a better alternative
existed that was not considered.

Rules:

- Do NOT list choices where the current solution is clearly the best one. Silence
  on a decision means you stand behind it.
- Only list decisions you are genuinely unsure about.
- For each: what you chose, the alternative, and why you are unsure. One or two
  lines each.
- Call out explicitly any decision that touches sensitive-data handling, tenant scoping,
  signing or approval flows, migrations, or cloud cost, even if you are only mildly unsure.
  Those are the expensive ones to get wrong.

Answer in short, plain English. Be very concise.
