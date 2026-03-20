Base directory for this skill: /Users/adithyafp_/Projects/nibbles/.claude/skills/screen

# /screen — New Flutter Screen

Creates a complete feature module scaffold: screen + controller + state, following Nibbles conventions.

## Input
- Feature path (e.g. `allergen/detail`, `auth/login`, `meal_plan`)
- Screen name in PascalCase (e.g. `AllergenDetail`, `Login`, `MealPlan`)
- Controller type: `async` (AsyncNotifier — has async data) or `sync` (Notifier — sync state only). Default: `async`

## Steps

### 1. Resolve file paths
- Screen: `lib/src/features/<feature_path>/<snake_name>_screen.dart`
- Controller: `lib/src/features/<feature_path>/<snake_name>_controller.dart`
- State: `lib/src/features/<feature_path>/<snake_name>_state.dart`
- Widgets dir: `lib/src/features/<feature_path>/widgets/`

### 2. Check for existing files
If any of the 3 files already exist — warn the user and stop. Do not overwrite.

### 3. Create state file

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part '<snake_name>_state.freezed.dart';

@freezed
class <ScreenName>State with _$<ScreenName>State {
  const factory <ScreenName>State({
    // TODO: add fields
  }) = _<ScreenName>State;
}
```

### 4. Create controller file

**AsyncNotifier (default):**
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '<snake_name>_state.dart';

part '<snake_name>_controller.g.dart';

@riverpod
class <ScreenName>Controller extends _$<ScreenName>Controller {
  @override
  FutureOr<<ScreenName>State> build() async {
    return const <ScreenName>State();
  }
}
```

**Notifier (sync):**
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '<snake_name>_state.dart';

part '<snake_name>_controller.g.dart';

@riverpod
class <ScreenName>Controller extends _$<ScreenName>Controller {
  @override
  <ScreenName>State build() {
    return const <ScreenName>State();
  }
}
```

### 5. Create screen file

**AsyncNotifier screen:**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '<snake_name>_controller.dart';

class <ScreenName>Screen extends ConsumerWidget {
  const <ScreenName>Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(<snakeName>ControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('<Screen Name>')),
      body: state.when(
        data: (data) => const SizedBox.shrink(), // TODO: implement
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }
}
```

**Notifier screen:**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '<snake_name>_controller.dart';

class <ScreenName>Screen extends ConsumerWidget {
  const <ScreenName>Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(<snakeName>ControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('<Screen Name>')),
      body: const SizedBox.shrink(), // TODO: implement using state
    );
  }
}
```

### 6. Create widgets directory
Create `lib/src/features/<feature_path>/widgets/.gitkeep` if the widgets dir doesn't exist.

### 7. Print route snippet (do NOT auto-write — show for user to paste)

```
Add to lib/src/routing/routes/<area>_routes.dart:

GoRoute(
  path: '/<feature-path-slug>',
  name: Routes.<screenNameCamelCase>.name,
  builder: (context, state) => const <ScreenName>Screen(),
),
```

### 8. Remind to run codegen
```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## Constraints
- Always `ConsumerWidget` — never `StatefulWidget` for screens
- Controller always `@riverpod` + `extends _$<Name>Controller`
- State always `@freezed`
- Never add business logic in screen — delegate to controller
- Never import DTOs or repository classes in screen files
- Match feature path to the feature list in CLAUDE.md
