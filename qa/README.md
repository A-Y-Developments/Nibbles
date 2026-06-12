# QA Pipeline

Autonomous QA pipeline: five loops running in separate Claude Code tabs, coordinating through Linear (tickets) and GitHub (PRs).

## Loops

| Loop | Skill | Cadence | What it does |
|---|---|---|---|
| Explorer | `/qa-explore` | 60 min | Drives the app on the QA-Explorer sim, runs golden flows, audits one feature area per run, files deduped Linear tickets (`Agent-QA` + `sev:*`) |
| Fixer | `/qa-fix` | 30 min | Picks the oldest highest-severity `Agent-QA` Todo ticket, fixes in a worktree, verifies on the QA-Fixer sim, opens a PR |
| Gate | `/qa-gate` | 30 min | Reviews open `auto-qa` PRs, runs local CI (analyze + test), rebase-merges clean ones, kicks findings back |
| Coverage | `/qa-coverage` | 120 min | Finds the weakest-tested module, writes unit tests, PRs through the gate |
| Supervisor | `/qa-supervise` | 60 min | Heartbeat watchdog, respawns dead loops, reseeds test data, daily digest (Linear doc + push) |

## Launch

Each loop runs in its own tab from the repo root:

```
new-claude-tab "/loop 60m /qa-explore" ~/Projects/nibbles
new-claude-tab "/loop 30m /qa-fix" ~/Projects/nibbles
new-claude-tab "/loop 30m /qa-gate" ~/Projects/nibbles
new-claude-tab "/loop 2h /qa-coverage" ~/Projects/nibbles
new-claude-tab "/loop 60m /qa-supervise" ~/Projects/nibbles
```

## Coordination contracts

- **Kill switch**: if `qa/PAUSED` exists, every loop exits immediately. `touch qa/PAUSED` to stop the world.
- **Heartbeats**: each loop writes `qa/state/heartbeat-<role>.txt` (ISO timestamp) at the end of every run. Supervisor alerts when one goes stale (> 2x cadence).
- **WIP cap**: fixer + coverage skip their run when >= 2 open PRs carry the `auto-qa` GitHub label.
- **Sim ownership**: explorer uses the sim named `QA-Explorer`, fixer uses `QA-Fixer` (resolve UDID by name via `qa/scripts/sim_udid.sh`). Never use each other's sim. The user's iPhone 17 sim stays untouched by loops.
- **Sim locks**: `qa/state/lock-<sim>.pid` while driving; clear stale locks (dead PID) before claiming.
- **Human-touch = post-merge review, not a merge block**: PRs labeled `human-touch` merge through the gate like any other; the label survives the merge and forms the user's review queue (`gh pr list --state merged --label human-touch` + the digest's "awaiting post-merge review" section).
- **Ticket states**: Explorer files in `Todo` -> Fixer moves to `In Progress` -> PR opened moves to `In Review` -> Gate merge moves to `Done`. Gate rejection moves back to `In Progress` with a comment. Never move tickets backwards otherwise.
- **Rework queue**: a rejected PR (newest "Gate rejection" comment newer than its head commit) is reworked by the fixer BEFORE it picks any new ticket, and is exempt from the WIP cap — otherwise two rejected PRs deadlock the pipeline (rejected tickets leave `Todo`, and the open PRs themselves fill the cap).

## Golden flows (`qa/flows/`)

axe batch step files (one step per line), targeted by semantic identifier (`tap --id login_email_field`). Secrets use `${VAR}` placeholders substituted from `.env.dev` at runtime (`envsubst < flow.steps`).

Status is tracked in `qa/flows/MANIFEST.md`. Flows marked `unverified` get authored/verified by the explorer in bootstrap mode (one per run) before regular sweeps begin.

| Flow | Covers |
|---|---|
| onboarding | fresh install -> intro -> register -> readiness -> baby setup -> paywall -> home |
| login | login screen -> seeded account -> home |
| allergen | start allergen, log clean x3 -> safe; log reaction -> flagged/stop path |
| allergen-complete | program completion screen (AL-08) |
| meal-plan | empty state -> setup -> choose recipe -> plan per phase |
| shopping-list | generate from meal plan, manual add, check off, delete |
| recipe-library | browse, search, filter, detail |
| profile-edit | open profile -> edit fields -> save -> verify |

## Baselines (`qa/baselines/`)

Last-known-good screenshots per screen, named `<flow>__<step>.png`. The explorer diffs against these; the gate refreshes them when intentionally merging UI changes.

## Test data

Account `test@nibbles.dev` (creds in `.env.dev`), baby "Testy". Reseed with `qa/scripts/reseed.sh` — the explorer may mutate data freely; supervisor reseeds daily.
