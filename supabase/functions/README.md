# Supabase Edge Functions

Deno + Supabase Functions runtime. Each function lives in its own folder;
`_shared/` holds cross-function helpers.

```
functions/
  _shared/cors.ts                 # shared CORS headers
  generate-meal-plan/
    index.ts                      # AI meal-plan generator
    deno.json                     # import map (supabase-js pin)
  delete-account/
    index.ts                      # hard account deletion (service role)
    deno.json                     # import map (supabase-js pin)
```

---

## generate-meal-plan

First edge function in the repo. Generates an AI meal plan by selecting from the
existing `recipes` pool, honouring the baby's age/stage and allergen history.

### What it does

1. Verifies the caller's JWT (401 if missing/invalid).
2. Reads, via a **JWT-bound client** (RLS-enforced, so only the caller's own
   data is visible): the `babies` row (name, DOB) and all `allergen_logs` for
   the baby. `recipes` are public-read, so no service role is used.
3. Computes `ageMonths` (whole months), the meal **stage** and **meals/day**
   target (clamped 1..3), and per-allergen status mirroring the app
   (`deriveStatusForLogs`: any reaction → flagged, ≥3 clean → safe, ≥1 → in
   progress, none → not started).
4. Builds an OpenAI Chat Completions request (JSON mode) with the baby context,
   per-allergen status, and the recipe pool, asking the model to fill each day
   up to the meals/day target.
5. **Validates the model output server-side**: keeps only assignments whose
   `recipeId` exists in the pool, drops any recipe containing a **flagged**
   allergen, and drops `dayOffset` outside `[0, dayCount-1]`.
6. Returns `{ assignments: [...] }`. Under-filling is acceptable (soft target);
   an empty valid result returns `502`.

The OpenAI key is read from `Deno.env.get("OPENAI_API_KEY")` and is never
hardcoded, logged, or returned in a response.

### Request / response contract

`POST /functions/v1/generate-meal-plan`

Headers: `Authorization: Bearer <user JWT>`, `Content-Type: application/json`.

Request body:

```json
{
  "babyId": "uuid",
  "startDate": "2026-07-07",
  "endDate": "2026-07-13",
  "preferences": ["Iron-rich puree", "Quick to make"],
  "notes": "No repeats on the same day, please."
}
```

- `babyId` — required, must be a baby the caller owns (RLS).
- `startDate` / `endDate` — required, `yyyy-MM-dd`; `endDate >= startDate`.
  Inclusive; `dayCount = end - start + 1` (capped at 60).
- `preferences` — optional `string[]` (preset labels; ignored if empty).
- `notes` — optional free-text string.

Success `200`:

```json
{
  "assignments": [
    { "recipeId": "e0000000-0000-0000-0000-000000000001", "dayOffset": 0 },
    { "recipeId": "e0000000-0000-0000-0000-000000000004", "dayOffset": 1 }
  ]
}
```

`dayOffset` is `0..dayCount-1` relative to `startDate`. Every `recipeId` is
guaranteed to exist in `recipes` and to be allergen-safe (no flagged allergen).

Error responses `{ "error": "<message>" }`:

| Status | When                                            |
| ------ | ----------------------------------------------- |
| 400    | missing/invalid body, dates, or range           |
| 401    | missing / invalid JWT                           |
| 404    | baby not found (or not owned by caller)         |
| 405    | non-POST method                                 |
| 500    | server misconfig or a DB read error             |
| 502    | OpenAI failure or no valid assignments produced |

### Environment / secrets

`SUPABASE_URL` and `SUPABASE_ANON_KEY` are injected by the runtime. Only the
OpenAI values must be set as secrets:

| Name             | Required | Default       |
| ---------------- | -------- | ------------- |
| `OPENAI_API_KEY` | yes      | —             |
| `OPENAI_MODEL`   | no       | `gpt-4o-mini` |

---

## delete-account

Hard-deletes the caller's account and **all** their data. Replaces the old
soft-delete (`request_account_deletion` RPC), which is left in the schema but no
longer called by the app.

### What it does

1. Verifies the caller's JWT (401 if missing/invalid) and resolves the uid from
   the token — never from the request body.
2. Via a **JWT-bound client** (RLS-enforced), inserts the churn `reason` into
   `account_deletion_requests`. Best-effort: a failure here is logged but does
   not block the deletion.
3. Via a **service-role client**, calls `auth.admin.deleteUser(uid)`. The
   `auth.users` row is deleted, which `ON DELETE CASCADE`s:
   - `babies` → `allergen_logs` → `reaction_details`, `allergen_program_state`,
     `meal_plans`, `meal_plan_entries`, `shopping_list_items`
   - `consents`
   - `feedback` and the `account_deletion_requests` audit row are
     `ON DELETE SET NULL`, so they survive with `user_id = NULL`.
4. Returns `{ "success": true }`.

The service-role key is read from `Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")`
(auto-injected by the runtime) and is never returned or logged.

### Request / response contract

`POST /functions/v1/delete-account`

Headers: `Authorization: Bearer <user JWT>`, `Content-Type: application/json`.

Request body: `{ "reason": "I achieved my goal already" }` (`reason` required).

Success `200`: `{ "success": true }`.

Error responses `{ "error": "<message>" }`:

| Status | When                                     |
| ------ | ---------------------------------------- |
| 400    | missing/invalid body or empty `reason`   |
| 401    | missing / invalid JWT                    |
| 405    | non-POST method                          |
| 500    | server misconfig or the delete failed    |

### Environment / secrets

All three are auto-injected by the runtime — no secrets to set:
`SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY`.

---

## Human-run commands (auth-gated — run these yourself)

Set the secret(s) on the linked project (dev or prod):

```bash
supabase secrets set OPENAI_API_KEY=sk-...            # required
supabase secrets set OPENAI_MODEL=gpt-4o-mini          # optional override
```

Serve locally (uses a local `.env` for the OpenAI key — do NOT commit it):

```bash
supabase functions serve generate-meal-plan --env-file ./supabase/functions/.env.local
```

`supabase functions serve` verifies JWTs by default; invoke with a real user
access token in the `Authorization` header.

Deploy:

```bash
supabase functions deploy generate-meal-plan
supabase functions deploy delete-account     # no secrets needed
```

Deploy targets whichever project is currently linked (`make link-dev` /
`make link-prod`). Set the secret on each project you deploy to.

`delete-account` also needs its migration applied so the reason-audit row
survives deletion:

```bash
supabase db push        # applies 20260708000001_account_deletion_hard.sql
```
