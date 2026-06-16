# iOS Release → TestFlight

Prod flavor `com.aydev.nibbles`, team `32T8HNVYGX`. All Apple-specific values are read
from env / GitHub secrets, so an account transfer only swaps secret values — no code changes.

## One-time Apple setup (manual, web)

1. **App ID** — Developer portal → Identifiers → confirm/register `com.aydev.nibbles`.
2. **App record** — App Store Connect → Apps → New App (name `Nibbles`, primary language,
   bundle `com.aydev.nibbles`, SKU e.g. `nibbles-ios`).
3. **ASC API key** — Users & Access → Integrations → App Store Connect API → generate key
   with **App Manager** role. Download the `.p8` once; note **Key ID** and **Issuer ID**.
4. Confirm the **Apple Developer Program License Agreement** is current.

## Local install

Use Homebrew Ruby (system Ruby 2.6 is too old for fastlane):

```bash
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
cd ios && bundle install
```

## Validate the build today (no API key, no app record needed)

Archives the prod IPA with your local Xcode signing. Proves the app compiles + signs.

```bash
cd ios && bundle exec fastlane build_only
```

Requires `.env.prod` and `ios/Runner/GoogleService-Info.plist` (prod) present locally.

## Upload to TestFlight (needs the ASC API key from step 3)

```bash
cd ios
ASC_KEY_ID=xxxx \
ASC_ISSUER_ID=xxxx-xxxx \
ASC_KEY_CONTENT="$(base64 -i AuthKey_xxxx.p8)" \
bundle exec fastlane beta
```

`beta` auto-bumps the build number from the latest TestFlight build, then uploads.
Defaults to automatic signing; set `SIGNING=manual` to use fastlane match (CI path).

## CI (`.github/workflows/release.yml`)

Inactive until these repo secrets exist. Trigger: push a `v*` tag or run manually.

| Secret | Value |
|---|---|
| `APPLE_TEAM_ID` | `32T8HNVYGX` (changes on account transfer) |
| `ASC_KEY_ID` | API key ID (step 3) |
| `ASC_ISSUER_ID` | API issuer ID (step 3) |
| `ASC_KEY_CONTENT` | base64 of the `.p8` file |
| `ENV_PROD` | base64 of `.env.prod` |
| `GOOGLE_SERVICE_PLIST_PROD` | base64 of the prod `GoogleService-Info.plist` |
| `MATCH_GIT_URL` | private repo storing encrypted signing assets |
| `MATCH_PASSWORD` | match encryption passphrase |
| `MATCH_GIT_BASIC_AUTHORIZATION` | base64 `user:PAT` for the match repo |

Set a secret: `gh secret set ASC_KEY_ID --repo A-Y-Developments/Nibbles`.

### First-time match init (run locally, once, after step 3)

```bash
cd ios
MATCH_GIT_URL=<private-repo> APP_IDENTIFIER=com.aydev.nibbles APPLE_TEAM_ID=32T8HNVYGX \
ASC_KEY_ID=xxxx ASC_ISSUER_ID=xxxx ASC_KEY_CONTENT="$(base64 -i AuthKey_xxxx.p8)" \
bundle exec fastlane match appstore
```

## Account transfer checklist

1. App Transfer in App Store Connect (keeps bundle ID + TestFlight history) **or** recreate.
2. Regenerate the ASC API key under the new account.
3. Update secrets: `APPLE_TEAM_ID`, `ASC_*`, and re-run match init against the new team.
4. Update the `team_id` default in `ios/fastlane/Appfile` / `Matchfile` if the fallback matters.
