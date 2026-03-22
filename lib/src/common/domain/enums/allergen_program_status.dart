enum AllergenProgramStatus { inProgress, completed, flagged }

extension AllergenProgramStatusX on AllergenProgramStatus {
  String toJson() => switch (this) {
        AllergenProgramStatus.inProgress => 'in_progress',
        AllergenProgramStatus.completed => 'completed',
        AllergenProgramStatus.flagged => 'flagged',
      };

  static AllergenProgramStatus fromJson(String value) => switch (value) {
        'in_progress' => AllergenProgramStatus.inProgress,
        'completed' => AllergenProgramStatus.completed,
        'flagged' => AllergenProgramStatus.flagged,
        _ => AllergenProgramStatus.inProgress,
      };
}
