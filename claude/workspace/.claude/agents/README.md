# Agents

Agents run in isolated contexts.
They do not receive the parent conversation, so every delegation must include the task, repository/branch or review base, relevant artifact, scope, constraints, acceptance criteria, and expected output.
Custom project agents receive their own prompt, project instructions, configured tools, and basic environment context.

Claude delegates based on each agent's `description`.
Use `@agent-name` when a specific specialist is mandatory.
Agent definitions are live-reloaded because this directory already exists.

## AI Team

The agent IDs stay the same.
The names are for talking about the team.

| Name | Role | Agent ID |
| --- | --- | --- |
| You | The user. Approves every plan, merge and production step. | (you) |
| Aiden | Architect | `architect` |
| Abi | Planner | `planner` |
| Jon Snow | Coder | `coder` |
| Josheb | Investigator | `investigator` |
| Malachi | Code simplifier | `code-simplifier` |
| Linus | Code reviewer | `code-reviewer` |
| Tyrion | Adversarial reviewer | `adversarial-reviewer` |
| Arya | Security reviewer | `security-reviewer` |
| Neumann | Performance reviewer | `performance-reviewer` |
| Jacaerys | Doc reviewer | `doc-reviewer` |
| Drogon | AI debt cleaner | `ai-debt-cleaner` |
| Daemon | Refactor engineer | `refactor` |
| Ada | Frontend designer | `frontend-designer` |
| Caraxes | CI/CD expert | `cicd-expert` |
| Aegon | Tofu wizard | `tofu-wizard` |
| Steve Woz | Tester | `tester` |

## Operating Model

`investigator` -> `architect` / `frontend-designer` / operational specialist -> `planner` -> user approval -> `coder` -> independent reviewers -> user review -> `/ship`

- `coder` is the only application-code writer in this workflow.
- `tester` writes only test files.
- All other agents are read-only advisors, planners, auditors, or reviewers.
  Their output is evidence for the planner and coder, not an authorization to change production behavior.
- Read-only agents use a scoped `PreToolUse` Bash guard that permits evidence gathering and validation while denying shell-side file edits, dependency changes, VCS mutations, state operations, deployments, and database migrations.
- `planner` is the binding implementation contract.
  If repository reality contradicts it, the coder stops and requests a revised plan.
- Use Context7 for version-sensitive third-party API decisions.
  Verify installed versions from manifests and lockfiles first; never guess an API signature.
- Every handoff must identify evidence, assumptions, non-goals, affected files/contracts, validation, and unresolved approval gates.
- No agent commits, pushes, deploys, creates tickets, applies infrastructure, or modifies production data without explicit user instruction.

## Agent Teams

Agent teams are enabled experimentally in `.claude/settings.json`.
Use a team only when work is genuinely independent and benefits from direct collaboration:

- Parallel research across frontend, backend, and infrastructure for a large feature.
- Parallel specialist review of a high-risk diff: security, performance, documentation, and adversarial analysis.
- Competing root-cause hypotheses during a complex incident.

Use 3-5 teammates.
Assign distinct files or analysis lenses, require plan approval before any teammate can edit, and never ask teammates to edit the same file.
Use ordinary subagents for sequential work such as investigation -> planning -> implementation.

## Routing Guide

| Agent | Use when | Output / handoff |
| --- | --- | --- |
| `investigator` | Bug, failed test, incident, or unexpected behavior | Evidence, safe reproduction, root-cause confidence, affected surface |
| `architect` | Cross-repository, integration, data-flow, submodule, or system decision | Draft architecture decision for `planner` |
| `frontend-designer` | New or changed user-facing flow, page, component, or visual system | Accessible interface design brief for `planner` |
| `cicd-expert` | Pipeline failure, CI configuration, cloud authentication, registry, runner, or deployment design | CI/CD assessment and safe remediation runbook |
| `tofu-wizard` | OpenTofu modules, state moves, account infrastructure, or provider/backend change | State-preserving infrastructure runbook |
| `planner` | Any non-trivial approved design or investigation | Draft implementation contract for `coder` |
| `coder` | An approved executable plan exists | Scoped implementation, test evidence, browser-use validation, independent review |
| `refactor` | Code is complex, hard to understand, or needs clean syntax/naming refactoring without altering logic | Refactored clean code, test evidence, behavioral parity report |
| `code-simplifier` | Code was just written or changed and should be simpler without changing behavior | Simplified code with behavior unchanged |
| `ai-debt-cleaner` | Recently changed code needs a surgical cleanup audit | Proven cleanup units for `coder` |
| `code-reviewer` | Every non-trivial final diff or pull request | Correctness, contract, plan-adherence, and test findings |
| `security-reviewer` | Sensitive boundary, input, auth, storage, logging, upload, API, dependency, or IaC change | Exploitable security and compliance findings |
| `performance-reviewer` | Query, endpoint, queue, collection, rendering, caching, or hot-path change | Evidence-backed performance findings |
| `doc-reviewer` | Docs, runbooks, release notes, API references, or developer instructions change | Documentation accuracy and safety findings |
| `adversarial-reviewer` | High-risk plan or diff needs independent failure-mode challenge | Assumption, failure-mode, and validation findings |
| `tester` | QA writes or runs automated tests for a route, screen, form, component, or helper, including a regression test for a bug fix | New test file, passing run output, plain-language summary, suggested commit message |

## Adding an Agent

Each agent must have a unique lowercase kebab-case `name`, a trigger-rich `description`, least-privilege `tools`, a narrow role, an evidence-first workflow, explicit boundaries, and a deterministic output contract.

```yaml
---
name: your-agent-name
description: Does a narrow job. Use proactively when <concrete triggers>.
tools:
  - Read
  - Grep
  - Glob
permissionMode: plan
---

State the role, what evidence to inspect, what not to do, the review or execution
steps, and the exact handoff format.
```

Use `Edit` and `Write` only for the deliberate implementation agents.
Add an MCP server or a preloaded skill only when the agent repeatedly needs it; unnecessary capabilities dilute focus and increase risk.

See [Claude Code subagent documentation](https://code.claude.com/docs/en/sub-agents) for supported frontmatter.
See [agent teams](https://code.claude.com/docs/en/agent-teams) for coordination behavior.
