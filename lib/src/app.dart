import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nibbles/src/app/themes/app_theme.dart';
import 'package:nibbles/src/routing/routes.dart';
import 'package:toastification/toastification.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return ToastificationWrapper(
      child: MaterialApp.router(
        title: 'Nibbles',
        theme: AppTheme.light(),
        routerConfig: router,
        builder: (context, child) {
          // Figma type sizes read a touch large on real devices; trim the
          // global text scale ~10% while still honouring the device
          // accessibility setting proportionally (clamped so very large
          // settings can't break layouts).
          final mq = MediaQuery.of(context);
          final scaled = (mq.textScaler.scale(1) * 0.9).clamp(0.7, 1.3);
          return MediaQuery(
            data: mq.copyWith(textScaler: TextScaler.linear(scaled)),
            child: GestureDetector(
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              behavior: HitTestBehavior.translucent,
              child: child,
            ),
          );
        },
      ),
    );
  }
}
