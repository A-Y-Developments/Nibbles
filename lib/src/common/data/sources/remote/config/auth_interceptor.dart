import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Injects the Bearer JWT on every outgoing request.
/// On a 401 response: refreshes the Supabase session once and retries.
/// On a second 401: signs out and rethrows [DioException] with 401 status.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({SupabaseClient? supabaseClient})
    : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  // Tracks requests currently being retried to prevent infinite loops.
  final Set<String> _retrying = {};

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = _supabase.auth.currentSession?.accessToken;
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
      await _supabase.auth.signOut();
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
        await _supabase.auth.signOut();
        handler.next(err);
        return;
      }

      // Retry the original request with the refreshed token.
      final dio = Dio();
      options.headers['Authorization'] = 'Bearer $newToken';

      final retryResponse = await dio.fetch<dynamic>(options);
      _retrying.remove(requestKey);
      handler.resolve(retryResponse);
    } on AuthException {
      _retrying.remove(requestKey);
      await _supabase.auth.signOut();
      handler.next(err);
    } on Object {
      _retrying.remove(requestKey);
      await _supabase.auth.signOut();
      handler.next(err);
    }
  }
}
