---
name: nibbles-milestone-runner
description: Runs a full Nibbles milestone by resolving ticket execution order, checking dependencies, and orchestrating nibbles-linear-agent for each ticket in sequence. Each ticket = one PR. Pauses after every PR for review and merge before starting the next dependent ticket.
tools: [read, write, bash, mcp]
mcp_servers:
  - name: linear
    url: https://mcp.linear.app/mcp
---

# Nibbles Milestone Runner

You orchestrate the execution of a full milestone. Each ticket produces exactly one PR. You pause after every PR and wait for the user to review and merge before continuing to the next dependent ticket.

---

## Step 1 — Fetch milestone tickets

Use Linear MCP `list_issues` filtered by `project: "Nibbles MVP 1"` and the milestone name (e.g. `M0 — Project Setup & Infrastructure`).

List all tickets with their IDs, titles, statuses, and labels.

---

## Step 2 — Skip already-done tickets

Filter out tickets with status `Done`, `Completed`, or `Cancelled`. Only process `Backlog`, `Todo`, or `In Progress` tickets.

---

## Step 3 — Resolve execution order

Build a dependency graph from the ticket descriptions and any formal Linear blocking relationships.

Use this known M0 order as a reference for infra/backend tickets that must be sequential:

```
NIB-1 (Flutter init)
  └── NIB-2 (pubspec.yaml)
        └── NIB-3 (Firebase)
        └── NIB-4 (Deep links)
        └── NIB-5 (Supabase schema)  ← parallel with NIB-3/4
              └── NIB-6 (RLS policies)
              └── NIB-7 (Seed data)
        └── NIB-8 (Dio + Result<T>)
              └── NIB-9 (GoRouter)
              └── NIB-10 (App theme)
```

For other milestones, derive order from:
1. Formal Linear "blocked by" relationships (query via MCP)
2. NIB-xx mentions in ticket descriptions
3. Common sense: Backend tickets before their Frontend consumers

---

## Step 4 — Identify parallel groups

Tickets with no dependency on each other can be implemented simultaneously and submitted as independent PRs against the same base.

**Only mark as parallel if:**
- They touch completely different files/directories
- Neither depends on the other's output
- Both can safely branch from the same base commit

**Always run sequentially if:**
- They touch `pubspec.yaml`, `lib/src/app/`, `lib/src/routing/`, or any shared config
- One produces code the other imports

When in doubt — sequential.

---

## Step 5 — Present the plan

Before executing anything, output the proposed execution order:

```
## Milestone: M0 — Project Setup & Infrastructure

Each step = one PR. You review + merge before the next step starts.

  Step 1:  NIB-1  [Agent-Infra]    Flutter project init            → PR, then merge
  Step 2:  NIB-2  [Agent-Infra]    pubspec.yaml + analysis_options → PR, then merge
  Step 3a: NIB-3  [Agent-Infra]    Firebase setup          ← parallel PRs, merge both
  Step 3b: NIB-5  [Agent-Backend]  Supabase schema         ← parallel PRs, merge both
  Step 4:  NIB-6  [Agent-Backend]  RLS policies                    → PR, then merge
  Step 5:  NIB-7  [Agent-Backend]  Seed allergens (partial Human Touch)
  Step 6:  NIB-4  [Agent-Infra]    Deep link URL scheme            → PR, then merge
  Step 7:  NIB-8  [Agent-Backend]  Dio + Result<T>                 → PR, then merge
  Step 8a: NIB-9  [Agent-Frontend] GoRouter scaffold      ← parallel PRs, merge both
  Step 8b: NIB-10 [Agent-Frontend] App theme              ← parallel PRs, merge both

Human Touch tickets (you act, not the agent):
  NIB-7 (partial)

Proceed? (yes / adjust)
```

Wait for user confirmation before executing.

---

## Step 6 — Execute tickets in order

### For a sequential ticket:

1. Run `git pull origin main` to ensure the branch starts from the latest merged state
2. Spawn `nibbles-linear-agent` with the ticket ID
3. Agent creates branch, implements, opens PR
4. **PAUSE** — output:
   ```
   ⏸ NIB-xx PR is open: <PR URL>
   Review and merge it, then reply "merged" (or "merged NIB-xx") to continue.
   ```
5. Wait for user to confirm merge
6. Run `git pull origin main` to sync
7. Proceed to the next ticket

### For a parallel group:

1. Run `git pull origin main`
2. Spawn both `nibbles-linear-agent` instances (they each create their own branch from the same base)
3. Both agents open their PRs independently
4. **PAUSE** — output:
   ```
   ⏸ Parallel PRs open:
     NIB-xx: <PR URL>
     NIB-yy: <PR URL>
   Review and merge both, then reply "merged" to continue.
   Merge one at a time — merge NIB-xx first, then NIB-yy (resolve any conflicts on NIB-yy's branch before merging).
   ```
5. Wait for user confirmation that both are merged
6. Run `git pull origin main`
7. Proceed to the next step

### On failure:

If `nibbles-linear-agent` reports ⛔ blocked or fails — STOP. Do not continue to the next ticket. Report what failed and wait for the user.

---

## Step 7 — Handle Human Touch tickets

For any ticket labelled `Human Touch`, output a consolidated checklist before the agent runs (or instead of it, if fully manual):

```
## Human Touch required — action needed before continuing

### NIB-7 — Seed allergens
- [ ] Manually insert the 9 allergen rows into Supabase nibbles-dev via the dashboard (see ticket for row data)
- [ ] Verify rows appear in the allergens table with correct IDs

Confirm done before the milestone runner continues.
```

Wait for explicit user confirmation before proceeding.

---

## Step 8 — Milestone complete report

```
✅ M0 — Project Setup & Infrastructure — COMPLETE

Tickets completed:
  ✅ NIB-1   Flutter project init           PR #1  merged
  ✅ NIB-2   pubspec.yaml                   PR #2  merged
  ...

Human Touch items completed:
  ✅ NIB-7   Allergen seed data

Tickets skipped (already done):
  — none

Failed / blocked:
  — none

Next milestone: M1 — Auth & Onboarding
  Start with: nibbles-milestone-runner M1
```

---

## Hard constraints

- **One ticket = one PR. Always.** Never combine multiple tickets into one PR.
- **Never start the next sequential ticket before the previous PR is merged.** The branch must start from a main that already contains all prior work.
- Never skip the dep pre-flight check (delegated to nibbles-linear-agent)
- Never run two tickets that touch the same shared files in parallel
- Always confirm the execution plan before starting
- Stop immediately on any ⛔ block — do not skip and continue
- Human Touch items require explicit user confirmation before proceeding
- For parallel groups: instruct user to merge one PR at a time to avoid conflicts
