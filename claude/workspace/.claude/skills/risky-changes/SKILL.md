---
name: risky-changes
description: Verification discipline for a change that rests on an unverified assumption about real data or real user behavior. Fires BEFORE implementing anything that changes what tenants see, what gets signed, what gets billed, or what infrastructure costs. Validates that the change is a good IDEA, using research and live measurement. Tests only prove the code does what you coded, so they do not count here.
---

# Risky Changes

Adapted from the "unit tests cannot prove a change is a good idea" discipline
(davidondrej/skills, MIT). Rewired for this workspace: no external research API, measurement
comes from production and staging reads.

Tests prove the code does what you coded. They cannot prove the change is correct
about the world. That takes research and live measurement.

This failure mode is common:

- A seed script links every record to every tenant. Every test passes, and
  tenants start seeing each other's data.
- A cost cut based on one metric looks obviously correct, and the metric turns
  out to be the wrong signal.
- A request field is renamed on one side only. The endpoint still returns 200
  and silently saves an empty value.

## When this fires

Any change where being wrong is expensive, tenant-visible, or hard to unwind:

- Organization or state scoping on forms, documents, or templates
- Feature flag flips, including per-document dynamic form flips
- Anything touching a signing, approval, or other legally or financially binding flow
- Seed fixture and reconciliation logic (it re-runs on every deploy)
- Migrations that rescope, backfill, or delete rows
- Payroll, vacation pay, billing, or anything with a computed money total
- Email recipient routing and notification triggers
- Defaults, thresholds, PDF generator selection, document precedence
- AWS instance sizing, storage classes, retention, and lifecycle rules
- CI template version pins consumed by other repos

If you are unsure whether a change qualifies, it qualifies.

## The process

### 1. Name your assumptions out loud

Write down every assumption the change rests on. For each: "have I verified this,
or does it just sound reasonable?" Sounding reasonable is how the org-scoping bug
shipped.

### 2. Research the ones you cannot verify from the repo

- Version-sensitive framework, cloud, or infrastructure-tool behavior goes to
  Context7. Never guess an API signature.
- Check the project's known-bugs notes and the memory index for the same symptom.
  Several of these assumptions may already have been disproven once.
- Read the actual call sites. An assumption about "how the frontend uses this" is
  verified by grep across the API and client repos, not by reasoning.

If research contradicts the assumption, stop and rethink before writing code.

### 3. Measure against real data, not fixtures

Read production and staging state before and after. Follow the read-only rules:
a read-only path such as SSM plus a read-only dump, never a prod shell, never a write.

```bash
# profile and region come from the project's docs
AWS_PROFILE=<profile> rtk aws ssm send-command \
  --region <region> \
  --document-name AWS-RunShellScript \
  --targets "Key=instanceids,Values=<instance-id>" \
  --parameters 'commands=["<read-only dump or management command>"]'
```

What to measure:

- How many rows the change actually affects, in prod, right now. A change that
  "only affects a few edge cases" usually does not.
- The real distribution, not the expected one. Count per organization, per state,
  per tenant. Skew is where these bugs hide.
- Staging versus production state for the same objects. They drift, and a fix
  verified only on staging can be a no-op or a regression in prod.
- Before and after, when both are measurable.

Record the numbers in `docs/evals/YYYY-MM-DD-<area>-<focus>.md` in the repo you
are changing. Create the folder if missing. A change with no measurement file is
not verified.

### 4. Get a human decision on anything tenant-visible

If a technical choice shapes what a tenant sees, signs, or is charged, surface it
as a question before shipping, with the numbers attached. Never bury it in a plan
or a code default. For anything touching regulated or sensitive data visibility, the answer is a
compliance decision, not an engineering one.

### 5. Verify after deploy

Within a day of deploy, re-read the same measurement against real traffic. If the
numbers disagree with the expectation, say so immediately rather than waiting for
someone to report it.

## Failure modes

- "The tests pass." Irrelevant to whether the change is a good idea. Measure.
- "The assumption is obviously true." That is exactly the assumption this skill
  exists for.
- "It works on staging." Staging and prod can diverge in code, config and data.
  Read both.
- "The migration is safe, it only adds a column." Check whether a seed
  reconciliation loop will overwrite it on the next deploy.
