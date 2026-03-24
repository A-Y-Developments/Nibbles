import 'package:dio/dio.dart';
import 'package:nibbles/src/app/config/flavor_config.dart';
import 'package:nibbles/src/common/data/sources/remote/config/auth_interceptor.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dio_client.g.dart';

/// Creates and configures the app-wide [Dio] instance.
///
/// Base URL is sourced from [FlavorConfig.supabaseUrl].
/// [AuthInterceptor] is always added.
/// [LogInterceptor] is added only in dev flavor to avoid log noise in prod.
Dio createDio(FlavorConfig config) {
  final dio = Dio(
    BaseOptions(
      baseUrl: config.supabaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    ),
  );

  dio.interceptors.add(AuthInterceptor());

  if (config.isDev) {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        // ignore: avoid_print — dev-only logging, intentional
        logPrint: print,
      ),
    );
  }

  return dio;
}

@Riverpod(keepAlive: true)
// ignore: deprecated_member_use_from_same_package // *Ref types deprecated in riverpod 3.0; upgrade deferred
Dio dio(DioRef ref) {
  return createDio(FlavorConfig.instance);
}
