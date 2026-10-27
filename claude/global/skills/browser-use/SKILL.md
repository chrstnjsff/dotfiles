---
name: browser-use
description: Headless browser tool for local stack E2E checks in the workspace and its repos (localhost and other local stacks). Claude in Chrome is the tool for staging and prod checks, where the user logs in. Use for E2E checks, UI verification after a user-facing change, click-throughs, screenshots, and mobile-width checks on a local stack. Drives a separate headless test Chrome over CDP. Not for running the existing Playwright suites (`npx playwright test`).
---

# browser-use

Drives a separate test Chrome over CDP with the `browser-use` CLI (0.13.11, installed with `uv tool install`).
Based on the upstream skill: https://github.com/browser-use/browser-use/blob/main/skills/browser-use/SKILL.md

## Rules

- Use this for every browser E2E check against a local stack. Write the test scenario first (persona, preconditions, numbered steps, expected result per step, evidence to capture), then run it.
- Use Claude in Chrome for staging and prod checks, where the user logs in. Use this skill on staging only when the user asks, and assert the host after every navigation. Do not use the CMUX browser or one-off Playwright, Puppeteer, or raw CDP scripts for browser checks.
- One browser check at a time. All calls share one daemon that follows one tab, so never run `bu.sh` from parallel subagents.
- The project's existing Playwright suites stay. Run them with their own `npx playwright test` commands.
- Always call it through `bu.sh` (below). It pins `BU_NAME=e2e-test` and `BU_CDP_URL=http://127.0.0.1:9333`, so it never touches the user's everyday Chrome.
- Never unset those variables, enable `chrome://inspect` remote debugging, or run `mac-approve`.
- No cloud browsers: no `start_remote_daemon`, `browser-use auth`, Browser Use Cloud, or its `qa` skill. Staging pages can show sensitive data.
- Telemetry stays off. Do not run `browser-use telemetry enable`, `--update`, `skill install`, or `recordings enable`.
- Log in only with local or staging test accounts. Pass passwords from env vars and never print them. If no test account is known, stop and ask.
- Print only what the check needs, not whole pages.

## Usage

```bash
~/.claude/skills/browser-use/scripts/bu.sh <<'PY'
new_tab("http://localhost:3000")
wait_for_load()
print(page_info())
PY
```

- `bu.sh` starts the headless test Chrome (profile `~/.cache/e2e-test-chrome`) when it is not running, then runs `browser-use`.
- To watch it: `pkill -f 'e2e-test-chrom[e]'`, then run with `HEADED=1`.
- Helpers are pre-imported. The daemon keeps the attached tab between calls, so call `new_tab(url)` once per task, then `goto_url(url)`.
- Reuse tabs with `current_tab()`, `list_tabs()`, `switch_tab()`. Close tabs you opened when the task is done.
- Single-page apps finish `wait_for_load()` before they render. Call `wait_for_element(selector, visible=True)` for real content before you assert or screenshot.

## Page workflow

- Find elements with the accessibility tree: `cdp("Accessibility.getFullAXTree")["nodes"]` gives role, name, and `backendDOMNodeId`. Filter in Python before printing.
- Coordinates: `q = cdp("DOM.getBoxModel", backendNodeId=n)["model"]["content"]; x, y = sum(q[0::2])/4, sum(q[1::2])/4`, then `click_at_xy(x, y)`.
- Type with `type_text("...")`, or `fill_input(selector, text)`. Keys with `press_key("Enter")`.
- Verify each action with a targeted `js(...)` or `page_info()` check.
- Screenshots: `capture_screenshot("<scratchpad>/shot.png")`, then read the file. Save them in the session scratchpad, never in a repo. Use them whenever layout or visuals matter, and look for anything that is off.
- Raw CDP: `cdp("Domain.method", param=value)`. Parameters are keywords; the second positional argument is a session id.

## Mobile widths

```python
cdp("Emulation.setDeviceMetricsOverride", width=390, height=844, deviceScaleFactor=3, mobile=True)
cdp("Emulation.setTouchEmulationEnabled", enabled=True, maxTouchPoints=5)
goto_url(url); wait_for_load()
print(cdp("Page.getLayoutMetrics")["cssLayoutViewport"]["clientWidth"])
cdp("Emulation.clearDeviceMetricsOverride")
cdp("Emulation.setTouchEmulationEnabled", enabled=False)
```

- Check width with `cssLayoutViewport`, not `innerWidth`; a scroll lock can inflate `innerWidth`.
- Headless Chrome on macOS uses overlay scrollbars, so classic-scrollbar overflow bugs do not show. Say so instead of claiming a pass.
- Always clear the override when done; it stays on the tab.

## Troubleshooting

- `bu.sh --doctor` checks the install and connection.
- `BU_CDP_URL ... unreachable`: the test Chrome is down. Run `bu.sh` again; it restarts it.
- Stuck daemon: `bu.sh --reload`, then run again.
- Hard browser mechanics (iframes, uploads, dialogs, downloads, shadow DOM): https://github.com/browser-use/browser-harness/tree/main/interaction-skills
