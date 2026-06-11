---
name: qa-explore
description: One explorer run of the QA pipeline. Builds the app if stale, runs verified golden flows on the QA-Explorer sim, audits one feature area, files deduped Linear tickets. Invoked via /loop 60m /qa-explore.
---

# QA Explore — one run

Work as the `qa-explorer` agent persona (read `.claude/agents/qa-explorer.md` and `qa/README.md` first if not already in context). Everything below happens in the main repo checkout, read-only except `qa/`.

## 0. Preflight
1. If `qa/PAUSED` exists → write heartbeat, say "paused", end run.
2. Resolve sim: `UDID=$(qa/scripts/sim_udid.sh QA-Explorer)`. Boot if not booted.
3. Lock: if `qa/state/lock-explorer.pid` exists and its PID is alive → end run (previous run still going). Else write own PID.
4. `git fetch origin main`. If `origin/main` SHA differs from `qa/state/last_build.sha` OR app not installed on sim: `flutter build ios --simulator --debug -t lib/main_dev.dart --flavor dev`, `simctl install`, record SHA to `qa/state/last_build.sha`.

## 1. Bootstrap mode (while flows remain unverified)
If `qa/flows/MANIFEST.md` has any `unverified` flow: author exactly ONE this run.
- Drive the flow manually via axe (identifier taps preferred), screenshot every step.
- Save working steps to `qa/flows/<flow>.steps` (secrets as `${VAR}` placeholders).
- Replay it via `envsubst < qa/flows/<flow>.steps | axe batch --stdin --udid $UDID` to prove determinism, verify end screenshot.
- Mark `verified` in MANIFEST, save end-state screenshots to `qa/baselines/`.
- If blocked (e.g., missing identifiers, paywall wall): mark `blocked`, file a `sev:major` ticket describing exactly what the app needs (e.g., dev-only skip, missing `Semantics(identifier:)`), commit qa/ changes directly to main (qa/-only commits skip the PR pipeline: `chore(qa): ...`).

## 2. Golden flow sweep (verified flows)
Fresh app state: `simctl terminate` + relaunch (or uninstall/reinstall when the flow needs first-launch state). Run each verified flow via axe batch with `envsubst`. Screenshot after each flow; compare against `qa/baselines/` (visual diff: load both images and compare yourself). Any failure or hard drift → `sev:critical`/`sev:major` ticket with evidence.

## 3. Audit rotation (one area per run)
Read `qa/state/rotation.txt` (create with the flow list from MANIFEST if missing), pick the next area, write the pointer back. Deep-audit that area per the hunt list in the agent definition, including Figma comparison via `qa/figma-map.yaml` (file `sev:trivial` mapping ticket if the map lacks this screen).

## 4. File findings
Load Linear tools via ToolSearch. Dedup against open `Agent-QA` issues. File per the agent definition's ticket standard.

## 5. Teardown
Reseed if data left dirty (`qa/scripts/reseed.sh`). Remove lock. Write ISO timestamp to `qa/state/heartbeat-explorer.txt` and commit qa/ state changes to main (`chore(qa): explorer run`). Push. Summarize: flows run, pass/fail, tickets filed.
