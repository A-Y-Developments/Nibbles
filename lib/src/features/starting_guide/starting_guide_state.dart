import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nibbles/src/features/starting_guide/constants/articles.dart';

part 'starting_guide_state.freezed.dart';

/// State for the Starting Guide hub.
///
/// [articles] is the full ordered article list. Content is hardcoded today
/// (see [kStartingGuideArticles]) but the controller stays AsyncNotifier-shaped
/// to match the project's controller pattern and so a future migration to a
/// remote/CMS-backed source slots in without changing screens.
@freezed
class StartingGuideState with _$StartingGuideState {
  const factory StartingGuideState({
    @Default(<GuideArticle>[]) List<GuideArticle> articles,
  }) = _StartingGuideState;
}
