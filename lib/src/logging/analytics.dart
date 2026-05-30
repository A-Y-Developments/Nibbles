import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'analytics.g.dart';

/// Provider for the [Analytics] wrapper. Defaults to the real singleton; tests
/// override it with a fake recorder to assert calls without touching Firebase.
@Riverpod(keepAlive: true)
// Specific *Ref types are deprecated; will be Ref in riverpod_generator 3.0.
// ignore: deprecated_member_use_from_same_package
Analytics analytics(AnalyticsRef ref) => Analytics.instance;

/// Auth methods surfaced in analytics events. Mirrors the values listed in
/// NIB-118: 'email', 'google', 'apple'.
enum AuthMethod {
  email,
  google,
  apple;

  String get value => name;
}

/// Social providers surfaced in `social_login_cancelled`. Distinct from
/// [AuthMethod] because email is never a "social" provider.
enum SocialProvider {
  google,
  apple;

  String get value => name;
}

/// Maps an [AppException] subtype to a stable, non-PII analytics error code.
///
/// Codes are derived from the exception TYPE only — the raw message (which can
/// contain Supabase or provider strings) is never used. Keep the set small and
/// stable so downstream dashboards stay consistent.
String authErrorCode(AppException error) => switch (error) {
  NetworkException() => 'network',
  ServerException() => 'server_exception',
  UnauthorizedException() => 'unauthorized',
  NotFoundException() => 'not_found',
  UnknownException() => 'unknown',
};

/// Thin wrapper around [FirebaseAnalytics] that enforces no-PII policy.
///
/// Rules:
/// - Never log user IDs, email addresses, names, or any PII.
/// - Event names must be snake_case and <= 40 characters.
/// - Parameter values must be non-PII primitives (String, num, bool).
class Analytics {
  Analytics._();

  static final Analytics instance = Analytics._();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  Future<void> logAppOpen() async {
    await _analytics.logAppOpen();
  }

  // ---------------------------------------------------------------------------
  // Onboarding
  // ---------------------------------------------------------------------------

  Future<void> logOnboardingStarted() async {
    await _logEvent('onboarding_started');
  }

  Future<void> logOnboardingCompleted() async {
    await _logEvent('onboarding_completed');
  }

  Future<void> logOnboardingStepViewed({required int step}) async {
    await _logEvent('onboarding_step_viewed', parameters: {'step': step});
  }

  // ---------------------------------------------------------------------------
  // Auth — login
  // ---------------------------------------------------------------------------

  Future<void> logLoginMethodSelected({required AuthMethod method}) async {
    await _logEvent(
      'login_method_selected',
      parameters: {'method': method.value},
    );
  }

  Future<void> logLoginSuccess({required AuthMethod method}) async {
    await _logEvent('login_success', parameters: {'method': method.value});
  }

  Future<void> logLoginFailure({
    required AuthMethod method,
    required String errorCode,
  }) async {
    await _logEvent(
      'login_failure',
      parameters: {'method': method.value, 'error_code': errorCode},
    );
  }

  // ---------------------------------------------------------------------------
  // Auth — sign up
  // ---------------------------------------------------------------------------

  Future<void> logSignUpMethodSelected({required AuthMethod method}) async {
    await _logEvent(
      'sign_up_method_selected',
      parameters: {'method': method.value},
    );
  }

  Future<void> logSignUpSuccess({required AuthMethod method}) async {
    await _logEvent('sign_up_success', parameters: {'method': method.value});
  }

  Future<void> logSignUpFailure({
    required AuthMethod method,
    required String errorCode,
  }) async {
    await _logEvent(
      'sign_up_failure',
      parameters: {'method': method.value, 'error_code': errorCode},
    );
  }

  // ---------------------------------------------------------------------------
  // Auth — password reset + social cancel + logout
  // ---------------------------------------------------------------------------

  Future<void> logPasswordResetRequested() async {
    await _logEvent('password_reset_requested');
  }

  Future<void> logSocialLoginCancelled({
    required SocialProvider provider,
  }) async {
    await _logEvent(
      'social_login_cancelled',
      parameters: {'provider': provider.value},
    );
  }

  Future<void> logLogout() async {
    await _logEvent('logout');
  }

  // ---------------------------------------------------------------------------
  // Subscription
  // ---------------------------------------------------------------------------

  Future<void> logPaywallViewed() async {
    await _logEvent('paywall_viewed');
  }

  Future<void> logSubscriptionStarted({required String productId}) async {
    await _logEvent(
      'subscription_started',
      parameters: {'product_id': productId},
    );
  }

  Future<void> logSubscriptionRestored() async {
    await _logEvent('subscription_restored');
  }

  // ---------------------------------------------------------------------------
  // Allergen tracker
  // ---------------------------------------------------------------------------

  Future<void> logAllergenLogCreated({
    required String allergenKey,
    bool hasAttachment = false,
  }) async {
    await _logEvent(
      'allergen_log_created',
      parameters: {
        'allergen_key': allergenKey,
        'has_attachment': hasAttachment,
      },
    );
  }

  Future<void> logAllergenLogEdited({
    required String allergenKey,
    required bool hasAttachment,
  }) async {
    await _logEvent(
      'allergen_log_edited',
      parameters: {
        'allergen_key': allergenKey,
        'has_attachment': hasAttachment,
      },
    );
  }

  Future<void> logAllergenLogDeleted({required String allergenKey}) async {
    await _logEvent(
      'allergen_log_deleted',
      parameters: {'allergen_key': allergenKey},
    );
  }

  Future<void> logAllergenStartIntroduce({required String allergenKey}) async {
    await _logEvent(
      'allergen_start_introduce',
      parameters: {'allergen_key': allergenKey},
    );
  }

  Future<void> logAllergenSegmentChanged({required String segment}) async {
    await _logEvent(
      'allergen_segment_changed',
      parameters: {'segment': segment},
    );
  }

  Future<void> logAllergenMarkedSafe({required String allergenKey}) async {
    await _logEvent(
      'allergen_marked_safe',
      parameters: {'allergen_key': allergenKey},
    );
  }

  Future<void> logReactionLogged({
    required String allergenKey,
    required String severity,
  }) async {
    await _logEvent(
      'reaction_logged',
      parameters: {'allergen_key': allergenKey, 'severity': severity},
    );
  }

  Future<void> logAllergenAdvanced({
    required String fromKey,
    required String toKey,
  }) async {
    await _logEvent(
      'allergen_advanced',
      parameters: {'from_key': fromKey, 'to_key': toKey},
    );
  }

  Future<void> logAllergenProgramCompleted() async {
    await _logEvent('allergen_program_completed');
  }

  // ---------------------------------------------------------------------------
  // Recipe
  // ---------------------------------------------------------------------------

  Future<void> logRecipeViewed({required String recipeId}) async {
    await _logEvent('recipe_viewed', parameters: {'recipe_id': recipeId});
  }

  Future<void> logRecipeAddedToMealPlan({required String recipeId}) async {
    await _logEvent(
      'recipe_added_to_meal_plan',
      parameters: {'recipe_id': recipeId},
    );
  }

  // ---------------------------------------------------------------------------
  // Meal Plan (NIB-109) — non-PII only: recipe IDs, ISO date strings, counts.
  // ---------------------------------------------------------------------------

  Future<void> logMealPlanViewed({required int dayCount}) async {
    await _logEvent('meal_plan_viewed', parameters: {'day_count': dayCount});
  }

  Future<void> logMealPlanDayExpanded({required String dayOffsetIso}) async {
    await _logEvent(
      'meal_plan_day_expanded',
      parameters: {'day_offset_iso': dayOffsetIso},
    );
  }

  Future<void> logMealPlanDayCollapsed({required String dayOffsetIso}) async {
    await _logEvent(
      'meal_plan_day_collapsed',
      parameters: {'day_offset_iso': dayOffsetIso},
    );
  }

  Future<void> logMealPlanAddDateTapped() async {
    await _logEvent('meal_plan_add_date_tapped');
  }

  Future<void> logMealPlanRecipeAssigned({
    required String recipeId,
    required String dayOffsetIso,
  }) async {
    await _logEvent(
      'meal_plan_recipe_assigned',
      parameters: {'recipe_id': recipeId, 'day_offset_iso': dayOffsetIso},
    );
  }

  Future<void> logMealPlanRecipeRemoved({required String recipeId}) async {
    await _logEvent(
      'meal_plan_recipe_removed',
      parameters: {'recipe_id': recipeId},
    );
  }

  Future<void> logMealPrepCreateStarted() async {
    await _logEvent('meal_prep_create_started');
  }

  Future<void> logMealPrepRangeSelected({required int days}) async {
    await _logEvent('meal_prep_range_selected', parameters: {'days': days});
  }

  Future<void> logMealPrepBrowseSelected({required String recipeId}) async {
    await _logEvent(
      'meal_prep_browse_selected',
      parameters: {'recipe_id': recipeId},
    );
  }

  Future<void> logMealPrepBrowseDeselected({required String recipeId}) async {
    await _logEvent(
      'meal_prep_browse_deselected',
      parameters: {'recipe_id': recipeId},
    );
  }

  Future<void> logMealPrepMappingAssigned({
    required String recipeId,
    required String dayOffsetIso,
  }) async {
    await _logEvent(
      'meal_prep_mapping_assigned',
      parameters: {'recipe_id': recipeId, 'day_offset_iso': dayOffsetIso},
    );
  }

  Future<void> logMealPrepCommitted({
    required int recipeCount,
    required int dayCount,
  }) async {
    await _logEvent(
      'meal_prep_committed',
      parameters: {'recipe_count': recipeCount, 'day_count': dayCount},
    );
  }

  Future<void> logMealPlanClearWeekConfirmed({required int dayCount}) async {
    await _logEvent(
      'meal_plan_clear_week_confirmed',
      parameters: {'day_count': dayCount},
    );
  }

  Future<void> logMealPlanAddToShopList({required int dayCount}) async {
    await _logEvent(
      'meal_plan_add_to_shop_list',
      parameters: {'day_count': dayCount},
    );
  }

  // ---------------------------------------------------------------------------
  // Screen tracking
  // ---------------------------------------------------------------------------

  Future<void> logScreenView({required String screenName}) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  // ---------------------------------------------------------------------------
  // Private
  // ---------------------------------------------------------------------------

  Future<void> _logEvent(String name, {Map<String, Object>? parameters}) async {
    await _analytics.logEvent(name: name, parameters: parameters);
  }
}
