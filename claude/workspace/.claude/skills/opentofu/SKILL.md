---
name: opentofu
description: Runs OpenTofu plan safely against a single account root, on the host.
---
When asked to run infrastructure changes:
1. NEVER run `tofu apply` directly.
2. NEVER run `tofu destroy` without user confirmation.
3. `cd` into the exact account root you are changing (for example `tofu/accounts/<org>/<env>`), then `export AWS_PROFILE=<profile>` and `aws sso login --profile "$AWS_PROFILE"`. If the roots set no provider `profile`, `AWS_PROFILE` is the only credential selector.
4. Always run `tofu fmt` and `tofu validate` before `tofu plan`.
5. Read the output and summarize the infrastructure changes.

Run `tofu` on the host. Do not run it in a container.

On an existing checkout the first `tofu init` needs `-reconfigure`, never `-migrate-state`: bucket, key, region and lock table are unchanged, so accepting a migration prompt risks copying state between keys.

Profiles and regions per account are listed in the project's docs.

Offline check without credentials: `tofu init -backend=false && tofu validate`.
