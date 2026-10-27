# AWS CLI Guidelines

Whenever you need to run AWS CLI commands, use the correct profile for the project by prefixing your commands with `AWS_PROFILE=<profile>`.
The user adds the project's profiles and accounts after joining.
Until then, ask which profile and account to use. Do not guess.

## Profiles
- Profiles and account IDs: <fill in after joining>

## SSO Login
Before running commands, you may need to log in via SSO.
Run `aws sso login --profile <profile>` for the profile you need.

## SSM Sessions (`aws ssm start-session`)
Start SSM sessions only against instances the user has named or approved.
You can export the profile or prefix it on the command.
For example:
`export AWS_PROFILE=<profile>; aws ssm start-session --target <instance-id> --region <region>`

## SSM Commands (`aws ssm send-command`)
Always include the correct `--region` flag explicitly.
Take the region for each environment from the project's documentation or the user, not from memory.
