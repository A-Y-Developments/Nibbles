import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nibbles/src/features/starting_guide/constants/articles.dart';
import 'package:nibbles/src/features/starting_guide/starting_guide_controller.dart';

void main() {
  group('StartingGuideController.build', () {
    test('resolves to kStartingGuideArticles', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = await container.read(
        startingGuideControllerProvider.future,
      );

      expect(state.articles, kStartingGuideArticles);
    });
  });

  group('StartingGuideController.articleFor', () {
    test('returns matching article when state is loaded', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await container.read(startingGuideControllerProvider.future);

      final controller = container.read(
        startingGuideControllerProvider.notifier,
      );
      final article = controller.articleFor('introduction');

      expect(article, isNotNull);
      expect(article!.slug, 'introduction');
    });

    test('returns null for unknown slug when state is loaded', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await container.read(startingGuideControllerProvider.future);

      final controller = container.read(
        startingGuideControllerProvider.notifier,
      );

      expect(controller.articleFor('unknown-slug'), isNull);
    });

    test('falls back to findArticleBySlug when state is not yet loaded', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final controller = container.read(
        startingGuideControllerProvider.notifier,
      );
      final article = controller.articleFor('first-nibbles');

      expect(article, isNotNull);
      expect(article!.slug, 'first-nibbles');
    });
  });
}
