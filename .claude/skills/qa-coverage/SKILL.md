---
name: qa-coverage
description: One coverage run of the QA pipeline. Finds the weakest-tested service/controller/mapper, writes unit tests, opens an auto-qa PR. Invoked via /loop 2h /qa-coverage.
---

# QA Coverage — one run

## 0. Preflight
1. `qa/PAUSED` exists → heartbeat, end.
2. WIP cap: >= 2 open `auto-qa` PRs → heartbeat, end.

## 1. Pick target
`flutter test --coverage` from a fresh worktree off origin/main, parse `coverage/lcov.info`. Rank `lib/src/common/services/`, `lib/src/common/data/` (repos + mappers), and feature controllers by uncovered lines — exclude generated files (`*.g.dart`, `*.freezed.dart`) and pure UI widgets. Pick the worst SINGLE file not already covered by an open PR or `Agent-QA` coverage ticket.

## 2. Write tests
Follow existing conventions in `test/` (mocking style, fakes like `test/support/fake_analytics.dart`, naming). Test behavior, not implementation: Result success/failure paths, mapper edge cases, error-level mapping per `.claude/rules/error-handling.md`. No comments in code. Tests must be deterministic — no network; mock repositories/Supabase boundaries.

## 3. PR
`flutter analyze --fatal-infos` clean, `flutter test` green, coverage of the target file meaningfully up (state before/after % in the PR body). Commit `chore(qa): unit tests for <file>`, push, `gh pr create` with label `auto-qa`. File a Linear ticket (`Agent-QA` + `sev:trivial`, state `In Review`) referencing the PR for traceability.

## 4. Teardown
Heartbeat `qa/state/heartbeat-coverage.txt` from the main checkout, commit+push (`chore(qa): coverage heartbeat`). Summarize target, before/after coverage, PR.
