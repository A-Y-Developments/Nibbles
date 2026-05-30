import 'package:nibbles/src/features/starting_guide/constants/articles.dart';
import 'package:nibbles/src/features/starting_guide/starting_guide_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'starting_guide_controller.g.dart';

/// AsyncNotifier for the Starting Guide hub.
///
/// Returns the hardcoded [kStartingGuideArticles] list. Async-shaped so the
/// screens treat the data the same way they would a future remote source.
@riverpod
class StartingGuideController extends _$StartingGuideController {
  @override
  Future<StartingGuideState> build() async {
    return const StartingGuideState(articles: kStartingGuideArticles);
  }

  /// Looks up an article by [slug]. Returns `null` if no article matches.
  GuideArticle? articleFor(String slug) {
    final current = state.valueOrNull;
    if (current == null) return findArticleBySlug(slug);
    for (final article in current.articles) {
      if (article.slug == slug) return article;
    }
    return null;
  }
}
