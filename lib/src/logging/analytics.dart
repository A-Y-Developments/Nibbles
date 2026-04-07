import 'package:firebase_analytics/firebase_analytics.dart';

/// Thin wrapper around [FirebaseAnalytics] that enforces no-PII policy.
///
/// Rules:
/// - Never log user IDs, email addresses, names, or any PII.
/// - Event names must be snake_case and <= 40 characters.
/// - Parameter values must be non-PII primitives (String, num, bool).
final class Analytics {
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
  // Auth
  // ---------------------------------------------------------------------------

  Future<void> logSignUp() async {
    await _analytics.logSignUp(signUpMethod: 'email');
  }

  Future<void> logLogin() async {
    await _analytics.logLogin(loginMethod: 'email');
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

  Future<void> logAllergenLogCreated({required String allergenKey}) async {
    await _logEvent(
      'allergen_log_created',
      parameters: {'allergen_key': allergenKey},
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
