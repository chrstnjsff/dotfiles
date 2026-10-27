# Debugging & Log Investigation

When encountering any bugs, crashes, or issues with the application or its services, **always check the Docker or container logs immediately** as your very first step before attempting to write code or propose fixes.

## Guidelines:
- **No Destructive Changes**: Do NOT restart services, reset databases, or make any destructive infrastructure changes while investigating.
  Your first priority is purely diagnostic.
- **Check Container Logs**: Use Docker log commands (e.g., `docker compose logs -n 100 <service-name>` or `docker logs <container-id>`) to identify the exact stack trace or error message causing the issue.
- **Identify the Root Cause**: Always pinpoint the exact error line in the logs to easily identify the problem before you begin fixing it.
