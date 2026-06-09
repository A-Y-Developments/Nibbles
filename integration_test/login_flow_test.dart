import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nibbles/src/app/config/flavor_config.dart';
import 'package:nibbles/src/app/runner.dart';
import 'package:nibbles/src/common/components/components.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 30),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 250));
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('Timed out after $timeout waiting for $finder');
}

Future<void> seedOnboardingFlags() async {
  await Hive.initFlutter();
  final flags = await Hive.openBox<dynamic>('local_flags');
  await flags.putAll(<String, dynamic>{
    'app_has_launched': true,
    'onboarding_readiness_done': true,
    'onboarding_baby_setup_done': true,
    'onboarding_done': true,
  });
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('login with seeded test account reaches home', (tester) async {
    await seedOnboardingFlags();
    await bootstrap(flavor: Flavor.dev);

    final auth = Supabase.instance.client.auth;
    if (auth.currentSession != null) {
      await auth.signOut();
    }

    final email = dotenv.env['TEST_ACCOUNT_EMAIL'];
    final password = dotenv.env['TEST_ACCOUNT_PASSWORD'];
    expect(
      email,
      isNotNull,
      reason: 'TEST_ACCOUNT_EMAIL missing from .env.dev',
    );
    expect(
      password,
      isNotNull,
      reason: 'TEST_ACCOUNT_PASSWORD missing from .env.dev',
    );

    final emailField = find.byKey(const Key('login_email_field'));
    await pumpUntilFound(tester, emailField);

    await tester.enterText(emailField, email!);
    await tester.pump();
    await tester.enterText(
      find.byKey(const Key('login_password_field')),
      password!,
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('login_submit_button')));

    await pumpUntilFound(
      tester,
      find.byType(AppBottomNav),
      timeout: const Duration(seconds: 45),
    );

    expect(auth.currentSession, isNotNull);
    expect(auth.currentUser?.email, email);
  });
}
