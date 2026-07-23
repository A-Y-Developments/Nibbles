# Nibbles — Project Rules

## What is Nibbles
Guided baby solids app. iOS 15+ / Android 10+. Flutter + Supabase + RevenueCat.
Target: MVP by 2026-06-05. Urgent priority.

---

## Stack (locked)
- State: `flutter_riverpod` — AsyncNotifier pattern
- Navigation: `go_router`
- Networking: `dio` + `retrofit` (code-gen via `retrofit_generator`)
- Local: `hive_flutter` (read-through cache + flags) + `flutter_secure_storage` (JWT only)
- Code gen: `freezed`, `json_serializable`, `retrofit_generator`, `flutter_gen`, `riverpod_generator`
- Backend: `supabase_flutter` (Auth + Postgres + RLS)
- Subscriptions: `purchases_flutter` (RevenueCat)
- Analytics/Crash: `firebase_analytics` + `firebase_crashlytics`
- Font: Nunito
- Linting: `very_good_analysis` + `riverpod_lint` — zero warnings merged to main

---

## Architecture (mandatory — no exceptions)

```
Screen (ConsumerWidget)
  └── Controller (AsyncNotifier via Riverpod)
        └── Service (business logic, composes repositories)
              └── Repository
                    ├── Remote: Retrofit → Dio → Supabase REST
                    └── Local: Hive (read-through cache for recipes/allergens; local flags)
```

### Hard rules
1. **Result<T>** — all async ops return `Result<T>` (freezed `Success<T> | Failure`). No raw throws in UI. Ever.
2. **Mappers** — every Supabase response DTO maps to a domain entity before reaching Service. UI/Service never touch DTOs.
3. **Supabase** — Repository layer only. No direct Supabase calls in Service, Controller, or Screen.
4. **Hive** — 3 boxes only: `recipes`, `allergens`, `local_flags`. Read-through cache for recipes/allergens. LocalFlagService wraps `local_flags` box.
5. **JWT** — read via `Supabase.instance.client.auth.currentSession?.accessToken`. The Supabase Flutter SDK manages session persistence; do NOT reintroduce `flutter_secure_storage` or persist tokens in Hive.
6. **Online only** — no offline write queue. If no connectivity on write → P1 error.
7. **Subscription guard** — GoRouter redirect checks `SubscriptionService.isActive` on every nav event. ⚠️ Currently removed from `routes.dart` while M2 is deferred — do not treat as a bug.

---

## Code Generation

Run after any `@freezed`, `@JsonSerializable`, `@RestApi`, `@riverpod` change:

```bash
make gen        # one-shot build
make gen-watch  # watch mode during active development
```

Generated files (`*.freezed.dart`, `*.g.dart`) ARE committed to source control.

## Common Commands (Makefile)

| Command | What it does |
|---|---|
| `make gen` | `dart run build_runner build --delete-conflicting-outputs` |
| `make gen-watch` | build_runner in watch mode |
| `make run-dev` | `flutter run` with dev flavor + entry point |
| `make run-prod` | `flutter run` with prod flavor + entry point |
| `make clean` | `flutter clean && flutter pub get` |
| `make fix` | `dart fix --apply && dart format .` |

## Simulator (UI verification)

Canonical sim: **iPhone 17 / iOS 26.0** — resolve UDID by name (`xcrun simctl list devices | grep "iPhone 17 ("`), don't hardcode it; two "iPhone 17" entries exist (iOS 26.0 + iOS 26.5) so match the runtime section, not just the name.

**Build prereq:** `dart pub global activate flutterfire_cli`. Without it the Runner `upload-crashlytics-symbols` script phase fails the sim build with `flutterfire: command not found`.

Sim build + install:
```
flutter build ios --simulator --debug -t lib/main_dev.dart --flavor dev --no-codesign
```

Drive UI with `axe` only — get coordinates from `describe-ui` frames (point space) and tap at frame center. Never estimate taps by scaling screenshot pixels; screenshots are ~2.29x/2.18x the point space and the error silently misses small targets. Verify every action with a screenshot: axe exit 0 only means the gesture was delivered.

Dev test account for automated flows: see `.env.dev` (`TEST_ACCOUNT_EMAIL` / `TEST_ACCOUNT_PASSWORD`). If login returns `invalid_credentials` the account was wiped — re-seed it: `POST /auth/v1/signup` with the anon key (auto-confirmed on dev), then create the baby via the `create_baby_with_program` RPC. An auth user plus one baby row with `onboarding_completed = true` is all that's needed to land on `/home`.

---

## QA Pipeline (autonomous loops)

Five loops in separate tabs coordinate via Linear + GitHub — see `qa/README.md` for contracts (kill switch `qa/PAUSED`, heartbeats, WIP cap, sim ownership QA-Explorer/QA-Fixer, ticket state machine). Skills: `/qa-explore`, `/qa-fix`, `/qa-gate`, `/qa-coverage`, `/qa-supervise`. PRs labeled `human-touch` are never auto-merged. The fixer is authorized to use the Workflow tool for large tickets.

## Agent Roles
| Agent | Domain |
|---|---|
| `nibbles-frontend` | screens, widgets, controllers, navigation |
| `nibbles-backend` | repositories, services, Supabase queries, Hive, mappers, DTOs |
| `nibbles-infra` | flavors, Firebase, RevenueCat, deep links, runner.dart, store prep |
| `nibbles-qa` | unit tests, widget tests, integration tests |

**Single ticket:** `/linear-start NIB-xx` (skill — runs in current context, routes to correct domain agent)
**Full milestone:** use `nibbles-milestone-runner` agent

## Linear Workflow Rules

**Before working any Linear ticket**, always do this first:
1. Look up the ticket's milestone via Linear MCP.
2. Fetch all tickets in that milestone.
3. Bulk-transition any tickets still in `Backlog` → `Todo`.
4. Skip tickets already in `Todo`, `In Progress`, `Done`, or `Cancelled`.
5. Never move tickets backwards.

This applies whether starting from a single ticket (e.g. `NIB-15`) or a full milestone batch.

---

## Commit Format
`feat(scope): message` / `fix(scope): message` / `refactor(scope): message` / `chore(scope): message`

Scope = feature name: `auth` · `allergen` · `meal-plan` · `recipe` · `shopping-list` · `home` · `profile` · `infra` · `routing`

---

## Critical Don'ts
- Never call Supabase directly from Service, Controller, or Screen
- Never expose DTOs above the Repository layer
- Never store JWT in Hive
- Never throw raw exceptions from async ops — always wrap in `Result<T>`
- Never use `AllergenStatus.completed` — use `AllergenStatus.safe`
- Never add offline write queueing (out of scope for MVP 1)
- CI exists (`.github/workflows/ci.yml`: analyze + test on every PR) — green CI is required before any merge
- No staging environment (dev + prod only)
- Zero linting warnings merged to main
