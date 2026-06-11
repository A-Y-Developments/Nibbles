---
name: qa-fix
description: One fixer run of the QA pipeline. Picks the oldest highest-severity Agent-QA ticket in Todo, fixes it in a worktree, verifies on the QA-Fixer sim, opens an auto-qa PR. Invoked via /loop 30m /qa-fix.
---

# QA Fix — one run

## 0. Preflight
1. `qa/PAUSED` exists → heartbeat, end.
2. WIP cap: `gh pr list --label auto-qa --state open` — if >= 2, heartbeat, end.
3. Pick ticket: Linear (via ToolSearch) open issues, label `Agent-QA`, state `Todo`, order `sev:critical` > `sev:major` > `sev:trivial`, oldest first. None → heartbeat, end.
4. Move ticket to `In Progress`.

## 1. Fix
- `git fetch origin main`. Worktree: `git worktree add .claude/worktrees/<ticket> -b fix/<ticket-id> origin/main`.
- Read the ticket evidence carefully; reproduce understanding from the code (read before any change — architecture rules in CLAUDE.md are mandatory: Result<T>, repos-only Supabase, mappers, no comments).
- Route by domain: UI → follow `nibbles-frontend` conventions; data/services → `nibbles-backend`. Add `Semantics(identifier:)` to any widget you touch that automation will need.
- **Large tickets** (multi-screen, > ~5 files, or a rebuild): you are authorized to use the Workflow tool to orchestrate subagents (understand → implement → self-review). Keep the worktree as the working copy.
- Run `make gen` if codegen-annotated files changed. `dart format` touched files. `flutter analyze --fatal-infos` must be clean. `flutter test` must pass.

## 2. Verify on sim (mandatory — no screenshot, no PR)
Resolve `qa/scripts/sim_udid.sh QA-Fixer`, boot if needed. Build the worktree (`flutter build ios --simulator --debug -t lib/main_dev.dart --flavor dev`), install, drive to the affected screen via axe, capture before-claim screenshots proving the fix. If the ticket's flow has a `verified` steps file, replay it.

## 3. PR
- Commit (`fix(<scope>): <ticket-id> <symptom>`), push, `gh pr create` with: ticket link, what changed, screenshot evidence embedded, label `auto-qa` (create label on first use). If the ticket carries `Human Touch`, also add the `human-touch` PR label.
- Ticket → `In Review` with PR link comment.

## 4. Teardown
Keep the worktree (gate cleans up after merge). Write the heartbeat to `qa/state/heartbeat-fixer.txt` in the MAIN checkout (never the worktree) and commit+push it to main as `chore(qa): fixer heartbeat`. Summarize: ticket, PR, evidence.
