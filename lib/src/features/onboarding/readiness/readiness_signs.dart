/// Canonical readiness sign labels — one per readiness question. Row 0 is the
/// Q1 pediatrician gate; rows 1-5 are the Q2-Q6 developmental signs. Order
/// matches the questionnaire so any result view reflects all six questions.
///
/// Single source of truth shared by the onboarding result screen and the
/// 5 Sign Readiness guide page so their copy never drifts.
const List<String> kReadinessSignLabels = [
  'Pediatrician approved starting solids',
  'Good head and neck control (can hold head steady)',
  'Sits upright with minimal support',
  "Loss of the tongue-thrust reflex (doesn't automatically push food out).",
  'Shows interest in food (watching, reaching, opening mouth).',
  'Can bring objects to their mouth.',
];

/// Ready only when every readiness sign is met (all six).
const int kReadinessReadyThreshold = 6;
