import 'package:nibbles/src/logging/analytics.dart';

/// In-memory recorder used by auth controller tests. Replaces the real
/// [Analytics] singleton (which would otherwise hit
/// `FirebaseAnalytics.instance` and throw when Firebase is uninitialised in
/// the test harness).
///
/// Each `log*` call appends a `(name, params)` tuple to [calls]. Tests assert
/// against [calls] / [eventNames] to verify the controller fired the right
/// event at the right state transition.
class FakeAnalytics implements Analytics {
  /// Every recorded call, in the order it fired.
  final List<RecordedEvent> calls = [];

  /// Convenience: just the event names, in order.
  List<String> get eventNames => calls.map((c) => c.name).toList();

  void _record(String name, [Map<String, Object>? params]) {
    calls.add(RecordedEvent(name, params ?? const {}));
  }

  @override
  Future<void> logAppOpen() async => _record('app_open');

  @override
  Future<void> logOnboardingStarted() async => _record('onboarding_started');

  @override
  Future<void> logOnboardingCompleted() async =>
      _record('onboarding_completed');

  @override
  Future<void> logOnboardingStepViewed({required int step}) async =>
      _record('onboarding_step_viewed', {'step': step});

  @override
  Future<void> logLoginMethodSelected({required AuthMethod method}) async =>
      _record('login_method_selected', {'method': method.value});

  @override
  Future<void> logLoginSuccess({required AuthMethod method}) async =>
      _record('login_success', {'method': method.value});

  @override
  Future<void> logLoginFailure({
    required AuthMethod method,
    required String errorCode,
  }) async => _record('login_failure', {
    'method': method.value,
    'error_code': errorCode,
  });

  @override
  Future<void> logSignUpMethodSelected({required AuthMethod method}) async =>
      _record('sign_up_method_selected', {'method': method.value});

  @override
  Future<void> logSignUpSuccess({required AuthMethod method}) async =>
      _record('sign_up_success', {'method': method.value});

  @override
  Future<void> logSignUpFailure({
    required AuthMethod method,
    required String errorCode,
  }) async => _record('sign_up_failure', {
    'method': method.value,
    'error_code': errorCode,
  });

  @override
  Future<void> logPasswordResetRequested() async =>
      _record('password_reset_requested');

  @override
  Future<void> logSocialLoginCancelled({
    required SocialProvider provider,
  }) async => _record('social_login_cancelled', {'provider': provider.value});

  @override
  Future<void> logLogout() async => _record('logout');

  @override
  Future<void> logPaywallViewed() async => _record('paywall_viewed');

  @override
  Future<void> logSubscriptionStarted({required String productId}) async =>
      _record('subscription_started', {'product_id': productId});

  @override
  Future<void> logSubscriptionRestored() async =>
      _record('subscription_restored');

  @override
  Future<void> logAllergenLogCreated({
    required String allergenKey,
    bool hasAttachment = false,
  }) async => _record('allergen_log_created', {
    'allergen_key': allergenKey,
    'has_attachment': hasAttachment,
  });

  @override
  Future<void> logAllergenLogEdited({
    required String allergenKey,
    required bool hasAttachment,
  }) async => _record('allergen_log_edited', {
    'allergen_key': allergenKey,
    'has_attachment': hasAttachment,
  });

  @override
  Future<void> logAllergenLogDeleted({required String allergenKey}) async =>
      _record('allergen_log_deleted', {'allergen_key': allergenKey});

  @override
  Future<void> logAllergenStartIntroduce({required String allergenKey}) async =>
      _record('allergen_start_introduce', {'allergen_key': allergenKey});

  @override
  Future<void> logAllergenSegmentChanged({required String segment}) async =>
      _record('allergen_segment_changed', {'segment': segment});

  @override
  Future<void> logAllergenMarkedSafe({required String allergenKey}) async =>
      _record('allergen_marked_safe', {'allergen_key': allergenKey});

  @override
  Future<void> logReactionLogged({
    required String allergenKey,
    required String severity,
  }) async => _record('reaction_logged', {
    'allergen_key': allergenKey,
    'severity': severity,
  });

  @override
  Future<void> logAllergenAdvanced({
    required String fromKey,
    required String toKey,
  }) async => _record('allergen_advanced', {
    'from_key': fromKey,
    'to_key': toKey,
  });

  @override
  Future<void> logAllergenProgramCompleted() async =>
      _record('allergen_program_completed');

  @override
  Future<void> logRecipeViewed({required String recipeId}) async =>
      _record('recipe_viewed', {'recipe_id': recipeId});

  @override
  Future<void> logRecipeAddedToMealPlan({
    required String recipeId,
    int dayCount = 1,
  }) async => _record('recipe_added_to_meal_plan', {
    'recipe_id': recipeId,
    'day_count': dayCount,
  });

  @override
  Future<void> logRecipeAddedToShoppingList({
    required String recipeId,
    required int itemCount,
  }) async => _record('recipe_added_to_shopping_list', {
    'recipe_id': recipeId,
    'item_count': itemCount,
  });

  @override
  Future<void> logRecipeSearch({int? queryLength}) async => _record(
    'recipe_search',
    {if (queryLength != null) 'query_length': queryLength},
  );

  @override
  Future<void> logStartingGuideOpened({required String source}) async =>
      _record('starting_guide_opened', {'source': source});

  @override
  Future<void> logStartingGuideArticleViewed({required String slug}) async =>
      _record('starting_guide_article_viewed', {'slug': slug});

  @override
  Future<void> logMealPlanViewed({required int dayCount}) async =>
      _record('meal_plan_viewed', {'day_count': dayCount});

  @override
  Future<void> logMealPlanDayExpanded({required String dayOffsetIso}) async =>
      _record('meal_plan_day_expanded', {'day_offset_iso': dayOffsetIso});

  @override
  Future<void> logMealPlanDayCollapsed({required String dayOffsetIso}) async =>
      _record('meal_plan_day_collapsed', {'day_offset_iso': dayOffsetIso});

  @override
  Future<void> logMealPlanAddDateTapped() async =>
      _record('meal_plan_add_date_tapped');

  @override
  Future<void> logMealPlanRecipeAssigned({
    required String recipeId,
    required String dayOffsetIso,
  }) async => _record('meal_plan_recipe_assigned', {
    'recipe_id': recipeId,
    'day_offset_iso': dayOffsetIso,
  });

  @override
  Future<void> logMealPlanRecipeRemoved({required String recipeId}) async =>
      _record('meal_plan_recipe_removed', {'recipe_id': recipeId});

  @override
  Future<void> logMealPrepCreateStarted() async =>
      _record('meal_prep_create_started');

  @override
  Future<void> logMealPrepRangeSelected({required int days}) async =>
      _record('meal_prep_range_selected', {'days': days});

  @override
  Future<void> logMealPrepBrowseSelected({required String recipeId}) async =>
      _record('meal_prep_browse_selected', {'recipe_id': recipeId});

  @override
  Future<void> logMealPrepBrowseDeselected({required String recipeId}) async =>
      _record('meal_prep_browse_deselected', {'recipe_id': recipeId});

  @override
  Future<void> logMealPrepMappingAssigned({
    required String recipeId,
    required String dayOffsetIso,
  }) async => _record('meal_prep_mapping_assigned', {
    'recipe_id': recipeId,
    'day_offset_iso': dayOffsetIso,
  });

  @override
  Future<void> logMealPrepCommitted({
    required int recipeCount,
    required int dayCount,
  }) async => _record('meal_prep_committed', {
    'recipe_count': recipeCount,
    'day_count': dayCount,
  });

  @override
  Future<void> logMealPlanClearWeekConfirmed({required int dayCount}) async =>
      _record('meal_plan_clear_week_confirmed', {'day_count': dayCount});

  @override
  Future<void> logMealPlanAddToShopList({required int dayCount}) async =>
      _record('meal_plan_add_to_shop_list', {'day_count': dayCount});

  @override
  Future<void> logScreenView({required String screenName}) async =>
      _record('screen_view', {'screen_name': screenName});
}

/// A single recorded analytics call.
class RecordedEvent {
  RecordedEvent(this.name, this.parameters);

  final String name;
  final Map<String, Object> parameters;

  @override
  String toString() => 'RecordedEvent($name, $parameters)';
}
