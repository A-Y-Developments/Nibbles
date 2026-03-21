import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_service.g.dart';

/// Stub AuthService — will be wired in NIB-13.
/// Returns false by default; redirect logic sends users to login.
@riverpod
class AuthService extends _$AuthService {
  @override
  bool build() => false;

  // Riverpod state assignment requires a method body —
  // setter syntax is not valid here.
  // ignore: use_setters_to_change_properties
  void setLoggedIn({required bool value}) => state = value;
}
