# Nibbles — App Flow Diagrams

> **Audience:** Client-facing. Plain language. One diagram per use case.
> **Last updated:** 2026-04-09

---

## Overview — All Features & Screens

High-level map of every major screen and how they connect.

```mermaid
flowchart LR
  SPLASH[Splash Screen]

  SPLASH --> INTRO[Welcome Screens]
  SPLASH --> LOGIN[Login]
  SPLASH --> HOME[Home Dashboard]

  INTRO --> LOGIN
  LOGIN --> REGISTER[Register]
  LOGIN --> FORGOT[Forgot Password]
  FORGOT --> RESET[Reset Password]
  RESET --> LOGIN

  LOGIN --> HOME
  REGISTER --> BABY[Baby Setup Wizard]
  BABY --> HOME

  HOME --> ALLERGEN[Allergen Tracker\n🔜 coming soon]
  HOME --> MEALPLAN[Meal Plan\n🔜 coming soon]
  HOME --> RLIB[Recipe Library]
  HOME --> PROF[Profile]

  RLIB --> RDETAIL[Recipe Detail]
  RDETAIL --> SHOPPING[Shopping List]
  RDETAIL --> MEALPLAN

  PROF --> PROFEDIT[Edit Profile]
  PROF --> LOGIN

  SHOPPING --> RLIB
```

---

## 1. App Launch & Redirect Logic

Every time the app opens, it checks these conditions in order before deciding where to send the user.

```mermaid
flowchart LR
  A[App Opens] --> B[Loading Screen\n3-second initialisation]
  B --> C{First time\nopening the app?}

  C -- Yes --> D([Mark app as launched\nso this only runs once])
  D --> E[Welcome Screens]
  E --> F[Login Screen]

  C -- No --> G{Logged in?}
  G -- No --> H[Login Screen]

  G -- Yes --> I[Sync settings\nfrom server]
  I --> J{Completed readiness\nquestionnaire?}
  J -- No --> K[Readiness Questionnaire]

  J -- Yes --> L{Baby profile\ncreated?}
  L -- No --> M[Baby Setup Wizard]
  L -- Yes --> N[Home Screen]

  K --> L
  M --> N
```

---

## 2. Onboarding — Welcome Screens

Shown only the very first time the app is opened.

```mermaid
flowchart LR
  A[Welcome Screen 1\nNibbles logo + tagline\n'Your guide to introducing solids'] --> B[tap 'Get Started']
  B --> C[Welcome Screen 2\nFeatures overview:\nAllergen tracking · Meal planning · Recipes]
  C --> D[tap 'Next']
  D --> E[Login Screen]
```

---

## 3. Onboarding — Readiness Questionnaire

A 6-question check to confirm the baby is physically ready to start solids. Only runs once.

```mermaid
flowchart LR
  A[Readiness Questionnaire\nShows 1 question at a time] --> B[/Answer 'Yes' or 'I'm not sure'\nTap Next — repeats for all 6 questions/]
  B --> C{Any 'I'm not sure'\nanswers?}
  C -- All answered 'Yes' --> D([Questionnaire marked as done])
  D --> E[Baby Setup Wizard]
  C -- At least one 'I'm not sure' --> F[Warning Screen\n'Not quite ready yet?'\nMedical advisory shown]
  F --> G{User decides}
  G -- tap 'Go Back' --> B
  G -- tap 'I Understand, Continue' --> D
```

---

## 4. Onboarding — Baby Setup Wizard

3-step wizard to create the baby's profile. Runs after the readiness questionnaire, or right after creating a new account.

```mermaid
flowchart LR
  A[Step 1 of 3\nWhat's your baby's name?] --> B[/Type baby's name/]
  B --> C[tap 'Next']
  C --> F[Step 2 of 3\nWhen was your baby born?]
  F --> G[/Scroll date picker\nSelect date of birth/]
  G --> H[tap 'Next']

  H --> I[Step 3 of 3\nWhat's your baby's gender?]
  I --> J[/Tap a gender option:\nMale · Female · Prefer not to say/]
  J --> K[tap 'Let's go!']

  K --> L[Saving baby profile...]
  L --> M{Saved\nsuccessfully?}
  M -- No --> N([Show error message\nTap 'Let's go!' again to retry])
  N --> K
  M -- Yes --> O([Baby profile created])
  O --> P[Home Screen]
```

---

## 5. Auth — Register (New Account)

```mermaid
flowchart LR
  A[Register Screen] --> B[/Fill in: Name · Email · Password/]
  B --> C[tap 'Sign Up']

  C --> D{All fields\nvalid?}
  D -- No --> E([Show field errors below each input\ne.g. 'Password must be at least 8 characters'])
  E --> B

  D -- Yes --> F[Creating account...]
  F --> G{Account\ncreated?}
  G -- No --> H([Show error message\ne.g. 'Email already in use'])
  H --> B

  G -- Yes --> I[Baby Setup Wizard\nStep 1: Name]
  I --> J[Home Screen]

  A --> K[tap 'Already have an account? Log In']
  K --> L[Login Screen]
```

---

## 6. Auth — Login

```mermaid
flowchart LR
  A[Login Screen] --> B[/Enter Email + Password/]
  B --> C[tap 'Log In']

  C --> D{Fields\nvalid?}
  D -- No --> E([Show field errors\ne.g. 'Please enter a valid email'])
  E --> B

  D -- Yes --> F[Checking credentials...]
  F --> G{Login\nsuccessful?}
  G -- No --> H([Show error message\ne.g. 'Incorrect email or password'])
  H --> B

  G -- Yes --> I[Loading Screen\nSyncs saved settings from server]
  I --> J{Onboarding\ncomplete?}
  J -- No --> K[Continue Onboarding\nReadiness or Baby Setup — whichever is pending]
  J -- Yes --> L[Home Screen]

  A --> M[tap 'Forgot your password?']
  M --> N[Forgot Password Screen]

  A --> O[tap 'Sign Up']
  O --> P[Register Screen]
```

---

## 7. Auth — Forgot Password

```mermaid
flowchart LR
  A[Forgot Password Screen\nEnter your email] --> B[/Type email address/]
  B --> C[tap 'Send Reset Link']

  C --> D{Valid email\nformat?}
  D -- No --> E([Show: 'Please enter a valid email'])
  E --> B

  D -- Yes --> F[Sending reset link...]
  F --> G{Email sent\nsuccessfully?}
  G -- No --> H([Show error message])
  H --> B

  G -- Yes --> I[Confirmation Screen\n'Check your email'\nReset link has been sent]
  I --> J[tap 'Back to Login']
  J --> K[Login Screen]
```

---

## 8. Auth — Reset Password (via email link)

The user taps the link in their email, which opens the app directly to this screen.

```mermaid
flowchart LR
  A[User taps link in email] --> B[Reset Password Screen\n'Create a new password']
  B --> C[/Enter new password\nEnter confirm password/]
  C --> D[tap 'Confirm']

  D --> E{Passwords valid\nand match?}
  E -- No --> F([Show error:\n'Min 8 characters' or 'Passwords do not match'])
  F --> C

  E -- Yes --> G[Saving new password...]
  G --> H{Password\nupdated?}
  H -- No --> I([Show error message])
  I --> C

  H -- Yes --> J([Show notification:\n'Password updated. Please log in.'])
  J --> K[Login Screen]
```

---

## 9. Main App — Tab Bar Navigation

Once onboarding is complete, the user lands in the main app. A tab bar at the bottom is always visible and lets the user switch between the 4 main sections.

```mermaid
flowchart LR
  A[Onboarding complete\nor logged in] --> B[Main App\nBottom tab bar always visible]

  B --> C[tap Home tab]
  B --> D[tap Meal Plan tab]
  B --> E[tap Shopping List tab]
  B --> F[tap Recipe Library tab]

  C --> G[Home Dashboard]
  D --> H[Meal Plan\n🔜 coming soon]
  E --> I[Shopping List]
  F --> J[Recipe Library]
```

---

## 10. Home Dashboard

The main screen after login. Shows baby info, today's meal, allergen progress, and recipe picks.

```mermaid
flowchart LR
  A[Home Screen] --> B{Data\nloaded?}
  B -- Loading --> C([Shows loading spinner])
  B -- Error --> D([Shows error message + Retry button])
  D --> B

  B -- Loaded --> E[Shows:\n• Baby's name + age stage\n• Allergen introduction card\n• Today's meal section\n• Recipe recommendations]

  E --> F[tap avatar or baby name]
  F --> G[Profile Screen]

  E --> H[tap recipe card\nor 'See All' recipes]
  H --> I[Recipe Library]

  E --> J[tap recipe card\nin recommendations]
  J --> K[Recipe Detail]

  E --> L[tap allergen card\nor 'Log Food Today' button]
  L --> M[Allergen Tracker\n🔜 coming soon]

  E --> N[tap 'Plan a Meal'\nin empty meal section]
  N --> O[Meal Plan\n🔜 coming soon]
```

---

## 11. Profile

```mermaid
flowchart LR
  A[Profile Screen] --> B{Data\nloaded?}
  B -- Loading --> C([Shows loading spinner])
  B -- Error --> D([Shows error + Try Again])
  D --> B

  B -- Loaded --> E[Shows:\n• Baby's name, age, gender\n• Subscription label\n• List of discovered safe allergens]

  E --> F{Safe allergens\nexist?}
  F -- No --> G([Shows: 'No safe allergens confirmed yet'])
  F -- Yes --> H([Shows allergen tags with emoji])

  E --> I[tap 'Edit']
  I --> J[Edit Profile Screen]

  E --> K[tap 'Sign Out']
  K --> L{Confirm\nsign out?}
  L -- No --> E
  L -- Yes --> M[Signing out...]
  M --> N[Login Screen]
```

---

## 12. Edit Profile

All fields are pre-filled with the current baby profile. The user only needs to change what they want.

```mermaid
flowchart LR
  A[Edit Profile Screen\nPre-filled with current data] --> B[/Edit any of:\n• Baby's name\n• Date of birth\n• Gender/]
  B --> C[tap 'Save']

  C --> D[Saving...]
  D --> E{Saved\nsuccessfully?}
  E -- No --> F([Show error message below form\nRetry by tapping Save again])
  F --> B

  E -- Yes --> G([Show: 'Profile updated' notification])
  G --> H[Back to Profile Screen\nwith updated data]
```

---

## 13. Recipe Library

Browse all recipes, or search by name or allergen tag.

```mermaid
flowchart LR
  A[Recipe Library] --> B{Data\nloaded?}
  B -- Loading --> C([Shows loading spinner])
  B -- Error --> D([Shows error message\nPull down to refresh])
  D --> B

  B -- Loaded --> E{Any recipes\navailable?}
  E -- No --> F([Shows: 'No recipes available right now\nCheck back after completing more allergen steps'])

  E -- Yes --> G[Shows recipes grouped in sections\ne.g. '6–9 months' · 'Breakfast Ideas']

  G --> H[/Type in search bar/]
  H --> I{Results\nfound?}
  I -- Yes --> J([Shows matching recipe cards])
  I -- No --> K([Shows: 'No recipes found for that search'])

  G --> L[tap a recipe card]
  J --> L
  L --> M[Recipe Detail]

  G --> N[pull down to refresh]
  N --> B

  H --> O[tap clear ×\nor clear search bar]
  O --> G
```

---

## 14. Recipe Detail

Full recipe view with options to add ingredients to the shopping list or assign the recipe to a meal plan date.

```mermaid
flowchart LR
  A[Recipe Detail] --> B{Data\nloaded?}
  B -- Loading --> C([Shows loading spinner])
  B -- Error --> D([Shows error + Retry])
  D --> B

  B -- Loaded --> E[Shows:\n• Hero image\n• Title + recommended age range\n• Allergen tags with colour-coded status\n• Ingredients list\n• Step-by-step instructions\n• How to serve\n• Notes if any]

  E --> F[tap 'Add to Shopping List']
  F --> G[Ingredient picker opens\nShows all ingredients\nAll pre-checked]
  G --> H[/Toggle checkboxes\nto select or deselect ingredients/]
  H --> I[tap 'Add X items']
  I --> J{Added\nsuccessfully?}
  J -- Yes --> K([Notification: 'Added to shopping list'])
  K --> E
  J -- No --> L([Notification: 'Couldn't add items. Try again.'])
  L --> G

  E --> M[tap 'Add to Meal Plan']
  M --> N[Calendar picker\nSelect a date]
  N --> O{Add a specific\nmeal time too?}
  O -- Skip --> P[Saving to meal plan...]
  O -- Add Time --> Q[Time picker\nSelect breakfast · lunch · dinner · snack]
  Q --> P
  P --> R{Saved\nsuccessfully?}
  R -- Yes --> S([Notification: 'Added to meal plan'])
  S --> E
  R -- No --> T([Notification: 'Couldn't add to meal plan. Try again.'])
  T --> E

  E --> U[tap back button]
  U --> V[Previous Screen\nHome or Recipe Library]
```

---

## 15. Shopping List

A two-tab list: **List** (items still to buy) and **Bought** (checked-off items). Items can come from recipes or be added manually.

```mermaid
flowchart LR
  A[Shopping List] --> B{Data\nloaded?}
  B -- Loading --> C([Shows loading spinner])
  B -- Error --> D([Shows error + Retry])
  D --> B

  B -- Loaded --> E{Any items\nin the list?}
  E -- No --> F([Empty state:\n'Browse recipes to get started'])
  F --> G[tap 'Browse recipes']
  G --> H[Recipe Library]

  E -- Yes --> I[Two tabs:\nList: items still to buy\nBought: items already checked off]

  I --> J[/Type item name\ntap 'Add'/]
  J --> K{Added\nsuccessfully?}
  K -- Yes --> L([Item appears in List tab])
  K -- No --> M([Notification: 'Couldn't add items. Try again.'])

  I --> N[tap checkbox\non a List item]
  N --> O([Item moves to Bought tab\nShown with strikethrough])

  I --> P[tap checkbox\non a Bought item]
  P --> Q([Item moves back to List tab])

  I --> R[tap trash icon\nor swipe item left]
  R --> S{Confirm delete?}
  S -- No --> I
  S -- Yes --> T{Deleted\nsuccessfully?}
  T -- Yes --> U([Item removed from list])
  T -- No --> V([Notification: 'Couldn't delete item. Try again.'])

  I --> W[tap ⋯ menu top right]
  W --> X{Choose action}
  X -- Copy list to clipboard --> Y([Notification: 'Copied to clipboard'\nAll item names copied as text])
  X -- Clear entire list --> Z{Confirm\nclear all?}
  Z -- No --> I
  Z -- Yes --> AA{Cleared\nsuccessfully?}
  AA -- Yes --> AB([Both tabs empty])
  AA -- No --> AC([Notification: 'Couldn't clear list. Try again.'])
```

---

*Nibbles — Guided baby solids app. iOS 15+ / Android 10+.*
