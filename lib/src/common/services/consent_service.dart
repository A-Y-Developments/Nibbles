import 'package:nibbles/src/common/data/repositories/consent_repository.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/enums/consent_type.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'consent_service.g.dart';

/// Thin facade over [ConsentRepository] (NIB-145). The DB receipt insert is
/// a passthrough today; the service exists to keep the controller agnostic of
/// the repository per CLAUDE.md (Controller -> Service -> Repository).
class ConsentService {
  const ConsentService(this._repo);

  final ConsentRepository _repo;

  Future<Result<void>> recordConsent({
    required String babyId,
    required ConsentType type,
  }) => _repo.recordConsent(babyId: babyId, type: type);
}

@Riverpod(keepAlive: true)
// Specific *Ref types are deprecated; will be Ref in riverpod_generator 3.0.
// ignore: deprecated_member_use_from_same_package
ConsentService consentService(ConsentServiceRef ref) =>
    ConsentService(ref.watch(consentRepositoryProvider));
