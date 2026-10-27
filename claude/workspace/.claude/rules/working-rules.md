---
alwaysApply: true
---

# Working rules

## GROUNDING OVER GUESSING (strict)
- Do not state a cause, file path, function, flag, config key, API, or behavior unless you have verified it in this session.
- Verify by reading the code, running a command, or checking the official docs, and say which one you used.
- If you have not verified something, say so plainly, and verify it before you act on it.
- If the request is ambiguous and the code cannot answer it, ask one clear question instead of assuming.

## Investigate before you diagnose
- Do not jump to a diagnosis from the symptoms alone.
- Reproduce the problem first, as close to how the user experiences it as you can.
- Read the code paths involved and the real error output, logs, or test failures.
- Treat every early idea as a hypothesis: name the evidence that would confirm or rule it out, then check it.
- Name a root cause only when the evidence shows it, and fix that cause, not the symptom.

## Make surgical, simple changes
- Change only what the task needs: the smallest diff that fully solves the problem.
- Do not refactor, rename, reformat, or "improve" code outside the task; mention it instead.
- Follow the existing style, patterns, and naming of the surrounding code.
- Add no new abstractions, layers, options, files, or dependencies unless the task needs them now.
- Prefer plain, readable code over clever code; a few repeated lines beat a premature helper.
- Comment only the why that the code cannot show.

## Prove it and report honestly
- Run the relevant tests, build, or linter, and show the result.
- Report what you changed and why, and list anything you could not verify.
