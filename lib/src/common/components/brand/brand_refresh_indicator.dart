import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:nibbles/src/common/components/brand/brand_flower_loader.dart';

/// Pull-to-refresh that shows the rotating brand flower instead of the stock
/// Material spinner. Drop-in for [RefreshIndicator] — same `{onRefresh, child}`
/// API — so call sites swap one for the other.
///
/// The flower scales in as the user drags and the content slides down to make
/// room; the flower self-rotates (via [BrandFlowerLoader.small]) while active,
/// so drag-refresh matches the app's idle loaders. It is only mounted while the
/// indicator is non-idle, so its looping animation never keeps the scheduler
/// busy at rest.
///
/// [topOffset] pushes the flower down by that many logical pixels. Full-bleed
/// screens that scroll behind the status bar (e.g. Home, which uses
/// `SafeArea(top: false)`) pass the top inset so the flower clears the notch
/// instead of rendering behind it. Headered screens leave it at 0.
class BrandRefreshIndicator extends StatelessWidget {
  const BrandRefreshIndicator({
    required this.onRefresh,
    required this.child,
    this.topOffset = 0,
    super.key,
  });

  final Future<void> Function() onRefresh;
  final Widget child;
  final double topOffset;

  static const double _indicatorExtent = 76;
  static const double _flowerSize = 56;

  @override
  Widget build(BuildContext context) {
    return CustomRefreshIndicator(
      onRefresh: onRefresh,
      builder: (context, child, controller) {
        return AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final progress = controller.value.clamp(0.0, 1.0);
            return Stack(
              children: [
                if (!controller.isIdle)
                  Padding(
                    padding: EdgeInsets.only(top: topOffset),
                    child: SizedBox(
                      height: _indicatorExtent,
                      width: double.infinity,
                      child: Center(
                        child: Transform.scale(
                          scale: progress,
                          child: Opacity(
                            opacity: progress,
                            child: const BrandFlowerLoader.small(
                              size: _flowerSize,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                Transform.translate(
                  offset: Offset(0, _indicatorExtent * progress),
                  child: child,
                ),
              ],
            );
          },
        );
      },
      child: child,
    );
  }
}
