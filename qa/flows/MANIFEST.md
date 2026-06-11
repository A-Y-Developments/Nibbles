# Flow Manifest

Bootstrap order for the explorer. Status: `verified` (replayable via axe batch) | `unverified` (needs authoring) | `blocked` (waiting on a fix).

| Flow | File | Status | Note |
|---|---|---|---|
| login | login.steps | verified | identifiers verified 2026-06-10. Since NIB-144 the flow ends on the PAYWALL, not home (tap Try for $0 at 201,732 to proceed — stub entitlement, resets every cold launch). Known flake: axe type drops characters intermittently (email truncated to `test@nib` on 2026-06-11) — verify the email field value after batch and retry once. |
| onboarding | onboarding.steps | blocked | paywall has no dev skip — NIB-150 (In Review) |
| allergen | allergen.steps | verified | replay-verified 2026-06-11. Preconditions: reseed.sh run, logged-in account, cold relaunch (starts at paywall). Covers dairy clean-x3 -> Safe and tree-nuts reaction -> Flagged. Mostly coordinate taps: `allergen_start_introduce_button` id is duplicated across rows (axe refuses ambiguous --id) and the AX tree lags visual updates after saves inside batch. End baseline: baselines/allergen__end.png. |
| allergen-complete | allergen_complete.steps | unverified | needs account state near completion |
| meal-plan | meal_plan.steps | unverified | |
| shopping-list | shopping_list.steps | unverified | |
| recipe-library | recipe_library.steps | unverified | |
| profile-edit | profile_edit.steps | unverified | |
