---
name: qa-gate
description: One gate run of the QA pipeline. Adversarially reviews open auto-qa PRs, runs local CI, rebase-merges clean PRs, rejects with comments. Invoked via /loop 30m /qa-gate.
---

# QA Gate — one run

Work as the `qa-gatekeeper` agent persona (read `.claude/agents/qa-gatekeeper.md` and `qa/README.md` first if not in context).

## 0. Preflight
1. `qa/PAUSED` exists → heartbeat, end.
2. `gh pr list --label auto-qa --state open --json number,createdAt,labels` — none → heartbeat, end.

## 1. Per PR, oldest first (max 2 merges per run)
1. PRs labeled `human-touch` are reviewed and merged like any other — do NOT hold them for pre-merge human review. KEEP the label through the merge; it marks the PR for the user's post-merge review queue (`gh pr list --state merged --label human-touch`). Flag it prominently in the digest under "awaiting post-merge review".
2. GitHub CI green? If pending → skip this PR this run. If red → reject (step 3).
3. Check out the PR into a worktree (`gh pr checkout` inside `git worktree add`). Rebase onto latest origin/main; conflicts → reject with a rebase request comment.
4. Local CI: `flutter analyze --fatal-infos` + `flutter test`. UI diff without screenshot evidence in the PR body → reject.
5. Adversarial review per the gatekeeper standard (use the project /review skill mindset; for diffs > ~400 lines or service-layer changes be extra hostile).
6. **Clean** → `gh pr merge --rebase --delete-branch`; Linear ticket → `Done` (add comment "merged with human-touch — awaiting post-merge review" when labeled); refresh affected `qa/baselines/` if UI changed; remove the PR's worktree and local branch.
   **Findings** → PR review comment with concrete actionable items; Linear ticket → `In Progress` with a pointer comment. Third rejection of the same PR → add `human-touch` label (it still merges once clean; the label routes it to post-merge review) and PushNotification the user.

## 2. Teardown
Clean any orphaned worktrees for merged branches (`git cherry main <branch>` to verify). Heartbeat `qa/state/heartbeat-gate.txt`, commit+push to main (`chore(qa): gate run`). Summarize: merged, rejected, skipped.
