# Nibbles UI/UX + Architecture Audit

Generated from 42 screens, 5 POVs (UI/UX, Flutter arch, QA behavior, A11y, Assets).

## Summary

| Metric | Value |
|---|---|
| Screens audited | 42 |
| Total triaged findings | 1346 |
| P0 (architecture violation) | 14 |
| P1 (major UX/behavior) | 226 |
| P2 (secondary drift/UX) | 519 |
| P3 (polish) | 587 |
| Auto-fixable (conf >= 0.85, single-file) | 241 |
| Cross-POV consensus (2+ POVs agreed) | 150 |

### Top Categories

- `semantics`: 189
- `layout-drift`: 153
- `form-submission`: 106
- `missing-reusable`: 105
- `state-coverage`: 87
- `hardcoded-constants`: 81
- `ad-hoc-component`: 68
- `navigation`: 62
- `separation-of-concerns`: 50
- `asset-placement`: 49

---

## P0 — Architecture Violations (fix before merge)

These break the Controller -> Service -> Repository contract defined in CLAUDE.md.

### AddToShoppingListModal and RangeAddToShoplistSheet do data fetch + business logic in widget (no Controller)
- **Screen**: `meal_plan:/home/meal`
- **File**: `/Users/adithyafp_/Projects/nibbles/lib/src/features/meal_plan/widgets/add_to_shopping_list_modal.dart`  line ?
- **Category**: `separation-of-concerns`  Confidence: 1.00
- **Description**: 
- **Fix**: Extract AddToShoppingListController and RangeAddToShoplistController (riverpod_generator AsyncNotifier with family args). Each owns load(), toggle(name), submit(). The widgets become ConsumerWidgets that ref.watch the controller's AsyncValue and call notifier methods. Result<T> branching stays in the controller; widgets receive only domain data + success/failure signals.
- **Agreed by**: flutter-arch

### Service-layer fetch + state lives in ConsumerStatefulWidget instead of AsyncNotifier controller
- **Screen**: `BrowseMealSheet`
- **File**: `/Users/adithyafp_/Projects/nibbles/lib/src/features/meal_plan/sheets/browse_meal_sheet.dart`  line ?
- **Category**: `separation-of-concerns`  Confidence: 1.00
- **Description**: 
- **Fix**: Introduce browse_meal_controller.dart (riverpod AsyncNotifier) + browse_meal_state.dart (@freezed: recipes, flaggedKeys, ongoingAllergenKey, selectedIds, deselectedIds, filter, query, isLoading, error). Move _load, _isUnsafe, _toggleRecipe, _recommendationsFor, _categoryGroups, _searchResults into the controller. Sheet becomes ConsumerWidget reading ref.watch(browseMealControllerProvider). In build use Future.wait for the 3 independent service calls; handle Result<T> with .when; map recipe failure to P3 (cached fallback + Crashlytics), allergen failure to P2 degradation, not blocking error. Use .select() for narrow rebuild slices.
- **Agreed by**: flutter-arch, qa-behavior

### LocalFlagService write is fire-and-forget AND called from screen instead of controller — race against router redirect + breaks alternative submit call sites
- **Screen**: `onboarding/baby_setup:/onboarding/baby-setup`
- **File**: `/Users/adithyafp_/Projects/nibbles/lib/src/features/onboarding/baby_setup/onboarding_baby_setup_screen.dart`  line ?
- **Category**: `separation-of-concerns`  Confidence: 0.99
- **Description**: 
- **Fix**: Move setOnboardingBabySetupDone() into BabySetupController.submit()'s success branch and await it before returning success. Screen's onSuccess then just does context.go(Routes.home.path). Ensure LocalFlagService write returns Future and is awaited so GoRouter redirect reads the new value.
- **Agreed by**: flutter-arch, qa-behavior

### Delete flow calls AllergenService directly from screen — bypasses controller
- **Screen**: `allergen/log_detail:/home/allergen/:allergenKey/log/:logId`
- **File**: `/Users/adithyafp_/Projects/nibbles/lib/src/features/allergen/log_detail/allergen_log_detail_screen.dart`  line ?
- **Category**: `separation-of-concerns`  Confidence: 0.95
- **Description**: 
- **Fix**: Add `deleteLog()` to `AllergenLogDetailController` that calls `AllergenService.deleteAllergenLog`, fires analytics, returns `Result<void>`, and invalidates sibling providers on success. Screen calls `ref.read(controller.notifier).deleteLog()` and only handles UI (snackbar + pop).
- **Agreed by**: flutter-arch

### Service-layer calls and LocalFlagService writes invoked directly from Screen
- **Screen**: `allergen/log:/home/allergen/:allergenKey/log`
- **File**: `/Users/adithyafp_/Projects/nibbles/lib/src/features/allergen/log/allergen_log_screen.dart`  line ?
- **Category**: `separation-of-concerns`  Confidence: 0.95
- **Description**: 
- **Fix**: Move post-save reachability gate into AllergenLogController.submit (or AllergenService.evaluatePostLogProgramState(babyId)). Controller emits postSaveAction: pop | navigateToComplete | snackbarPhotoFailed. Screen listens and only does context.pop / goNamed / showSnackBar. No service calls or local-flag writes in Screen.
- **Agreed by**: flutter-arch

### Service calls live in widget instead of AsyncNotifier controller (arch violation)
- **Screen**: `RangeAddToShoplistSheet`
- **File**: `/Users/adithyafp_/Projects/nibbles/lib/src/features/meal_plan/widgets/range_add_to_shoplist_sheet.dart`  line ?
- **Category**: `separation-of-concerns`  Confidence: 0.95
- **Description**: 
- **Fix**: Extract a RangeAddToShoplistController (AsyncNotifier family of {babyId,startDate,endDate}) and RangeAddToShoplistState (@freezed). Move _loadIngredients/_toggle/_toggleAll/_submit into the controller. Convert sheet to ConsumerWidget that ref.watches state and ref.reads controller actions. Use ref.listen for snackbar/pop side effects.
- **Agreed by**: flutter-arch

### Business logic and async state live in widget — no Controller/State layer
- **Screen**: `AddToShoppingListModal`
- **File**: `/Users/adithyafp_/Projects/nibbles/lib/src/features/meal_plan/widgets/add_to_shopping_list_modal.dart`  line ?
- **Category**: `separation-of-concerns`  Confidence: 0.95
- **Description**: 
- **Fix**: Create add_to_shopping_list_controller.dart (AsyncNotifier<AddToShoppingListState>) + add_to_shopping_list_state.dart (@freezed: ingredients, selected, isSubmitting, error). Move _loadIngredients/_confirm into controller; widget becomes ConsumerWidget that ref.watch-es state and calls controller.toggle/selectAll/confirm. Surface Result<T> failures as typed state.
- **Agreed by**: flutter-arch

### No screen-reader semantics / live region — loading state inaccessible to a11y users
- **Screen**: `onboarding/baby_setup_loading:/onboarding/baby-setup-loading`
- **File**: `/Users/adithyafp_/Projects/nibbles/lib/src/features/onboarding/baby_setup_loading/onboarding_baby_setup_loading_screen.dart`  line ?
- **Category**: `semantics`  Confidence: 0.94
- **Description**: 
- **Fix**: Wrap the Scaffold body in Semantics(label: 'Setting up your baby profile', liveRegion: true, container: true). Wrap PetalBlob in ExcludeSemantics. On the ref.listen ready-edge callback, call SemanticsService.announce('Setup complete, opening home', TextDirection.ltr) before _goHome(). Update PopScope to onPopInvokedWithResult and announce 'Please wait, setting up your profile' when back is attempted.
- **Agreed by**: a11y

### Local flag write and readiness completion logic in Screen layer
- **Screen**: `onboarding/readiness:/onboarding/readiness`
- **File**: `/Users/adithyafp_/Projects/nibbles/lib/src/features/onboarding/readiness/onboarding_readiness_screen.dart`  line ?
- **Category**: `separation-of-concerns`  Confidence: 0.90
- **Description**: 
- **Fix**: Add controller.completeReadiness() returning Result<void> that derives allMet, calls setReadinessReady, awaits LocalFlagService via service hop. Screen does `final r = await controller.completeReadiness(); r.when(success: ..., failure: showP1Error)`.
- **Agreed by**: flutter-arch

### Phase transition not announced to screen readers (no liveRegion)
- **Screen**: `subscription/success:/subscription/success`
- **File**: `/Users/adithyafp_/Projects/nibbles/lib/src/features/subscription/success/subscription_success_screen.dart`  line ?
- **Category**: `semantics`  Confidence: 0.90
- **Description**: 
- **Fix**: Wrap LoadingConfirmation in Semantics(container: true, liveRegion: true, label: phase == success ? 'Subscription activated. You are all set. Returning to home.' : 'Setting up your subscription, please wait.', child: ...). Re-emit label on phase flip so assistive tech announces before auto-route fires.
- **Agreed by**: a11y

### _SquareCheckbox lacks checkbox semantics (no checked state, no label association)
- **Screen**: `shopping_list:/home/shopping-list`
- **File**: `/Users/adithyafp_/Projects/nibbles/lib/src/features/shopping_list/shopping_list_screen.dart`  line ?
- **Category**: `semantics`  Confidence: 0.90
- **Description**: 
- **Fix**: Wrap _ShoppingItemRow in MergeSemantics + Semantics(checked: item.isChecked, label: item.name, onTap: onToggle, container: true, child: ...).
- **Agreed by**: a11y

### Business logic (LocalFlagService write + navigation) lives in the screen
- **Screen**: `onboarding/intro:/onboarding/intro`
- **File**: `/Users/adithyafp_/Projects/nibbles/lib/src/features/onboarding/intro/onboarding_intro_screen.dart`  line ?
- **Category**: `separation-of-concerns`  Confidence: 0.85
- **Description**: 
- **Fix**: Add onboarding_intro_controller.dart (AsyncNotifier) and onboarding_intro_state.dart (@freezed: currentPage, isLast, autoAdvancing). Move _scheduleAutoAdvance, _onPageChanged, _onPrimaryPressed into controller. Controller calls LocalFlagService.setHasLaunched; screen listens via ref.listen for navigation events.
- **Agreed by**: flutter-arch

### Inline FutureProvider for signed-URL fetch in screen file leaks repository concerns
- **Screen**: `allergen/log_detail:/home/allergen/:allergenKey/log/:logId`
- **File**: `/Users/adithyafp_/Projects/nibbles/lib/src/features/allergen/log_detail/allergen_log_detail_screen.dart`  line ?
- **Category**: `separation-of-concerns`  Confidence: 0.85
- **Description**: 
- **Fix**: Move signed-URL resolution into controller state, OR colocate a parameterized `signedPhotoUrlProvider` with the service. Widget watches a controller-owned slice instead of declaring its own FutureProvider in a UI file.
- **Agreed by**: flutter-arch

### Imperative router-side navigation + flag flip lives in Screen, not Controller
- **Screen**: `onboarding/dob:/onboarding/dob`
- **File**: `/Users/adithyafp_/Projects/nibbles/lib/src/features/onboarding/dob/onboarding_dob_screen.dart`  line ?
- **Category**: `separation-of-concerns`  Confidence: 0.75
- **Description**: 
- **Fix**: Move both writes into OnboardingController as `Future<Result<void>> completeBabySetup(DateTime dob)` that calls updateDob then LocalFlagService.setOnboardingBabySetupDone() and returns Result<void>. Screen reacts to Result for navigation.
- **Agreed by**: flutter-arch

---

## P1 — Major UX / Behavior Findings

### AddToMealPlanSheet
- **[semantics]** `[auto-fixable]` Day accordion header lacks Semantics(button, expanded, label) wrapper  (conf=1.00)
  - 
  - Fix: Wrap _DayHeader InkWell in Semantics(button: true, label: _formatDate(day), hint: isExpanded ? 'Collapse day' : 'Expand day to add to meal plan', expanded: isExpanded, child: ExcludeSemantics(child: row)).
- **[ad-hoc-component]** `[auto-fixable]` _DayChip is ad-hoc decoration; should reuse AppRoundButton  (conf=0.99)
  - 
  - Fix: Replace _DayChip with AppRoundButton(icon, tone: green, size: small, onPressed: null) inside ExcludeSemantics/IgnorePointer. Remove the dead more_horiz placeholder, or wire it to a real per-day action.
- **[semantics]** `[auto-fixable]` Decorative _DayChip icons leak into semantics ('more_horiz' announced)  (conf=0.99)
  - 
  - Fix: Wrap _DayChip's Icon (or the whole _DayChip return) in ExcludeSemantics. Also remove the dead more_horiz placeholder until a real action exists.
- **[layout-drift]** `[auto-fixable]` Confirm CTA undersized; should be full-bleed primary bar  (conf=0.85)
  - 
  - Fix: In _ConfirmCta, drop horizontal Padding wrapper, switch size to AppPillButtonSize.full, ensure parent Column allocates full width so the CTA reads as the primary bottom commit bar.
- **[density]** Top counter binds to session selections, not assigned-slot count  (conf=0.70)
  - 
  - Fix: Pass an existingSlotCount int into the sheet (from MealPlan service for the visible window) and bind _SelectedCounter to that. Keep _ConfirmCta tied to _selected.length for session picks.
- **[density]** Expanded day card missing list of existing meal-plan entries  (conf=0.70)
  - 
  - Fix: Pass List<MealPlanEntry> per day into _DayAccordion. Render entries (thumbnail + title + chips) above the 'Add' pill in the expanded body.

### AddToShoppingListModal
- **[interaction]** `[auto-fixable]` List rows use Material CheckboxListTile — missing cream pill card and trailing delete-X affordance  (conf=0.99)
  - 
  - Fix: Replace CheckboxListTile in _buildContent with the _IngredientRow widget from range_add_to_shoplist_sheet.dart (or extract into common/components/cards/). Render in ListView.separated with SizedBox(height: AppSizes.sp12) separators. Wire trailing Icon(Icons.close, color: AppColors.burgundy, size:18) to a handler removing the ingredient from _ingredients and _selected.
- **[layout-drift]** `[auto-fixable]` Footer is single FilledButton — should be 2-button row (outline Select/Unselect All + filled Add (N))  (conf=0.99)
  - 
  - Fix: Drop the TextButton('Select all/Deselect all') from header. Replace single FilledButton footer with the _BottomActions widget from range_add_to_shoplist_sheet.dart: Row of OutlinedButton(Select/Unselect All) + FilledButton('Add (N)'), both Size.fromHeight(AppSizes.xxl)=48, BorderRadius.circular(AppSizes.radius2xl)=24, backgroundColor: AppColors.greenDeep.
- **[ad-hoc-component]** `[auto-fixable]` CheckboxListTile checkbox color/style instead of AppCheckbox/ShopRow token  (conf=0.99)
  - 
  - Fix: Use a Row of AppCheckbox + Text inside the new cream pill row (see row-card finding) — consolidated with the IngredientRow extraction.
- **[result-handling]** `[auto-fixable]` Bulk add uses wrong source tag — calls addFromRecipe with empty recipeId instead of addFromMealPlan  (conf=0.99)
  - 
  - Fix: Replace ref.read(shoppingListServiceProvider).addFromRecipe(widget.babyId, '', selected) with ref.read(shoppingListServiceProvider).addFromMealPlan(widget.babyId, selected). Drop the placeholder recipeId argument and explanatory comment.
- **[ad-hoc-component]** `[auto-fixable]` Confirm CTA reimplemented as raw FilledButton instead of AppPillButton  (conf=0.95)
  - 
  - Fix: Replace FilledButton with AppPillButton(label: 'Add ${_selected.length} items', onPressed: (_selected.isEmpty || _submitting) ? null : _confirm, variant: AppPillButtonVariant.primary). If AppPillButton lacks isLoading, add it as a small additive change.
- **[separation-of-concerns]** Service navigation/snackbar imperative in widget + empty-string recipeId hack  (conf=0.90)
  - 
  - Fix: Move pop/snackbar out of widget — controller exposes a one-shot success/failure event, widget ref.listen-s and reacts. Use addFromMealPlan in service (no recipeId).
- **[semantics]** `[auto-fixable]` Submit-state spinner inside FilledButton has no accessible label  (conf=0.85)
  - 
  - Fix: Wrap submit-state spinner with Semantics(label: 'Adding items, please wait', child: ...), or keep visible label by rendering a Row(spinner + 'Adding...' text).

### AddToShoppingListSheet
- **[ad-hoc-component]** Inline _IngredientRow + sheet header re-implemented instead of reusing ShopRow / SheetHeader / SheetGrabHandle  (conf=0.99)
  - 
  - Fix: Extract shared SheetHeader (title + close via AppRoundButton ghost) and SheetGrabHandle to common/components. Either extend ShopRow with a selectable variant (AppCheckbox + burgundy X) or extract _IngredientRow to common/components/cards/selectable_ingredient_row.dart so add_to_meal_plan_sheet can reuse. Collapse the duplicate Material+Container decoration into a single Material(shape: RoundedRectangleBorder(side, radius)).
- **[semantics]** `[auto-fixable]` Remove (X) semantic label missing ingredient name  (conf=0.99)
  - 
  - Fix: Forward the ingredient name to _RemoveButton and set Semantics(label: 'Remove $name', button: true).
- **[semantics]** `[auto-fixable]` Ingredient row not exposed as a single checkbox semantic to screen readers  (conf=0.85)
  - 
  - Fix: Wrap the row's InkWell content in Semantics(container: true, label: name, checked: selected, onTap: onToggle, child: ExcludeSemantics(child: <visual row>)). Keep _RemoveButton outside the ExcludeSemantics so its Remove semantics still surface.
- **[form-submission]** No double-tap / canPop guard on Add CTA and Close (X) — risk of popping recipe-detail route  (conf=0.75)
  - 
  - Fix: Add a single _dismissing bool guard shared by _confirm and the X onPressed. Early-return if true. Also gate with Navigator.of(context).canPop() before pop.

### AttachmentSheet
- **[ad-hoc-component]** Inline _FieldLabel duplicates AppTextField's built-in `label` parameter and diverges in style  (conf=1.00)
  - 
  - Fix: Delete _FieldLabel (lines 222-236). Pass label: 'Title' and label: 'Description' to AppTextField directly and remove the manual SizedBox(height: AppSizes.sm) above each — AppTextField inserts the gap when a label is provided.
- **[textfield-behavior]** Title/Description fields missing textInputAction, focus chain, capitalization, and multiline config  (conf=1.00)
  - 
  - Fix: Add _descriptionFocus FocusNode in state (dispose it). Title: textInputAction: TextInputAction.next, textCapitalization: TextCapitalization.sentences, onSubmitted advances focus. Description: focusNode: _descriptionFocus, textInputAction: TextInputAction.done, textCapitalization: TextCapitalization.sentences, keyboardType: TextInputType.multiline, onSubmitted: (_) => _onAdd(). Extend AppTextField to forward these props if not already supported.
- **[semantics]** `[auto-fixable]` Photo picker InkWell + Image.file + add_a_photo icon lack semantics (no button label, no decorative exclusion, screen reader silent)  (conf=0.99)
  - 
  - Fix: Wrap InkWell in Semantics(button: true, label: photoPath != null ? 'Replace attached photo' : 'Add photo', hint: 'Opens camera or gallery picker', child: ...). Add ExcludeSemantics around Image.file (or set semanticLabel: 'Attached photo preview'). Wrap inner Column in MergeSemantics so icon+label collapse to one node. Add semanticLabel: 'Add photo' to the Icon or rely on the wrapper.
- **[state-coverage]** Photo file existence not validated — Image.file paints error widget on missing file or remote URL (breaks EDIT mode)  (conf=0.95)
  - 
  - Fix: Detect URL vs local path (startsWith('http')) and render Image.network/CachedNetworkImage for remote, Image.file for local. Always supply errorBuilder falling back to the 'Tap to add photo' placeholder + log to Crashlytics. Add cacheWidth ~600 for memory safety. Audit whether AttachmentSheet should accept the remote URL or only a local path.
- **[asset-placement]** Sheet missing cream/butter Grad-1 background — renders pure white instead of allergen-flow gradient  (conf=0.85)
  - 
  - Fix: Set backgroundColor: Colors.transparent on showModalBottomSheet, wrap _AttachmentSheet body in a Container with a BoxDecoration using LinearGradient ~150deg (AppColors.butterSoft → AppColors.surfaceVariant) plus existing top-radius BorderRadius.vertical(top: Radius.circular(AppSizes.radius2xl)).
- **[result-handling]** `[auto-fixable]` Image picker errors swallowed — no try/catch around _picker.pickImage; PlatformException bubbles unhandled  (conf=0.85)
  - 
  - Fix: Wrap the picker call in try/catch (or route through a repository returning Result<String?>) and on failure show a SnackBar inline error 'Couldn't open camera. Check app permissions.' plus log to Crashlytics. Keep mounted guards before any setState/ScaffoldMessenger call.
- **[form-submission]** `[auto-fixable]` Add button always enabled — taps with all-empty fields produce no-op result that clobbers prior attachment  (conf=0.85)
  - 
  - Fix: Compute hasAny = _photoPath != null || _titleCtrl.text.trim().isNotEmpty || _descriptionCtrl.text.trim().isNotEmpty. Pass onPressed: hasAny ? _onAdd : null to AppPillButton. Listen to both controllers via addListener in initState so the button rebuilds. Also reconsider parent's clobber-clearing logic.
- **[semantics]** TextFields lack persistent accessible label — only hint text shown, lost once typing starts (screen reader can't identify field)  (conf=0.85)
  - 
  - Fix: Pass labelText='Title' / 'Description' into AppTextField so it renders InputDecoration.labelText (semantically exposed), or wrap each field in Semantics(label: 'Title', textField: true, child: AppTextField(...)).

### BrowseMealSheet
- **[ad-hoc-component]** `[auto-fixable]` Search input forks AppSearchField — wrong fill, missing focus/onSubmitted, no debounce/autocorrect config  (conf=1.00)
  - 
  - Fix: Delete BrowseMealSearchField and use AppSearchField(controller, hintText: 'Search recipes', onChanged, onSubmitted: (_) => FocusScope.of(context).unfocus()). Ensure AppSearchField sets autocorrect: false, enableSuggestions: false, textCapitalization: none, and exposes a clear suffix. Add ~250ms Timer debounce around onChanged in the controller so per-keystroke setState/list rebuild is avoided. Pass semantic label 'Search recipes'.
- **[ad-hoc-component]** `[auto-fixable]` Sticky CTA forks FilledButton instead of AppPillButton + lacks loading/disabled semantic state  (conf=1.00)
  - 
  - Fix: Replace inline FilledButton in _StickyAddBar with AppPillButton(label: _label, onPressed: onPressed, variant: primary). Keep the outer container's top border (or move to shadowCardLifted). Wrap with Semantics(hint: onPressed == null ? 'Select at least one recipe to enable' : null) and add semanticsLabel that spells out 'Add N recipes to meal plan' / 'Map meal plan'. Add HapticFeedback.selectionClick() in _confirm and a _submitting guard.
- **[asset-placement]** `[auto-fixable]` Recipe cards missing Iron Rich + allergen-count chips per Figma  (conf=0.99)
  - 
  - Fix: Below title in BrowseMealRecipeCard, render a Wrap of AppChip items: one chip per Recipe.category token (e.g. 'Iron Rich') and a trailing '+N' chip when recipe.allergenTags.length > 1. Use coralSoft bg / coralDeep fg from AppColors. Mirror same chip row in BrowseMealRecipeRow.
- **[layout-drift]** `[auto-fixable]` Master list rendered as flat divider rows instead of stacked rounded cards with chips and circular indicator  (conf=0.94)
  - 
  - Fix: Wrap each BrowseMealRecipeRow in AppCard (radiusLg, surface bg, shadowCard) instead of flat InkWell. Replace SliverList separator from Divider to SizedBox(height: AppSizes.sm + AppSizes.xs). Render meta line as Wrap of AppChip (Iron Rich + +N allergen chip) below title. Swap square _RowSelectIndicator for the circular _SelectIndicator used by the carousel card so visuals are consistent.
- **[sheet-behavior]** `[auto-fixable]` Sheet drag-dismiss / close X silently discards selections — no PopScope guard  (conf=0.94)
  - 
  - Fix: Wrap sheet body in PopScope(canPop: _selectedRecipeIds.isEmpty, onPopInvoked: ...) and route both X icon and system back gesture through _maybeClose() that prompts 'Discard your selections?' when count > 0. Also set isDismissible: false / enableDrag: false on showModalBottomSheet OR keep them and rely on the prompt.
- **[semantics]** Sheet missing top-level Semantics scope (modal route announcement + focus containment)  (conf=0.83)
  - 
  - Fix: Wrap the SafeArea/ConstrainedBox body in Semantics(scopesRoute: true, namesRoute: true, explicitChildNodes: true, label: 'Browse meal sheet', child: ...) so the sheet is announced as a modal route to screen readers.
- **[layout-drift]** Selection counter pills placed below carousels instead of directly under header  (conf=0.80)
  - 
  - Fix: Move SelectionCounters out of the sliver column and place it as a sibling immediately under _Header (above the search field). Keep tap-to-filter behaviour. In inReviewMode the counters belong at the top regardless of mode.

### ClearAllConfirmSheet
- **[layout-drift]** `[auto-fixable]` Sheet vertical rhythm too tight vs Figma 335px composition  (conf=0.85)
  - 
  - Fix: Increase the two `SizedBox(height: AppSizes.sm)` separators (title->illustration and illustration->buttons) to `AppSizes.lg` (24), and change the outer padding bottom from `AppSizes.sm` to `AppSizes.md` (16) to match Figma's py-16 button container. Optionally wrap the column in `ConstrainedBox(minHeight: 335)` to land at the designed altitude.
- **[result-handling]** Controller throws and screen wraps in try/catch instead of surfacing Result<T>  (conf=0.85)
  - 
  - Fix: Change controller's `clearAll` (and addManual/check/uncheck/delete) to return `Result<void>` rather than throwing. In the screen call: `final r = await ref.read(...).clearAll(); if (!mounted) return; r.when(success: (_) {}, failure: (e) => _showToast("Couldn't clear list. Try again."));` to comply with CLAUDE.md's no-raw-throws rule.
- **[semantics]** Missing semantic role/header for modal and title (screen reader announces flat structure)  (conf=0.77)
  - 
  - Fix: Wrap the inner Column in `Semantics(container: true, label: 'Clear all shopping list items confirmation', explicitChildNodes: true, child: ...)` and mark the title Text with `Semantics(header: true, child: ...)` so assistive tech announces this as a destructive confirmation dialog with a header.

### ClearConfirmDialog
- **[asset-placement]** Hero illustration undersized at 80px vs Figma ~150px composed illustration  (conf=0.75)
  - 
  - Fix: Bump illustration to ~150px: change `Quatrefoil(size: AppSizes.avatarLg)` to `Quatrefoil(size: 150)` (or introduce `AppSizes.illustrationMd = 150`). If a richer composed asset matching the 153/104/81 vector trio exists in /assets, prefer that SVG over the brand Quatrefoil.

### DeleteLogConfirmationDialog
- **[form-submission]** Delete button has no submit guard / loading state — double-tap pops twice and no progress feedback during in-flight delete  (conf=1.00)
  - 
  - Fix: Convert `_DeleteLogConfirmationDialog` to StatefulWidget with `_isSubmitting` flag. Accept optional `Future<bool> Function()? onConfirm`. On Delete tap: set `_isSubmitting = true`, disable both buttons (pass `onPressed: null`), swap Delete label for `CircularProgressIndicator`, await op, then `pop(true/false)`. This single change also closes the double-tap pop window.
- **[result-handling]** Caller treats delete failure as P2 snackbar but error-handling rules classify allergen-log writes as P1 (modal + Retry)  (conf=0.60)
  - 
  - Fix: On `result.isFailure` in `_confirmAndDelete`, show an AlertDialog with the failure message and a Retry button that re-runs `service.deleteAllergenLog(...)` — matches the project's P1 contract for allergen log writes.

### RangeAddToShoplistSheet
- **[ad-hoc-component]** `[auto-fixable]` Custom _CheckboxIcon bypasses AppCheckbox and lacks Semantics(checked:)  (conf=1.00)
  - 
  - Fix: Delete _CheckboxIcon. Replace usage in _IngredientRow with AppCheckbox(value: selected, onChanged: (_) => onTap()) from lib/src/common/components/controls/app_checkbox.dart. This restores Semantics(checked:) + animation + design-system parity. If 18px is needed, add a size param to AppCheckbox rather than forking.
- **[ad-hoc-component]** `[auto-fixable]` Bottom CTAs reimplement AppPillButton (and miss Parkinsans font spec)  (conf=1.00)
  - 
  - Fix: Replace OutlinedButton with Expanded(child: AppPillButton(label: toggleLabel, variant: AppPillButtonVariant.secondary, onPressed: submitting ? null : onToggleAll)) and FilledButton with Expanded(child: AppPillButton(label: 'Add ($selectedCount)', variant: AppPillButtonVariant.primary, onPressed: anySelected && !submitting ? onSubmit : null)). For submitting state, pass an isLoading flag (extend AppPillButton) or swap label for a sized spinner.
- **[semantics]** `[auto-fixable]` Close button: missing semantic label and tap target below 48dp  (conf=1.00)
  - 
  - Fix: Replace InkWell+Padding+Icon with AppRoundButton(icon: const Icon(Icons.close), tone: AppRoundButtonTone.ghost, size: AppRoundButtonSize.small, semanticLabel: 'Close', onPressed: onClose). This fixes the semantic label, the 48dp tap-target, and rounded ink ripple in one swap.
- **[semantics]** `[auto-fixable]` Trailing red 'X' icon on row is decorative but not ExcludeSemantics — looks like delete affordance  (conf=0.85)
  - 
  - Fix: Wrap the trailing Icon in ExcludeSemantics so AT skips it. Visual concern (looks like delete) needs designer input — but the semantic exclusion can land immediately as a minimal change.
- **[ad-hoc-component]** _IngredientRow is ad-hoc card overlapping ShopRow / AppCard pattern  (conf=0.85)
  - 
  - Fix: Either reuse ShopRow (bought/unbought maps to selected/unselected) or extract a SelectableIngredientRow in common/components/cards composed of AppCard + AppCheckbox + small delete icon. Stop hand-rolling Container+BoxDecoration.

### SelectPeriodDateSheet
- **[layout-drift]** `[auto-fixable]` Header missing explicit close (X) button — drag handle and centered title diverge from Figma; also blocks assistive-tech dismiss  (conf=0.99)
  - 
  - Fix: Replace the centered drag-handle + centered Text title with a Row containing a left-aligned Text('Select Period Date') (titleMedium-bold, w700) and a trailing IconButton(Icons.close, tooltip: 'Close', onPressed: () => Navigator.of(context).pop()) sized ≥48x48dp. Drop the inline drag-handle Container. mainAxisAlignment: spaceBetween, crossAxisAlignment: center, AppSizes.md spacing below.
- **[form-submission]** No double-submit guard on CTA — rapid taps can fire onSubmit/pop twice  (conf=0.70)
  - 
  - Fix: In MealPlanDateRangeForm State add `bool _submitted = false;`. At top of _onSubmit: `if (_submitted) return; _submitted = true;` before invoking widget.onSubmit. Optionally also wrap CTA in IgnorePointer once submitted.

### allergen/complete:/home/allergen/complete
- **[ad-hoc-component]** `[auto-fixable]` Raw Material Chip used instead of AppChip(tone: safe, emoji:) design-system component  (conf=1.00)
  - 
  - Fix: Replace inline Chip(...) with AppChip(label: a.name, emoji: a.emoji, tone: AppChipTone.safe). Drop manual backgroundColor/side/labelStyle — AppChip binds the brand safe tokens and Parkinsans typography. Keep Wrap parent with AppSizes.sm spacing.
- **[ad-hoc-component]** `[auto-fixable]` Raw FilledButton instead of AppPillButton brand CTA  (conf=1.00)
  - 
  - Fix: Swap FilledButton(...) for AppPillButton(label: 'View in Profile', onPressed: ...). Preserve the .animate().fadeIn(delay: 900.ms) chain.
- **[result-handling]** `[auto-fixable]` Error branch leaks raw exception toString — no friendly message, no retry  (conf=1.00)
  - 
  - Fix: Replace Center(child: Text(e.toString())) with a friendly error widget (icon + P1 copy 'Couldn't load your celebration. Please try again.' + Retry button calling ref.invalidate(allergenCompleteControllerProvider)). Use EmptyState from common/components/feedback/. Also fix controller to surface sanitized error rather than re-throwing.
- **[separation-of-concerns]** Sort + Analytics fired inside controller build(); analytics double-counts on invalidation  (conf=1.00)
  - 
  - Fix: Move sequenceOrder sort into AllergenService.getAllergenBoardSummary or a mapper. Move logAllergenProgramCompleted() into markShown() and guard with LocalFlagService.isProgramCompletionShown(babyId) so it fires once per baby (false→true transition only).
- **[result-handling]** markShown is fire-and-forget; race with navigation, write failures swallowed, OS-kill desyncs flag  (conf=0.94)
  - 
  - Fix: Make controller markShown() async, await the LocalFlagService set, log failures to Crashlytics. Persist the flag the moment the screen renders successfully (after build resolves to data) — not in PopScope. Consolidate to a single controller dismiss() method invoked by both PopScope and CTA. CTA handler must await ref.read(...).dismiss() then check context.mounted before context.goNamed.
- **[asset-placement]** Hero is a raw 🎉 emoji rather than a brand celebration asset/illustration  (conf=0.77)
  - 
  - Fix: Replace Text('🎉', fontSize: 80) with a brand asset: either a layered PetalBlob/Quatrefoil/BrandLogo composition tinted with AppColors.butterSoft, or a committed illustration (assets/images/allergen_complete_hero.png/svg) referenced via flutter_gen with bounded SizedBox(height: 200) and cacheWidth/cacheHeight. Keep elastic-scale animation. Requires designer asset.
- **[page-vs-sheet]** No Figma reference for AL-08 — page vs sheet/dialog shape unverified  (conf=0.55)
  - 
  - Fix: Confirm intended presentation with designer. Section uses centered popups for terminal confirmations (delete confirmation 1525:31338). If sheet/dialog, change routes.dart to register a route that triggers showDialog/showModalBottomSheet on entry and pops on dismiss; drop Scaffold+SafeArea wrapper.

### allergen/detail:/home/allergen/:allergenKey
- **[tap-target]** `[auto-fixable]` Add reaction button tap target is 32dp (below 48dp minimum)  (conf=1.00)
  - 
  - Fix: Wrap the InkWell in a SizedBox of at least 48x48 (keep the visual circle at 32 by centering a 32x32 Container inside a 48x48 hit area), or bump AppSizes.roundButtonSm to 48. Easiest: replace the inner SizedBox(width: roundButtonSm, height: roundButtonSm) with a 48dp hit surface that paints a 32dp circle inside.
- **[result-handling]** `[auto-fixable]` Error fallback never shows controller's actual failure message (StateError vs AppException)  (conf=0.95)
  - 
  - Fix: Either (a) have the controller rethrow AppException directly (e.g. throw AppException(result.errorOrNull!.message) instead of StateError), or (b) update the screen to render err.toString() / pattern-match on StateError as well. Preferred: change _throwIfFailure in the controller to throw AppException so the screen branch surfaces the real message.
- **[layout-drift]** `[auto-fixable]` Hero card scope collapsed — dates, progress bar, and contextual banner moved outside the AppCard  (conf=0.90)
  - 
  - Fix: Wrap DetailHeaderCard, DetailDatesBlock, DetailSegmentBar and DetailContextualBanner inside a single AppCard (or compose them inside DetailHeaderCard) so the white card encloses the hero, dates, progress, and banner — matching the 370x281 allergen-progres component. Keep ReactionLogHeader and log rows OUTSIDE the card.
- **[layout-drift]** `[auto-fixable]` Unsafe status pill uses orange coral background instead of Figma red/pink tokens  (conf=0.85)
  - 
  - Fix: Change the flagged case to bg: AppColors.destructiveSoft (#FFE8E8) and fg: AppColors.flagFg (#B92020) — these tokens already exist and map closely to Figma #ffdfe0 / #ff474a. Keep label 'Unsafe'.
- **[layout-drift]** `[auto-fixable]` Segment progress bar uses wrong fill color and resets to empty when flagged  (conf=0.85)
  - 
  - Fix: Use AppColors.green (#5C7852) as the fill color for ALL post-intro states (inProgress, safe, flagged) and AppColors.greenTint or borderSoft as the empty track. Remove the flagged-resets-to-0 logic — keep filledCount = cleanCount.clamp(0,3) for every status.
- **[interaction]** `[auto-fixable]` Add reaction button is shown on every state — Figma hides it on Safe and Unsafe  (conf=0.85)
  - 
  - Fix: Conditionally render ReactionLogHeader's add button only when state.status == AllergenStatus.inProgress (or AllergenStatus.notStarted). Pass an optional showAdd: bool flag to ReactionLogHeader and hide the InkWell when false. Also confirm with PO whether notStarted should show the +chip.
- **[semantics]** `[auto-fixable]` Log entry cards lack semantic label summarising row state  (conf=0.85)
  - 
  - Fix: Wrap the AppCard in Semantics(button: true, container: true, label: 'Log $logNumber, ${hadReaction ? "Unsafe" : "Safe"}${notes != null ? ", notes: $notes" : ""}${attachment != null ? ", attachment $attachment" : ""}', child: ...) and exclude the chevron via ExcludeSemantics or Semantics(excludeSemantics: true, child: Icon(...)).
- **[asset-placement]** Log entry avatar shows initial in sage circle — Figma uses peach baby illustration  (conf=0.80)
  - 
  - Fix: Replace _BabyAvatar's initial-in-circle with an asset-based baby illustration on a coralSoft circular background (matches the hero emoji tile treatment). Add the baby illustration asset to lib/gen/ via flutter_gen and reference it through Image.asset or SvgPicture. Increase tile size from avatarSm toward 48-56 to match the Figma 62x62 visual weight.

### allergen/log:/home/allergen/:allergenKey/log
- **[tooltip]** `[auto-fixable]` Back IconButton lacks tooltip/semantic label  (conf=1.00)
  - 
  - Fix: Add tooltip: 'Back' to IconButton (or wrap with Semantics(label: 'Back', button: true)). IconButton(tooltip: 'Back', icon: const Icon(Icons.arrow_back_rounded), color: AppColors.fgStrong, onPressed: () => context.pop(false)).
- **[ad-hoc-component]** Notes field reimplemented as Container+TextField instead of using AppTextField  (conf=0.95)
  - 
  - Fix: Replace _NotesField with AppTextField(controller: notesCtrl, hintText: 'My baby loves it, no reaction', onChanged: onChanged, textInputAction: TextInputAction.newline). If multi-line needed, extend AppTextField with minLines/maxLines props rather than re-rolling. Delete _NotesField.
- **[result-handling]** `[auto-fixable]` hydrateForEdit throws StateError on missing log — bypasses Result<T>  (conf=0.95)
  - 
  - Fix: Replace firstWhere(orElse: throw ...) with firstWhereOrNull or manual loop; on null, set state.copyWith(isLoading: false, errorMessage: "Couldn't load this log. Please try again.") and return. Optionally pop screen with snackbar.
- **[ad-hoc-component]** `[auto-fixable]` Reaction toggle hit-test broken — IgnorePointer wraps AppSwitch breaking drag and onChanged contract  (conf=0.94)
  - 
  - Fix: Remove IgnorePointer. Pass onChanged: (_) => onToggle() to AppSwitch so it remains directly interactive (tap + drag). Keep outer GestureDetector/InkWell for label-tap convenience. Preserves both affordances and matches native iOS toggle behavior.
- **[layout-drift]** Edit mode hides photo, title and description — diverges from Figma inline attachment block  (conf=0.90)
  - 
  - Fix: Branch _AttachmentBlock on hasAttachment. When attachment exists, render: (1) ClipRRect 370x195 photo preview using state.photoPath / state.existingPhotoPath, (2) butter AppPillButton 'Change Picture' opening the attachment sheet, (3) Row with stacked title/description Texts and trailing 35x35 AppRoundButton edit icon. Only when hasAttachment is false show the dashed AppCard with the lone 'Add Picture' pill.
- **[missing-reusable]** Date field reimplemented inline instead of an AppDateField/AppTextField wrapper  (conf=0.90)
  - 
  - Fix: Extract AppPickerField (or add readOnly/onTap mode to AppTextField) in lib/src/common/components/inputs/ that takes value, hint, leading icon, onTap, and renders the same focus/error states as AppTextField. Use for date picker, gender picker, allergen picker. Replace _DateField with this component.
- **[semantics]** `[auto-fixable]` Reaction toggle missing accessible label / button semantics  (conf=0.90)
  - 
  - Fix: Promote Semantics wrapper to labeled toggle: Semantics(label: 'Any Reaction?', toggled: hadReaction, button: true, onTap: onToggle, excludeSemantics: true, child: ...). Also consider Switch.adaptive with onChanged wired so platform a11y semantics fire correctly.
- **[semantics]** `[auto-fixable]` Date field is not announced as a button / picker (no Semantics)  (conf=0.90)
  - 
  - Fix: Wrap InkWell child with Semantics(button: true, label: 'Log date', value: hasValue ? value! : 'Not set', hint: 'Opens date picker', child: ...).
- **[state-coverage]** `[auto-fixable]` Error states from hydrateForEdit have no Retry CTA — only inline label  (conf=0.85)
  - 
  - Fix: Render dedicated error view with Retry button when state.errorMessage != null && !state.hydrated && isEdit. Retry re-invokes controller.hydrateForEdit. Inline error label fine for submit failures (recoverable by tapping Save).
- **[semantics]** `[auto-fixable]` Notes TextField has no accessible label (only hint)  (conf=0.85)
  - 
  - Fix: Wrap TextField with Semantics(label: 'Notes', textField: true, child: ...) or add InputDecoration(labelText: 'Notes', ...). Alternatively merge semantics so _SectionLabel reads as label for field.
- **[state-coverage]** ref.listen for isSaved re-fires on stale keepAlive state — auto-pops on second open  (conf=0.80)
  - 
  - Fix: Always call controller.reset() in initState before hydrate, regardless of isEdit, so isSaved/isLoading/photoUploadFailed start clean. Alternatively gate listener with a 'navigated' flag, or have submit() consume isSaved after listener fires.
- **[state-coverage]** ref.read of currentBabyIdProvider in initState may race; null babyId silently becomes CREATE mode  (conf=0.80)
  - 
  - Fix: If isEdit and babyId resolves to null, set error state (errorMessage + isLoading:false + hydrated:false) and show dedicated error view. Alternatively derive babyId via babyIdAsync.when in build and gate hydration with ref.listen so AsyncValue is source of truth.
- **[semantics]** Error message Text not announced as alert / liveRegion  (conf=0.80)
  - 
  - Fix: Wrap error Text in Semantics(liveRegion: true, container: true, child: Text(state.errorMessage!, ...)). Optionally prefix label with 'Error: '.
- **[form-submission]** Save button can double-tap during post-submit window — duplicate submits  (conf=0.75)
  - 
  - Fix: Add state.isSaved to disabled guard: _canSubmit = !state.isLoading && !state.isSaved && state.hydrated. Or have submit() keep isLoading: true after isSaved is true until screen pops. Also add idempotency guard in controller.
- **[navigation]** AL-08 navigation uses context.goNamed — replaces stack, breaks back nav and skips pop(true) contract  (conf=0.75)
  - 
  - Fix: Use context.pushReplacementNamed, or pop(true) first (so parent allergen detail invalidates) then push the complete screen. Verify AllergenDetail receives pop result so its provider invalidation runs before AL-08 takes over.
- **[semantics]** Error/loading scaffolds show plain text with no Semantics liveRegion and no retry CTA  (conf=0.75)
  - 
  - Fix: Wrap error/empty content in Semantics(liveRegion: true, container: true, label: 'Could not load baby profile, tap retry', child: ...) and add retry button calling ref.invalidate(currentBabyIdProvider). Aligns with P0 error rule.

### allergen/log_detail:/home/allergen/:allergenKey/log/:logId
- **[tooltip]** `[auto-fixable]` Overflow menu IconButton missing tooltip / semantic label  (conf=1.00)
  - 
  - Fix: Add `tooltip: 'Log actions'` to the more-horiz IconButton so screen readers announce its purpose.
- **[missing-reusable]** `[auto-fixable]` _FieldLabel duplicated across allergen log feature — missing AppFieldLabel  (conf=1.00)
  - 
  - Fix: Add `lib/src/common/components/inputs/app_field_label.dart` exposing `AppFieldLabel(text)` using Parkinsans 15/600 token (promote to `AppTypography.fieldLabel`). Replace both `_FieldLabel` copies and export from components.dart.
- **[ad-hoc-component]** `[auto-fixable]` _ReadOnlyField is an ad-hoc Container — should be a shared AppReadOnlyField  (conf=0.99)
  - 
  - Fix: Extract `lib/src/common/components/inputs/app_read_only_field.dart` reusing `AppSizes.fieldHeight/radiusFull` and `theme.textTheme.bodyLarge.copyWith(color: AppColors.fgFaint)`. Replace `_ReadOnlyField` with the shared component.
- **[missing-reusable]** `[auto-fixable]` _PhotoPreview duplicated between log_detail and attachment_sheet  (conf=0.99)
  - 
  - Fix: Extract `lib/src/common/components/media/app_attachment_photo.dart` accepting URL/path + optional `onTap`. Add `AppSizes.attachmentPhotoHeight = 195`. Replace both feature copies.
- **[density]** `[auto-fixable]` Notes field truncates to single line — content hidden + breaks Dynamic Type  (conf=0.94)
  - 
  - Fix: Add `isMultiline` flag to `_ReadOnlyField`. For Notes: drop fixed `AppSizes.fieldHeight`, use `BorderRadius.circular(AppSizes.radiusLg)` instead of `radiusFull`, remove `maxLines: 1` and `TextOverflow.ellipsis`, add vertical padding. Keep Date row single-line.
- **[form-submission]** `[auto-fixable]` Delete action lacks double-submit guard and loading indicator  (conf=0.85)
  - 
  - Fix: Add local `_isDeleting` flag. Guard re-entry at top of `_confirmAndDelete` and `_onMenuPressed`. Show blocking loading indicator (modal barrier / spinner dialog) while delete is in flight.
- **[result-handling]** Delete failure shown as auto-dismiss snackbar — should be modal with retry per P1 rule  (conf=0.75)
  - 
  - Fix: Replace failure SnackBar with AlertDialog carrying error + explicit Retry and Cancel actions. Surface `result.errorOrNull?.message` instead of generic copy.

### allergen/tracker:/home/allergen/tracker
- **[semantics]** `[auto-fixable]` 'See All' GestureDetector lacks Semantics button role and label  (conf=0.99)
  - 
  - Fix: Wrap with Semantics(button: true, label: 'See All', child: GestureDetector(...)) or replace with a TextButton/InkWell which provides automatic button semantics and a 48dp ripple area.
- **[asset-placement]** Reaction Log row avatar uses green baby initial instead of coral allergen icon  (conf=0.85)
  - 
  - Fix: Replace babyInitial avatar + taste-glyph stack with the parent allergen emoji rendered in a coralSoft circle, mirroring AllergenProgressCard. Drop babyInitial/_currentBabyProvider plumbing and the corner taste badge. Take allergen as a parameter on ReactionLogRow (look up by log.allergenKey in _OngoingList).

### auth/forgot_password:/auth/forgot-password
- **[layout-drift]** `[auto-fixable]` Title typography undersized vs Figma Title 1/Bold (28px)  (conf=0.85)
  - 
  - Fix: Replace `style: textTheme.headlineSmall` with `style: textTheme.displaySmall` in both `_InputView` ('Forgot your password?') and `_ConfirmationView` ('Check your email') to match Figma Title 1/Bold (28/700).
- **[form-submission]** `[auto-fixable]` Double-tap race on submit possible via keyboard onSubmitted + button tap  (conf=0.85)
  - 
  - Fix: Add idempotency guard at top of submit(): `if (state.isLoading) return;` — defends against simultaneous triggers from button + keyboard action regardless of UI throttling.
- **[semantics]** Inline form error is not announced to screen readers (no liveRegion)  (conf=0.75)
  - 
  - Fix: Wrap the error caption Text in AppTextField (app_text_field.dart) in Semantics(liveRegion: true, child: Text(...)) — fixes all forms at once. Alternative: wrap AppTextField in Semantics(liveRegion: true) when error is present.

### auth/login:/auth/login
- **[missing-illustration]** Google 'G' glyph is a fake styled letter, not the official Google brand mark  (conf=1.00)
  - 
  - Fix: Add the official Google 'G' multi-color SVG as assets/icons/google_g.svg, run flutter_gen, and render via SvgPicture.asset(Assets.icons.googleG, width: 24, height: 24) inside _GoogleGlyph. Remove the hand-rolled Parkinsans letter + hardcoded _googleBlue. Required for Google Sign-In brand compliance.
- **[ad-hoc-component]** `[auto-fixable]` Single errorMessage duplicated on BOTH email and password fields (visual + a11y noise)  (conf=1.00)
  - 
  - Fix: Show the global errorMessage exactly once — pass errorText only to the password field (or to an inline banner above the submit button). Stop passing errorText to the email field unless EmailInput.error is dirty. Wrap banner in Semantics(liveRegion: true) for screen reader announcement.
- **[ad-hoc-component]** `[auto-fixable]` Password visibility toggle replaced by misleading check icon on error  (conf=1.00)
  - 
  - Fix: Keep eye toggle visible during error state (optionally tinted burgundy). Remove the Icons.check_rounded swap entirely — check semantics contradict the error state and remove user's ability to verify their input. Add Semantics(button: true, toggled: !obscure, label: obscure ? 'Show password' : 'Hide password').
- **[navigation]** `[auto-fixable]` No 'Forgot password?' affordance on login screen — route exists but unreachable  (conf=1.00)
  - 
  - Fix: Add a 'Forgot password?' TextButton below the password field (right-aligned, burgundy, Parkinsans SemiBold 13) routing to context.goNamed(AppRoute.forgotPassword.name). Mark with TODO referencing the Figma follow-up.
- **[semantics]** `[auto-fixable]` Password visibility toggle has no semantic label and tap target <48dp  (conf=1.00)
  - 
  - Fix: Replace InkResponse with IconButton (gives 48x48 tap target + tooltip slot). Add Semantics(button: true, toggled: !obscure, label: obscure ? 'Show password' : 'Hide password'). Exclude inner Icon semantics.
- **[form-submission]** `[auto-fixable]` Submit button not disabled when form is invalid  (conf=0.95)
  - 
  - Fix: Derive state.canSubmit = email.isValid && password.isValid in LoginState/controller. Gate onPressed: (state.isLoading || !state.canSubmit) ? null : controller.submit.
- **[tap-target]** `[auto-fixable]` Sign Up link tap target ~30dp, below 48dp minimum, missing semantic role  (conf=0.88)
  - 
  - Fix: Replace InkWell+Text with TextButton (built-in 48dp + semantic role) or wrap in SizedBox(height: 48) and add Semantics(button: true, label: 'Sign up').
- **[missing-illustration]** Apple sign-in icon uses Material Icons.apple_rounded instead of Apple's mandated brand glyph  (conf=0.85)
  - 
  - Fix: Add official Apple logo SVG (assets/icons/apple_logo.svg) per Apple HIG, render via SvgPicture.asset with ColorFilter to AppColors.surface. Better: use sign_in_with_apple package's SignInWithAppleButton for App Store compliance.

### auth/register:/auth/register
- **[ad-hoc-component]** Hand-rolled Google/Apple social buttons duplicate AppPillButton instead of extending it  (conf=1.00)
  - 
  - Fix: Extract AppSocialPillButton(label, leading, foreground, background, borderSide, onPressed, isLoading) in lib/src/common/components/buttons/. Or extend AppPillButton with social variant + leading slot. Delete _GoogleSignUpButton/_AppleSignUpButton and reuse for login screen.
- **[semantics]** `[auto-fixable]` Password obscure toggle missing semantic label and tap target below 48dp  (conf=1.00)
  - 
  - Fix: Replace InkResponse with IconButton (default 48dp tap area) and add Semantics(button: true, label: obscure ? 'Show password' : 'Hide password', child: ...) or use tooltip prop on IconButton.
- **[semantics]** `[auto-fixable]` Decorative logo mark and Google 'G' badge not excluded from semantics  (conf=1.00)
  - 
  - Fix: Wrap _SignUpLogoMark inner Stack in ExcludeSemantics (or Semantics(label: 'Nibbles', image: true, child: ExcludeSemantics(...))). Wrap _GoogleGlyph in ExcludeSemantics.
- **[asset-placement]** Google glyph is a fake blue badge instead of the brand-color G mark  (conf=0.90)
  - 
  - Fix: Replace _GoogleGlyph with proper SVG asset of official Google G mark (4-color: blue, red, yellow, green). Add assets/svg/google_g.svg, wire through flutter_gen as Assets.svg.googleG, render via SvgPicture.asset at 24x24 to match inline icon scale.
- **[result-handling]** Password format error never displayed when server returns password-specific error  (conf=0.85)
  - 
  - Fix: Differentiate error category in controller — emailErrorMessage, passwordErrorMessage, generalErrorMessage based on Failure code. Render each under appropriate field; show snackbar/banner for general errors.
- **[form-submission]** Double-submit / cross-button race — email Sign Up not disabled when social sign-in in flight  (conf=0.80)
  - 
  - Fix: Shared 'busy' flag covering email + social in state. Disable Sign Up button whenever state.isLoading regardless of isValid. Synchronously set isLoading=true at top of submit/_runSocial before any await.
- **[result-handling]** errorMessage cleared by every keystroke — server error vanishes when typing in the OTHER field  (conf=0.70)
  - 
  - Fix: Split errorMessage into per-field server errors (emailServerError, passwordServerError, generalError) in RegisterState. updateEmail clears only emailServerError; updatePassword clears only passwordServerError.
- **[result-handling]** No connectivity / offline check before submit — confusing Supabase network error surfaced  (conf=0.60)
  - 
  - Fix: Map Dio/SocketException to known Failure type in service. Surface 'No internet connection. Please check and try again.' per error-handling rules.

### auth/reset_password:/auth/reset-password
- **[ad-hoc-component]** errorText slot abused as always-on guidance — wrong border/focus state + screen readers announce error  (conf=1.00)
  - 
  - Fix: Add helperText + helperColor params to AppTextField that render a green caption without flipping border to error state or suppressing focus shadow, and without setting InputDecoration.errorText. In reset_password_screen, pass helperText: passwordHelper instead of errorText, and only set errorText when state.passwordTooShort / confirmTooShort / confirmMismatch is true.
- **[textfield-behavior]** `[auto-fixable]` Missing textInputAction + focus chain between password and confirm fields  (conf=1.00)
  - 
  - Fix: Convert ResetPasswordScreen to ConsumerStatefulWidget with two FocusNodes (passwordNode, confirmNode). First field: textInputAction.next + focusNode + onSubmitted: (_) => confirmNode.requestFocus(). Second field: textInputAction.done + focusNode + onSubmitted: (_) => controller.submit(). Dispose both nodes.
- **[form-submission]** `[auto-fixable]` Confirm-empty mismatch silently no-ops (errorMessage filtered, helper hidden) — blocking submission with no feedback  (conf=0.85)
  - 
  - Fix: Gate the submit button on validity (canSubmit = !isLoading && !password.isNotValid && passwordsMatch && confirmPassword.isNotEmpty) so the silent-failure path cannot be reached, and remove the string-equality suppression of errorMessage when confirm is empty.
- **[navigation]** Back button on AU-03 leaks recovery session — does not sign out before falling back to /login  (conf=0.60)
  - 
  - Fix: Before context.goNamed(login) in goBack(), await authService.signOut() so the recovery session is invalidated. Alternatively block back nav with PopScope until the password is updated.

### home:/home
- **[state-coverage]** `[auto-fixable]` Outer baby-id error has no retry CTA — user permanently stuck  (conf=1.00)
  - 
  - Fix: Pass onRetry that invalidates the baby id provider: error: (_, __) => _HomeErrorScaffold(message: 'Could not load baby profile.', onRetry: () => ref.invalidate(currentBabyIdProvider)). _HomeScreen is already a ConsumerStatefulWidget so ref is available.
- **[navigation]** `[auto-fixable]` Header avatar tap is dead — onAvatarTap never wired to profile route  (conf=1.00)
  - 
  - Fix: Pass onAvatarTap: () => context.pushNamed(AppRoute.profile.name) to HomeHeader at line 159, mirroring OngoingIntroducedCard's pattern.
- **[layout-drift]** Hero is fragmented floating cards instead of single full-bleed butter band (SafeArea blocks status-bar bleed)  (conf=0.99)
  - 
  - Fix: Restructure _HomeContent: remove outer SafeArea, render one full-bleed butter→butterSoft gradient hero Container that extends under the status bar (use MediaQuery.padding.top inner padding only). Inside the hero, lay out Today pill / Nibbles wordmark / avatar Row, tri-color greeting Text.rich, then nested butterSoft StatRingCard — all on the butter band with AppSizes.pagePaddingH inner padding. Strip the rounded gradient Container from HomeHeader so it becomes a pure Row composable inside the hero. Apply page horizontal padding only to middle/tips sections so hero reaches screen edges. Keep SafeArea(top: false) on the scrollable content below. Apply same change to home_empty_state_full.dart.
- **[missing-reusable]** HomeHeader reimplements AppHeader instead of consuming AppHeaderWash.butterGradient  (conf=0.99)
  - 
  - Fix: Replace HomeHeader's Container+Row with AppHeader(title: 'Nibbles', wash: AppHeaderWash.butterGradient, leading: _TodayPill(), trailing: _HeaderAvatar(...)). Move _TodayPill into common/components/chips or expose as typed slot. Drop unused ageMonths param.
- **[missing-reusable]** StatRingCard reimplements AppProgressRing with private painter  (conf=0.94)
  - 
  - Fix: Delete _StatRing + _RingPainter. Compose AppProgressRing(value: x, max: y, diameter: 44, thickness: 6) beside label/value Column. If value/max label must live outside the ring, add AppProgressRing.barebones constructor or showLabel: false flag so same painter is reused without inner RichText.
- **[semantics]** `[auto-fixable]` Loading indicator has no semantic label  (conf=0.85)
  - 
  - Fix: Wrap with Semantics(label: 'Loading home dashboard', child: const CircularProgressIndicator()) or use SemanticsService.announce so screen readers convey loading state.
- **[missing-illustration]** Empty-state 'Ready to Start?' has no hero illustration  (conf=0.65)
  - 
  - Fix: Add a hero illustration slot above the 'Ready to Start?' headline inside ReadyToStartCard (or above it in HomeEmptyStateFull). Once SVG provided (e.g. assets/images/home_empty_meal.svg), render via Assets.images.homeEmptyMeal.svg() with flutter_svg, sized ~140-180dp, centered, semanticLabel: 'Empty meal plan illustration'. Confirm Figma frame 1266:12135 with designer.

### meal_plan/map:/home/meal/map
- **[ad-hoc-component]** `[auto-fixable]` Allergen tag chip reimplemented inline in two duplicate _TagsRow widgets instead of AppChip  (conf=1.00)
  - 
  - Fix: Delete both _TagsRow copies. Use AppChip(label: t.replaceAll('_',' '), emoji: AllergenEmoji.get(t)) inside a Wrap. Removes the hardcoded vertical: 2 padding magic numbers as a side effect.
- **[tooltip]** `[auto-fixable]` Back IconButton missing tooltip/semantic label  (conf=1.00)
  - 
  - Fix: Add tooltip: 'Back' to the leading IconButton in _MapMealsAppBar (and/or wrap with Semantics(label: 'Back', button: true)).
- **[layout-drift]** Header subtitle rendered as trailing pill chip instead of stacked subline under title  (conf=0.99)
  - 
  - Fix: Replace _MapMealsAppBar with AppHeader (or a non-AppBar Column + SafeArea) that stacks title (Title3/Bold 17/700) and the slot-count line (Subhead/SemiBold 13/600 in fgMuted) left-aligned next to a 44px round back button. Remove the trailing pill. Wrap slot-count in Semantics(container: true, liveRegion: true, label: '${filled} of ${total} meal slots filled'). Add Semantics(header: true) to the title and tooltip 'Back' to the leading IconButton. Apply butter/cream gradient wash (AppHeaderWash.butterGradient) to the hero area.
- **[semantics]** `[auto-fixable]` Commit CTA loses label and announces only 'disabled' while saving  (conf=0.94)
  - 
  - Fix: Wrap the FilledButton (or its child) in Semantics(button: true, enabled: !disabled, label: state.isCommitting ? 'Saving meal plan' : label, child: ...) and ExcludeSemantics around the CircularProgressIndicator. Optionally add a hidden Semantics(liveRegion: true) Text('Saving…') while committing.
- **[ad-hoc-component]** Commit FilledButton and retry dialog FilledButton duplicate AppPillButton styling  (conf=0.90)
  - 
  - Fix: Replace _CommitBar's FilledButton with AppPillButton(label, variant: primary, onPressed: disabled ? null : onCommit, loading: state.isCommitting). Extend AppPillButton with a `loading: bool` prop that renders a CircularProgressIndicator and excludes it from semantics. Apply the same swap to _showRetryDialog actions.
- **[ad-hoc-component]** `[auto-fixable]` PickedRecipeRow and AssignedRecipeCard use inline Container instead of AppCard (broken ripple)  (conf=0.85)
  - 
  - Fix: Replace InkWell+Container with AppCard(onTap: onTap, child: Row(...)) and delete the local BoxDecoration. Apply the same swap to selected_day_slot_list.dart::_AssignedRecipeCard.
- **[navigation]** `[auto-fixable]` No PopScope guard — back gesture during commit or with assignments loses work silently  (conf=0.85)
  - 
  - Fix: Wrap Scaffold in PopScope(canPop: state.assignments.isEmpty && !state.isCommitting, onPopInvoked: ...) showing a 'Discard unsaved meal mappings?' confirm. Route the AppBar leading IconButton through the same guard.
- **[result-handling]** commit() can throw raw exception from currentBabyIdProvider.future — violates Result<T>  (conf=0.70)
  - 
  - Fix: Wrap ref.read(currentBabyIdProvider.future) in try/catch in commit(). On error: set state.errorMessage, isCommitting=false, log to Crashlytics, return false so the existing retry dialog path fires.

### meal_plan:/home/meal
- **[state-coverage]** `[auto-fixable]` babyId error/empty branches have no Retry CTA or recovery path (and no live-region semantics)  (conf=0.94)
  - 
  - Fix: Replace the bare `Text('Could not load baby profile.')` with an ErrorState using the _ErrorView pattern (or common EmptyState) wired to ref.invalidate(currentBabyIdProvider). For the null-baby branch surface a 'Set up baby profile' CTA routing to /onboarding/baby_setup or /home/profile/edit. Wrap message in Semantics(liveRegion: true, container: true).
- **[ad-hoc-component]** `[auto-fixable]` AddToShoppingListModal uses CheckboxListTile + FilledButton instead of AppCheckbox + AppPillButton  (conf=0.90)
  - 
  - Fix: Replace CheckboxListTile with Row(children: [AppCheckbox(value: selected, onChanged: ...), SizedBox(width: sm), Expanded(child: Text(name))]). Replace FilledButton with AppPillButton(label: 'Add ($n) items', onPressed: ..., variant: primary). Reuse drag-handle pattern.
- **[ad-hoc-component]** `[auto-fixable]` RangeAddToShoplistSheet hand-rolls checkbox and bottom actions instead of DS components  (conf=0.90)
  - 
  - Fix: Replace _CheckboxIcon with AppCheckbox. Replace _IngredientRow's Container with AppCard(variant: AppCardVariant.soft). Replace _BottomActions inner buttons with AppPillButton(variant: secondary) + AppPillButton(variant: primary, onPressed: anySelected ? onSubmit : null). Delete _BottomActions raw styling.
- **[ad-hoc-component]** `[auto-fixable]` AddDatePill reimplements stadium pill instead of using AppPillButton.secondary  (conf=0.85)
  - 
  - Fix: Replace AddDatePill body with `AppPillButton(label: 'Add Date', variant: AppPillButtonVariant.secondary, size: AppPillButtonSize.small, leading: const Icon(Icons.add), expand: true, onPressed: onPressed)` wrapped in the same Padding. Delete the Material/StadiumBorder/Text overrides.
- **[form-submission]** `[auto-fixable]` Double-submit possible on day-card '+ Add' (no in-flight guard, no spinner)  (conf=0.85)
  - 
  - Fix: Track `Set<DateTime> _dayInFlight` in `_MealPlanBodyState`, set day true before showing browse sheet, reset in `finally`. Pass `isSubmitting`/`enabled` down to DayAccordionCard so its 'Add' pill disables while in-flight and shows a small inline spinner.
- **[asset-placement]** Header band uses butter gradient instead of page-level Grad-1 (and section title trapped inside header)  (conf=0.82)
  - 
  - Fix: Remove the LinearGradient(butter→butterSoft) BoxDecoration from MealPlanHeader. Paint the Scaffold with the cream Grad-1 gradient (or AppColors.background). Drop the dayCount slot from MealPlanHeader and render 'Meal plan for $dayCount days' as a SliverToBoxAdapter Text in _PopulatedView using AppTypography.textTheme.title3 with EdgeInsets.fromLTRB(pagePaddingH, md, pagePaddingH, sm).
- **[form-submission]** _onClearWindow lacks in-flight guard and progress feedback  (conf=0.80)
  - 
  - Fix: Add `bool _clearing` to `_MealPlanBodyState`; early-return if already clearing; show a non-dismissible loading dialog while clearRange awaits; reset in `finally`. Fire HapticFeedback.mediumImpact() on Delete tap.
- **[semantics]** SnackBar error toasts lack live-region announcement and Retry action  (conf=0.70)
  - 
  - Fix: Wrap SnackBar Text in Semantics(liveRegion: true, ...). Project error rules note these are P2 toasts — but add SnackBarAction(label: 'Retry', onPressed: ...) where retry is feasible (meal plan add, clear). At minimum mark the message as live region.
- **[ad-hoc-component]** DayAccordionCard outer GestureDetector swallows taps for popup/chevron  (conf=0.60)
  - 
  - Fix: Make only the Expanded(dateLabel Text) tappable for toggle (wrap that Expanded in InkWell/GestureDetector). Let PopupMenuButton and the chevron own their gesture areas. Remove the outer GestureDetector(onTap: onToggle).
- **[tooltip]** MealPlanOverflowButton icon-only button semantics/tooltip not verified  (conf=0.60)
  - 
  - Fix: Open meal_plan_overflow_button.dart and confirm it wraps IconButton/InkWell with Tooltip(message: 'More options') and Semantics(button: true, label: 'More options', hint: 'Opens meal plan menu'). If absent, add it.

### onboarding/baby_setup:/onboarding/baby-setup
- **[ad-hoc-component]** Name step uses raw Material TextField instead of AppTextField; missing body subtext, optional last-name field, controller, autofocus, maxLength, textInputAction/onSubmitted  (conf=1.00)
  - 
  - Fix: Convert _NameStep to a ConsumerStatefulWidget owning a TextEditingController seeded with state.babyName.value. Replace TextField with AppTextField(label: "Baby's name", controller, autofocus: true, maxLength: 50, autofillHints: const [AutofillHints.name], textInputAction: TextInputAction.done, onChanged: controller.updateName, onSubmitted: (_) { if (state.babyName.isValid) controller.nextStep(); }, errorText: switch on state.babyName.error). Add body subtext Text via textTheme.bodyMedium with AppColors.subtext below the headline. Optional last name field requires state change (deferred).
- **[ad-hoc-component]** `[auto-fixable]` Raw FilledButton inline spinner used instead of AppPillButton with loading prop  (conf=1.00)
  - 
  - Fix: Replace each FilledButton with AppPillButton(label: 'Next' | "Let's go!", expand: true, isLoading: state.isLoading, onPressed: <validity guard> ? controller.nextStep / submit : null). Use AppPillButton's built-in loading affordance instead of inline CircularProgressIndicator.
- **[navigation]** `[auto-fixable]` Hardware/system back button bypasses controller.previousStep (no PopScope)  (conf=0.99)
  - 
  - Fix: Wrap Scaffold in PopScope(canPop: state.step == 0, onPopInvoked: (didPop) { if (!didPop) controller.previousStep(); }) so Android system back / iOS swipe-back steps backward through the wizard instead of popping the route.
- **[layout-drift]** Step indicator uses Material AppBar with text counter instead of AppHeader + progress bar / Figma's bottom-row back button pattern  (conf=0.94)
  - 
  - Fix: Remove the Material AppBar. Render an AppHeader (cream wash, optional AppRoundButton leading for back when step > 0) at the top of the body Column, and replace the 'Step X of 3' text with the shared ReadinessProgressBar / OnboardingProgressBar (filledCount: step + 1, totalSegments: 3) below the header. Per Figma, the back button can alternatively live in the bottom row next to the primary CTA as a lime circular AppRoundButton.
- **[tooltip]** `[auto-fixable]` Back IconButton missing tooltip / semantic label  (conf=0.94)
  - 
  - Fix: Add tooltip: 'Back' and Icon(Icons.arrow_back_rounded, semanticLabel: 'Back') to the IconButton. If migrating to AppHeader + AppRoundButton, ensure the round button exposes equivalent semantics.
- **[result-handling]** `[auto-fixable]` Submit error path uses inline Text without Retry CTA, non-brand error color, missing live-region semantics, and no fallback for null error message  (conf=0.88)
  - 
  - Fix: Wrap error Text in Semantics(liveRegion: true, container: true, child: ...). Use AppColors.burgundy + textTheme.labelSmall (10/16 caption) per brand error spec. Change CTA label to 'Retry' when state.errorMessage != null. In controller failure branch, default errorMessage to 'Something went wrong. Please try again.' when error.message is null.
- **[density]** Baby-setup flow missing housekeeping/medical-clearance step and loading transition; uses non-Figma gender step  (conf=0.70)
  - 
  - Fix: Reconcile with product/design: (a) add the housekeeping acknowledgement step (gt6mo: 2 checkboxes, lt6mo: 3 checkboxes branched on DOB) before final submit; (b) route through AppRoute.onboardingBabySetupLoading after submit instead of jumping straight to /home; (c) confirm whether the gender step is intentional in-house addition or should be removed.
- **[result-handling]** Submit step 2 lacks createBaby/createAllergenProgramState atomic guarantee — retry creates duplicate baby rows  (conf=0.65)
  - 
  - Fix: Move the two-write into a single Supabase RPC/transaction at the repository layer. Until then, on retry detect existing baby for user and re-attempt only createAllergenProgramState. Surface 'Something went wrong setting up your baby. Tap Retry to continue.'

### onboarding/baby_setup_loading:/onboarding/baby-setup-loading
- **[contrast]** Cream-on-cream 'LOADING' caption fails WCAG contrast — invisible to low-vision users with no alternative loading affordance  (conf=1.00)
  - 
  - Fix: Keep the decorative cream caption (intentional per spec) but add a sibling Semantics(label: 'Loading', liveRegion: true) wrapper so the loading state is communicated non-visually. For visible affordance to low-vision users, consider either a CircularProgressIndicator with AppColors.sage, or animating the PetalBlob (pulsing glow) so movement signals progress.
- **[interaction]** Static frame — missing rotating petal / pulsing glow animation called out in NIB-131 spec  (conf=0.75)
  - 
  - Fix: Add a subtle continuous animation to PetalBlob: rotate the outer Quatrefoil slowly (4-6s linear repeating) and/or pulse the glow dot's BoxShadow blurRadius/spreadRadius (1.2s ease-in-out) via TweenAnimationBuilder. Wire via StatefulWidget + SingleTickerProviderStateMixin. Gate with MediaQuery.disableAnimationsOf for reduced-motion users.
- **[navigation]** Auto-route fires only on loading->ready edge — no defense if state is already ready at mount  (conf=0.70)
  - 
  - Fix: After registering ref.listen, read current phase via ref.read inside a postFrameCallback and call _goHome() guarded by an _alreadyRouted flag if state is already `ready`. Also add a Timer fallback (minDwell + 200ms) calling _goHome() unconditionally as belt-and-suspenders.

### onboarding/consent:/onboarding/consent
- **[navigation]** `[auto-fixable]` Back button + system back can race in-flight submit, causing orphan baby + missed flag  (conf=0.94)
  - 
  - Fix: Gate back button: `onPressed: isSubmitting ? null : _onBack`. Wrap Scaffold body in `PopScope(canPop: !isSubmitting, onPopInvokedWithResult: (didPop, _) {})` to block Android hardware/gesture back during submit. Optionally surface a 'Setting up your baby...' snackbar on blocked pop.
- **[semantics]** `[auto-fixable]` Consent checkbox row lacks merged semantics — checkbox + label announced as separate nodes  (conf=0.94)
  - 
  - Fix: Wrap the InkWell child in MergeSemantics and add an outer Semantics(container: true, checked: value, onTap: () => onChanged(!value), label: label). Pass excludeSemantics: true on the inner AppCheckbox so its node isn't duplicated. Verify VoiceOver/TalkBack announce as a single 'label, checkbox, checked/not checked, double tap to toggle'.
- **[semantics]** `[auto-fixable]` Inline error not announced — missing live region for P1 error surface (WCAG 4.1.3)  (conf=0.94)
  - 
  - Fix: Wrap _InlineError outer Container in Semantics(liveRegion: true, container: true, label: 'Error: $message'). Wrap the inner Icon in ExcludeSemantics since the text duplicates meaning. Apply same treatment when extracted to common/components/feedback/inline_error.dart.
- **[rebuild-scope]** DOB change in keepAlive controller doesn't recompute checkbox count (initState stale)  (conf=0.90)
  - 
  - Fix: Replace initState derivation with reactive watch: in build(), ref.watch(onboardingControllerProvider.select((s) => s.dob)) and compute targetCount = _countFor(ageMonths). Reconcile _checks length on change (preserving existing values where indices overlap). Add a didUpdateWidget/listener fallback if state migration is needed. Add widget test that simulates DOB edit and asserts third checkbox appears for <6mo.
- **[state-coverage]** setOnboardingDone() Future not awaited — flag may not persist across cold-start  (conf=0.65)
  - 
  - Fix: Ensure LocalFlagService.setOnboardingDone returns Future<void> and await it before navigating: `await ref.read(localFlagServiceProvider).setOnboardingDone(); if (!mounted) return; context.goNamed(...);`. Better: move the await into OnboardingController.submit() per the separation-of-concerns finding.
- **[result-handling]** Result<T> from submit collapsed to bool — UI cannot distinguish auth-lost (P0) from connectivity (P1) from validation  (conf=0.55)
  - 
  - Fix: Expose Result<Baby> (or typed OnboardingSubmitOutcome enum) from submit() on controller state. Branch in screen: 401/auth-lost -> AuthService.signOut + goNamed('/auth/login') per error-handling.md; connectivity Failure -> canonical 'No internet connection. Please check and try again.' P1; validation Failure -> existing inline error.

### onboarding/dob:/onboarding/dob
- **[asset-placement]** Hero illustration missing the baby-face icon overlay  (conf=0.90)
  - 
  - Fix: Stack a baby-face SVG/asset inside the Quatrefoil. Add a brand component BabyFaceMark in common/components/brand/ that renders the line-art baby head matching Group76, then replace Quatrefoil() with Stack(alignment: Alignment.center, children: [Quatrefoil(size: 120), BabyFaceMark(size: 74)]). Also verify if Figma cluster includes 2-3 PetalBlob accents per the dartdoc reference.
- **[ad-hoc-component]** _AgeChip reimplements AppChip neutral tone inline  (conf=0.90)
  - 
  - Fix: Delete _AgeChip and use AppChip(label: _ageLabel(_selected), tone: AppChipTone.neutral). If Figma needs larger pill, add a size: AppChipSize.lg variant on AppChip once and reuse.
- **[asset-placement]** `[auto-fixable]` Background uses solid cream instead of Figma's diagonal gradient  (conf=0.85)
  - 
  - Fix: Replace `backgroundColor: AppColors.cream` with `backgroundColor: Colors.transparent` and wrap the SafeArea in a Container with `BoxDecoration(gradient: LinearGradient(begin/end at ~154deg, colors: [AppColors.butterSoft, Color(0xFFF5F5F5)], stops: [0.19, 0.5]))`. Better: lift the gradient into a shared OnboardingBackground widget.
- **[semantics]** `[auto-fixable]` Date wheel columns lack semantic labels and value announcements  (conf=0.85)
  - 
  - Fix: Wrap the CupertinoPicker (or parent SizedBox) in Semantics(label: header, value: itemBuilder(selectedIndex), container: true, child: ...). Optionally SemanticsService.announce composed DOB on change.

### onboarding/intro:/onboarding/intro
- **[missing-illustration]** Device-mockup placeholder instead of designed iPhone illustration (NIB-138)  (conf=1.00)
  - 
  - Fix: Land NIB-138: export 3 iPhone 15 phone-mockup SVGs from Figma frames (971:10019/1242:10897/1242:11124) into assets/images/onboarding/intro_slide_{1,2,3}.svg with the white-fade Rectangle 7183 overlay baked in, regenerate assets via make gen, then replace _DeviceMockupPlaceholder with an _IntroIllustration using SvgPicture.asset indexed by slideIndex. Wrap in ExcludeSemantics since illustrations are decorative.
- **[semantics]** `[auto-fixable]` Dot indicator has no semantics — invisible to screen readers  (conf=1.00)
  - 
  - Fix: Wrap the _DotIndicator Row in Semantics(container: true, label: 'Page ${currentIndex + 1} of $count', excludeSemantics: true, liveRegion: true) so dots don't pollute the tree but page position is announced on change.
- **[form-submission]** `[auto-fixable]` Back button (visible+tappable) has no-op + no disabled state on slide 1  (conf=0.94)
  - 
  - Fix: Pass onPressed: currentPage == 0 ? null : onBack to AppRoundButton so it visually + semantically disables on slide 1 (InkWell treats null as disabled and Semantics.enabled becomes false).
- **[ad-hoc-component]** _AppleShoplistRow reimplements ShopRow with broken checkbox + ad-hoc Container  (conf=0.90)
  - 
  - Fix: Replace _AppleShoplistRow with the existing ShopRow component from lib/src/common/components/cards/shop_row.dart (label: 'Apple', isBought toggled by local state, no-op onToggle/onDelete or tiny demo state). Add a tone/background param to ShopRow if butter variant is needed, instead of forking a Container. Remove hardcoded Color(0xFFFFFEEA).
- **[semantics]** `[auto-fixable]` Carousel slides lack Semantics container + live region for screen readers  (conf=0.85)
  - 
  - Fix: Wrap each slide's content in Semantics(container: true, liveRegion: true, label: '${_eyebrow} ${data.title}. ${data.body}') with the inner Text widgets excluded from semantics, so the eyebrow+title+body read as one merged sentence and slide changes are announced.
- **[semantics]** `[auto-fixable]` Fake AppCheckbox + Icons.cancel on slide-2 demo are announced as actionable  (conf=0.85)
  - 
  - Fix: Wrap _AppleShoplistRow in ExcludeSemantics + add a Semantics(label: 'Example: Apple item on shopping list') node so the fake checkbox and cancel icon don't surface as interactive.
- **[semantics]** Auto-advance carousel inaccessible — no pause control / WCAG 2.2.2 violation  (conf=0.80)
  - 
  - Fix: Disable auto-advance when MediaQuery.of(context).accessibleNavigation == true (screen reader on) or MediaQuery.disableAnimations == true. Skip _scheduleAutoAdvance in those cases.
- **[navigation]** setHasLaunched fire-and-forget before navigation can race router redirect  (conf=0.70)
  - 
  - Fix: Add awaitable markHasLaunched() to LocalFlagService (mirror markProgramCompletionShown / setAccountDeleted patterns), then await ref.read(localFlagServiceProvider).markHasLaunched(); before the if (!mounted) return; context.goNamed(...) in _onPrimaryPressed.

### onboarding/name:/onboarding/name
- **[navigation]** `[auto-fixable]` context.goNamed wipes back-stack; user cannot return to Name from DOB  (conf=0.85)
  - 
  - Fix: Replace `context.goNamed(AppRoute.onboardingDob.name)` with `context.pushNamed(AppRoute.onboardingDob.name)` so DOB pushes onto the stack and system back returns to Name with state intact.
- **[semantics]** Form field error announced only visually (no liveRegion)  (conf=0.60)
  - 
  - Fix: Either confirm AppTextField forwards errorText to inner InputDecoration (Flutter auto-sets semantic error) or wrap field in Semantics(liveRegion:true) when errorText != null.
- **[missing-illustration]** Possible missing hero illustration above name prompt  (conf=0.45)
  - 
  - Fix: Cross-check Figma 971:10266 for hero illustration. If present, export, add to assets/images/, run make gen, render via Assets.images.<name>.image(...) above the headline.

### onboarding/readiness:/onboarding/readiness
- **[semantics]** `[auto-fixable]` ReadinessProgressBar has no semantic value or label  (conf=0.95)
  - 
  - Fix: Wrap the ClipRRect in Semantics(label: 'Readiness progress', value: '${currentIndex + 1} of $stepCount', child: ...). Pass currentIndex and stepCount down to the widget if not already available.
- **[semantics]** `[auto-fixable]` Step changes not announced as live region (a11y)  (conf=0.91)
  - 
  - Fix: Wrap the counter Text in Semantics(liveRegion: true, container: true, label: 'Question ${_currentIndex + 1} of $_readinessTotalSteps', child: ...). Add SemanticsService.announce('Question N of M') inside _onNext/_onBack after setState.
- **[asset-placement]** `[auto-fixable]` Missing cream-to-grey background gradient  (conf=0.90)
  - 
  - Fix: Replace `Scaffold(backgroundColor: AppColors.background, body: SafeArea(...))` with a Container wrapping SafeArea using LinearGradient from AppColors.butterSoft to Color(0xFFF5F5F5). Better: extract into a shared OnboardingGradientBackground widget since every onboarding screen needs it.
- **[layout-drift]** `[auto-fixable]` Title and body text alignment drift from Figma (centered vs left-aligned)  (conf=0.85)
  - 
  - Fix: Remove `textAlign: TextAlign.center` from title (line 160) and body (line 166) Text widgets. Set crossAxisAlignment: CrossAxisAlignment.start on outer Column. Keep the question counter centered as in Figma.

### onboarding/result:/onboarding/result
- **[asset-placement]** Hero illustration missing baby face (Group 78) — renders bare Quatrefoil instead  (conf=1.00)
  - 
  - Fix: Export Figma node Group 78 as SVG (or 2x/3x PNG) at 154x154 to assets/images/onboarding/readiness_baby_hero.svg, run make gen, then replace the bare Quatrefoil in _HeroCard.build with SvgPicture.asset(Assets.images.onboarding.readinessBabyHero) sized to 154. Recompute the overlap padding (heroSize/2 = 77) and _SignsCard top padding accordingly.
- **[semantics]** `[auto-fixable]` Sign-row check/cross icon state invisible to screen readers  (conf=0.95)
  - 
  - Fix: Wrap _SignRow Row in Semantics(container: true, label: '${positive ? 'Met' : 'Not met'}: $label', child: ExcludeSemantics(child: Row(...))). Alternative: set semanticLabel on the Icon directly.
- **[separation-of-concerns]** Readiness threshold business rule and UI copy live in the Screen file  (conf=0.70)
  - 
  - Fix: Move readinessReadyThreshold and the ready derivation onto OnboardingController (or a selector on OnboardingState) and ref.watch a readinessOutcome view-model. Move _signLabels into a constants file or easy_localization keys.

### profile/edit:/home/profile/edit
- **[asset-placement]** Avatar uses Material baby icon fallback instead of Figma peach illustration  (conf=1.00)
  - 
  - Fix: Ship the Figma 143x143 'Nibbles Graphic_Circle Peach 1' asset into assets/images/ (with 2x/3x), regenerate via `make gen`, and replace the Container+Icon in _EditAvatar with Assets.images.profileAvatar.image(width: 143, height: 143, fit: BoxFit.cover). Centralize in a shared BabyAvatar widget under common/components/brand/ so ProfileAvatarCard and _EditAvatar both reference the same asset and glyph fallback.
- **[layout-drift]** `[auto-fixable]` Text-field border drifts from Figma forest-darken outline to soft grey  (conf=0.90)
  - 
  - Fix: Extend AppTextField with optional borderColor/backgroundColor overrides (or add an AppTextFieldVariant.outlined variant) and pass borderColor: AppColors.greenDeep + backgroundColor: AppColors.borderSoft on this screen to match Figma h48, radius 10, 1px ForestDarkn outline on #EAEAEA fill.
- **[semantics]** `[auto-fixable]` Form field labels not linked to text inputs (accessible name broken)  (conf=0.85)
  - 
  - Fix: Pass the label down into AppTextField as InputDecoration.labelText (preferred — keeps native a11y wiring) so screen readers announce 'First Name' / 'Last Name, optional' / 'Email' when focusing the input. Alternatively wrap each field with Semantics(label, textField: true) + MergeSemantics linking the visible Text to the field.
- **[semantics]** `[auto-fixable]` Inline error text not live-announced to screen readers  (conf=0.85)
  - 
  - Fix: Wrap the formState.errorMessage Text in Semantics(liveRegion: true, child: Text(...)) and prefix message with 'Error:' so it is announced when it appears after a failed save.
- **[separation-of-concerns]** Email/firstName/canSave validation logic computed in build instead of controller/state  (conf=0.80)
  - 
  - Fix: Move emailValid / firstNameValid / canSave / emailTouched into ProfileEditState (freezed) and the controller using Formz EmailInput + BabyName. Expose canSave and emailError as derived getters; screen only reads precomputed booleans.
- **[result-handling]** Save uses bare success bool instead of Result<T> + no P1 retry on failure  (conf=0.75)
  - 
  - Fix: Refactor controller.save() to return Result<ProfileEditSaveData> per CLAUDE.md rule. UI handles .when(success, failure) and shows a P1 inline error + Retry button per error-handling.md spec.

### profile/feedback:/home/profile/feedback
- **[ad-hoc-component]** _FeedbackField re-implements AppTextField instead of extending it with multiline knobs  (conf=1.00)
  - 
  - Fix: Extend AppTextField with optional multiline knobs (minLines, maxLines, maxLength, textCapitalization, optional height override that bypasses the fixed AppSizes.fieldHeight) and replace _FeedbackField with AppTextField(hintText: 'Your feedback...', controller: _controller, onChanged: widget.onChanged, minLines: 6, maxLines: 10, maxLength: 2000, textCapitalization: TextCapitalization.sentences, keyboardType: TextInputType.multiline). Delete the local AnimatedContainer + decoration block.
- **[semantics]** `[auto-fixable]` TextField has no accessibility label / semantic relationship to helper text  (conf=0.99)
  - 
  - Fix: Wrap the TextField (lines 389-412) in Semantics(label: 'Feedback message', hint: 'Thank you. We read every message.', textField: true, child: ...) so screen readers announce the purpose and the helper string together. Alternatively wrap field + helper in MergeSemantics.
- **[semantics]** `[auto-fixable]` Loading/Success caption not announced as live region — screen reader users cannot verify success  (conf=0.94)
  - 
  - Fix: Wrap the caption Text in _FeedbackTransitionScreen (lines 226-239) in Semantics(liveRegion: true, label: caption, child: Text(...)). Optionally call SemanticsService.announce(caption, TextDirection.ltr) on phase change so success is announced before auto-pop.

### profile:/home/profile
- **[asset-placement]** Avatar circle uses placeholder coral + Material icon instead of brand peach-circle PNG asset  (conf=1.00)
  - 
  - Fix: Export `Nibbles Graphic_Circle Peach 1` from Figma as 286x286 PNG (2x of 143 logical), add to `assets/illustrations/profile_avatar_peach.png`, register in pubspec, regen flutter_gen, replace Container+Icon with `Image.asset(Assets.illustrations.profileAvatarPeach.path, width: 143, height: 143)`. Reuse in profile_edit_screen and future allergen-complete screen.
- **[sheet-behavior]** `[auto-fixable]` Delete account sheet allows scrim/back dismissal during in-flight deletion (data-loss UX)  (conf=1.00)
  - 
  - Fix: Pass isDismissible: !submitting and enableDrag: !submitting on showModalBottomSheet, AND wrap the sheet body in PopScope(canPop: !submitting, onPopInvoked: (_) {}) to block Android back-button during the destructive call.
- **[semantics]** `[auto-fixable]` Settings rows lack Semantics button role / hint  (conf=0.99)
  - 
  - Fix: Wrap the Material/InkWell tree in Semantics(button: true, label: title, value: subtitle, hint: danger ? 'Destructive action' : null, child: ExcludeSemantics(child: ...)). Wrap chevron Icon in ExcludeSemantics.
- **[semantics]** `[auto-fixable]` Edit button has no Semantics label / button role  (conf=0.94)
  - 
  - Fix: Wrap InkWell in Semantics(button: true, label: 'Edit', hint: 'Edit baby profile', child: ...). Alternatively use a TextButton/FilledButton.tonal which already provides correct semantics.
- **[asset-placement]** `[auto-fixable]` Header back chip is the wrong shape, size, and glyph vs Figma's rounded-square button-chip  (conf=0.90)
  - 
  - Fix: Replace AppRoundButton with a 41x41 Material InkWell wrapped in a `RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd))` (or introduce a `ButtonChip` shared component used by every header). Use `Icons.arrow_back` (Material) at 24px instead of `arrow_back_ios_new_rounded`. Apply `Colors.transparent` background. Long-term: factor this into a shared `AppHeader` + `AppButtonChip` pair so all audited section headers share one impl.
- **[ad-hoc-component]** `[auto-fixable]` ProfileAvatarCard hand-rolls pill button instead of using AppPillButton  (conf=0.88)
  - 
  - Fix: Replace with: AppPillButton(label: 'Edit', variant: AppPillButtonVariant.ghost, size: AppPillButtonSize.small, expand: false, onPressed: onEdit). If Figma height truly is 48, add a customHeight to AppPillButton or reconcile the spec.
- **[result-handling]** `[auto-fixable]` Sign-out failure is silently swallowed with no UI feedback (violates Result<T> rule)  (conf=0.85)
  - 
  - Fix: Either have authService.signOut() return Result<void> and handle Failure with a SnackBar 'Couldn't sign out, please try again', or wrap the await in try/catch and surface a P1 SnackBar on error.

### recipe/detail:/home/recipes/:recipeId
- **[navigation]** `[auto-fixable]` Error view traps user with no back navigation when recipe fetch fails  (conf=0.95)
  - 
  - Fix: Wrap all three error/empty branches (babyIdAsync.error, babyId==null, detailAsync.error) in a Scaffold with a RecipeDetailHeader (or AppBar) exposing a back chip wired to Navigator.maybePop(). Or render _ErrorView inside the existing RecipeDetailHeader layout.
- **[form-submission]** Shopping list add has no loading indicator while in-flight; overflow re-entrant; selection lost on failure  (conf=0.95)
  - 
  - Fix: Consume state.isAddingToShoppingList: disable RecipeDetailHeader overflow chip while true, short-circuit _handleOverflow if already true. Either show a blocking overlay/progress indicator, or keep the sheet open until the controller resolves (loading state on confirm CTA, pop on success, inline error on failure). On failure surface a Retry action that re-submits same payload.
- **[semantics]** `[auto-fixable]` Success banner not announced to screen readers (no liveRegion semantics)  (conf=0.94)
  - 
  - Fix: Wrap AddToMealPlanSuccessBanner container in Semantics(liveRegion: true, container: true, label: message) so screen readers announce the success message when it appears.
- **[layout-drift]** `[auto-fixable]` Ingredients/Method/Utensils not wrapped in a single white card  (conf=0.90)
  - 
  - Fix: Wrap the three IconSection blocks (Ingredients, Method, Utensils) in a single AppCard (cream/white surface, radiusLg). Inside the card, swap the SizedBox(AppSizes.lg) gaps for thin Divider(color: AppColors.borderSoft) rows between subsections, matching Figma 971:9659 grouping.
- **[layout-drift]** Storage/Freezer cards use coralSoft instead of design's deep salmon fill  (conf=0.80)
  - 
  - Fix: Change _StorageCard background from AppColors.coralSoft to AppColors.coral. Set title to AppColors.surface (white) and body to cream. Re-tone the leading icon to white so it reads against the salmon.
- **[missing-illustration]** Recipe hero placeholder uses Material icon instead of brand illustration  (conf=0.50)
  - 
  - Fix: Confirm with design whether the fallback should be a branded SVG. If yes, add assets/images/recipe_placeholder.svg, register in pubspec.yaml, regenerate assets.gen.dart, and replace the Icon with SvgPicture.asset inside _Fallback.

### recipe/library:/home/recipe
- **[state-coverage]** `[auto-fixable]` babyId error/null branches lack retry CTA and accessible recovery (also no pull-to-refresh action)  (conf=1.00)
  - 
  - Fix: Replace bare Center(Text(...)) blocks with a Column containing the message + ElevatedButton('Retry') invoking ref.invalidate(currentBabyIdProvider); for null-babyId route to onboarding/baby_setup; wrap with Semantics(liveRegion: true).
- **[semantics]** `[auto-fixable]` CircularProgressIndicator instances missing semanticsLabel  (conf=0.99)
  - 
  - Fix: Add semanticsLabel: 'Loading recipes' to each CircularProgressIndicator instance.
- **[semantics]** `[auto-fixable]` Error/empty text blocks lack liveRegion semantics and accessible retry  (conf=0.94)
  - 
  - Fix: Wrap error/empty Text in Semantics(liveRegion: true, container: true); add an explicit accessible Retry button alongside pull-to-refresh.
- **[interaction]** `[auto-fixable]` Starting Guide opens SnackBar TODO stub instead of pushing live route  (conf=0.90)
  - 
  - Fix: Replace SnackBar in _openStartingGuide with context.pushNamed(AppRoute.startingGuide.name); keep _onReadGuideTap marking the seen flag before the push; remove TODO and ScaffoldMessenger boilerplate.
- **[result-handling]** Recipe list fetch failure shows full-screen error instead of stale cache (violates P3 rule)  (conf=0.85)
  - 
  - Fix: Treat categoriesResult.isFailure as P3: log to Crashlytics via FirebaseCrashlytics.instance.recordError, fall back to cached recipes; only throw if cache also fails.

### shopping_list:/home/shopping-list
- **[missing-reusable]** Ad-hoc _ShoppingItemRow + _SquareCheckbox + _CancelChip duplicate ShopRow reusable  (conf=1.00)
  - 
  - Fix: Delete _ShoppingItemRow, _SquareCheckbox, _CancelChip. In _ItemsList.itemBuilder use ShopRow(label: item.name, isBought: item.isChecked, onToggle: ..., onDelete: ...). If size differences are design-locked, add dense flag to ShopRow.
- **[semantics]** `[auto-fixable]` _AddChip ('+') and _OverflowChip (more_horiz) have no semantic label or button role  (conf=1.00)
  - 
  - Fix: Wrap each with Semantics(button: true, label: 'Add ingredient'/'More options', child: ...). Better: replace with AppRoundButton which already provides semantics.
- **[semantics]** `[auto-fixable]` _CancelChip per-row delete has no semantic label  (conf=1.00)
  - 
  - Fix: Wrap with Semantics(button: true, label: 'Delete \${item.name}', hint: 'Removes this item from the list', child: ...). Plumb item name into _CancelChip via MergeSemantics on row.
- **[layout-drift]** Header '+' chip not present in canonical Figma screens; both chips use green-deep treatment  (conf=0.94)
  - 
  - Fix: Confirm with designer (Open Question 4). Recommended: drop _AddChip and keep a single green-deep more_horiz chip to match canonical 971:9851/971:9989/971:9872/971:9958. If both chips kept, render _OverflowChip with neutral surface to match 971:9889/971:9915.
- **[ad-hoc-component]** Ad-hoc _AddChip and _OverflowChip reimplement AppRoundButton (drops Semantics, Material ink, kit tokens)  (conf=0.90)
  - 
  - Fix: Replace _AddChip and _OverflowChip with AppRoundButton(tone: AppRoundButtonTone.green, ...). If 40px square is design-locked, extend AppRoundButton with shape: square|circle plus medium size token instead of forking inline.
- **[ad-hoc-component]** AddIngredientCard uses bare TextField + hand-rolled _AddPillButton instead of AppTextField/AppPillButton  (conf=0.85)
  - 
  - Fix: Add AppTextField.borderless constructor for embedded card use; replace _AddPillButton with AppPillButton(variant: ghost, size: small/compact).

### splash:/
- **[asset-placement]** Background and wordmark color inverted vs Figma forest-on-cream  (conf=0.77)
  - 
  - Fix: Set Scaffold.backgroundColor to AppColors.green (#5C7852) and override the wordmark style to AppTypography.brandWordmark.copyWith(color: AppColors.cream) so the lockup reads cream-on-forest like the Figma welcome frame. Optionally expose a brandWordmarkOnGreen variant in app_typography.dart.
- **[layout-drift]** Missing 'Welcome to' eyebrow line above the wordmark  (conf=0.60)
  - 
  - Fix: Add a Text('Welcome to') above the wordmark in _buildBranding using textTheme.titleSmall (Parkinsans ~17/600) in cream, with a small AppSizes.xs/sm gap so the eyebrow + wordmark read as one lockup. Consider gating on first launch via app_has_launched.
- **[asset-placement]** Quatrefoil icon shown on splash but not present in Figma welcome  (conf=0.55)
  - 
  - Fix: Drop the Quatrefoil from _buildBranding so the lockup is wordmark-only as in Figma. Confirm with designer before removing, since the petal mark may be an intentional brand signature held over from previous splash.

### starting_guide:/home/recipe/guide
- **[layout-drift]** `[auto-fixable]` ArticleCard diverges from Figma: should be cream-fill cards with quatrefoil chevron, title-only (no glyph, no subtitle, no shadow)  (conf=1.00)
  - 
  - Fix: Rebuild ArticleCard: replace Material+InkWell+Container(surface, shadowCard) with AppCard or a single container using color=AppColors.butterSoft (#FFFCD5), borderRadius=AppSizes.radiusMd (10), no boxShadow, padding EdgeInsets.symmetric(horizontal: 12, vertical: 24). Remove BabyFaceGlyph leading icon. Remove subtitle Text + preceding SizedBox. Replace trailing Icons.chevron_right_rounded with SizedBox(width: 48, height: 48, child: Quatrefoil(color: AppColors.butter, child: Icon(Icons.arrow_forward_rounded, color: AppColors.greenDeep, size: AppSizes.iconMd))). Title style: AppTypography.textTheme.titleSmall, AppColors.fgStrong. Wrap InkWell child with Semantics(button: true, label: article.title, child: MergeSemantics(...)) and ExcludeSemantics on the decorative Quatrefoil. Consolidates: layout-drift card identity (P1), subtitle not in Figma (P2), trailing chevron asset (P2), ad-hoc AppCard reimplementation (P2), missing semantics grouping (P1), decorative icons not excluded (P2).
- **[ad-hoc-component]** `[auto-fixable]` _Header reimplements AppHeader inline; should use AppHeader + AppRoundButton (delete GuideBackButton)  (conf=1.00)
  - 
  - Fix: Delete the private _Header widget (lines 115-165). Replace SliverToBoxAdapter(child: _Header(onBack: _onBack)) with SliverToBoxAdapter(child: AppHeader(title: 'Starting Guide', wash: AppHeaderWash.butterGradient, leading: AppRoundButton(icon: const Icon(Icons.arrow_back_rounded), tone: AppRoundButtonTone.ghost, size: AppRoundButtonSize.small, onPressed: _onBack, semanticLabel: 'Back'))). Drop the invented subtitle string (not in Figma 'Verbatim copy'). Delete widgets/guide_back_button.dart (duplicates AppRoundButton ghost/small). Restores Semantics(button: true, label: 'Back') for a11y and aligns with every other screen's header pattern. Consolidates: _Header duplication (P1), GuideBackButton duplicate (P2), invented subtitle (P2), back button missing Semantics (P1), back button tap target <48dp (P2), back button missing Tooltip (P2).
- **[missing-reusable]** `[auto-fixable]` Error state lacks retry CTA and uses ad-hoc Padding+Text instead of EmptyState reusable  (conf=0.94)
  - 
  - Fix: Replace the error branch with EmptyState(title: "Couldn't load the Starting Guide.", subtitle: 'Pull down or tap retry to try again.', ctaLabel: 'Retry', onCtaPressed: () => ref.invalidate(startingGuideControllerProvider)). Render this inside the CustomScrollView so the header (AppHeader with back button) remains visible — i.e. lift the header out of the data branch so loading/error/data all keep the back button reachable. Consolidates: missing EmptyState reusable (P2), missing retry CTA stranding the user (P1), loading state has no header (P3).
- **[separation-of-concerns]** Side effects (markStartingGuideSeen + analytics) in Screen initState violate Screen→Controller→Service layering  (conf=0.85)
  - 
  - Fix: Convert StartingGuideHubScreen to ConsumerWidget. Move markStartingGuideSeen + analytics events into StartingGuideController (e.g. fire from build() after data resolves, or expose markSeen()). Use ref.listen on the controller provider to fire markSeen() only when state transitions to AsyncData so the flag is only set after successful render (also fixes the 'markStartingGuideSeen fires on failure' P2 bug).

### starting_guide:/home/recipe/guide/:slug
- **[ad-hoc-component]** `[auto-fixable]` Custom _Header reimplements AppHeader with butter gradient instead of using design system  (conf=1.00)
  - 
  - Fix: Replace the custom `_Header` (lines 244-283) with `AppHeader(title: article.title, wash: AppHeaderWash.cream, leading: AppRoundButton(icon: const Icon(Icons.arrow_back_rounded), tone: AppRoundButtonTone.ghost, size: AppRoundButtonSize.small, semanticLabel: 'Back', onPressed: onBack))`. Use cream wash to match Figma recipe-library article convention. This also fixes title typography drift (AppHeader enforces w700/fgStrong/height:1) and the hardcoded butter gradient duplication.
- **[missing-reusable]** `[auto-fixable]` GuideBackButton duplicates AppRoundButton small+ghost variant and has no semantic label  (conf=1.00)
  - 
  - Fix: Delete `GuideBackButton`. Replace both call sites (article screen line 270 and _NotFound line 298, plus hub screen) with `AppRoundButton(icon: const Icon(Icons.arrow_back_rounded), tone: AppRoundButtonTone.ghost, size: AppRoundButtonSize.small, semanticLabel: 'Back', onPressed: onBack)`. This consolidates the design system, fixes the missing semantic label, and uses the kit's proper tap target.
- **[asset-placement]** Hero card renders generic BabyFaceGlyph placeholder instead of editorial illustration + splash decoration  (conf=0.99)
  - 
  - Fix: Extend `HeroCardBlock` with optional `imageAsset` and `splashAsset` fields. Add per-article SVG/PNG assets under `assets/images/starting_guide/<slug>/` and regenerate `assets.gen.dart` via `make gen`. In `GuideHeroCard`, switch to a `Stack` with the cream card body plus a positioned splash vector top-right; inside the card use a `Row` (text Column flex:1 on left, `Image.asset(imageAsset, width: 140)` on right). Keep `BabyFaceGlyph` as `errorBuilder` fallback. Update `articles.dart` introduction/baby_first_nibbles to pass hero asset keys.
- **[asset-placement]** Generic BabyFaceGlyph reused across InfoCard/IconTileGrid/PhilosophyCard creating uniform brown-circle wall  (conf=0.94)
  - 
  - Fix: Introduce a typed `GuideGlyph` enum (`nutrient`, `leaf`, `food`, `babyFace`) and per-block optional `glyph` field on `InfoCardBlock` / `IconTileGridBlock` / `PhilosophyCardBlock`. Wire each to a flutter_gen SVG under `assets/glyphs/starting-guide/`. Interim: tint BabyFaceGlyph differently per block (coral for nutrient, greenSoft for leaf) so blocks read as visually distinct.

### subscription/paywall:/subscription/paywall
- **[missing-illustration]** Mascot icon and feature thumbnails are Material placeholders, not Figma brand assets (missing assets/svgs/ directory)  (conf=1.00)
  - 
  - Fix: Export Nibble-Icon-2 (42x42), allergen-montage, recipes, and meal-plan thumbnails (68x68) from Figma. Create assets/svgs/ + assets/images/paywall/, register in pubspec.yaml, run make gen, then wire Assets.svgs.nibbleIcon2.svg() and Assets.images.paywall.* into _BrandRow and _FeatureRow. Keep radius-10 on first row only.
- **[ad-hoc-component]** Primary 'Try for $0' and secondary 'View all plans' CTAs hand-rolled instead of AppPillButton  (conf=1.00)
  - 
  - Fix: Replace both SizedBox+Material+InkWell blocks with AppPillButton (primary/secondary variants). Add `loading: bool` prop to AppPillButton so the purchasing spinner is uniform. This also picks up proper disabled-state semantics for free.
- **[tap-target]** `[auto-fixable]` Close button 34x33 tap target below 44pt/48dp accessibility minimum  (conf=1.00)
  - 
  - Fix: Remove the outer SizedBox(34x33) and BoxConstraints(minWidth:34,minHeight:33). Let IconButton default to 48x48 hit-box, or wrap the visual chip in SizedBox(width:48,height:48) so painted shape can stay 34x33 while tap surface meets the threshold.
- **[ad-hoc-component]** Restore-purchase pill rebuilt as TextButton+StadiumBorder instead of AppPillButton ghost/secondary  (conf=0.99)
  - 
  - Fix: Use AppPillButton(label: 'Restore purchase', variant: ghost/secondary, size: small, expand: false, onPressed: onRestore) with shared `loading` prop for spinner state.
- **[navigation]** `[auto-fixable]` Restore success calls Navigator.pop with no canPop guard — strands user when entered via /subscription/paywall route  (conf=0.99)
  - 
  - Fix: Mirror the purchase-success path: call context.goNamed(AppRoute.subscriptionSuccess.name) (or AppRoute.home) on restore success so destination is deterministic on both surfaces. Optionally guard with Navigator.canPop before fallback to goNamed.
- **[semantics]** `[auto-fixable]` Spinner-replaces-label leaves Restore and primary CTA buttons unlabeled to screen readers  (conf=0.99)
  - 
  - Fix: Wrap spinner branches in Semantics(label:'Restoring purchase', child:...) and Semantics(label:'Starting free trial', child:...). Alternatively keep visible text and stack spinner via Stack so accessible name never disappears.
- **[semantics]** `[auto-fixable]` Decorative icons (mascot, feature thumbnails, 5 star_rounded) not excluded from semantics  (conf=0.94)
  - 
  - Fix: Wrap each decorative icon in ExcludeSemantics or set semanticLabel:''. For the star row, wrap in MergeSemantics + Semantics(label:'5 star rating') so it announces once instead of five times.
- **[page-vs-sheet]** PaywallScreen full-page route mimics sheet without sheet ergonomics (no slide-up, no scrim dismiss, no drag handle)  (conf=0.88)
  - 
  - Fix: Replace the route page with a route that, on first frame, calls showPaywallSheet(context) on top of an empty Scaffold and pops on dismiss — unifying the modal sheet path. Alternative: keep the page treatment but add a GestureDetector on the scrim that pops, a drag handle, and a slide-up CustomTransitionPage. Option A is preferred (single rendering path).
- **[navigation]** Purchase success calls context.goNamed without popping the sheet — success screen appears beneath the paywall sheet  (conf=0.83)
  - 
  - Fix: Before context.goNamed, pop the sheet if active: `if (Navigator.canPop(context)) Navigator.of(context).pop();` then goNamed. Alternatively use rootNavigator: true on the pop.

### subscription/success:/subscription/success
- **[state-coverage]** Loading timeout silently 'succeeds' even when entitlement provisioning failed  (conf=0.50)
  - 
  - Fix: Add a provisioningTimeout phase (or expose Result<SubscriptionSuccessPhase>) so screen can render P1 'still working on it' with retry/contact-support when loadingTimeout fires AND isActive remains false. Alternatively guard route entry so this screen only renders when SubscriptionService.isActive has flipped true.

---

## P2 — Secondary Drift / UX Polish

### AddToMealPlanSheet
- **[separation-of-concerns]** babyId param required but unused in sheet  (conf=1.00)
- **[ad-hoc-component]** `[auto-fixable]` _SelectedDayBadge duplicates AppChip(tone: butter)  (conf=1.00)
  - Fix: Delete _SelectedDayBadge and replace its usage with const AppChip(label: 'Added', tone: AppChipTone.butter).
- **[ad-hoc-component]** `[auto-fixable]` Redundant Back + Close in sheet header (both pop; back arrow semantically wrong)  (conf=0.90)
  - Fix: Remove the leading back-arrow AppRoundButton from _SheetHeader. Sheets dismiss via the close X or barrier tap; modal has no nav stack to back to.
- **[missing-reusable]** Bottom-sheet shell (rounded top + safe area + radius) should be extracted to AppBottomSheet  (conf=0.85)
- **[sheet-behavior]** Selections silently discarded on swipe/scrim/back/close  (conf=0.85)
- **[layout-drift]** Unselected day cards should render dashed border, not solid  (conf=0.80)
- **[layout-drift]** Selected-day badge wrong color/content (should be cream count chip, not lime 'Added')  (conf=0.75)
- **[missing-reusable]** Day-card outer Container reimplements AppCard  (conf=0.75)
- **[tap-target]** _DayChip visual tap surface below 48dp minimum  (conf=0.75)
- **[missing-reusable]** _SheetHeader duplicates AppHeader pattern  (conf=0.70)
- **[semantics]** Selected-count text not announced as live region  (conf=0.70)
- **[semantics]** Selected-day badge and Add pill both announce 'Added' — duplicate semantics  (conf=0.70)
- **[layout-drift]** Sheet top inset hand-rolled; should use useSafeArea and natural sheet sizing  (conf=0.60)
- **[sheet-behavior]** Inner ListView vs sheet drag — gesture competition risk  (conf=0.50)

### AddToShoppingListModal
- **[layout-drift]** Sheet background flat white instead of butter Grad-1 gradient + wrong corner radius (16 vs 30)  (conf=1.00)
- **[layout-drift]** `[auto-fixable]` Title typography uses titleLarge (22) instead of Figma-spec titleSmall (17)  (conf=0.95)
  - Fix: Replace style: textTheme.titleLarge with style: textTheme.titleSmall on the 'Add to Shopping List' Text.
- **[state-coverage]** `[auto-fixable]` Error state has no retry/close affordance — user can only drag-down to dismiss  (conf=0.90)
  - Fix: In the _error != null branch render a Retry button (resets _loading=true, _error=null, recalls _loadIngredients) and a Close button (Navigator.pop(false)).
- **[layout-drift]** `[auto-fixable]` Header missing date subtitle and close (X) affordance  (conf=0.85)
  - Fix: Replace title Row with Expanded Column of Text(title, textTheme.titleSmall) over Text(formattedDate, textTheme.bodyMedium); add trailing InkWell(Icon(Icons.close, size:24)) → Navigator.pop(false). Reuse _Header pattern from range_add_to_shoplist_sheet.dart.
- **[missing-reusable]** Drag-handle Container reimplemented inline — missing SheetHandle reusable  (conf=0.85)
- **[ad-hoc-component]** `[auto-fixable]` Loading/error/empty states reimplemented instead of EmptyState/LoadingConfirmation  (conf=0.85)
  - Fix: Use EmptyState(title:'No ingredients', subtitle:'No ingredients found for this day.') for empty branch. Use shared LoadingConfirmation for loading. For error branch surface a typed Failure to EmptyState with Retry CTA.
- **[sheet-behavior]** `[auto-fixable]` Sheet dismissible during in-flight submit — silent partial success/failure  (conf=0.85)
  - Fix: Wrap sheet content in PopScope(canPop: !_submitting, onPopInvoked: (_) {}) so back gesture/drag/scrim is blocked while submitting.
- **[rebuild-scope]** Over-scoped setState rebuilds entire sheet on every selection change  (conf=0.80)
- **[semantics]** Initial-load CircularProgressIndicator has no semantics label  (conf=0.80)
- **[ad-hoc-component]** Header Select all/Deselect all uses TextButton instead of AppPillButton ghost  (conf=0.75)
- **[rebuild-scope]** ConsumerStatefulWidget where ConsumerWidget + provider suffices  (conf=0.75)
- **[semantics]** Error text not announced as liveRegion  (conf=0.75)
- **[tap-target]** Select all/Deselect all TextButton tap target below 48dp  (conf=0.70)
- **[navigation]** SnackBar captured against modal context popped in same frame — fragile success feedback  (conf=0.55)

### AddToShoppingListSheet
- **[tap-target]** `[auto-fixable]` Close (X) and per-row Remove tap targets below 48dp minimum  (conf=1.00)
  - Fix: Close button: use BoxConstraints(minWidth: 48, minHeight: 48) (or AppSizes.xxl) and remove EdgeInsets.zero. Per-row Remove: wrap the Icon in SizedBox(width: 48, height: 48) inside the InkResponse, keep visual icon at iconMd, set InkResponse radius >= 24.
- **[state-coverage]** `[auto-fixable]` Remove action has no Undo and is unrecoverable for the session  (conf=0.94)
  - Fix: Add SnackBarAction(label: 'Undo', onPressed: () => setState(() { _removed.remove(index); _selected.add(index); })) on the Removed snackbar. Include ingredient name in the message ('Removed $name'). Capture index in a closure per-call.
- **[semantics]** `[auto-fixable]` Removal SnackBar text not specific (no ingredient name)  (conf=0.94)
  - Fix: Replace 'Removed.' with 'Removed $name'. Optionally call SemanticsService.announce for AT reliability.
- **[missing-reusable]** Empty state forks the canonical EmptyState component and lacks recovery affordance  (conf=0.88)
- **[interaction]** Snackbar fired from inside modal sheet collides with caller toasts and risks being obscured  (conf=0.77)
- **[semantics]** Primary CTA 'Add (N)' label not screen-reader friendly and lacks object  (conf=0.75)
- **[rebuild-scope]** Whole sheet rebuilds on every selection / removal toggle  (conf=0.75)
- **[layout-drift]** Missing date-range / context subtitle under sheet title  (conf=0.75)
- **[layout-drift]** Sheet max-height capped at 60% of viewport — design intent is ~80-85%  (conf=0.70)
- **[asset-placement]** Per-row remove glyph renders as bare X — Figma uses Icons.cancel_outlined (X-in-circle)  (conf=0.70)
- **[separation-of-concerns]** Sheet returns List<String> and bypasses ShoppingListService boundary  (conf=0.70)

### AttachmentSheet
- **[missing-reusable]** _PhotoPreview reimplements tappable bordered surface + duplicates PhotoCaptureButton — should compose AppCard / shared PhotoDropZone  (conf=0.94)
- **[missing-reusable]** Source-picker nested sheet uses raw Material ListTile + Material icons instead of DS components  (conf=0.88)
- **[textfield-behavior]** Description field is single-line — long text clipped/scrolled horizontally (AppTextField has no minLines/maxLines knob)  (conf=0.85)
- **[sheet-behavior]** Sheet fully dismissible mid-edit — drafted title/description/photo silently lost with no PopScope confirmation  (conf=0.80)
- **[semantics]** Modal sheet missing semantic header — 'Attachment' title not marked as a heading  (conf=0.80)
- **[state-coverage]** `[auto-fixable]` Missing `if (!mounted) return;` guards after awaits in _pickPhoto — risk of setState after dispose  (conf=0.75)
  - Fix: Add `if (!mounted) return;` guard after each await in _pickPhoto (after _pickSource() returns AND after _picker.pickImage() returns) before calling setState.
- **[form-submission]** No double-submit / double-pick guard — fast taps spawn two pickers or two pops  (conf=0.75)
- **[layout-drift]** Modal title uses titleMedium (20/700) — Figma specifies Title 3/Bold = Parkinsans 17/700  (conf=0.70)
- **[layout-drift]** Primary CTA labelled 'Add' but Figma audit doc says 'Save' (truncated copy)  (conf=0.55)
- **[missing-illustration]** Empty-state photo slot uses generic Material icon — may be a missing brand illustration import  (conf=0.45)
- **[tap-target]** AppPillButton tap-target height unverified — Cancel/Add may fall below 48dp  (conf=0.40)

### BrowseMealSheet
- **[missing-reusable]** Bespoke _GrabHandle / _Header / _ErrorPlaceholder / _UnsafeBadge duplicate design-system surfaces  (conf=0.99)
- **[rebuild-scope]** Whole sheet rebuilds on every keystroke/toggle — no .select() scoping, no memoized derived state  (conf=0.94)
- **[result-handling]** Three loader failures collapsed into single blocking error — violates per-feature P3 rule for recipe fetch  (conf=0.94)
- **[missing-reusable]** `[auto-fixable]` _Counter selection pill duplicates AppChip/RadioPill — bespoke fourth implementation  (conf=0.94)
  - Fix: Add an `active` parameter to AppChip (border becomes foreground colour, 1.5 width) and wrap with InkWell + stadium customBorder for ripple + Semantics(button: true, selected: ...). Then _Counter becomes AppChip(label: '$selectedCount selected', tone: butter, active: active, onTap: onTap). Removes parallel implementation.
- **[semantics]** Loading spinner has no semantic announcement / live region  (conf=0.80)
- **[asset-placement]** Header close uses generic IconButton instead of AppRoundButton chip; semantics ambiguous  (conf=0.77)
- **[semantics]** Sticky CTA copy 'Mapp Meal Plan' typo announced verbatim by screen readers  (conf=0.75)
- **[missing-reusable]** Empty/no-results placeholders should use EmptyState or shared SimpleEmptyText component  (conf=0.70)
- **[state-coverage]** Review-mode filter has no explicit exit affordance  (conf=0.70)
- **[navigation]** _confirm uses Navigator.pop instead of context.pop and lacks double-submit guard  (conf=0.70)
- **[focus-order]** Search TextField focus order and Semantics label dependency on inner widget  (conf=0.50)

### ClearAllConfirmSheet
- **[layout-drift]** `[auto-fixable]` Heading uses SemiBold 17 instead of Figma-spec Bold 17  (conf=0.90)
  - Fix: Replace `style: AppTypography.textTheme.titleSmall` with `style: AppTypography.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)` to match the Figma Title 3/Bold token (Parkinsans 17/w700) on this destructive confirmation heading.
- **[state-coverage]** No in-sheet loading state during clearAll write  (conf=0.85)
- **[missing-reusable]** Sheet chrome (radius+scrim+surface) lacks a reusable wrapper  (conf=0.80)
- **[dynamic-type]** Fixed-width title SizedBox can clip with Dynamic Type  (conf=0.75)
- **[form-submission]** Delete button has no double-submit guard  (conf=0.70)
- **[semantics]** Destructive Delete button lacks distinguishing semantic hint  (conf=0.55)
- **[tap-target]** Tap targets depend on AppPillButton internal height (not enforced here)  (conf=0.40)

### ClearConfirmDialog
- **[missing-reusable]** Confirm-delete bottom sheet duplicated across meal_plan and shopping_list (no shared ConfirmActionSheet)  (conf=1.00)
- **[layout-drift]** `[auto-fixable]` Title typography drifts from Figma Title 3 Bold 17/700 (uses titleMedium 20/700 with dead fallback)  (conf=0.88)
  - Fix: Replace `Theme.of(context).textTheme.titleMedium ?? AppTypography.sectionTitle` with `AppTypography.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)` to hit the Figma 'Title 3/Bold' 17/700 spec, dropping the dead-code fallback and aligning with the sibling clear_all_confirm_sheet typography source.
- **[layout-drift]** Vertical rhythm too tight — gaps and top padding undershoot Figma breathing room  (conf=0.70)
- **[form-submission]** No loading state / double-submit guard on Delete during async clearRange  (conf=0.70)
- **[semantics]** Destructive Delete button lacks distinct semantic label/hint  (conf=0.70)
- **[sheet-behavior]** showModalBottomSheet missing useRootNavigator inside ShellRoute  (conf=0.60)
- **[result-handling]** Destructive write failure SnackBar lacks Retry action  (conf=0.55)
- **[semantics]** Bottom sheet lacks dialog-route semantics for assistive tech  (conf=0.55)
- **[tap-target]** Pill button tap target height not guaranteed >= 48dp  (conf=0.45)

### DeleteLogConfirmationDialog
- **[missing-reusable]** Missing reusable AppConfirmationDialog in common/components — this file open-codes a generic confirm shell  (conf=0.85)
- **[semantics]** Dialog not announced as an alert region / question Text lacks header semantics  (conf=0.75)
- **[sheet-behavior]** showDialog barrierDismissible defaults to true on a destructive confirm  (conf=0.70)
- **[layout-drift]** Illustration-to-action gap doubled vs Figma (24px vs 12px) and 16px bottom padding adds inset Figma does not have  (conf=0.70)
- **[layout-drift]** Delete button is destructive but uses primary green styling — visually indistinguishable from Cancel, no destructive cue  (conf=0.66)
- **[asset-placement]** Quatrefoil may be substituting for a distinct 'Group 74' delete/warning illustration  (conf=0.50)

### RangeAddToShoplistSheet
- **[state-coverage]** `[auto-fixable]` Error state has no Retry — dead-end on load failure  (conf=0.92)
  - Fix: In the _error != null branch of _buildList, add a TextButton(onPressed: () { setState(() { _error = null; _loading = true; }); _loadIngredients(); }, child: Text('Retry')) below the error message.
- **[rebuild-scope]** ConsumerStatefulWidget forces over-broad rebuilds on selection toggle  (conf=0.90)
- **[form-submission]** `[auto-fixable]` Toggle-All label/behavior wrong on partial selection — destructively clears curated selection  (conf=0.88)
  - Fix: Use allSelected = _selected.length == (_ingredients?.length ?? 0). In _BottomActions, label becomes allSelected ? 'Unselect All' : 'Select All'. In _toggleAll: _selected = allSelected ? <String>{} : items.toSet(). Stops the misleading partial-state nuke.
- **[separation-of-concerns]** ScaffoldMessenger/Navigator side effects called from widget instead of via ref.listen  (conf=0.85)
- **[form-submission]** Rapid double-tap on Add can fire two identical submissions before _submitting flips  (conf=0.82)
- **[missing-reusable]** Local _Header duplicates pattern reused across sheets — extract AppSheetHeader  (conf=0.80)
- **[missing-reusable]** Empty/error/loading reimplement EmptyState; raw CircularProgressIndicator instead of branded loader  (conf=0.80)
- **[layout-drift]** Bottom action bar missing white floating-card surface from Figma  (conf=0.75)
- **[missing-reusable]** showRangeAddToShoplistSheet should go through a shared AppBottomSheet primitive  (conf=0.70)
- **[tap-target]** Ingredient row tap target ~42dp — below 48dp minimum  (conf=0.70)
- **[layout-drift]** Selected row tints butter yellow but Figma keeps cream surface  (conf=0.60)

### SelectPeriodDateSheet
- **[missing-reusable]** Inline drag-handle Container duplicated across many sheets — missing SheetDragHandle reusable; also lacks semantics exclusion and uses hardcoded 40/4 dimensions  (conf=1.00)
- **[missing-reusable]** Sheet shell scaffolding (SafeArea + viewInsets + drag handle + title) duplicated per sheet — no AppBottomSheet reusable  (conf=0.90)
- **[semantics]** Sheet title not marked as header for screen readers  (conf=0.80)
- **[semantics]** Modal sheet missing scopesRoute/namesRoute semantics for screen readers  (conf=0.60)

### allergen/complete:/home/allergen/complete
- **[semantics]** `[auto-fixable]` Decorative emoji 🎉 and chip avatar emojis not excluded from semantics — duplicate/noisy announcements  (conf=0.99)
  - Fix: Wrap hero emoji in ExcludeSemantics(child: Text('🎉', ...)). Wrap chip avatar emoji in ExcludeSemantics(child: Text(a.emoji, ...)). Eliminates 'party popper' announcement and the duplicate 'peanuts, Peanut' chip readout.
- **[state-coverage]** Empty/short allergen list not handled — celebration would render broken  (conf=0.75)
- **[interaction]** CTA navigation goNamed(profile) coupled with dismiss semantics is ambiguous; no secondary dismiss action  (conf=0.65)
- **[layout-drift]** Background drops section-wide cream→neutral gradient  (conf=0.60)
- **[contrast]** Safe chip text/background contrast may fail WCAG AA (alpha-15% tint with same-hue text)  (conf=0.60)
- **[layout-drift]** Headline uses Theme textTheme.headlineSmall instead of brand display weight  (conf=0.55)

### allergen/detail:/home/allergen/:allergenKey
- **[missing-reusable]** `[auto-fixable]` DetailSegmentBar duplicates existing AppSegmentedProgressBar component  (conf=1.00)
  - Fix: Delete detail_segment_bar.dart. In allergen_detail_screen.dart, render AppSegmentedProgressBar(filledCount: status == AllergenStatus.flagged ? 0 : _cleanCount.clamp(0,3), tone: _toneFor(status)) where _toneFor maps safe -> green, inProgress -> coral, flagged -> flag. Keep the status-to-tone mapping in a tiny private extension on AllergenStatus inside the feature.
- **[ad-hoc-component]** `[auto-fixable]` ReactionLogHeader reimplements AppRoundButton inline  (conf=1.00)
  - Fix: Replace the Semantics+Material+InkWell tree with AppRoundButton(icon: const Icon(Icons.add_rounded), onPressed: onAddPressed, tone: AppRoundButtonTone.green, size: AppRoundButtonSize.small, semanticLabel: 'Add reaction log'). Drop the explicit Semantics — AppRoundButton already wraps in Semantics(button: true, label: semanticLabel).
- **[layout-drift]** `[auto-fixable]` AppBar title shows allergen name instead of Figma 'Details Allergen' label  (conf=0.90)
  - Fix: Change AppBar title to a static const Text('Details Allergen') (or l10n key) so it matches Figma. Leave the allergen name only inside DetailHeaderCard.
- **[missing-reusable]** _BabyAvatar reimplemented per feature instead of as shared component  (conf=0.90)
- **[layout-drift]** `[auto-fixable]` Add reaction button is a circle — Figma uses a rounded square Button-chip  (conf=0.85)
  - Fix: Replace CircleBorder with a RoundedRectangleBorder (BorderRadius.circular(AppSizes.radiusLg or 12)) on both the Material shape and InkWell customBorder. Match Figma 47x47 dimensions exactly via AppSizes if a token matches, otherwise hardcode 47x47.
- **[navigation]** `[auto-fixable]` Add (+) button has no double-tap guard — can push create sheet twice  (conf=0.85)
  - Fix: Add a local bool _isNavigating (via StatefulWidget or a Riverpod state) and early-return if already navigating. Reset in finally. Alternatively guard with if (!ModalRoute.of(context)!.isCurrent) return; before pushNamed.
- **[layout-drift]** Safe-state contextual banner uses green text — Figma uses near-black on cream  (conf=0.80)
- **[asset-placement]** Attachment chip uses muted tone + paperclip icon — Figma uses cream pill without icon  (conf=0.80)
- **[missing-reusable]** Empty-logs state should use shared EmptyState component instead of bare Text  (conf=0.77)
- **[asset-placement]** Screen background is solid cream — Figma uses butter→neutral linear gradient  (conf=0.75)
- **[semantics]** Baby initial avatar reads as raw letter to screen readers  (conf=0.75)
- **[focus-order]** Body uses ListView with no scroll semantics or focus management on log save  (conf=0.60)
- **[missing-illustration]** Empty logs state has no illustration  (conf=0.60)
- **[semantics]** Status announced multiple times — emoji glyph, pill, segment bar, and banner all encode status  (conf=0.50)

### allergen/log:/home/allergen/:allergenKey/log
- **[missing-reusable]** `[auto-fixable]` Section label widget duplicated per-screen instead of shared  (conf=0.90)
  - Fix: Promote to lib/src/common/components/inputs/app_field_label.dart as AppFieldLabel(this.text) and re-export from components.dart. Replace both _SectionLabel and _FieldLabel (attachment_sheet.dart) with it.
- **[textfield-behavior]** `[auto-fixable]` Notes TextField missing keyboardType, textCapitalization, and textInputAction  (conf=0.90)
  - Fix: Pass keyboardType: TextInputType.multiline, textInputAction: TextInputAction.newline, textCapitalization: TextCapitalization.sentences to the Notes TextField. Verify enableSuggestions/autocorrect defaults aren't overridden elsewhere.
- **[asset-placement]** Missing screen-wide cream-to-grey gradient background (Grad-1 token)  (conf=0.85)
- **[ad-hoc-component]** Attachment 'Add Picture' button is hand-rolled Material+InkWell instead of AppPillButton  (conf=0.85)
- **[textfield-behavior]** Attachment sheet title/description fields have no input semantics or focus chain  (conf=0.85)
- **[state-coverage]** `[auto-fixable]` No loading skeleton while hydrateForEdit runs — form shows defaults  (conf=0.85)
  - Fix: When isEdit && !state.hydrated && state.errorMessage == null, render Center(child: CircularProgressIndicator()) in body instead of empty form. Reveal form only after hydration completes.
- **[navigation]** Back button discards in-flight edits without confirm; no PopScope for system back  (conf=0.85)
- **[layout-drift]** AppBar missing trailing overflow ('...') action present in Figma  (conf=0.75)
- **[rebuild-scope]** ConsumerStatefulWidget watches whole state in build despite owning only TextEditingController  (conf=0.75)
- **[form-submission]** Save button enabled without validating logDate — silently records 'now'  (conf=0.75)
- **[semantics]** Loading spinner in Save button is not labeled  (conf=0.75)
- **[dynamic-type]** Typography fixed heights clip at very large Dynamic Type  (conf=0.75)
- **[ad-hoc-component]** Custom AppBar instead of AppHeader reusable  (conf=0.70)
- **[separation-of-concerns]** Imperative async work in initState postFrameCallback for hydration  (conf=0.70)
- **[sheet-behavior]** Attachment bottom sheet not draggable-safe — drag/scrim dismiss discards draft silently  (conf=0.70)
- **[tooltip]** Attachment 'Add Picture' / 'Edit Picture' button has no semantic hint  (conf=0.70)
- **[focus-order]** Section labels and form fields not grouped via MergeSemantics  (conf=0.70)
- **[form-submission]** showDatePicker has no past/future bounds matching baby-data integrity  (conf=0.60)
- **[semantics]** Snackbar lacks semantics duration / urgency for screen-reader users  (conf=0.60)
- **[navigation]** ref.listen async-gap between mounted checks risks double-navigation  (conf=0.55)
- **[tap-target]** Reaction toggle row tap area may be < 48dp depending on AppSizes.sm  (conf=0.55)

### allergen/log_detail:/home/allergen/:allergenKey/log/:logId
- **[layout-drift]** `[auto-fixable]` AppBar misses butter-gradient header + uses raw AppBar instead of AppHeader (title size, alignment, back-button styling, IconButton wrappers)  (conf=0.94)
  - Fix: Replace Material `AppBar` with `AppHeader(title: 'Reaction Log', wash: AppHeaderWash.butterGradient, leading: AppRoundButton(icon: Icons.arrow_back_rounded, onPressed: () => context.pop()), trailing: AppRoundButton(icon: Icons.more_horiz_rounded, onPressed: _onMenuPressed, key: _menuAnchorKey))`. This also fixes the 20pt vs 17pt title token, center-title default, and back-button styling drift.
- **[dynamic-type]** `[auto-fixable]` Field/title text uses hardcoded fontSize: 15 instead of theme.textTheme — breaks Dynamic Type  (conf=0.94)
  - Fix: Replace `GoogleFonts.figtree(fontSize: 15, height: 22/15, color: AppColors.fgFaint)` with `Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.fgFaint)` (and matching token for Parkinsans 15/600). Drop google_fonts import. Promote `AppTypography.fieldLabel` if absent.
- **[layout-drift]** `[auto-fixable]` `Log N` heading uses 22pt titleLarge — should be 17pt titleSmall per Figma  (conf=0.90)
  - Fix: In `_LogTitleRow` change `textTheme.titleLarge` to `textTheme.titleSmall` keeping `fontWeight: FontWeight.w700`.
- **[rebuild-scope]** `[auto-fixable]` _AttachmentBlock is ConsumerWidget but never uses ref  (conf=0.85)
  - Fix: Change `class _AttachmentBlock extends ConsumerWidget` to `extends StatelessWidget` and drop the `WidgetRef` parameter.
- **[state-coverage]** Error state collapses StateError to generic copy; 'Try Again' loops on non-recoverable not-found  (conf=0.85)
- **[semantics]** Download chip semantics ambiguous and tap target below 48dp  (conf=0.85)
- **[missing-reusable]** Loading and error scaffolds duplicate AppBar three times — collapse to single Scaffold  (conf=0.80)
- **[semantics]** Photo preview Image.network missing semanticLabel  (conf=0.80)
- **[tooltip]** Back IconButton missing tooltip  (conf=0.70)
- **[missing-reusable]** showLogActionsMenu reimplements PopupMenu primitives — missing AppActionsMenu  (conf=0.65)
- **[rebuild-scope]** Outer ConsumerWidget + nested ConsumerStatefulWidget widens rebuild scope and may disturb GlobalKey lifecycle  (conf=0.60)
- **[navigation]** Edit-then-return path doesn't handle log deleted from edit screen  (conf=0.60)
- **[focus-order]** Floating actions menu lacks focus management for keyboard/screen reader  (conf=0.60)
- **[navigation]** context.pop after delete may pop wrong route on deep-link entry  (conf=0.55)

### allergen/tracker:/home/allergen/tracker
- **[semantics]** `[auto-fixable]` CircularProgressIndicator missing semanticsLabel on loading states  (conf=0.99)
  - Fix: Replace bare CircularProgressIndicator() with CircularProgressIndicator(semanticsLabel: 'Loading allergen tracker') so screen readers announce what is loading.
- **[missing-reusable]** Avatar + emoji circle pattern duplicated across 3 widgets — extract AppAvatarCircle  (conf=0.95)
- **[tap-target]** `[auto-fixable]` 'See All' link tap target below 48dp minimum (WCAG 2.5.5)  (conf=0.95)
  - Fix: Wrap Text in SizedBox(height: 48) or add Padding(EdgeInsets.symmetric(vertical: 12, horizontal: 8)) inside GestureDetector so hit area meets 48dp. Better: use TextButton which enforces 48dp minimum by default.
- **[missing-reusable]** Custom _TrackerAppBar reimplements AppHeader instead of using shared component  (conf=0.90)
- **[missing-reusable]** _SectionHeader and _SeeAllLink are private duplicates of a missing shared component  (conf=0.85)
- **[ad-hoc-component]** StartIntroduceCard hand-rolls a card with Container+BoxDecoration instead of AppCard  (conf=0.85)
- **[separation-of-concerns]** Imperative go_router navigation inside SliverList builder via inline Builder  (conf=0.85)
- **[semantics]** `[auto-fixable]` Section header titles not marked Semantics(header: true) — breaks heading-jump navigation  (conf=0.85)
  - Fix: Wrap title Text in Semantics(header: true, child: Text(title, ...)) inside _SectionHeader.
- **[layout-drift]** Trailing whitespace in 'Ongoing ' segment label leaks to UI and screen readers  (conf=0.83)
- **[layout-drift]** Attachment chip has unspecified paperclip emoji and dynamic label  (conf=0.80)
- **[stack-abuse]** ReactionLogRow uses Stack+Positioned with negative offsets — Align approach cleaner  (conf=0.75)
- **[navigation]** Back button uses context.pop() without canPop guard — crashes on deep-link entry  (conf=0.75)
- **[semantics]** _TrackerAppBar 'Allergen Trackers' title not exposed as page heading (no namesRoute)  (conf=0.75)
- **[missing-reusable]** Bespoke loading/error/empty states bypass shared EmptyState/LoadingConfirmation components  (conf=0.70)
- **[rebuild-scope]** Three nested ref.watch chains rebuild gradient scaffold on every controller refresh  (conf=0.70)
- **[state-coverage]** No pull-to-refresh on tracker — stale Hive cache cannot be re-fetched without navigating away  (conf=0.70)
- **[state-coverage]** Error state retry only invalidates tracker provider, not _currentBabyProvider or currentBabyIdProvider  (conf=0.70)
- **[semantics]** Error/empty Text strings lack Semantics liveRegion and header role  (conf=0.70)
- **[density]** Ongoing tab filter surfaces Safe/Flagged allergens under Allergen Exposure instead of only inProgress  (conf=0.60)
- **[form-submission]** Start Introduce CTA lacks double-submit guard and loading affordance during navigation  (conf=0.60)
- **[state-coverage]** Top-level babyId loading shows bare spinner with no timeout/retry path  (conf=0.60)

### auth/forgot_password:/auth/forgot-password
- **[textfield-behavior]** Email field lacks autocorrect/suggestions/autofill/autofocus controls  (conf=0.99)
- **[missing-reusable]** Grad-1 background gradient duplicated across 4 auth screens  (conf=0.95)
- **[missing-reusable]** Ad-hoc circular icon badge built with Container + BoxDecoration  (conf=0.90)
- **[ad-hoc-component]** AppPillButton has no built-in loading state — label flips to 'Sending…' with no spinner  (conf=0.88)
- **[tap-target]** Back button tap target is 44dp (below 48dp WCAG minimum)  (conf=0.85)
- **[layout-drift]** Confirmation 'Check your email' view has no Figma source — invented UX  (conf=0.80)
- **[form-submission]** Submit button enabled while email invalid — only gated by isLoading  (conf=0.75)
- **[layout-drift]** Spacer-anchored Confirm CTA may collide with keyboard / large text on small devices  (conf=0.71)
- **[form-submission]** Validation error overridden by generic network caption — hides real cause  (conf=0.70)
- **[state-coverage]** No cooldown/rate-limit state — Supabase 429 surfaces as generic error  (conf=0.70)
- **[state-coverage]** Back button on confirmation view may show stale 'sent' state on return  (conf=0.60)
- **[semantics]** Email field lacks explicit accessibility label  (conf=0.55)
- **[missing-illustration]** Confirmation view uses Material icon instead of brand illustration  (conf=0.55)
- **[missing-illustration]** Input view has no hero illustration -- Figma frame 971:10119 likely shows one  (conf=0.40)

### auth/login:/auth/login
- **[missing-reusable]** _OrDivider and _GoogleGlyph duplicated verbatim in register_screen.dart  (conf=1.00)
- **[textfield-behavior]** `[auto-fixable]` Email textInputAction.next has no FocusNode chain; password Done does not submit  (conf=0.98)
  - Fix: Convert LoginScreen to ConsumerStatefulWidget. Create _emailFocus/_passwordFocus. Pass focusNode + onSubmitted: (_) => _passwordFocus.requestFocus() on email, and onSubmitted: (_) => state.isLoading ? null : controller.submit() on password (same pattern used in forgot_password_screen.dart).
- **[ad-hoc-component]** Social login buttons reimplement AppPillButton instead of extending it  (conf=0.90)
- **[rebuild-scope]** `[auto-fixable]` ref.watch(loginControllerProvider) rebuilds entire tree on every keystroke  (conf=0.90)
  - Fix: Convert to ConsumerStatefulWidget. Wrap email/password/submit subtrees in Consumer widgets using ref.watch(loginControllerProvider.select((s) => ...)). Make static branding/divider/footer const outside Consumer scope.
- **[textfield-behavior]** Missing autofillHints — password managers can't fill the form  (conf=0.90)
- **[textfield-behavior]** Email field lacks autocorrect/suggestions/capitalization tuning  (conf=0.90)
- **[semantics]** `[auto-fixable]` Decorative brand glyphs ('n' logo, 'G' letterform, Apple icon) not excluded from semantics  (conf=0.90)
  - Fix: Wrap _LoginLogoMark, _GoogleGlyph, and the Apple Icon in ExcludeSemantics(child: ...) so screen readers don't announce 'n', 'G', or 'Apple' alongside surrounding text.
- **[dynamic-type]** Hardcoded fontSize values break Dynamic Type scaling  (conf=0.90)
- **[layout-drift]** `[auto-fixable]` Background gradient endpoint and angle drift from Figma spec (#F5F5F5 at 154.398deg)  (conf=0.85)
  - Fix: Introduce AppColors.neutral10 = #F5F5F5 and AppGradients.grad1 with the 154.398deg angle and #FFFCD5 -> #F5F5F5 stops. Replace inline DecoratedBox/LinearGradient with the token. Compute alignment from the 154.398deg angle rather than topLeft->bottomRight.
- **[navigation]** `[auto-fixable]` Sign Up footer uses context.goNamed which replaces the stack  (conf=0.85)
  - Fix: Use context.pushNamed(AppRoute.register.name) so register pushes onto the auth stack and the user can swipe/back to login. Verify GoRouter pre-login redirect allows it.
- **[layout-drift]** Primary Login CTA height (52) and label typography drift from Figma (h42, Parkinsans SemiBold 15/22)  (conf=0.80)
- **[layout-drift]** AppTextField label uses wrong font family/weight/size (Figtree 14/700 vs Parkinsans 15/600)  (conf=0.80)
- **[stack-abuse]** _LoginLogoMark Stack-abuse + hardcoded magic numbers for brand mark  (conf=0.80)
- **[semantics]** Loading state on submit button not announced to screen readers  (conf=0.70)
- **[missing-illustration]** Brand logo mark code-drawn instead of using canonical asset  (conf=0.60)
- **[result-handling]** Controller submit lacks try/finally guard around await  (conf=0.60)

### auth/register:/auth/register
- **[textfield-behavior]** `[auto-fixable]` Email→Password focus chain not wired; 'Next' key on keyboard does nothing useful  (conf=0.95)
  - Fix: Convert RegisterScreen to ConsumerStatefulWidget. Add FocusNodes for email and password. On email onSubmitted: requestFocus password node. On password onSubmitted: invoke submit if valid and not loading.
- **[textfield-behavior]** Email field missing autofillHints and autocorrect/suggestion suppression  (conf=0.90)
- **[form-submission]** Submit button shows no progress indicator while loading; social buttons lack per-provider loading state  (conf=0.90)
- **[hardcoded-constants]** `[auto-fixable]` Hardcoded TextStyle for social-button and login-link labels — bypasses AppTypography tokens  (conf=0.90)
  - Fix: Replace inline TextStyle blocks with AppTypography.button.copyWith(...) or AppTypography.linkSmall for footer link. Reference named display token for 'n' glyph (e.g. AppTypography.displayLarge with sizing).
- **[missing-reusable]** _OrDivider reimplements a separator that login also needs — should be shared  (conf=0.90)
- **[missing-reusable]** Login footer reimplements link styling instead of shared LinkText/AuthFooter component  (conf=0.90)
- **[textfield-behavior]** `[auto-fixable]` Keyboard can hide focused password field; no tap-outside dismiss  (conf=0.90)
  - Fix: Set keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag on SingleChildScrollView. Wrap SafeArea body in GestureDetector(behavior: opaque, onTap: FocusScope.unfocus). Ensure resizeToAvoidBottomInset stays true.
- **[textfield-behavior]** Password field missing autofillHints=newPassword (blocks password-manager save prompt)  (conf=0.85)
- **[rebuild-scope]** `[auto-fixable]` ConsumerWidget rebuilds entire screen on any controller field change  (conf=0.85)
  - Fix: Use ref.watch(provider.select((s) => slice)) for each reactive subtree (email, password, submit, social) and ref.read elsewhere. Replace top-level state watch with scoped Consumer/select slices.
- **[missing-reusable]** Inline obscure-toggle widget — generic enough to live as AppPasswordField  (conf=0.85)
- **[semantics]** `[auto-fixable]` Loading state and error messages not announced to assistive tech (liveRegion)  (conf=0.85)
  - Fix: Wrap primary button in Semantics(liveRegion: true, label: isLoading ? 'Signing up' : null) or use SemanticsService.announce on isLoading transitions. Add liveRegion to AppTextField errorText or use announce on submit failure.
- **[layout-drift]** Primary and social buttons are 52px tall vs Figma's 42px  (conf=0.80)
- **[stack-abuse]** Logo mark uses Stack with no positioning + recreates BrandLogo composition  (conf=0.80)
- **[navigation]** Login footer uses context.goNamed instead of pop — destroys back stack from login→register push flow  (conf=0.75)
- **[tap-target]** Login link tap target below 48dp  (conf=0.75)
- **[form-submission]** Sign Up onPressed not async-safe against widget disposal (autoDispose race)  (conf=0.70)
- **[semantics]** Social buttons lack explicit button semantics  (conf=0.70)
- **[form-submission]** Password format hint precedence — client rule may shadow server message and mismatch policy  (conf=0.70)
- **[navigation]** No back navigation / canPop guard on screen  (conf=0.70)
- **[navigation]** Submit can navigate after widget unmount via stale closure / redirect race  (conf=0.60)
- **[semantics]** Submit button disabled state may not be announced by AppPillButton  (conf=0.50)

### auth/reset_password:/auth/reset-password
- **[missing-reusable]** Grad-1 LinearGradient duplicated across 4 auth screens — missing AuthGradientBackground reusable  (conf=1.00)
- **[form-submission]** `[auto-fixable]` Submit button not gated by form validity — allows submits with clearly invalid state  (conf=0.99)
  - Fix: Compute canSubmit = !state.isLoading && !state.password.isNotValid && state.passwordsMatch && state.confirmPassword.isNotEmpty; pass onPressed: canSubmit ? controller.submit : null. AppPillButton will render disabled style.
- **[textfield-behavior]** Password fields missing autofillHints (newPassword) + autocorrect/suggestions suppression  (conf=0.94)
- **[separation-of-concerns]** Stringly-typed coupling: screen filters errorMessage by literal comparison to controller-emitted strings  (conf=0.90)
- **[state-coverage]** `[auto-fixable]` errorMessage state sticky across success — success branch does not clear errorMessage  (conf=0.85)
  - Fix: In the success branch: state = state.copyWith(isLoading: false, success: true, errorMessage: null). Consider invalidating the provider after navigation or modeling success as a one-shot event.
- **[layout-drift]** Title uses Title 2 (headlineSmall 22pt) instead of Title 1 (28pt) per Figma token  (conf=0.80)
- **[form-submission]** No scroll wrapper — keyboard can overlap Confirm button on small devices + dynamic-type overflow  (conf=0.80)
- **[navigation]** Success SnackBar can be torn down by goNamed mid-animation + not announced as live region  (conf=0.77)
- **[rebuild-scope]** ConsumerWidget root rebuilds full tree on every keystroke via ref.watch  (conf=0.75)
- **[semantics]** Submit button loading state not announced to screen readers  (conf=0.70)
- **[semantics]** Generic non-field error Text has no Semantics(liveRegion) — async failures not announced  (conf=0.70)
- **[separation-of-concerns]** Post-success navigation hardcoded in screen instead of router redirect  (conf=0.60)
- **[state-coverage]** ref.listen success branch missing context.mounted guard — may fire after dispose  (conf=0.60)
- **[result-handling]** Supabase failure rendered as small caption instead of inline-error banner mandated by AU-03 P1 spec  (conf=0.60)

### home:/home
- **[missing-reusable]** `[auto-fixable]` OngoingIntroducedCard reimplements AppSegmentedProgressBar  (conf=1.00)
  - Fix: Replace _ProgressSegments with const AppSegmentedProgressBar(filledCount: filled, totalSegments: 3, tone: AppSegmentedProgressTone.coral, height: 6). Delete the private class.
- **[asset-placement]** `[auto-fixable]` Avatar is a green circle with initial, not Figma profile-icon squircle  (conf=0.99)
  - Fix: Replace _HeaderAvatar with 36x36 Container using BorderRadius.circular(10) (squircle), fill AppColors.greenDeep, render Icon(Icons.person_outline, size: 20, color: AppColors.cream) centered. Keep GestureDetector/onTap wiring. Drop _avatarInitial getter and babyName initial derivation.
- **[state-coverage]** `[auto-fixable]` No pull-to-refresh on dashboard  (conf=0.99)
  - Fix: Wrap SingleChildScrollView in RefreshIndicator(onRefresh: () async => ref.invalidate(homeControllerProvider(babyId))). Promote _HomeContent to ConsumerWidget so it can read ref, or pass VoidCallback onRefresh from _HomeBody.
- **[state-coverage]** `[auto-fixable]` Loading flash on refetch — full UI replaced by spinner (skipLoadingOnRefresh missing)  (conf=0.94)
  - Fix: Use asyncState.when(skipLoadingOnRefresh: true, skipLoadingOnReload: true, loading: ..., error: ..., data: ...) so previously rendered content remains while refresh is in flight. Same for babyIdAsync.when.
- **[asset-placement]** Decorative cloud/petal blob behind greeting is missing  (conf=0.85)
- **[layout-drift]** StatRingCard nesting contrast lost — sits on plain cream instead of inside butter hero  (conf=0.85)
- **[separation-of-concerns]** _monthsBetween duplicates canonical ageInMonths helper, risking drift  (conf=0.85)
- **[missing-reusable]** DayChipRow reimplements DayChip / WeekStrip with inline _CalendarPerday  (conf=0.80)
- **[missing-reusable]** TodaysMealsCard._MealRow hardcodes gradient thumb + static 🍲 placeholder; near-duplicate of _CoralThumb  (conf=0.75)
- **[separation-of-concerns]** OngoingIntroducedCard derives ongoing key in build via linear scan — policy in widget  (conf=0.70)
- **[semantics]** Main scroll column lacks semantic section grouping  (conf=0.65)
- **[dynamic-type]** Error scaffold can clip vertically at max dynamic-type scale  (conf=0.60)
- **[rebuild-scope]** _HomeContent rebuilds entire dashboard on any HomeState change  (conf=0.55)

### meal_plan/map:/home/meal/map
- **[missing-reusable]** DayChipRow reimplements common WeekStrip/DayChip and duplicates weekday/month abbreviation maps  (conf=1.00)
- **[missing-reusable]** _Thumbnail widget duplicated across two files; uses Image.network without cache/loading placeholder/cacheWidth  (conf=1.00)
- **[ad-hoc-component]** Custom AppBar instead of common AppHeader; stat-chip Container reimplemented  (conf=0.88)
- **[layout-drift]** `[auto-fixable]` Commit bar lacks elevated white floating container with top shadow  (conf=0.85)
  - Fix: Wrap _CommitBar's button in Container(color: AppColors.surface, padding: EdgeInsets.fromLTRB(lg, sm, lg, MediaQuery.padding.bottom + sm), decoration: BoxDecoration(color: surface, boxShadow: [BoxShadow(blurRadius: 16, color: Colors.black.withOpacity(0.08), offset: Offset(0, -4))])). Keep button height AppSizes.buttonHeight.
- **[missing-reusable]** _DashedBorderPainter reimplements AppCard's dashed border painter  (conf=0.85)
- **[missing-reusable]** _EmptyDayPlaceholder reimplements EmptyState  (conf=0.80)
- **[rebuild-scope]** ListView rebuilds all PickedRecipeRows on every state change  (conf=0.75)
- **[navigation]** Retry dialog fires _onCommit without awaiting; context guard ordering risky  (conf=0.75)
- **[asset-placement]** Picked recipe row tag chips and trailing assignedLabel pill diverge from Figma mp-card  (conf=0.70)
- **[ad-hoc-component]** Retry dialog is a raw AlertDialog; severity may conflict with error-handling rule book  (conf=0.65)

### meal_plan:/home/meal
- **[missing-reusable]** `[auto-fixable]` Duplicated showMenu positioning logic between _openEmptyStateMenu and _openScreenMenu  (conf=0.95)
  - Fix: Move positioning + showMenu into a helper `Future<T?> showOverflowMenuAnchored<T>(BuildContext context, {required GlobalKey anchorKey, required List<PopupMenuEntry<T>> items})`. Replace both call sites with a one-liner. Better: switch to PopupMenuButton.builder for framework-managed anchoring.
- **[missing-reusable]** Three duplicated green-deep rounded-square icon buttons (overflow / day-chip / chevron)  (conf=0.90)
- **[missing-reusable]** _ScreenMenuRow and _MenuRow are duplicate popup-menu row widgets  (conf=0.90)
- **[ad-hoc-component]** _FormCard in MealPlanEmptyState reimplements AppCard (radius drifted)  (conf=0.85)
- **[textfield-behavior]** `[auto-fixable]` Browse-meal search TextField missing keyboard hints and debounce  (conf=0.85)
  - Fix: Add `autocorrect: false`, `enableSuggestions: false`, `textCapitalization: TextCapitalization.none`, `keyboardType: TextInputType.text` to the TextField. Wrap onChanged in a 200ms Timer-based debounce so filtering doesn't fire per keystroke.
- **[semantics]** `[auto-fixable]` PopupMenu icon+text rows produce redundant screen-reader announcements  (conf=0.85)
  - Fix: Wrap the Icon in ExcludeSemantics(child: Icon(...)) so only the label is announced. Better: wrap the row in Semantics(button: true, label: label, container: true, child: ExcludeSemantics(child: row)).
- **[layout-drift]** Title typography overshoots Figma — titleLarge (22/700) instead of Title3 (17/700)  (conf=0.80)
- **[semantics]** Loading spinners lack Semantics label for screen readers  (conf=0.80)
- **[form-submission]** Create-meal-prep / empty-state create flow re-entrant on double-tap  (conf=0.75)
- **[result-handling]** Day-card add-to-shopping-list uses addFromRecipe with empty recipeId (source mis-attribution)  (conf=0.75)
- **[layout-drift]** Header overflow button sized roundButtonSm (32) instead of Figma 44  (conf=0.70)
- **[density]** Empty state shows a single-item overflow menu that duplicates the form CTA  (conf=0.70)
- **[sheet-behavior]** Browse-meal sheet swipe-to-dismiss / X close silently discards selections  (conf=0.70)
- **[semantics]** _ErrorView error text lacks live-region semantics  (conf=0.70)
- **[layout-drift]** Age subtitle uses caption (12/400 Figtree) instead of Parkinsans 13/600 subhead  (conf=0.65)
- **[layout-drift]** + Add Date pill does not stretch full width  (conf=0.60)
- **[asset-placement]** Empty state wraps form in shadowed _FormCard; Figma shows form flush on Grad-1 page  (conf=0.60)
- **[rebuild-scope]** _MealPlanBody rebuilds entire body on every controller state change; SliverList lacks keys  (conf=0.60)
- **[tap-target]** PopupMenu items may fall under 48dp tap target  (conf=0.55)

### onboarding/baby_setup:/onboarding/baby-setup
- **[missing-reusable]** `[auto-fixable]` Bespoke _GenderCard reimplements existing RadioPill / selectable card pattern with non-DS tokens  (conf=0.94)
  - Fix: Delete _GenderCard. Replace with RadioPill(label: _genderLabel(g), selected: state.gender == g, onTap: () => controller.updateGender(g)) using DS tokens (greenDeep/cream/borderSoft) instead of primary/onPrimary/divider. Adds proper Semantics(button, selected) via the shared component.
- **[semantics]** `[auto-fixable]` Question Text widgets and progress label not exposed as headers / live region to assistive tech  (conf=0.94)
  - Fix: Wrap each step's question Text ('What's your baby's name?', 'When was your baby born?', 'What's your baby's gender?') in Semantics(header: true, child: ...). Wrap step indicator in Semantics(header: true, liveRegion: true, label: 'Step X of 3') so step transitions are announced.
- **[form-submission]** `[auto-fixable]` Loading state doesn't block gender card taps or back navigation — user can mutate state mid-submit  (conf=0.85)
  - Fix: Wrap Scaffold body in AbsorbPointer(absorbing: state.isLoading, child: ...) and gate AppBar back button (or AppRoundButton in header) onPressed to null when state.isLoading. Same for PopScope canPop.
- **[state-coverage]** DOB picker seeded with default value enabling skip-without-interaction and no age preview chip / picker is too small  (conf=0.85)
- **[tap-target]** `[auto-fixable]` Gender card lacks 48dp+ tap target, non-color selection affordance, and haptic feedback  (conf=0.85)
  - Fix: Add BoxConstraints(minHeight: 48) to the gender card. Add trailing Icons.check when selected as non-color affordance. Wrap onTap with HapticFeedback.selectionClick(). Largely subsumed by migration to RadioPill which encodes these patterns.
- **[rebuild-scope]** ConsumerWidget watches entire BabySetupState — every keystroke / date wheel tick rebuilds AppBar, Scaffold, and inactive steps  (conf=0.80)
- **[hardcoded-constants]** Pre-redesign color tokens used (primary/surface/divider/onPrimary/error) instead of redesign tokens (greenDeep/cream/borderSoft/destructive/burgundy)  (conf=0.77)
- **[semantics]** Loading spinner inside submit button has no semantics/live region announcement  (conf=0.75)
- **[interaction]** Final CTA copy 'Let's go!' diverges from Figma; final navigation skips loading transition route  (conf=0.75)
- **[stack-abuse]** Each step body uses Column + Spacer without scroll — overflows on small viewports, with keyboard open, or at large text scales  (conf=0.70)
- **[semantics]** DOB picker has no accessible label/header and fixed 160px height clips at larger text scales  (conf=0.70)
- **[interaction]** Hard widget swap between steps with no transition animation; no per-step illustration  (conf=0.65)

### onboarding/baby_setup_loading:/onboarding/baby-setup-loading
- **[missing-reusable]** Screen reimplements LoadingConfirmation composite + Stack/Alignment magic instead of reusing shared widget  (conf=1.00)
- **[layout-drift]** Loading caption rendered inside PetalBlob footprint instead of below — overlaps bottom petals  (conf=0.80)
- **[dynamic-type]** Caption uses fixed pixel font size (12.8) — bypasses Dynamic Type scaling  (conf=0.75)
- **[separation-of-concerns]** ConsumerStatefulWidget used only for one analytics call — should be ConsumerWidget with controller-owned analytics  (conf=0.70)
- **[semantics]** PopScope blocks back nav without screen-reader feedback  (conf=0.70)
- **[layout-drift]** Footer typography uses bodyLarge (MD3 16/24) instead of Figma's Body/SemiBold 15/22 — sizing drift  (conf=0.60)
- **[asset-placement]** PetalBlob glow dot omits the spec'd 27px lime blurred halo  (conf=0.60)

### onboarding/consent:/onboarding/consent
- **[missing-reusable]** `[auto-fixable]` _InlineError duplicated across screens — promote to common/components/feedback  (conf=1.00)
  - Fix: Extract to lib/src/common/components/feedback/inline_error.dart as `class InlineError extends StatelessWidget` with {required String message, VoidCallback? onRetry, String retryLabel = 'Retry', InlineErrorRetryStyle style = InlineErrorRetryStyle.pill}. Export from components.dart. Replace both _InlineError occurrences (consent screen + delete_account_overlay.dart) with the shared component. Bake in Semantics(liveRegion: true) per the a11y finding.
- **[form-submission]** Submit CTA has no loading indicator while createBaby is in flight  (conf=1.00)
- **[separation-of-concerns]** LocalFlagService write happens in Screen — should live in Controller.submit  (conf=0.85)
- **[semantics]** Disabled CTA gives no audible reason; label silently changes without live region  (conf=0.77)
- **[layout-drift]** Layout drift — PetalBlob 180 vs Figma 220, title gap tight, checkboxes pushed mid-screen, inline error inside scroll view  (conf=0.75)
- **[missing-reusable]** _ConsentCheckboxRow pattern is a kit primitive — promote alongside AppCheckbox  (conf=0.70)
- **[form-submission]** Retry button silently inert if user un-ticks after error appears  (conf=0.70)
- **[tap-target]** Checkbox row tap target may be <48dp at default text size  (conf=0.60)
- **[result-handling]** No connectivity check before submit — generic error instead of canonical P1 copy  (conf=0.60)
- **[dynamic-type]** Dynamic type / large text scale not verified — bottom CTA may obscure checkboxes  (conf=0.50)
- **[navigation]** Defensive back fallback to onboardingResult may render stale/empty result on cold start  (conf=0.50)

### onboarding/dob:/onboarding/dob
- **[layout-drift]** Age chip uses Figtree/15/700 instead of Parkinsans/13/600  (conf=0.80)
- **[dynamic-type]** Fixed-pixel wheel item extent breaks Dynamic Type scaling  (conf=0.80)
- **[layout-drift]** Wheel row labels use Figtree labelLarge (17/600) instead of Parkinsans 15/600  (conf=0.75)
- **[missing-reusable]** DOB wheel (3-column CupertinoPicker) is reusable component reimplemented inline  (conf=0.75)
- **[layout-drift]** Selection pill spans full column width instead of hugging value  (conf=0.70)
- **[form-submission]** Next button has no double-tap guard - can fire navigation/flag write twice  (conf=0.70)
- **[semantics]** Age chip has no semantic label connecting it to baby age  (conf=0.70)
- **[form-submission]** Default DOB silently rewrites controller state on Next - stale at submit if user backs out  (conf=0.65)
- **[tap-target]** Picker row item extent below Material 48dp tap target  (conf=0.60)
- **[layout-drift]** Vertical rhythm above wheel tighter than Figma (~128px from top)  (conf=0.55)
- **[rebuild-scope]** ref.watch on babyName rebuilds entire DOB tree  (conf=0.55)
- **[result-handling]** Local flag flipped before controller state guaranteed - no error handling on Hive write  (conf=0.55)

### onboarding/intro:/onboarding/intro
- **[layout-drift]** `[auto-fixable]` Background gradient direction and end-stop diverge from Grad-1 token (154°, #F5F5F5)  (conf=0.95)
  - Fix: Add AppColors.gradGrad1Neutral = Color(0xFFF5F5F5) token in app_colors.dart, then replace the LinearGradient with begin: Alignment(-0.34, -1.0), end: Alignment(0.34, 1.0), stops: [0.19, 0.50], colors: [AppColors.butterSoft, AppColors.gradGrad1Neutral]. Update the misleading comment to reference Grad-1.
- **[semantics]** `[auto-fixable]` Decorative device-mockup placeholder not excluded from semantics  (conf=0.90)
  - Fix: Wrap _DeviceMockupPlaceholder's returned Container in ExcludeSemantics so 'Preview' isn't announced.
- **[interaction]** Staged-reveal entrance animation per slide is missing  (conf=0.80)
- **[missing-reusable]** Dot indicator should reuse AppSegmentedProgressBar or be extracted to shared widget  (conf=0.80)
- **[separation-of-concerns]** NotificationListener cancels timer but never reschedules on drag end  (conf=0.80)
- **[navigation]** Hardware back on slide 2/3 exits screen instead of paging back (no PopScope)  (conf=0.80)
- **[form-submission]** Double-tap on Let's Go can fire twice — no isSubmitting guard  (conf=0.75)
- **[rebuild-scope]** Screen state mixed into widget — should be ConsumerWidget after controller extraction  (conf=0.70)
- **[tap-target]** Back round button (44dp) below Material 48dp tap-target minimum  (conf=0.70)
- **[focus-order]** PageView swipe via screen reader + focus does not move to new slide title  (conf=0.70)
- **[missing-reusable]** PageView + auto-advance carousel pattern not extracted  (conf=0.55)
- **[missing-illustration]** Slide-2 demo lacks apple-glyph asset next to 'Apple' label  (conf=0.55)

### onboarding/name:/onboarding/name
- **[missing-reusable]** Recurring back-round-button + primary-pill footer not extracted as reusable  (conf=0.95)
- **[form-submission]** `[auto-fixable]` First-name error message wrong for tooLong validation failure  (conf=0.95)
  - Fix: Switch on validator result: empty → 'You must fill the name', tooLong → 'Name must be 50 characters or fewer', null → null. Also enforce maxLength:50 via inputFormatters.
- **[layout-drift]** `[auto-fixable]` Error border uses destructive (#851E1E) instead of Figma burgundy token (#77393B)  (conf=0.90)
  - Fix: Replace `errorColor: AppColors.destructive` with `errorColor: AppColors.burgundy` and update the inline comment to reference the canonical Nibble-primary-Burgundy token.
- **[form-submission]** `[auto-fixable]` Last-name >50 chars silently disables Next with no error feedback  (conf=0.90)
  - Fix: Add `errorText: _lastErrorText` to Last Name AppTextField returning the >50 message, and apply LengthLimitingTextInputFormatter(50) on both fields.
- **[textfield-behavior]** `[auto-fixable]` TextInputAction.next on First Name does not move focus to Last Name  (conf=0.90)
  - Fix: Add `late final FocusNode _lastNameFocus` (dispose in dispose), pass to Last Name via focusNode, and on First Name pass `onSubmitted:(_)=>_lastNameFocus.requestFocus()`.
- **[asset-placement]** `[auto-fixable]` Background is solid cream instead of Figma Grad-1 cream→grey gradient  (conf=0.85)
  - Fix: Wrap Scaffold body in DecoratedBox with LinearGradient(begin: topLeft, end: bottomRight, stops:[0.19,0.50], colors:[AppColors.butterSoft (#FFFCD5), Color(0xFFF5F5F5)]). Consider extracting as shared OnboardingBackground.
- **[textfield-behavior]** No textCapitalization / autocorrect / suggestions config on name fields  (conf=0.85)
- **[semantics]** `[auto-fixable]` Heading text not marked as semantic header  (conf=0.85)
  - Fix: Wrap title Text in `Semantics(header: true, child: Text(...))`.
- **[stack-abuse]** Form not wrapped in scrollable — keyboard squashes layout, Spacer collapses  (conf=0.82)
- **[layout-drift]** Input placeholder color uses greenSoft instead of Neutral-50 (#969696)  (conf=0.80)
- **[dynamic-type]** Layout may clip at large text scale (no scrollable wrapper)  (conf=0.80)
- **[layout-drift]** Field labels use Figtree 14/700 instead of Parkinsans 15/600 (Headline/SemiBold)  (conf=0.75)
- **[rebuild-scope]** Empty setState in _onLastChanged rebuilds whole screen  (conf=0.70)
- **[textfield-behavior]** Last-name field allows multi-line / no maxLength enforcement  (conf=0.70)
- **[semantics]** Disabled Next button gives no semantic reason  (conf=0.70)
- **[tap-target]** Back IconButton tap target not verified to meet 48dp  (conf=0.50)

### onboarding/readiness:/onboarding/readiness
- **[tap-target]** `[auto-fixable]` Back round button tap target below 48dp WCAG minimum  (conf=0.90)
  - Fix: Wrap the back AppRoundButton in a SizedBox(width: 48, height: 48) / Padding to expand the hit-test area while keeping the visual 44dp circle. Verify InkWell hit-test extends to wrapper.
- **[missing-reusable]** ReadinessProgressBar duplicates AppLinearProgress capability  (conf=0.85)
- **[ad-hoc-component]** `[auto-fixable]` Outer TweenAnimationBuilder<double> not actually animating width (begin == end)  (conf=0.85)
  - Fix: Use `Tween<double>(end: fraction)` (omit begin) so Flutter back-fills previous end as new begin. Even simpler: replace outer builder with AnimatedFractionallySizedBox.
- **[layout-drift]** Typography drift: counter weight and body color diverge from Figma tokens  (conf=0.80)
- **[semantics]** Choice card row not grouped as a radio-group for assistive tech  (conf=0.80)
- **[semantics]** Question title lacks header semantics  (conf=0.75)
- **[layout-drift]** Choice card surface and selected state diverge from Figma (cream vs white)  (conf=0.70)
- **[missing-reusable]** ReadinessChoiceCard reimplements AppCard surface/border instead of composing it  (conf=0.70)
- **[focus-order]** No focus management on step transition  (conf=0.70)
- **[asset-placement]** Choice card uses Material cancel_outlined instead of DS Nibble cancel glyph  (conf=0.65)
- **[separation-of-concerns]** Stepper index held in widget state instead of controller  (conf=0.55)
- **[ad-hoc-component]** Choice cards in Row misalign when labels wrap to different line counts  (conf=0.55)

### onboarding/result:/onboarding/result
- **[layout-drift]** `[auto-fixable]` Hero size hardcoded to 96 instead of Figma's 154  (conf=0.99)
  - Fix: Change _HeroCard._heroSize from 96 to 154 to match Figma Group 78 dimensions. Existing math derives overlap from _heroSize so cascades automatically; verify visual result.
- **[layout-drift]** `[auto-fixable]` Lime card uses 24pt radius instead of Figma's 30pt (radius3xl)  (conf=0.90)
  - Fix: Swap BorderRadius.circular(AppSizes.radius2xl) for BorderRadius.circular(AppSizes.radius3xl) in _SignsCard.build.
- **[semantics]** `[auto-fixable]` Readiness score chip lacks context for screen readers  (conf=0.90)
  - Fix: Wrap the chip DecoratedBox in Semantics(label: '$signsMet of $total readiness signs met', excludeSemantics: true, child: ...) keeping the inner Text as visual source of truth.
- **[asset-placement]** `[auto-fixable]` Background is flat cream instead of Figma's cream-to-grey gradient  (conf=0.85)
  - Fix: Replace solid Scaffold.backgroundColor with a Container wrapping SafeArea body using BoxDecoration(gradient: LinearGradient(begin: topLeft, end: bottomRight, stops: [0.19, 0.50], colors: [AppColors.butterSoft, Color(0xFFF5F5F5)])). Ideally extract to a shared OnboardingGradientBackground.
- **[ad-hoc-component]** _ScoreChip is a parallel implementation of AppChip(neutral)  (conf=0.85)
- **[ad-hoc-component]** _SignsCard reimplements card surface inline instead of using AppCard  (conf=0.80)
- **[semantics]** Result heading and section header not marked as Semantics headers  (conf=0.80)
- **[stack-abuse]** Hero-overlap Stack couples through private static _heroSize across sibling widgets  (conf=0.75)
- **[navigation]** Back uses context.pop() which may pop to an unrelated route  (conf=0.60)
- **[form-submission]** Next button lacks double-tap / rapid-fire guard and haptic feedback  (conf=0.55)
- **[state-coverage]** No defensive fallback when readinessAnswers length drifts from expected  (conf=0.45)

### profile/edit:/home/profile/edit
- **[missing-reusable]** `[auto-fixable]` _EditAvatar duplicates ProfileAvatarCard fallback (74 vs 72 glyph drift)  (conf=1.00)
  - Fix: Extract common/components/brand/baby_avatar.dart exposing BabyAvatar({double size = 143, double glyphSize = 72}). Use in both _EditAvatar and ProfileAvatarCard so puck/glyph ratio lives in one place.
- **[textfield-behavior]** `[auto-fixable]` textInputAction: next has no focus chain — Next key does nothing  (conf=0.95)
  - Fix: Add FocusNodes for firstName/lastName/email in _ProfileEditFormState. Wire onSubmitted: (_) => FocusScope.of(context).requestFocus(nextNode). On email: unfocus + _save() if canSave.
- **[missing-reusable]** `[auto-fixable]` Custom _EditHeader reimplements shared AppHeader component  (conf=0.90)
  - Fix: Replace _EditHeader with AppHeader(title: 'Change Profile', wash: AppHeaderWash.butterSoft, leading: AppRoundButton(...ghost...)). Delete the local _EditHeader class.
- **[semantics]** `[auto-fixable]` Decorative avatar icon not excluded from semantics (announces 'child care')  (conf=0.90)
  - Fix: Wrap the _EditAvatar Container/Icon in ExcludeSemantics so TalkBack/VoiceOver does not announce 'child care' before the form fields.
- **[textfield-behavior]** `[auto-fixable]` Email field allows iOS autocorrect/suggestions/capitalization  (conf=0.85)
  - Fix: Extend AppTextField with autocorrect, enableSuggestions, textCapitalization props (forwarded to inner TextField). On email field pass autocorrect: false, enableSuggestions: false, textCapitalization: TextCapitalization.none.
- **[layout-drift]** `[auto-fixable]` Save CTA taller and more pill-shaped than Figma compact button  (conf=0.85)
  - Fix: Pass size: AppPillButtonSize.small (or add AppPillButtonSize.medium = 42h, radius 24, Parkinsans SemiBold 15 if 42x15 Figma metrics are required) to match Figma rectangle-with-rounded-corners CTA.
- **[layout-drift]** Save button anchoring drifts — should be bottom-anchored not adjacent to last field  (conf=0.80)
- **[rebuild-scope]** `[auto-fixable]` Whole-controller watch causes form-wide rebuild on every keystroke  (conf=0.80)
  - Fix: Replace ref.watch(profileEditControllerProvider(babyId)).valueOrNull with .select() calls for isLoading + errorMessage. Wrap Save button + error Text in their own Consumer so avatar/header/labelled fields don't rebuild on every keystroke.
- **[navigation]** Snackbar fires before context.pop race — success message may be destroyed with route  (conf=0.80)
- **[form-submission]** Email-change confirmation surfaced as snackbar — too easy to miss for irreversible-feeling action  (conf=0.80)
- **[dynamic-type]** Label font sizes hardcoded — bypass Dynamic Type scaling  (conf=0.75)
- **[semantics]** Loading/error screens lack semantic announcements (no liveRegion)  (conf=0.75)
- **[semantics]** Snackbar success message lacks focus/announcement guarantee  (conf=0.70)
- **[missing-reusable]** _LabelledField reinvents AppTextField's built-in label support  (conf=0.70)
- **[semantics]** Email validation error caption not live-announced  (conf=0.60)
- **[form-submission]** No double-submit guard beyond canSave  (conf=0.60)
- **[result-handling]** No connectivity check before save — P1 'no internet' friendly path missing  (conf=0.55)
- **[separation-of-concerns]** Imperative navigation and snackbar side effects baked into screen build  (conf=0.55)
- **[tap-target]** Back button hit target may fall below 44pt/48dp minimum  (conf=0.50)

### profile/feedback:/home/profile/feedback
- **[layout-drift]** `[auto-fixable]` Helper line and transition caption use bodyMedium (14px) with magic 22/15 height — wrong type slot + hardcoded ratio  (conf=0.99)
  - Fix: Swap bodyMedium -> bodyLarge (15/1.467 Figtree) and replace fixed height: 22/15 with a unitless multiplier (height: 1.47) on both Text widgets (lines ~170-177 and 234-238). Consider extracting a named bodyLargeStrong token in app_typography.dart and reusing it in both places so the 22/15 magic ratio is not duplicated.
- **[missing-reusable]** _FeedbackTransitionScreen duplicates LoadingConfirmation reusable  (conf=0.94)
- **[missing-reusable]** _FeedbackHeader bypasses AppHeader — needs leading-aligned title variant  (conf=0.88)
- **[form-submission]** Send button has no in-flight disabled state / spinner during submit — double-tap possible  (conf=0.70)
- **[interaction]** Textarea fill flips from grey to white on focus — diverges from Figma single-state grey input  (conf=0.70)
- **[semantics]** Send button disabled state not announced to screen readers  (conf=0.60)
- **[textfield-behavior]** TextField missing textInputAction / tap-outside dismiss for iOS multiline UX  (conf=0.60)
- **[textfield-behavior]** _FeedbackField does not sync external initialValue after first mount — controller may go stale  (conf=0.50)
- **[textfield-behavior]** Scroll view does not autoscroll field above keyboard on small phones  (conf=0.45)

### profile:/home/profile
- **[layout-drift]** `[auto-fixable]` Page background gradient is vertically flipped (butter renders at bottom instead of top)  (conf=0.95)
  - Fix: Negate the y-component on both anchors: `begin: Alignment(-0.460, -0.888)`, `end: Alignment(0.460, 0.888)`. Update the inline comment so it no longer claims `(-0.460, 0.888)` is the correct sin/cos mapping (it's the flipped one).
- **[ad-hoc-component]** Sign-out confirmation uses raw Material AlertDialog instead of branded sheet  (conf=0.94)
- **[semantics]** `[auto-fixable]` Decorative chevron / avatar / crown icons not excluded from semantics  (conf=0.94)
  - Fix: Wrap chevron Icon in ExcludeSemantics in settings_row.dart, baby_care icon in profile_avatar_card.dart, and workspace_premium icon in premium_teaser_card.dart.
- **[layout-drift]** Settings list rendered as detached shadow cards instead of grouped card with 12px gutters  (conf=0.80)
- **[asset-placement]** Premium teaser uses Material workspace_premium glyph instead of brand Nibble-Icon-2 mark  (conf=0.80)
- **[missing-reusable]** _ProfileError reimplements EmptyState pattern from scratch  (conf=0.80)
- **[dynamic-type]** Fixed pixel font sizes + fixed-width Edit pill ignore Dynamic Type  (conf=0.80)
- **[missing-reusable]** Wordmark text 'nibbles' rendered inline instead of BrandLogo (with possible SVG asset)  (conf=0.71)
- **[missing-reusable]** Inline screen gradient + Alignment trig should be reusable token/BrandedScaffold  (conf=0.70)
- **[form-submission]** Sign-out has no loading state / double-tap guard during in-flight signOut  (conf=0.70)
- **[missing-reusable]** SettingsRow chevron color logic should be a variant on a reusable list-row component  (conf=0.65)
- **[rebuild-scope]** Nested ConsumerWidget layers with .when cause over-rebuilds  (conf=0.60)
- **[missing-reusable]** PremiumTeaserCard reimplements card surface instead of using AppCard  (conf=0.55)
- **[separation-of-concerns]** Analytics screen_view fires before content actually renders  (conf=0.50)
- **[navigation]** Manage Subscription row navigates to deferred feature with no guard  (conf=0.50)

### recipe/detail:/home/recipes/:recipeId
- **[hardcoded-constants]** `[auto-fixable]` Toast/snackbar copy hardcoded; 'Succesfully' typo visible to users  (conf=0.99)
  - Fix: Fix 'Succesfully' -> 'Successfully' at line 398 immediately. Move user-visible strings into easy_localization catalog; centralize duplicate 'Try again.' wording to match error-handling.md.
- **[missing-reusable]** `[auto-fixable]` Three near-identical numbered list widgets duplicated in screen file  (conf=0.95)
  - Fix: Extract a single NumberedList<T> widget accepting items + label mapper into lib/src/common/components/lists/numbered_list.dart, export via components.dart, and call three times.
- **[ad-hoc-component]** `[auto-fixable]` Overflow bottom sheet built inline in Screen with hand-rolled grab handle  (conf=0.95)
  - Fix: Extract a SheetGrabHandle widget into common/components/feedback/sheet_grab_handle.dart and reuse in both sheets. Move the overflow sheet body into widgets/recipe_overflow_sheet.dart exposing showRecipeOverflowSheet(context). Wrap grab handle in ExcludeSemantics and pass isScrollControlled/useSafeArea to showModalBottomSheet.
- **[asset-placement]** `[auto-fixable]` Section icons do not match Figma glyph set  (conf=0.90)
  - Fix: Replace icons in recipe_detail_screen.dart: Ingredients -> Icons.menu_book_outlined, Method -> Icons.cookie_outlined, Utensils -> Icons.restaurant_menu_outlined. Mirror Figma component IDs 1474:53195 / 1474:53220 / 1474:53248.
- **[rebuild-scope]** `[auto-fixable]` _showSuccessBanner setState rebuilds entire Stack subtree  (conf=0.90)
  - Fix: Move toast state into a small _ToastOverlay widget with its own ValueNotifier<bool>, exposed via a controller/GlobalKey. Wrap only the Positioned(top:...) banner in ValueListenableBuilder/AnimatedSwitcher so the outer Stack/Column does not depend on the banner flag.
- **[sheet-behavior]** `[auto-fixable]` _RemoveRow snackbar appears behind modal sheet (invisible to user)  (conf=0.90)
  - Fix: Replace the root SnackBar with an in-sheet confirmation (inline toast/banner or undo affordance on the row). If keeping a snackbar, defer it until after the sheet pops (capture intent and emit from parent post-pop).
- **[layout-drift]** `[auto-fixable]` Numbered list items render as filled green dots instead of plain numerals  (conf=0.85)
  - Fix: Replace _NumberDot with a Text widget rendering the numeral in titleSmall (Parkinsans SemiBold 13/20, color fgStrong). Reserve a fixed 24px column so numerals align. Drop the BoxDecoration circle entirely.
- **[asset-placement]** Texture Tip / Why This Meal cards missing illustration asset  (conf=0.85)
- **[missing-reusable]** `[auto-fixable]` Inline _ErrorView duplicates EmptyState; FilledButton breaks DS consistency  (conf=0.85)
  - Fix: Replace _ErrorView with EmptyState(title, subtitle, ctaLabel: 'Retry', onCtaPressed: onRetry). Add an icon parameter to EmptyState if needed rather than a one-off.
- **[stack-abuse]** `[auto-fixable]` Unnecessary Stack + Positioned.fill for sticky CTA pattern  (conf=0.85)
  - Fix: Lift AddToMealPlanCta into Scaffold.bottomNavigationBar in _RecipeDetailBody. Keep Stack only for the floating success-banner overlay (or use ScaffoldMessenger MaterialBanner). Removes Positioned.fill and manual bottom inset math.
- **[form-submission]** `[auto-fixable]` RemoveButton tap target below platform minimum (a11y)  (conf=0.85)
  - Fix: Wrap inner Icon in SizedBox(width: kMinInteractiveDimension, height: kMinInteractiveDimension) centered, or replace InkResponse with IconButton so platform-standard tap area + ripple are applied automatically.
- **[result-handling]** _ErrorView treats all error types identically (no 401/404/connectivity differentiation)  (conf=0.80)
- **[layout-drift]** Page background is solid cream instead of warm gradient  (conf=0.75)
- **[asset-placement]** Recipe hero is single image instead of stacked rotated collage  (conf=0.70)
- **[separation-of-concerns]** ConsumerStatefulWidget used only for one-shot analytics call  (conf=0.70)
- **[semantics]** Ingredient/Step/Utensil rows lack list-item semantics tying number to body  (conf=0.70)
- **[dynamic-type]** Fixed-height number dot clips under large Dynamic Type  (conf=0.70)
- **[semantics]** Loading and error states unlabeled/silent for screen readers  (conf=0.60)

### recipe/library:/home/recipe
- **[form-submission]** `[auto-fixable]` Filter chip and search clear button lack Semantics labels/tooltips  (conf=0.99)
  - Fix: Wrap _FilterChipButton in Semantics(button: true, label: 'Open Starting Guide'); add tooltip: 'Clear search' to the clear IconButton.
- **[scaling]** `[auto-fixable]` CachedNetworkImage thumbnail missing memCacheWidth/memCacheHeight decode hints  (conf=0.99)
  - Fix: Add memCacheWidth: (158 * devicePixelRatio).round() and memCacheHeight: (117 * devicePixelRatio).round() to the CachedNetworkImage call.
- **[textfield-behavior]** `[auto-fixable]` Search TextField has no onChanged debounce — every keystroke triggers full filter + state mutation  (conf=0.90)
  - Fix: Wrap _onSearchChanged in a 200-300ms Timer-based debounce in _RecipeLibraryBodyState (dispose timer in dispose()); keep clear path immediate.
- **[textfield-behavior]** `[auto-fixable]` Search TextField missing autocorrect: false, enableSuggestions: false, textCapitalization.none  (conf=0.90)
  - Fix: Set autocorrect: false, enableSuggestions: false, textCapitalization: TextCapitalization.none on the search TextField.
- **[layout-drift]** `[auto-fixable]` Page gradient end color uses cream (#FFFDF8) instead of Figma off-white #F5F5F5  (conf=0.85)
  - Fix: Add AppColors.offWhite = Color(0xFFF5F5F5) token and use as the gradient end color in _PageScaffold instead of AppColors.cream. Optionally compute begin/end with a 128.4deg transform to match the Figma angle.
- **[layout-drift]** `[auto-fixable]` Screen title weight is SemiBold 17 instead of Figma Bold 17  (conf=0.85)
  - Fix: Swap to titleSmall.copyWith(fontWeight: FontWeight.w700) or introduce a dedicated screenTitle Parkinsans Bold 17/22 token. Also remove the inaccurate '17/Bold' comment.
- **[result-handling]** `[auto-fixable]` markStartingGuideSeen optimistic state never rolled back on Hive write failure  (conf=0.85)
  - Fix: Wrap Hive write in try/catch; on failure restore previous state and log to Crashlytics, or await write before mutating state.
- **[result-handling]** Controller throws raw exceptions from build() — violates project Result<T> rule  (conf=0.80)
- **[dynamic-type]** Hard-coded English copy bypasses easy_localization  (conf=0.80)
- **[layout-drift]** Horizontal page padding is 20 but Figma column is inset 16  (conf=0.75)
- **[textfield-behavior]** Search TextField controller can desync from state.searchQuery (half-controlled pattern)  (conf=0.75)
- **[dynamic-type]** Fixed-height SizedBox layouts don't respect Dynamic Type / textScaler  (conf=0.75)
- **[layout-drift]** Search results layout uses a 2-column grid but Figma shows a horizontal row  (conf=0.70)
- **[semantics]** Recommendation row title bakes emoji into the semantic title (sesame/soy collide)  (conf=0.70)
- **[form-submission]** SnackBar for Starting Guide stub lacks haptic, semantics, and a11y announcement  (conf=0.61)
- **[focus-order]** Empty search results lack focus/announcement handoff for screen readers  (conf=0.55)
- **[missing-illustration]** Empty 'No recipes yet' state has no illustration (inconsistent with search-empty)  (conf=0.50)

### shopping_list:/home/shopping-list
- **[tap-target]** `[auto-fixable]` Cancel chip tap target is 37x37, below 48dp minimum  (conf=0.95)
  - Fix: Wrap visible 37x37 chip in 48x48 transparent SizedBox/InkWell so hit area is 48 while preserving visible size.
- **[tap-target]** `[auto-fixable]` Square checkbox tap target is 30x30, below 48dp minimum  (conf=0.95)
  - Fix: Wrap visible 30x30 box in 48x48 transparent SizedBox/InkWell; keep visible square at 30.
- **[state-coverage]** `[auto-fixable]` Optimistic placeholder appended to end of list — appears at bottom despite intent of top; placeholder rows still allow delete with empty id  (conf=0.92)
  - Fix: Prepend with [placeholder, ...current.items] to match documented intent. Also disable swipe/X on rows where item.id.isEmpty (gate _delete/_check/_uncheck on item.id.isNotEmpty).
- **[form-submission]** `[auto-fixable]` Add button has no disabled-until-valid state — blank submits silently swallowed  (conf=0.90)
  - Fix: Listen to TextEditingController; rebuild AddIngredientCard with enabled flag bound to controller.text.trim().isNotEmpty. Render pill at reduced opacity and ignore taps when disabled.
- **[textfield-behavior]** `[auto-fixable]` Add TextField uses textInputAction.done — keyboard collapses after each submit despite intent to keep card open  (conf=0.88)
  - Fix: Switch to TextInputAction.send (or .next); after _addController.clear() in _submitAdd, call _addFocusNode.requestFocus() to keep IME up.
- **[layout-drift]** `[auto-fixable]` Inter-row gap is 8px (AppSizes.sm) but Figma column gap is 12px  (conf=0.85)
  - Fix: Change separator from SizedBox(height: AppSizes.sm) to SizedBox(height: AppSizes.sp12) (12px) in _ItemsList separatorBuilder.
- **[missing-reusable]** _EmptyState and _ErrorState bypass published EmptyState reusable; FilledButton instead of AppPillButton  (conf=0.85)
- **[state-coverage]** `[auto-fixable]` AsyncValue.when shows full-screen spinner on every refresh, destroying selected tab/swipe state  (conf=0.85)
  - Fix: Use controllerAsync.when(skipLoadingOnRefresh: true, skipLoadingOnReload: true, ...) so existing list stays visible during background refresh.
- **[result-handling]** Controller throws raw AppException from Result — violates rule 'no raw throws from async ops in UI'  (conf=0.85)
- **[layout-drift]** Title uses SemiBold 17 (titleSmall) instead of Figma's Title 3/Bold (Bold 17)  (conf=0.80)
- **[form-submission]** Add card outside-tap dismiss discards typed text without confirmation  (conf=0.80)
- **[navigation]** Missing PopScope — Android back does not close Add card or open swipe row  (conf=0.80)
- **[stack-abuse]** Stack with Positioned for keyboard-anchored Add card; outer dismiss GestureDetector does not fill screen  (conf=0.78)
- **[missing-reusable]** Toast bypasses brand pattern — ScaffoldMessenger.showSnackBar called directly with 5 sites  (conf=0.70)
- **[form-submission]** No double-submit guard on Add — rapid taps could enqueue duplicate optimistic inserts  (conf=0.70)
- **[semantics]** Outer tap-dismiss GestureDetector lacks excludeFromSemantics  (conf=0.70)
- **[rebuild-scope]** Root ref.watch(currentBabyIdProvider) rebuilds entire Stack body on baby-id refresh  (conf=0.60)
- **[semantics]** Error and toast messages not announced as live regions to screen readers  (conf=0.60)
- **[separation-of-concerns]** copyToClipboard returns bool from controller instead of Result<Unit>; clipboard side-effect lives in controller not service  (conf=0.55)

### splash:/
- **[state-coverage]** `[auto-fixable]` Retry CTA shows no progress indicator while boot re-runs (no loading state surfaced)  (conf=1.00)
  - Fix: Either branch on (state.hasError || state.isReloading) to keep the error view visible during retry, or render a small CircularProgressIndicator near the CTA when isReloading is true. Best: extend AppPillButton with an isLoading prop that swaps the label for a sized progress indicator. Also wrap the disabled button in Semantics(label: 'Try again, retrying', enabled: false, button: true, liveRegion: true) so screen reader users know work is in progress.
- **[missing-reusable]** Inline brand lockup duplicates BrandLogo; vertical lockup missing as reusable  (conf=0.94)
- **[semantics]** Error state not announced as a live region for screen readers  (conf=0.70)
- **[rebuild-scope]** ref.watch at build root rebuilds entire Scaffold on every AsyncValue transition  (conf=0.60)
- **[interaction]** No fade-in / cross-fade transition on brand lockup or splash exit  (conf=0.40)

### starting_guide:/home/recipe/guide
- **[asset-placement]** `[auto-fixable]` Screen background should be cream→off-white gradient, not solid AppColors.cream  (conf=1.00)
  - Fix: Change Scaffold(backgroundColor: AppColors.cream) to Scaffold(backgroundColor: Colors.transparent) and wrap the body in a Container with BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.butterSoft, Color(0xFFF5F5F5)])) to match the section-wide gradient documented in .figma-audit/recipe-library/section_report.md.
- **[state-coverage]** markStartingGuideSeen fires on mount regardless of load result — banner dismissed even on error  (conf=0.80)
- **[navigation]** Article card tap has no double-tap guard — duplicate route pushes possible  (conf=0.70)
- **[missing-illustration]** Possible missing hero illustration in hub header  (conf=0.45)

### starting_guide:/home/recipe/guide/:slug
- **[tap-target]** `[auto-fixable]` Back button tap target is 32x32 — below 48dp WCAG minimum  (conf=1.00)
  - Fix: Resolved by replacing GuideBackButton with AppRoundButton (see consolidated finding). If keeping GuideBackButton, wrap the InkWell in a SizedBox(width: 48, height: 48) with the 32px visual circle centered inside to preserve the kit visual while providing a 48dp hit area.
- **[semantics]** `[auto-fixable]` Loading spinner has no semantic label  (conf=0.90)
  - Fix: Change `CircularProgressIndicator()` at line 89 to `CircularProgressIndicator(semanticsLabel: 'Loading guide article')`. Localize via easy_localization if available.
- **[layout-drift]** `[auto-fixable]` Page background flat cream — missing Figma cream→off-white gradient  (conf=0.88)
  - Fix: Set `Scaffold(backgroundColor: Colors.transparent)` and wrap the body in `DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment(-1,-1), end: Alignment(1,1), colors: [AppColors.bgCardTint, AppColors.background])))` to approximate the ~135° Figma angle. Reuse the same gradient on the Starting Guide hub so the section reads as a unit.
- **[state-coverage]** `[auto-fixable]` Error branch swallows real errors and shows misleading 'Article not found' UI  (conf=0.88)
  - Fix: Split error and not-found states in `AsyncValue.when`. Error branch: render dedicated error widget with a Retry button calling `ref.invalidate(startingGuideControllerProvider)`, log error+stack via `unawaited(FirebaseCrashlytics.instance.recordError(err, st))`. Keep `_NotFound` strictly for unmatched-slug case inside the data branch.
- **[semantics]** `[auto-fixable]` Header title not flagged as a heading for screen readers  (conf=0.85)
  - Fix: Wrap the title Text in _Header with `Semantics(header: true, child: Text(...))` so VoiceOver/TalkBack expose it as a heading. Resolved automatically if migrating to `AppHeader` (which should also expose heading semantics — verify and add if missing).
- **[navigation]** CTA uses context.goNamed — replaces route stack instead of pushing forward  (conf=0.83)
- **[layout-drift]** Numbered-list CTA pair rendered as separate block — Figma keeps CTAs INSIDE the cream card  (conf=0.80)
- **[separation-of-concerns]** _onCta encodes routing policy in Screen with defensive AppRoute allowlist  (conf=0.77)
- **[semantics]** Error/not-found state has no live-region announcement  (conf=0.75)

### subscription/manage:/subscription/manage
- **[missing-reusable]** _BrandLockup duplicated across 4 files — actively drifting  (conf=1.00)
- **[layout-drift]** `[auto-fixable]` Primary CTA height drifts from Figma (52h vs 42h)  (conf=0.85)
  - Fix: Pass `size: AppPillButtonSize.small` to both AppPillButton invocations (or add an `AppPillButtonSize.compact` mapped to 42 in AppSizes) so CTA renders at Figma-spec 42h instead of 52h.
- **[missing-reusable]** _BrandCard duplicates bordered-soft surface with PremiumTeaserCard  (conf=0.85)
- **[layout-drift]** CTA label uses Figtree 16/700 instead of Parkinsans SemiBold 15  (conf=0.80)
- **[missing-reusable]** _ManageSubscriptionHeader duplicates ProfileHeader's left-aligned back+title pattern  (conf=0.80)
- **[semantics]** Timeline dots + connector unlabeled; row reads as fragmented utterances  (conf=0.77)
- **[semantics]** Decorative _BrandLockup wordmark + crown not excluded from semantics  (conf=0.75)
- **[asset-placement]** Timeline connector too short — stub instead of full inter-dot stem  (conf=0.70)
- **[missing-reusable]** Inline timeline connector has 6-level wrapper nesting + leaky encapsulation  (conf=0.70)
- **[sheet-behavior]** Cancel sheet dismissible by drag/scrim while submission in-flight  (conf=0.70)
- **[sheet-behavior]** Local ScaffoldMessenger may tear down before SnackBar resolves on rapid dismiss  (conf=0.40)

### subscription/paywall:/subscription/paywall
- **[ad-hoc-component]** Trial/loading/error cards built as raw Container+BoxDecoration instead of AppCard  (conf=0.99)
- **[tap-target]** `[auto-fixable]` Retry button in trial-card error has shrink-wrap tap target far below 48dp  (conf=0.99)
  - Fix: Remove minimumSize: Size.zero and tapTargetSize: MaterialTapTargetSize.shrinkWrap, or wrap in SizedBox(height: 48). Keep compact visuals via padding-only tightening.
- **[asset-placement]** `[auto-fixable]` Inline GoogleFonts.nunito at runtime instead of bundled FontFamily.nunito / AppTypography token  (conf=0.94)
  - Fix: Replace `GoogleFonts.nunito(fontSize:15, fontWeight:w700, ...)` in _TrialCard's price TextSpan with a bundled `TextStyle(fontFamily: FontFamily.nunito, ...)` or AppTypography.priceEmphasis. Verify Nunito is in gen/fonts.gen.dart; add to pubspec if missing.
- **[state-coverage]** View-all-plans CTA shows TODO snackbar instead of wiring existing showAllPlansSheet  (conf=0.94)
- **[layout-drift]** `[auto-fixable]` SafeArea(top: true) on sheet body wastes ~44-59px above the close X on notched devices  (conf=0.85)
  - Fix: Change `SafeArea(...)` to `SafeArea(top: false, child: ...)` matching AllPlansSheet's pattern. The showModalBottomSheet's own inset already keeps the sheet below the status bar.
- **[semantics]** `[auto-fixable]` Heading 'Everything you need for safe feeding' not exposed as semantic header  (conf=0.85)
  - Fix: Wrap _Heading's Text in Semantics(header: true, child: Text(...)). Apply same to trial card's '3 Days Free' if intended as section heading.
- **[rebuild-scope]** ref.watch on whole PaywallController state rebuilds full subtree on any action change  (conf=0.80)
- **[semantics]** Feature rows announced as fragmented Text nodes — should be MergeSemantics-grouped  (conf=0.80)
- **[ad-hoc-component]** PaywallScreen scrim/sheet wrapper duplicates showModalBottomSheet shape — two surfaces will drift  (conf=0.75)
- **[dynamic-type]** Fixed pill/CTA heights (42, 48) will clip text at large Dynamic Type settings  (conf=0.75)
- **[sheet-behavior]** P1 error dialog uses default barrierDismissible:true and lacks Retry button  (conf=0.70)
- **[state-coverage]** Trial card renders empty placeholder ('0 Days Free', empty price) when phase=ready but offering null  (conf=0.70)

### subscription/success:/subscription/success
- **[contrast]** Low-contrast LOADING caption (cream on butterSoft) likely fails WCAG AA  (conf=0.80)
- **[dynamic-type]** Hardcoded fontSize/height breaks Dynamic Type for loading caption  (conf=0.75)
- **[semantics]** PopScope blocks back with no a11y explanation  (conf=0.70)
- **[state-coverage]** Analytics activation event re-fires on every controller build  (conf=0.60)
- **[separation-of-concerns]** Auto-route Timer lives in screen instead of controller  (conf=0.55)
- **[navigation]** PopScope traps user if successDwell timer is cancelled or never reschedules  (conf=0.50)
- **[navigation]** Auto-route uses context.goNamed and success may remain in back stack  (conf=0.45)

---

## P3 — Polish (cosmetic, low priority)

- **AddToMealPlanSheet**: 'Add' pill in expanded card relabels to 'Added' instead of using fill-state; Typography token mismatch — titleSmall used where Headline/SemiBold 15/22 expected; Date formatting hand-rolled instead of intl DateFormat; Hardcoded user-facing strings (counter, CTA, Add/Added) — not localized; Hardcoded border opacity AppColors.green.withValues(alpha: 0.5)...
- **AddToShoppingListModal**: Horizontal divider under header not in Figma — fights gradient; Drag handle present but absent in Figma (and would be redundant once close-X added); Hardcoded colors/sizes bypass sage/butter/coral tokens; Empty state has no explicit close CTA; Action label 'Add 0/1 items' has bad grammar and copy...
- **AddToShoppingListSheet**: Grab handle not in Figma reference and constructed inline (should be shared SheetGrabHandle); Header X vertically misaligned vs title (CrossAxisAlignment.start) and Material IconButton constraints drift X position; Title typography may not be Parkinsans Bold 17 (titleMedium defaults to 16/24); Hardcoded English strings not localised; Magic 0.6 multiplier for sheet max-height inconsistent with neighbour sheet...
- **AttachmentSheet**: No drag handle on modal sheet — accessibility/affordance gap on keyboard-pushed sheet; Photo file rendered with redundant Container background + nested ClipRRect overdraw; Hardcoded 195px height and inline user-facing strings (no token, no localization); Sheet uses StatefulWidget despite Riverpod feature-module pattern (advisory); Sheet header pattern (centered title + spacing) is repeated across sheets with no reusable AppSheetHeader...
- **BrowseMealSheet**: Filtered empty state collapses with cold-empty state — misleading copy; Recipe-card overlay uses Stack+Positioned where Align/Padding suffices; Hardcoded sizes/colors/durations bypass AppSizes/AppColors tokens; Header subtitle uses bodyMedium/fgDefault instead of Subhead/SemiBold + fgMuted; Grab handle present in code but not in Figma — dual dismissal affordance...
- **ClearAllConfirmSheet**: Hardcoded title width (212) and quatrefoil size (153) bypass AppSizes tokens; Scrim alpha 0.5 hardcoded instead of theme token; Cancel/Delete two-button row is a repeatable pattern worth extracting; No haptic feedback on destructive Delete action; isDismissible / enableDrag not explicitly set on showModalBottomSheet...
- **ClearConfirmDialog**: Buttons not wrapped in the 'Floating-button' white shadowed footer container; Background/scrim/typography style drift vs sibling clear_all_confirm_sheet (cream vs surface, missing explicit barrierColor); Imperative Navigator.pop inside builder couples sheet to caller (addressed during shared extraction); No haptic feedback on destructive Delete tap; Tri-state bool? return contract is misleading — caller collapses cancel and scrim-dismiss...
- **DeleteLogConfirmationDialog**: No haptic feedback on destructive confirm; Question text inlines TextStyle (Parkinsans 17/700) instead of using AppTypography ramp; Hardcoded magic numbers — Quatrefoil size 153 and barrier color black/0.32; Decorative Quatrefoil illustration not excluded from accessibility tree; Dialog return type bool? conflates explicit cancel with barrier/back dismissal...
- **RangeAddToShoplistSheet**: Header title weight is 17/600 SemiBold but Figma spec is 17/700 Bold; Sheet gradient angle ~135deg vs Figma 156.9deg spec; DraggableScrollableSheet enables drag without affordance — Figma is fixed-height; SnackBar success may want LoadingConfirmation instead; Raw CircularProgressIndicator on loading state — no brand tint...
- **SelectPeriodDateSheet**: Title typography weight is w600 (SemiBold) but Figma specifies Title 3/Bold w700; Sheet backgroundColor uses #FFFFFF instead of Nibble cream (#FFFDF8); Hardcoded drag-handle dimensions (40, 4) bypass AppSizes tokens; Hardcoded sheet title string 'Select Period Date' — no localization or constant; Imperative Navigator.pop in widget build closure instead of controller-mediated submit...
- **allergen/complete:/home/allergen/complete**: Body copy uses AppColors.subtext rather than semantic fgMuted token; contrast also unverified; Wrap of 9 variable-width chips renders ragged, competes with hero; Vertical breathing room may be insufficient for celebration hero; View in Profile CTA: no double-tap guard, no haptic, no awaited persistence; Loading state: no SafeArea wrapper, no min-display time, no semantic label...
- **allergen/detail:/home/allergen/:allergenKey**: Dates label letter-spacing/typography diverges from Figma SemiBold treatment; DetailStatusPill duplicates AppChip behavior and geometry; Screen owns presentation-derived logic instead of state/controller; Inline AppBar + error/loading scaffolds reimplement empty/error reusable patterns; DetailHeaderCard builds the emoji tile inline with hardcoded sizes...
- **allergen/log:/home/allergen/:allergenKey/log**: Edit-mode CTA copy ('Edit Picture') does not match Figma ('Change Picture'); Notes field is multi-line but Figma renders a static single-line input; Date hint shows today's date verbatim instead of a faint placeholder; Months array + _formatDate is a per-screen date util; Hardcoded loading spinner sizes instead of AppSizes tokens...
- **allergen/log_detail:/home/allergen/:allergenKey/log/:logId**: Download chip uses elevated white circle + shadow — Figma shows flat glyph; Local _months/_formatDate reimplements date formatting; Hardcoded photo height 195 repeated 4x — promote to AppSizes; Title style Parkinsans 15/600 hardcoded — missing AppTypography.fieldLabel token; _DownloadChip inline Container — should use AppRoundButton...
- **allergen/tracker:/home/allergen/tracker**: Segmented control inactive text color does not match Figma green spec; 'Big 11' tab label inconsistent with 9-allergen domain; 'N log(s) total' caption not in Figma adds extra row height; _currentBabyProvider redundantly re-fetches Baby just for avatar initial — single source of truth violated; Hardcoded emoji font size 24 + height 1 repeated across 3 widgets...
- **auth/forgot_password:/auth/forgot-password**: Back-button tone uses 'butter' instead of audit-noted Lime; Inline error precedence logic duplicated form-side instead of derived in state; Forgot-password screen watches whole controller, rebuilds entire view on every keystroke; Hardcoded magic numbers for badge sizing and inline user-facing strings; No haptic feedback on submit success/failure...
- **auth/login:/auth/login**: Login button text color uses cream (#FFFDF8) instead of pure white; Hand-rolled inline LinearGradient instead of reusable AppGradients token; Hardcoded font styles bypass AppTypography tokens; Hardcoded Google brand blue (0xFF4285F4) instead of AppColors token; User-facing copy hardcoded — bypasses easy_localization...
- **auth/register:/auth/register**: 'Or sign up with' dividers expand full width instead of fixed 96px segments; Body copy hard-wraps with explicit '\n' instead of natural soft-wrap; Password field shows client-side 8-char helper that's not in Figma copy; Hardcoded Google brand blue color outside AppColors; Gradient background hardcoded inline — should be reusable AuthScaffold / AppGradients.grad1...
- **auth/reset_password:/auth/reset-password**: Grad-1 end-stop drifts from Figma #F5F5F5 to AppColors.background warm cream; Forest-green error tone here vs burgundy on sibling forgot_password — auth-family coherence; Inline 16x16 CircularProgressIndicator hand-rolled in submit button — missing isLoading affordance on AppPillButton; User-facing copy hardcoded — should use easy_localization keys; No password visibility toggle (eye icon) on obscured fields...
- **home:/home**: Today pill sizing/alignment off-spec (32px vs ~28px, row alignment); Inline _NoMealsInline in TodaysMealsCard duplicates HomeNoMealsState and is dead/unsafe code; DayChipRow shows today + 2 previous days instead of conventional today-centered strip; InkWell ripple feels off-brand on OngoingIntroducedCard and meal rows; ReadyToStartCard duplicates butter-gradient surface inline (no shared BrandButterSurface)...
- **meal_plan/map:/home/meal/map**: Day chip filled state stacks check inline making chip taller than peers; Page background uses flat cream instead of Grad-1 wash used across meal-plan screens; Drag & drop helper conditional placement is wrong-by-coincidence and string is duplicated across two files; Meals Picked section title and 'N selected' counter use wrong typography tokens; AppTypography.caption with explicit fontSize: 12 leaks design tokens...
- **meal_plan:/home/meal**: Day accordion card has 1px borderSoft outline; Figma is borderless white-on-cream; Day-card chevron lacks expand/collapse animation; DayAccordionCard root Container reimplements AppCard surface; Ad-hoc loading/error scaffolds bypass DS button + error rules; Hardcoded weekday/month name arrays duplicated across 3 files (locale-unsafe)...
- **onboarding/baby_setup:/onboarding/baby-setup**: Submit handler missing haptic feedback on success and step transitions; controller.nextStep doesn't re-validate prior data — programmatic callers can skip invalid steps; Name field error UX doesn't distinguish tooLong vs invalid, lacks brand burgundy border; DOB step missing inline selected-date confirmation / error display path; Subtext color contrast on step indicator may fail WCAG AA 4.5:1
- **onboarding/baby_setup_loading:/onboarding/baby-setup-loading**: Hardcoded typography constants (12.8/19.2/4.33) duplicated between this screen and LoadingConfirmation._PhaseLabel; Caption color may render too high-contrast against green petals (until caption is moved below blob); State enum has two phases but build() ignores phase — no explicit branching, fragile to a future error phase; Controller's _scheduleSettle reassigns timers without cancelling prior handles — minor leak risk on rebuild; Analytics swallow catches all errors silently — no Crashlytics breadcrumb...
- **onboarding/consent:/onboarding/consent**: Hardcoded PetalBlob size + checkbox baseline magic number — should use AppSizes tokens; PetalBlob decorative — exclude from semantics; No haptic feedback on checkbox toggle / CTA tap; Status-bar to title gap mismatch with Figma (subset of layout drift); Error icon decorative — exclude from semantics...
- **onboarding/dob:/onboarding/dob**: Month wheel normalizes to 3-letter abbreviations vs Figma mixed; Back-button affordance confirmation (no top app bar); Selection-pill background reimplemented via Container+BoxDecoration; Hardcoded typography and sizes in _AgeChip / wheel column; Onboarding footer (back + next) is repeated pattern missing reusable...
- **onboarding/intro:/onboarding/intro**: Dot indicator added that does not exist in Figma source; _DeviceMockupPlaceholder is a Container masquerading as a card — use AppCard; Inline typography metrics (height: 34/22, 22/15) bypass AppTypography tokens; Hardcoded color #FFFEEA outside the token system; Magic device-mockup ratio constants 9/19.5/0.72 in build()...
- **onboarding/name:/onboarding/name**: Title line-height too tight (1.273 vs Figma 1.545); Body copy uses fgStrong (#2C2C2C) instead of Labels/Primary (#000000); Top gap to title is ~72px vs Figma ~128px; Hardcoded error string 'You must fill the name' — not localized; ref.read in initState may yield stale UI if babyName mutated upstream...
- **onboarding/readiness:/onboarding/readiness**: Horizontal page padding is 20 vs Figma's 16; Inter-block vertical spacing non-uniform vs Figma's gap 36; Question counter copy uses 'of' vs Figma's 'from'; Ad-hoc step counter typography not in theme tokens; Stack inside SizedBox for progress bar is unnecessary...
- **onboarding/result:/onboarding/result**: Title typography uses theme styles rather than explicit Title 1/Title 3 Parkinsans ramps; _SignRow icon bubble is inline Container instead of a reusable CircleIcon; Coarse rebuilds — ref.watch full controller drives whole screen rebuilds; Imperative navigation in Screen instead of controller intent; User-facing copy hardcoded inline instead of routed through easy_localization...
- **profile/edit:/home/profile/edit**: Save button loading state lacks button/busy semantics; Inline error Text duplicates AppTextField's caption styling; Hardcoded magic numbers for spacing/sizing/colors instead of AppSizes/AppColors; Triple ConsumerWidget chain when one ConsumerStatefulWidget suffices; No textCapitalization.words on First/Last Name fields...
- **profile/feedback:/home/profile/feedback**: TextField has no autofocus on a screen whose sole purpose is typing; Header title height: 1 override may clip Parkinsans descenders; Background lacks butter-to-cream gradient — hard color seam at header bottom; Loader is a single Quatrefoil instead of Figma's nested layered composition; Loader caption layout — captions stacked-and-swapped vs Figma's overlapping/separate positioning...
- **profile:/home/profile**: Delete account row is tinted destructive red; Figma uses neutral chrome; Header has excess bottom padding pushing content lower than Figma; Inline _ageLabel computation should live in domain extension; ProfileAvatarCard hardcodes typography inline instead of using AppTypography/theme; Avatar circle hardcodes 143 diameter + 72 icon size...
- **recipe/detail:/home/recipes/:recipeId**: Bottom CTA has leading '+' icon and shadow not in design; Overflow chip visible during success-state; 'Contains allergens' header uses shield icon instead of Figma's bolt/leaf; Recipe banner card uses default surface instead of cream #FFFDF8; _NumberDot and IconSectionHeader circle should share a GlyphDot primitive...
- **recipe/library:/home/recipe**: Title -> search vertical rhythm is tighter than Figma; Read Guide banner color may be Forest-dark not Forest-green; Filter chip uses bookmark icon — Figma glyph likely a 'class/book' symbol; RefreshIndicator is unsanctioned by design and unthemed; Loading/error scaffold states bypass header + design typography...
- **shopping_list:/home/shopping-list**: Empty-state vertical anchoring drifts and gap is 8 not Figma's 10; Add card floats flush above keyboard; Figma anchors mid-screen; Add card 'Ingredients' placeholder is left-aligned; Figma centers it; Cancel icon uses Icons.cancel at 24px instead of Figma's 18px in rounded-10 chip; Hardcoded sizes (40 chip, 30 checkbox, 37 cancel, 153 mark, 100 reveal) bypass AppSizes tokens...
- **splash:/**: Lockup vertically centered vs Figma's slightly-above-center anchor; ConsumerStatefulWidget used solely for one-shot screen-view analytics; Error copy and CTA label hardcoded in screen instead of localized; Body color override mixes Theme.textTheme with AppColors instead of AppTypography; No haptic feedback on P0 retry tap...
- **starting_guide:/home/recipe/guide**: Card spacing tighter than Figma stack; Analytics source hardcoded 'unknown' — entry-point attribution lost (NIB-53); Back navigation hardcodes recipeLibrary fallback when cannot pop; Article card tap has no haptic feedback; markStartingGuideSeen Hive write failure silently swallowed...
- **starting_guide:/home/recipe/guide/:slug**: Hero card body text uses muted grey — Figma uses near-black; No transition/micro-interaction polish (Hero animation, scroll parallax); ParagraphBlock uses raw AppTypography.bodyLarge.copyWith instead of typed widget; ConsumerStatefulWidget shares build scope between initState analytics and provider watch; Article lookup loop in build duplicates controller's articleFor()...
- **subscription/manage:/subscription/manage**: Header back chip horizontal padding misaligned with body column (12px vs 16px); Verbatim copy preserves stray-space colon strings — hardcoded + bypasses i18n + bad TTS; Hardcoded '/home' route string instead of AppRoute.home.name; Hardcoded gradient math + magic numbers + dead Scaffold backgroundColor; Body 15/22 text style inlined 3+ times across screen...
- **subscription/paywall:/subscription/paywall**: Brand wordmark renders ~162px vs Figma 173px spec (6% under); Feature row thumbnails render as unrounded coral squares, breaking visual rhythm; Mascot circle built inline — should be extracted to reusable MascotBadge in common/components/brand/; Feature row inlined — should be reusable FeatureBulletRow + FeatureThumbnail in common/components/cards/; Hardcoded TextStyles repeated 8+ times — should reference AppTypography ramp...
- **subscription/success:/subscription/success**: Success label weight is Bold (w700) vs Figma SemiBold (w600); Screen uses Analytics.instance singleton instead of analyticsProvider; ref.watch on phase rebuilds entire Scaffold instead of LoadingConfirmation subtree; Auto-route timer survives backgrounding and fires on resume; No haptic feedback on loading -> success transition...

---

## Cross-POV Consensus (highest-signal findings)

These were flagged by 2 or more independent POV agents — highest priority regardless of auto-fixable status.

- **[P0]** `BrowseMealSheet` — Service-layer fetch + state lives in ConsumerStatefulWidget instead of AsyncNotifier controller
  - POVs: flutter-arch, qa-behavior  |  Confidence: 1.00  |  Category: `separation-of-concerns`
- **[P0]** `onboarding/baby_setup:/onboarding/baby-setup` — LocalFlagService write is fire-and-forget AND called from screen instead of controller — race against router redirect + breaks alternative submit call sites
  - POVs: flutter-arch, qa-behavior  |  Confidence: 0.99  |  Category: `separation-of-concerns`
- **[P1]** `onboarding/result:/onboarding/result` — Hero illustration missing baby face (Group 78) — renders bare Quatrefoil instead
  - POVs: ui-ux, assets  |  Confidence: 1.00  |  Category: `asset-placement`
- **[P1]** `onboarding/intro:/onboarding/intro` — Device-mockup placeholder instead of designed iPhone illustration (NIB-138)
  - POVs: ui-ux, assets, a11y  |  Confidence: 1.00  |  Category: `missing-illustration`
- **[P1]** `onboarding/baby_setup_loading:/onboarding/baby-setup-loading` — Cream-on-cream 'LOADING' caption fails WCAG contrast — invisible to low-vision users with no alternative loading affordance
  - POVs: a11y, ui-ux  |  Confidence: 1.00  |  Category: `contrast`
- **[P1]** `onboarding/baby_setup:/onboarding/baby-setup` — Name step uses raw Material TextField instead of AppTextField; missing body subtext, optional last-name field, controller, autofocus, maxLength, textInputAction/onSubmitted
  - POVs: ui-ux, flutter-arch, qa-behavior, a11y  |  Confidence: 1.00  |  Category: `ad-hoc-component`
- **[P1]** `onboarding/baby_setup:/onboarding/baby-setup` — Raw FilledButton inline spinner used instead of AppPillButton with loading prop
  - POVs: ui-ux, flutter-arch  |  Confidence: 1.00  |  Category: `ad-hoc-component`
- **[P1]** `auth/register:/auth/register` — Hand-rolled Google/Apple social buttons duplicate AppPillButton instead of extending it
  - POVs: ui-ux, flutter-arch  |  Confidence: 1.00  |  Category: `ad-hoc-component`
- **[P1]** `auth/register:/auth/register` — Password obscure toggle missing semantic label and tap target below 48dp
  - POVs: qa-behavior, a11y  |  Confidence: 1.00  |  Category: `semantics`
- **[P1]** `auth/reset_password:/auth/reset-password` — errorText slot abused as always-on guidance — wrong border/focus state + screen readers announce error
  - POVs: ui-ux, flutter-arch, a11y  |  Confidence: 1.00  |  Category: `ad-hoc-component`
- **[P1]** `auth/reset_password:/auth/reset-password` — Missing textInputAction + focus chain between password and confirm fields
  - POVs: flutter-arch, qa-behavior, a11y  |  Confidence: 1.00  |  Category: `textfield-behavior`
- **[P1]** `auth/login:/auth/login` — Google 'G' glyph is a fake styled letter, not the official Google brand mark
  - POVs: ui-ux, assets  |  Confidence: 1.00  |  Category: `missing-illustration`
- **[P1]** `auth/login:/auth/login` — Single errorMessage duplicated on BOTH email and password fields (visual + a11y noise)
  - POVs: ui-ux, flutter-arch, qa-behavior, a11y  |  Confidence: 1.00  |  Category: `ad-hoc-component`
- **[P1]** `auth/login:/auth/login` — Password visibility toggle replaced by misleading check icon on error
  - POVs: ui-ux, flutter-arch, qa-behavior, a11y  |  Confidence: 1.00  |  Category: `ad-hoc-component`
- **[P1]** `auth/login:/auth/login` — No 'Forgot password?' affordance on login screen — route exists but unreachable
  - POVs: ui-ux, qa-behavior  |  Confidence: 1.00  |  Category: `navigation`
- **[P1]** `starting_guide:/home/recipe/guide` — _Header reimplements AppHeader inline; should use AppHeader + AppRoundButton (delete GuideBackButton)
  - POVs: flutter-arch, ui-ux  |  Confidence: 1.00  |  Category: `ad-hoc-component`
- **[P1]** `subscription/paywall:/subscription/paywall` — Mascot icon and feature thumbnails are Material placeholders, not Figma brand assets (missing assets/svgs/ directory)
  - POVs: ui-ux, assets  |  Confidence: 1.00  |  Category: `missing-illustration`
- **[P1]** `subscription/paywall:/subscription/paywall` — Primary 'Try for $0' and secondary 'View all plans' CTAs hand-rolled instead of AppPillButton
  - POVs: flutter-arch, a11y  |  Confidence: 1.00  |  Category: `ad-hoc-component`
- **[P1]** `subscription/paywall:/subscription/paywall` — Close button 34x33 tap target below 44pt/48dp accessibility minimum
  - POVs: flutter-arch, a11y  |  Confidence: 1.00  |  Category: `tap-target`
- **[P1]** `shopping_list:/home/shopping-list` — _AddChip ('+') and _OverflowChip (more_horiz) have no semantic label or button role
  - POVs: a11y, flutter-arch  |  Confidence: 1.00  |  Category: `semantics`
- **[P1]** `starting_guide:/home/recipe/guide/:slug` — Custom _Header reimplements AppHeader with butter gradient instead of using design system
  - POVs: ui-ux, flutter-arch  |  Confidence: 1.00  |  Category: `ad-hoc-component`
- **[P1]** `starting_guide:/home/recipe/guide/:slug` — GuideBackButton duplicates AppRoundButton small+ghost variant and has no semantic label
  - POVs: ui-ux, flutter-arch, a11y  |  Confidence: 1.00  |  Category: `missing-reusable`
- **[P1]** `allergen/complete:/home/allergen/complete` — Raw Material Chip used instead of AppChip(tone: safe, emoji:) design-system component
  - POVs: ui-ux, flutter-arch  |  Confidence: 1.00  |  Category: `ad-hoc-component`
- **[P1]** `allergen/complete:/home/allergen/complete` — Raw FilledButton instead of AppPillButton brand CTA
  - POVs: ui-ux, flutter-arch  |  Confidence: 1.00  |  Category: `ad-hoc-component`
- **[P1]** `allergen/complete:/home/allergen/complete` — Error branch leaks raw exception toString — no friendly message, no retry
  - POVs: flutter-arch, qa-behavior, a11y  |  Confidence: 1.00  |  Category: `result-handling`
- **[P1]** `allergen/complete:/home/allergen/complete` — Sort + Analytics fired inside controller build(); analytics double-counts on invalidation
  - POVs: flutter-arch, qa-behavior  |  Confidence: 1.00  |  Category: `separation-of-concerns`
- **[P1]** `recipe/library:/home/recipe` — babyId error/null branches lack retry CTA and accessible recovery (also no pull-to-refresh action)
  - POVs: qa-behavior, a11y  |  Confidence: 1.00  |  Category: `state-coverage`
- **[P1]** `allergen/detail:/home/allergen/:allergenKey` — Add reaction button tap target is 32dp (below 48dp minimum)
  - POVs: a11y, ui-ux  |  Confidence: 1.00  |  Category: `tap-target`
- **[P1]** `AttachmentSheet` — Inline _FieldLabel duplicates AppTextField's built-in `label` parameter and diverges in style
  - POVs: ui-ux, flutter-arch  |  Confidence: 1.00  |  Category: `ad-hoc-component`
- **[P1]** `AttachmentSheet` — Title/Description fields missing textInputAction, focus chain, capitalization, and multiline config
  - POVs: flutter-arch, qa-behavior  |  Confidence: 1.00  |  Category: `textfield-behavior`

---

## Auto-Fixable Findings (241 total, conf >= 0.85, single-file)

These can be shipped as individual PRs without human design input.

| Sev | Screen | Title | Category | File |
|---|---|---|---|---|
| P0 | subscription/success | Phase transition not announced to screen readers (no liveReg | semantics | `lib/src/features/subscription/success/subscription_success_screen.dart` |
| P1 | onboarding/intro | Dot indicator has no semantics — invisible to screen readers | semantics | `lib/src/features/onboarding/intro/onboarding_intro_screen.dart` |
| P1 | onboarding/baby_setup | Raw FilledButton inline spinner used instead of AppPillButto | ad-hoc-component | `lib/src/features/onboarding/baby_setup/onboarding_baby_setup_screen.dart` |
| P1 | auth/register | Password obscure toggle missing semantic label and tap targe | semantics | `lib/src/features/auth/register/register_screen.dart` |
| P1 | auth/register | Decorative logo mark and Google 'G' badge not excluded from  | semantics | `lib/src/features/auth/register/register_screen.dart` |
| P1 | auth/reset_password | Missing textInputAction + focus chain between password and c | textfield-behavior | `lib/src/features/auth/reset_password/reset_password_screen.dart` |
| P1 | auth/login | Single errorMessage duplicated on BOTH email and password fi | ad-hoc-component | `lib/src/features/auth/login/login_screen.dart` |
| P1 | auth/login | Password visibility toggle replaced by misleading check icon | ad-hoc-component | `lib/src/features/auth/login/login_screen.dart` |
| P1 | auth/login | No 'Forgot password?' affordance on login screen — route exi | navigation | `lib/src/features/auth/login/login_screen.dart` |
| P1 | auth/login | Password visibility toggle has no semantic label and tap tar | semantics | `lib/src/features/auth/login/login_screen.dart` |
| P1 | starting_guide | ArticleCard diverges from Figma: should be cream-fill cards  | layout-drift | `lib/src/features/starting_guide/widgets/article_card.dart` |
| P1 | starting_guide | _Header reimplements AppHeader inline; should use AppHeader  | ad-hoc-component | `lib/src/features/starting_guide/starting_guide_hub_screen.dart` |
| P1 | subscription/paywall | Close button 34x33 tap target below 44pt/48dp accessibility  | tap-target | `lib/src/features/subscription/paywall/paywall_sheet.dart` |
| P1 | meal_plan/map | Allergen tag chip reimplemented inline in two duplicate _Tag | ad-hoc-component | `lib/src/features/meal_plan/map/widgets/picked_recipe_row.dart` |
| P1 | meal_plan/map | Back IconButton missing tooltip/semantic label | tooltip | `lib/src/features/meal_plan/map/map_meals_screen.dart` |
| P1 | shopping_list | _AddChip ('+') and _OverflowChip (more_horiz) have no semant | semantics | `lib/src/features/shopping_list/shopping_list_screen.dart` |
| P1 | shopping_list | _CancelChip per-row delete has no semantic label | semantics | `lib/src/features/shopping_list/shopping_list_screen.dart` |
| P1 | starting_guide | Custom _Header reimplements AppHeader with butter gradient i | ad-hoc-component | `lib/src/features/starting_guide/starting_guide_article_screen.dart` |
| P1 | starting_guide | GuideBackButton duplicates AppRoundButton small+ghost varian | missing-reusable | `lib/src/features/starting_guide/widgets/guide_back_button.dart` |
| P1 | home | Outer baby-id error has no retry CTA — user permanently stuc | state-coverage | `lib/src/features/home/home_screen.dart` |
| P1 | home | Header avatar tap is dead — onAvatarTap never wired to profi | navigation | `lib/src/features/home/home_screen.dart` |
| P1 | allergen/complete | Raw Material Chip used instead of AppChip(tone: safe, emoji: | ad-hoc-component | `lib/src/features/allergen/complete/allergen_complete_screen.dart` |
| P1 | allergen/complete | Raw FilledButton instead of AppPillButton brand CTA | ad-hoc-component | `lib/src/features/allergen/complete/allergen_complete_screen.dart` |
| P1 | allergen/complete | Error branch leaks raw exception toString — no friendly mess | result-handling | `lib/src/features/allergen/complete/allergen_complete_screen.dart` |
| P1 | recipe/library | babyId error/null branches lack retry CTA and accessible rec | state-coverage | `lib/src/features/recipe/library/recipe_library_screen.dart` |
| P1 | allergen/detail | Add reaction button tap target is 32dp (below 48dp minimum) | tap-target | `lib/src/features/allergen/detail/widgets/reaction_log_header.dart` |
| P1 | allergen/log_detail | Overflow menu IconButton missing tooltip / semantic label | tooltip | `lib/src/features/allergen/log_detail/allergen_log_detail_screen.dart` |
| P1 | allergen/log_detail | _FieldLabel duplicated across allergen log feature — missing | missing-reusable | `lib/src/features/allergen/log_detail/allergen_log_detail_screen.dart` |
| P1 | allergen/log | Back IconButton lacks tooltip/semantic label | tooltip | `lib/src/features/allergen/log/allergen_log_screen.dart` |
| P1 | BrowseMealSheet | Search input forks AppSearchField — wrong fill, missing focu | ad-hoc-component | `lib/src/features/meal_plan/sheets/widgets/recommendation_carousel_section.dart` |
| P1 | BrowseMealSheet | Sticky CTA forks FilledButton instead of AppPillButton + lac | ad-hoc-component | `lib/src/features/meal_plan/sheets/browse_meal_sheet.dart` |
| P1 | profile | Delete account sheet allows scrim/back dismissal during in-f | sheet-behavior | `lib/src/features/profile/delete/delete_account_overlay.dart` |
| P1 | AddToMealPlanSheet | Day accordion header lacks Semantics(button, expanded, label | semantics | `lib/src/features/recipe/detail/widgets/add_to_meal_plan_sheet.dart` |
| P1 | RangeAddToShoplistSheet | Custom _CheckboxIcon bypasses AppCheckbox and lacks Semantic | ad-hoc-component | `lib/src/features/meal_plan/widgets/range_add_to_shoplist_sheet.dart` |
| P1 | RangeAddToShoplistSheet | Bottom CTAs reimplement AppPillButton (and miss Parkinsans f | ad-hoc-component | `lib/src/features/meal_plan/widgets/range_add_to_shoplist_sheet.dart` |
| P1 | RangeAddToShoplistSheet | Close button: missing semantic label and tap target below 48 | semantics | `lib/src/features/meal_plan/widgets/range_add_to_shoplist_sheet.dart` |
| P1 | onboarding/baby_setup | Hardware/system back button bypasses controller.previousStep | navigation | `lib/src/features/onboarding/baby_setup/onboarding_baby_setup_screen.dart` |
| P1 | subscription/paywall | Restore success calls Navigator.pop with no canPop guard — s | navigation | `lib/src/features/subscription/paywall/paywall_sheet.dart` |
| P1 | subscription/paywall | Spinner-replaces-label leaves Restore and primary CTA button | semantics | `lib/src/features/subscription/paywall/paywall_sheet.dart` |
| P1 | recipe/library | CircularProgressIndicator instances missing semanticsLabel | semantics | `lib/src/features/recipe/library/recipe_library_screen.dart` |
| P1 | allergen/tracker | 'See All' GestureDetector lacks Semantics button role and la | semantics | `lib/src/features/allergen/tracker/allergen_tracker_screen.dart` |
| P1 | allergen/log_detail | _ReadOnlyField is an ad-hoc Container — should be a shared A | ad-hoc-component | `lib/src/features/allergen/log_detail/allergen_log_detail_screen.dart` |
| P1 | allergen/log_detail | _PhotoPreview duplicated between log_detail and attachment_s | missing-reusable | `lib/src/features/allergen/log_detail/allergen_log_detail_screen.dart` |
| P1 | profile/feedback | TextField has no accessibility label / semantic relationship | semantics | `lib/src/features/profile/feedback/feedback_screen.dart` |
| P1 | SelectPeriodDateSheet | Header missing explicit close (X) button — drag handle and c | layout-drift | `lib/src/features/meal_plan/sheets/select_period_date_sheet.dart` |
| P1 | AttachmentSheet | Photo picker InkWell + Image.file + add_a_photo icon lack se | semantics | `lib/src/features/allergen/log/widgets/attachment_sheet.dart` |
| P1 | BrowseMealSheet | Recipe cards missing Iron Rich + allergen-count chips per Fi | asset-placement | `lib/src/features/meal_plan/sheets/widgets/browse_meal_recipe_card.dart` |
| P1 | profile | Settings rows lack Semantics button role / hint | semantics | `lib/src/features/profile/widgets/settings_row.dart` |
| P1 | AddToMealPlanSheet | _DayChip is ad-hoc decoration; should reuse AppRoundButton | ad-hoc-component | `lib/src/features/recipe/detail/widgets/add_to_meal_plan_sheet.dart` |
| P1 | AddToMealPlanSheet | Decorative _DayChip icons leak into semantics ('more_horiz'  | semantics | `lib/src/features/recipe/detail/widgets/add_to_meal_plan_sheet.dart` |
| P1 | AddToShoppingListSheet | Remove (X) semantic label missing ingredient name | semantics | `lib/src/features/recipe/detail/widgets/add_to_shopping_list_sheet.dart` |
| P1 | AddToShoppingListModal | List rows use Material CheckboxListTile — missing cream pill | interaction | `lib/src/features/meal_plan/widgets/add_to_shopping_list_modal.dart` |
| P1 | AddToShoppingListModal | Footer is single FilledButton — should be 2-button row (outl | layout-drift | `lib/src/features/meal_plan/widgets/add_to_shopping_list_modal.dart` |
| P1 | AddToShoppingListModal | CheckboxListTile checkbox color/style instead of AppCheckbox | ad-hoc-component | `lib/src/features/meal_plan/widgets/add_to_shopping_list_modal.dart` |
| P1 | AddToShoppingListModal | Bulk add uses wrong source tag — calls addFromRecipe with em | result-handling | `lib/src/features/meal_plan/widgets/add_to_shopping_list_modal.dart` |
| P1 | onboarding/result | Sign-row check/cross icon state invisible to screen readers | semantics | `lib/src/features/onboarding/result/onboarding_result_screen.dart` |
| P1 | onboarding/readiness | ReadinessProgressBar has no semantic value or label | semantics | `lib/src/features/onboarding/readiness/widgets/readiness_progress_bar.dart` |
| P1 | auth/login | Submit button not disabled when form is invalid | form-submission | `lib/src/features/auth/login/login_screen.dart` |
| P1 | allergen/detail | Error fallback never shows controller's actual failure messa | result-handling | `lib/src/features/allergen/detail/allergen_detail_screen.dart` |
| P1 | allergen/log | hydrateForEdit throws StateError on missing log — bypasses R | result-handling | `lib/src/features/allergen/log/allergen_log_controller.dart` |
| P1 | recipe/detail | Error view traps user with no back navigation when recipe fe | navigation | `lib/src/features/recipe/detail/recipe_detail_screen.dart` |
| P1 | AddToShoppingListModal | Confirm CTA reimplemented as raw FilledButton instead of App | ad-hoc-component | `lib/src/features/meal_plan/widgets/add_to_shopping_list_modal.dart` |
| P1 | onboarding/consent | Back button + system back can race in-flight submit, causing | navigation | `lib/src/features/onboarding/consent/onboarding_consent_screen.dart` |
| P1 | onboarding/consent | Consent checkbox row lacks merged semantics — checkbox + lab | semantics | `lib/src/features/onboarding/consent/onboarding_consent_screen.dart` |
| P1 | onboarding/consent | Inline error not announced — missing live region for P1 erro | semantics | `lib/src/features/onboarding/consent/onboarding_consent_screen.dart` |
| P1 | onboarding/intro | Back button (visible+tappable) has no-op + no disabled state | form-submission | `lib/src/features/onboarding/intro/onboarding_intro_screen.dart` |
| P1 | onboarding/baby_setup | Back IconButton missing tooltip / semantic label | tooltip | `lib/src/features/onboarding/baby_setup/onboarding_baby_setup_screen.dart` |
| P1 | starting_guide | Error state lacks retry CTA and uses ad-hoc Padding+Text ins | missing-reusable | `lib/src/features/starting_guide/starting_guide_hub_screen.dart` |
| P1 | subscription/paywall | Decorative icons (mascot, feature thumbnails, 5 star_rounded | semantics | `lib/src/features/subscription/paywall/paywall_sheet.dart` |
| P1 | meal_plan/map | Commit CTA loses label and announces only 'disabled' while s | semantics | `lib/src/features/meal_plan/map/map_meals_screen.dart` |
| P1 | recipe/library | Error/empty text blocks lack liveRegion semantics and access | semantics | `lib/src/features/recipe/library/recipe_library_screen.dart` |
| P1 | profile/feedback | Loading/Success caption not announced as live region — scree | semantics | `lib/src/features/profile/feedback/feedback_screen.dart` |
| P1 | recipe/detail | Success banner not announced to screen readers (no liveRegio | semantics | `lib/src/features/recipe/detail/widgets/add_to_meal_plan_cta.dart` |
| P1 | BrowseMealSheet | Master list rendered as flat divider rows instead of stacked | layout-drift | `lib/src/features/meal_plan/sheets/widgets/browse_meal_recipe_card.dart` |
| P1 | BrowseMealSheet | Sheet drag-dismiss / close X silently discards selections —  | sheet-behavior | `lib/src/features/meal_plan/sheets/browse_meal_sheet.dart` |
| P1 | profile | Edit button has no Semantics label / button role | semantics | `lib/src/features/profile/widgets/profile_avatar_card.dart` |
| P1 | meal_plan | babyId error/empty branches have no Retry CTA or recovery pa | state-coverage | `lib/src/features/meal_plan/meal_plan_screen.dart` |
| P1 | allergen/log_detail | Notes field truncates to single line — content hidden + brea | density | `lib/src/features/allergen/log_detail/allergen_log_detail_screen.dart` |
| P1 | allergen/log | Reaction toggle hit-test broken — IgnorePointer wraps AppSwi | ad-hoc-component | `lib/src/features/allergen/log/allergen_log_screen.dart` |
| P1 | onboarding/readiness | Step changes not announced as live region (a11y) | semantics | `lib/src/features/onboarding/readiness/onboarding_readiness_screen.dart` |

*...and 161 more. See journal for full list.*

---

## Methodology

- 5 POVs run per screen: UI/UX designer, Senior Flutter engineer, QA auditor, Accessibility, Assets
- Static code analysis + Figma .figma-audit/ comparison (no sim render)
- Auto-fix gate: confidence >= 0.85 AND severity P1/P2 AND single-file scope AND not page-vs-sheet AND not separation-of-concerns
- Source: workflow wf_927fed90-040, run 2026-06-01, 42 screens, 1346 triaged findings from 3485 raw POV findings