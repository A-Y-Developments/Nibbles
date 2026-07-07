import 'package:flutter/material.dart';
import 'package:nibbles/src/app/themes/app_gradients.dart';

enum GradientBackgroundVariant { standard, moreWhite }

class GradientScaffold extends StatelessWidget {
  const GradientScaffold({
    required this.body,
    super.key,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.resizeToAvoidBottomInset,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.variant = GradientBackgroundVariant.moreWhite,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool? resizeToAvoidBottomInset;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final GradientBackgroundVariant variant;

  @override
  Widget build(BuildContext context) {
    final gradient = switch (variant) {
      GradientBackgroundVariant.standard => AppGradients.background,
      GradientBackgroundVariant.moreWhite => AppGradients.backgroundMoreWhite,
    };
    return DecoratedBox(
      decoration: BoxDecoration(gradient: gradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: appBar,
        body: body,
        bottomNavigationBar: bottomNavigationBar,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        extendBody: extendBody,
        extendBodyBehindAppBar: extendBodyBehindAppBar,
      ),
    );
  }
}
