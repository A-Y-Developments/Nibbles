import 'package:supabase_flutter/supabase_flutter.dart';

/// In-memory PKCE storage so [Supabase.initialize] does not reach for
/// SharedPreferences (which needs a platform channel) under the test runner.
class _InMemoryGotrueAsyncStorage extends GotrueAsyncStorage {
  final Map<String, String> _store = {};

  @override
  Future<String?> getItem({required String key}) async => _store[key];

  @override
  Future<void> setItem({required String key, required String value}) async {
    _store[key] = value;
  }

  @override
  Future<void> removeItem({required String key}) async {
    _store.remove(key);
  }
}

bool _initialized = false;

/// Boots a no-persistence Supabase singleton for widget tests whose screens
/// read `Supabase.instance` directly (e.g. reset-password's session check).
///
/// [EmptyLocalStorage] disables session persistence, so `currentSession` is
/// always `null` — no network is touched. Safe to call multiple times per
/// isolate; only the first call initializes.
Future<void> ensureTestSupabaseInitialized() async {
  if (_initialized) return;
  _initialized = true;
  await Supabase.initialize(
    url: 'http://localhost:54321',
    anonKey: 'test-anon-key',
    authOptions: FlutterAuthClientOptions(
      localStorage: const EmptyLocalStorage(),
      pkceAsyncStorage: _InMemoryGotrueAsyncStorage(),
      autoRefreshToken: false,
    ),
  );
}
