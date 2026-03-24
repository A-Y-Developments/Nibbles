---
name: linear-start
description: Nibbles-specific linear ticket workflow. Fetches ticket, runs dependency pre-flight, explores code, creates branch, routes to correct domain agent, opens PR. Overrides global linear-start for this project.
---

# /linear-start — Nibbles Ticket Workflow

Ticket ID: `$ARGUMENTS`

---

## ⚠️ Anti-hallucination rules — read first

- Never infer, recall, or fabricate ticket data. Everything must come from Linear MCP.
- After fetching, output the raw title, status, labels, and description before doing anything else.
- If Linear MCP is unavailable or returns an error — STOP. Report: "Linear MCP unavailable. Cannot proceed."

---

## Step 1 — Fetch ticket

Make two MCP calls in parallel immediately:
1. `get_issue(id: "$ARGUMENTS", includeRelations: true)` — title, description, acceptance criteria, labels, priority, milestone, relations
2. `list_comments(issueId: "$ARGUMENTS")` — clarifications or decisions

Output now:
```
Ticket: <ID> — <title>
Status: <status>
Labels: <labels>
Description:
<description text>
Relations: <blocked_by entries if any>
```

Do not proceed until this is shown.

---

## Step 2 — Dependency pre-flight ⛔

**Never skip.**

### 2a. Extract blockers
- From `relations`: entries where `type == "blocked_by"` → collect `relatedIssue.identifier`
- From the **fetched** description text: any `NIB-\d+` patterns
- Union both sets

### 2b. Fetch all dependency statuses in parallel
Call `get_issue` for each dep simultaneously.

### 2c. Classify

| Status | Classification |
|---|---|
| Done / Completed / Cancelled | ✅ Clear |
| In Progress | ⚠️ Warn |
| Backlog / Todo / Unstarted | ⛔ Blocked |

### 2d. Decide

**⛔ Any blocked deps → STOP:**
```
⛔ BLOCKED — cannot start <ID> until:
  ⛔ <dep-id>  [<status>]  <title>
Finish these first, then re-run.
```

**⚠️ Only in-progress deps → ask user:**
```
⚠️ WARNING — in progress but not done:
  ⚠️ <dep-id>  [In Progress]  <title>
1. Wait (recommended)
2. Proceed anyway
```
Wait for response.

**✅ All clear → proceed.**

---

## Step 3 — Clarify if needed

If description is ambiguous or missing acceptance criteria — list questions and wait. Do not assume.

Read any Figma links or spec docs referenced in the fetched description now.

---

## Step 4 — Load project context

Read `.claude/CLAUDE.md`. This is mandatory.

Only read `.claude/context/PROJECT_CONTEXT.md` if the ticket is large, multi-step, or touches cross-cutting concerns (routing, auth, shared services). Skip for small, well-scoped tickets.

---

## Step 5 — Explore relevant code

Use grep, glob, and file reads to find all files this ticket will touch.

- Small ticket: read only directly affected files (controller, service, repo, screen)
- Large ticket: map all relevant files and dependencies before writing anything

Start narrow, expand only if you find unexpected coupling. Show the user what you found.

---

## Step 6 — Assess scope

| Ticket type | Path |
|---|---|
| Small / well-defined | Implement directly (no plan needed) |
| Large / multi-step | Create a written plan → show user → get approval → implement |
| Unclear | Ask user |

---

## Step 6b — Create task list

After scope is assessed (and plan approved if large), create tasks with `TaskCreate` to track the remaining steps:

- One task per logical implementation unit (e.g. "Implement AllergenRepository", "Build AllergenDetailScreen", "Wire routing")
- Plus fixed tasks at the end: "QA tests", "Review", "PR + Linear update"

Mark each task **done immediately** when that unit of work completes. Do not batch.

---

## Step 7 — Route to domain agent

Use the ticket's **labels** field (from Step 1 MCP response — not title text):

| Label | Agent to spawn |
|---|---|
| `Agent-Frontend` | `nibbles-frontend` |
| `Agent-Backend` | `nibbles-backend` |
| `Agent-Infra` | `nibbles-infra` |
| `Agent-QA` | `nibbles-qa` |
| `Human Touch` | STOP — output checklist, do not automate |

Fallback: if no agent label, check title prefix `[Frontend]` / `[Backend]` / `[Infra]` / `[QA]`. If still unclear — ask.

Tell the user which agent will be spawned and why.

---

## Step 8 — Create branch

```
git checkout -b <type>/<ticket-id>-<short-slug>
```
- Type from label: `feat`, `fix`, `chore`
- Slug: 2–4 word kebab from ticket title
- Must include the ticket ID

---

## Step 9 — Mark In Progress

Set ticket status to **In Progress** via Linear MCP.

---

## Step 10 — Implement

Spawn the domain agent identified in Step 7. Pass it:
- The full ticket description and acceptance criteria
- The branch name
- The list of relevant files found in Step 5
- Any plan approved in Step 6

After the domain agent completes:
1. Mark implementation task(s) done via `TaskUpdate`
2. Spawn `nibbles-qa` on affected files (skip if this is a QA ticket) → mark "QA tests" task done
3. Run `/review` on all uncommitted changes → mark "Review" task done
4. If review flags Must Fix → spawn domain agent to resolve → re-run `/review`

---

## Step 11 — Commit, push, and open PR

Run `/pr-finish`. Do NOT ask for confirmation — execute immediately.

After PR is created:
- Add PR URL as attachment on the ticket via Linear MCP: `create_attachment(issueId, url, title: "PR")`
- Set ticket status to **In Review** via Linear MCP
- Mark "PR + Linear update" task done

---

## Step 12 — Report

```
✅ <ID> — <title>

Branch:  <branch>
PR:      <URL>
Agent:   <agent used>

What was built:
- <bullet>

Deviations: <any or "none">
Manual steps: <any or "none">
```

---

## Hard constraints

- First action is always the Step 1 MCP fetch — no analysis before real data
- Never skip pre-flight (Step 2)
- Never start while ⛔ blocked tickets exist
- Never implement Human Touch items
- Branch name must include ticket ID
- Always invoke `commit-push-pr` skill at Step 11 — never skip
- Keep ticket status in sync at each major step
- If ticket has no acceptance criteria — ask before building
- If Linear MCP is unavailable — STOP. Do not proceed.
- Never call Supabase directly from Service, Controller, or Screen
- Never expose DTOs above the Repository layer
- Never use `AllergenStatus.completed` — use `AllergenStatus.safe`
- Zero linting warnings
