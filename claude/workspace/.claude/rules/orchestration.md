# Model Orchestration

The main session is the orchestrator.
For every step, it picks the agent, and the agent file sets the model and effort.

## Routing

| Tier | Model | Effort | Agents |
| --- | --- | --- | --- |
| Think | Opus 5.5 | high | `planner`, `architect`, `investigator`, `frontend-designer`, `cicd-expert`, `tofu-wizard`, `code-reviewer`, `adversarial-reviewer`, `security-reviewer` |
| Build | Sonnet 5.5 | high | `refactor`, `code-simplifier`, `ai-debt-cleaner`, `performance-reviewer` |
| Build | Sonnet 5.5 | medium | `coder`, `tester`, `doc-reviewer` |
| Quick | Haiku 5.5 | low | No default. Passed per call only, see below. |

- Do not pass `model` or `effort` when spawning an agent, except for the Haiku tier or when the user asks.
- Haiku tier: pass `model: "haiku"` and `effort: "low"` to `coder` or `tester` only for a plan step tagged `Executor: haiku`, and to the built-in `Explore` agent for quick code lookups.
- Use Fable 5.1 only for hard projects, and only when the user asks.

## Haiku gate

The planner tags a step `Executor: haiku` only when all of these are true:

- The step names the exact files and the exact change. No design choice is left.
- It touches at most 3 files.
- It does not touch auth, permissions, personal or regulated data, migrations, payments or billing, any flow the project marks as critical, CI/CD, or infrastructure.
- It has an exact verify command with a known expected result.

If a Haiku run fails its verify command or finds anything unexpected, it stops and reports.
Rerun that step on `coder` with no override.
Never retry on Haiku.

## Flow

- Save the approved plan as checkable items in `tasks/` (for example `tasks/<TICKET>-todo.md`) before any code changes.
  A finished plan file is not approval; wait for the user in chat.
- Pass executors the plan file path.
  The main session coordinates the work after approval; it does not edit code itself.
- If an executor finds the plan wrong or incomplete, it stops and reports.
  Send the question back to `planner`.
  Executors never change the plan.
