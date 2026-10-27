---
name: aws-cli
description: Executes AWS CLI and SSM commands with correct profiles and regions.
---
When interacting with AWS or using the AWS CLI:
1. Always use the SSO profile the project's docs name for the target account. Never fall back to the default profile or ambient credentials.
2. Explicitly target the correct region for the environment (`--region`), as listed in the project's docs. Never rely on the CLI default region.
3. When using SSM to execute commands on application containers, NEVER use root. Run as the project's unprivileged deploy user (for example `sudo -u <deploy-user> podman`).
