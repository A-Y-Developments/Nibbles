---
name: qa-supervise
description: One supervisor run of the QA pipeline. Heartbeat watchdog, respawns dead loops, reseeds test data, cleans stale state, compiles the daily digest to Linear + push notification. Invoked via /loop 60m /qa-supervise.
---

# QA Supervise — one run

You are the pipeline's manager. You never write app code.

## 0. Kill switch
`qa/PAUSED` exists → write own heartbeat, end (the pause also applies to you, except you still note it in your summary).

## 1. Health check
`git pull origin main` first (heartbeats arrive via commits). For each role (explorer 60m, fixer 30m, gate 30m, coverage 120m): read `qa/state/heartbeat-<role>.txt`. Stale > 2x cadence → **first determine stalled vs dead via claude-peers** (load `mcp__claude-peers__list_peers` scope `repo` via ToolSearch):
- **Peer ALIVE** (role's session still listed, recent last-seen) = STALLED, not dead. DO NOT respawn — respawning a live-peer loop creates a DUPLICATE process (this caused a duplicate fixer on 2026-06-14). Instead: `send_message` a nudge asking it to re-invoke its skill + re-arm its loop, record the incident, and leave further action (kill+respawn) to the coordinator/user. Re-nudge at most once per run.
- **Peer GONE** (role's session absent from list_peers) = genuinely DEAD. Only then respawn: `CLAUDE_TAB_FLAGS="--dangerously-skip-permissions" new-claude-tab "/loop <cadence> /qa-<role>" ~/Projects/nibbles <model>` (model: fixer opus, coverage/supervisor sonnet, else omit). Verify exactly one process after (`pgrep -f "/qa-<role>"`); if two, you spawned a duplicate — kill the new one.
1. Send a PushNotification naming the dead/stalled loop.
Record the incident for the digest.

## 2. Hygiene
- Stale sim locks in `qa/state/lock-*.pid` (dead PID) → delete.
- Linear tickets `In Progress` with no activity > 2h and no open PR → back to `Todo` with a comment.
- Worktrees/branches whose PRs merged (`git cherry main <branch>` empty) → `git worktree remove` + `git branch -D`.
- Disk: delete `/tmp` QA screenshots older than 2 days.
- Daily (first run after 06:00): run `qa/scripts/reseed.sh`.

## 3. Digest (first run after 07:00 local, else skip to teardown)
Compile since last digest: PRs merged (`gh pr list --state merged --label auto-qa`), tickets opened/closed by severity (Linear), stuck items (`human-touch` PRs, repeated rejections, blocked flows in `qa/flows/MANIFEST.md`), loop health incidents. Update the Linear document "QA Pipeline Digest" (id `5afba812-62a4-444f-b0fb-02af4dbb721d`) — prepend the new digest under "Latest digest", keep prior digests below. Send a PushNotification with the 3-line summary.

## 4. Teardown
Heartbeat `qa/state/heartbeat-supervisor.txt`, commit+push (`chore(qa): supervisor run`). Summarize health + actions.
