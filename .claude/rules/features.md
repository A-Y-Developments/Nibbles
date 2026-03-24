# Feature Module Pattern (every feature, no exceptions)

```
<feature>/
├── <feature>_controller.dart   # AsyncNotifier / Notifier (Riverpod)
├── <feature>_state.dart        # @freezed state class
├── <feature>_screen.dart       # ConsumerWidget root screen
└── widgets/                    # sub-widgets scoped to this feature
```

## All feature paths

| Path | Screen |
|---|---|
| `splash` | Boot, session check, redirect |
| `onboarding/intro` | OB-01 + OB-02 |
| `onboarding/readiness` | OB-03 to OB-09 |
| `onboarding/baby_setup` | OB-11 to OB-13 |
| `auth/register` | Sign up |
| `auth/login` | Log in |
| `auth/forgot_password` | Forgot password |
| `auth/reset_password` | AU-03 — password reset via deep link |
| `subscription/paywall` | SB-01 |
| `home` | HM-01 Dashboard |
| `allergen/tracker` | AL-01 + AL-02 |
| `allergen/detail` | AL-03 |
| `allergen/reaction_log` | AL-06 modal |
| `allergen/complete` | AL-08 (shown once per baby) |
| `meal_plan` | MP-01 |
| `recipe/library` | RC-01 |
| `recipe/detail` | RC-02 |
| `shopping_list` | SL-01 |
| `profile` | PR-01 |
| `profile/edit` | PR-02 |
