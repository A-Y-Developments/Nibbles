import 'package:nibbles/src/common/data/repositories/feedback_repository.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'feedback_service.g.dart';

/// Thin facade over [FeedbackRepository]. The feedback feature is a
/// straight passthrough today; the service exists to keep the controller
/// agnostic of the repository and to match the project's
/// Controller -> Service -> Repository pattern.
class FeedbackService {
  const FeedbackService(this._repo);

  final FeedbackRepository _repo;

  Future<Result<void>> submit(String message) => _repo.submit(message);
}

@Riverpod(keepAlive: true)
// Specific *Ref types are deprecated; will be Ref in riverpod_generator 3.0.
// ignore: deprecated_member_use_from_same_package
FeedbackService feedbackService(FeedbackServiceRef ref) =>
    FeedbackService(ref.watch(feedbackRepositoryProvider));
