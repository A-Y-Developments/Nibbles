import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nibbles/src/app/themes/app_colors.dart';
import 'package:nibbles/src/app/themes/app_sizes.dart';
import 'package:nibbles/src/app/themes/app_typography.dart';
import 'package:nibbles/src/common/components/components.dart';
import 'package:nibbles/src/features/legal/constants/legal_document.dart';
import 'package:nibbles/src/logging/analytics.dart';

/// Full-screen reader for a [LegalDocument], routed by slug.
///
/// Follows the Starting Guide article shape (cream header + scrolling typed
/// block list) because these are long-form read-only documents with the same
/// navigation affordances. An unknown slug renders a not-found fallback rather
/// than crashing — protects against a malformed deeplink.
class LegalDocumentScreen extends StatefulWidget {
  const LegalDocumentScreen({required this.slug, super.key});

  final String slug;

  @override
  State<LegalDocumentScreen> createState() => _LegalDocumentScreenState();
}

class _LegalDocumentScreenState extends State<LegalDocumentScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(
        Analytics.instance.logScreenView(screenName: 'legal_${widget.slug}'),
      );
    });
  }

  void _onBack() {
    if (context.canPop()) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final document = legalDocumentForSlug(widget.slug);

    return GradientScaffold(
      body: document == null
          ? _NotFound(onBack: _onBack)
          : _DocumentBody(document: document, onBack: _onBack),
    );
  }
}

class _DocumentBody extends StatelessWidget {
  const _DocumentBody({required this.document, required this.onBack});

  final LegalDocument document;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: SafeArea(
            bottom: false,
            child: AppHeader(
              title: document.title,
              wash: AppHeaderWash.cream,
              leading: AppRoundButton(
                key: const Key('legal_document_back'),
                icon: const Icon(Icons.arrow_back_rounded),
                tone: AppRoundButtonTone.ghost,
                size: AppRoundButtonSize.small,
                semanticLabel: 'Back',
                onPressed: onBack,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.pagePaddingH,
            AppSizes.md,
            AppSizes.pagePaddingH,
            AppSizes.xl,
          ),
          sliver: SliverList.separated(
            itemCount: document.blocks.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSizes.md),
            itemBuilder: (context, index) =>
                _buildBlock(document.blocks[index]),
          ),
        ),
      ],
    );
  }
}

Widget _buildBlock(LegalBlock block) {
  switch (block) {
    case LegalHeading():
      return Padding(
        padding: const EdgeInsets.only(top: AppSizes.sm),
        child: Text(
          block.text,
          style: AppTypography.textTheme.titleMedium?.copyWith(
            color: AppColors.fgStrong,
          ),
        ),
      );
    case LegalParagraph():
      return Text(
        block.text,
        style: AppTypography.textTheme.bodyLarge?.copyWith(
          color: AppColors.fgDefault,
        ),
      );
    case LegalBullets():
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final item in block.items)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.sm),
              child: _Bullet(item),
            ),
        ],
      );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final style = AppTypography.textTheme.bodyLarge?.copyWith(
      color: AppColors.fgDefault,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSizes.sm, right: AppSizes.sm),
          child: Text('•', style: style),
        ),
        Expanded(child: Text(text, style: style)),
      ],
    );
  }
}

class _NotFound extends StatelessWidget {
  const _NotFound({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppRoundButton(
              key: const Key('legal_document_back'),
              icon: const Icon(Icons.arrow_back_rounded),
              tone: AppRoundButtonTone.ghost,
              size: AppRoundButtonSize.small,
              semanticLabel: 'Back',
              onPressed: onBack,
            ),
            const SizedBox(height: AppSizes.lg),
            const Text(
              'Document not found',
              style: AppTypography.emptyStateTitle,
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              "We couldn't find that document.",
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.fgMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
