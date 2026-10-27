---
alwaysApply: true
---

# Clean Code & Repo Hygiene

Applies to every implementation language the project uses (for example Python, JS/TS, PHP, Terraform/OpenTofu, Bash, YAML).

- **Clean, self-documenting code first.**
  Clear names over cleverness.
  See `code-quality.md` for anti-defaults, naming, and file organization.
- **Comments short and concise, prefer *why* over *what*.**
  One line at most where a name can't carry the meaning.
  No block banners, no commented-out code, no outdated narration (`code-quality.md`: WHY comments only, no dead code).
- **Never commit throwaway work.**
  Ad-hoc test/debug scripts (root-level `test_*.py`, `check_*.py`, `*_probe*.py`), scratch logs, `.bak` files, generated schemas, and one-off deploy helpers stay local.
  `.gitignore` them and never add them to a commit.
  Real, kept tests live in the proper `tests/` tree (and those DO get committed).
- **Never commit secrets.**
  No keys, tokens, `.p12`/certs, `.env` values, or connection strings in git or history.
  Load them from a secret store (for example AWS SSM Parameter Store or Secrets Manager) at runtime.
  Run secret scanning (for example gitleaks); a committed secret is a production incident.
  See `security.md`.
- **Refactor continuously to prevent tech debt.**
  Follow the discipline at https://refactoring.guru/refactoring/what-is-refactoring: small, behavior-preserving improvements while you're already in the code, verified by tests.
  Don't defer cleanup to a "later" backlog.
