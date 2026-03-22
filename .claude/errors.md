# Error Rules Per Feature

| Feature | Level | Message |
|---|---|---|
| Allergen log save fails | P1 | "Couldn't save your log. Please try again." + Retry |
| Reaction modal save fails | P1 | "Couldn't save reaction. Please try again." + Retry |
| Recipe list fetch fails | P3 | Show cached. Log to Crashlytics. |
| Meal plan assignment fails | P2 | Toast: "Couldn't add to meal plan. Try again." |
| Shopping list add fails | P2 | Toast: "Couldn't add items. Try again." |
| Shopping list delete fails | P2 | Toast: "Couldn't delete item. Try again." |
| Subscription purchase fails | P1 | Show RevenueCat error verbatim |
| Subscription restore fails | P1 | "No active subscription found." |
| Auth sign up / login fails | P1 | Show Supabase error message |
| Password update fails (AU-03) | P1 | Show Supabase error inline |
| Session refresh fails (401) | P0 | Sign out + redirect to login |
| No connectivity on write | P1 | "No internet connection. Please check and try again." |
