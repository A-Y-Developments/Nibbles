import 'package:flutter/material.dart';

/// Placeholder for NIB-96 (full empty state — no baby OR zero activity).
/// Wave 2 will replace.
class HomeEmptyStateFull extends StatelessWidget {
  const HomeEmptyStateFull({this.babyName, super.key});

  final String? babyName;

  @override
  Widget build(BuildContext context) {
    // TODO(NIB-96): implement full empty state per redesign.
    return const SizedBox.shrink();
  }
}
