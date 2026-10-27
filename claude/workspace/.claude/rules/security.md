---
alwaysApply: true
paths:
  - "src/api/**"
  - "src/auth/**"
  - "src/middleware/**"
  - "**/routes/**"
  - "**/controllers/**"
  - "**/views/**"
  - "**/serializers.py"
  - "**/permissions.py"
  - "**/tofu/**"
  - "**/*.tf"
---

# Security Rules

## Compliance and Sensitive Data (non-negotiable)

- **Encrypt at rest:** All storage that holds sensitive data (object storage, databases, volumes) must use customer-managed KMS keys (CMK).
  Never use provider-managed keys for sensitive data.
- **No public S3 buckets.**
  All buckets must have `block_public_acls = true`, `block_public_policy = true`, `ignore_public_acls = true`, `restrict_public_buckets = true`.
- **Encrypt in transit:** All inter-service communication must use TLS 1.2 or higher.
  Never disable certificate verification.
- Never log personal or regulated data.
  This includes names, dates of birth, government IDs, addresses, and health or financial details.
- Never output or commit secrets.
  Secret scanning (for example gitleaks) should run in CI; treat any secret in source as a production incident.
- Audit logs must be tamper-evident.
  Use CloudTrail with S3 Object Lock or equivalent.

## Environment Files (.env)

- **Never read, write, edit, or delete `.env`, `.env.*`, or any file in a `secrets/` directory.**
- Application `.env` files are especially sensitive: they contain database credentials, API keys, and app secrets.
- If configuration values are needed, read from environment variables or documented config files only.
- Never hardcode credentials, tokens, API keys, or connection strings in source code.

## General Application Security

- Validate all user input at the system boundary. Never trust request parameters.
- Use parameterized queries. Never concatenate user input into SQL or shell commands.
- Sanitize output to prevent XSS. Use framework-provided escaping (Django templates, Blade `{{ }}`, React JSX).
- Never use `dangerouslySetInnerHTML` without explicit sanitization.
- Authentication tokens must be short-lived (up to 1 hour).
  Store refresh tokens server-side only (httpOnly cookies or server-side session).
- Never log secrets, tokens, passwords, or PII at any log level.
- Use constant-time comparison for secrets and tokens (`hmac.compare_digest` in Python, `hash_equals()` in PHP).
- Set appropriate CORS, CSP, and security headers.
  Use the framework's security middleware (for example Django's `SecurityMiddleware`).
- Rate-limit authentication endpoints (login, password reset, 2FA).
- Use `bcrypt` or `argon2` for password hashing. Never MD5, SHA1, or SHA256 for passwords.
- Never use `Math.random()` or `random.random()` for security tokens.
  Use `secrets.token_hex()` (Python) or `Str::random()` (Laravel).

## Infrastructure (IaC)

- Always run `plan` before any `apply`.
- **Never run `apply` or `destroy` without explicit user confirmation.**
- Reuse the project's existing infrastructure modules before creating new resources.
- Tag all new cloud resources following the project's tagging standard (for example `Environment`, `Project`, `Owner`, `CostCenter`).
