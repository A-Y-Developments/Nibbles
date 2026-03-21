import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Key used to store / retrieve the JWT in [FlutterSecureStorage].
const _kJwtKey = 'jwt_token';

/// Injects the Bearer JWT on every outgoing request.
/// On a 401 response: refreshes the Supabase session once and retries.
/// On a second 401: signs out and rethrows [DioException] with 401 status.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    FlutterSecureStorage? storage,
    SupabaseClient? supabaseClient,
  })  : _storage = storage ?? const FlutterSecureStorage(),
        _supabase = supabaseClient ?? Supabase.instance.client;

  final FlutterSecureStorage _storage;
  final SupabaseClient _supabase;

  // Tracks requests currently being retried to prevent infinite loops.
  final Set<String> _retrying = {};

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: _kJwtKey);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final response = err.response;
    final options = err.requestOptions;

    if (response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    final requestKey = '${options.method}:${options.path}';

    // Second 401 on a retry → sign out and propagate error.
    if (_retrying.contains(requestKey)) {
      _retrying.remove(requestKey);
      await _signOut();
      handler.next(err);
      return;
    }

    _retrying.add(requestKey);

    try {
      // Attempt to refresh the Supabase session.
      final refreshResponse = await _supabase.auth.refreshSession();
      final newToken = refreshResponse.session?.accessToken;

      if (newToken == null) {
        _retrying.remove(requestKey);
        await _signOut();
        handler.next(err);
        return;
      }

      // Persist the new JWT.
      await _storage.write(key: _kJwtKey, value: newToken);

      // Retry the original request with the refreshed token.
      final dio = Dio();
      options.headers['Authorization'] = 'Bearer $newToken';

      final retryResponse = await dio.fetch<dynamic>(options);
      _retrying.remove(requestKey);
      handler.resolve(retryResponse);
    } on AuthException {
      _retrying.remove(requestKey);
      await _signOut();
      handler.next(err);
    } on Object {
      _retrying.remove(requestKey);
      await _signOut();
      handler.next(err);
    }
  }

  Future<void> _signOut() async {
    await _storage.delete(key: _kJwtKey);
    await _supabase.auth.signOut();
  }
}
