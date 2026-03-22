enum ReactionSeverity { mild, moderate, severe }

extension ReactionSeverityX on ReactionSeverity {
  String toJson() => switch (this) {
        ReactionSeverity.mild => 'mild',
        ReactionSeverity.moderate => 'moderate',
        ReactionSeverity.severe => 'severe',
      };

  static ReactionSeverity fromJson(String value) => switch (value) {
        'mild' => ReactionSeverity.mild,
        'moderate' => ReactionSeverity.moderate,
        'severe' => ReactionSeverity.severe,
        _ => ReactionSeverity.mild,
      };
}
