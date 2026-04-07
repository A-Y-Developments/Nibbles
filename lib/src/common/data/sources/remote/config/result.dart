import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';

part 'result.freezed.dart';

@freezed
sealed class Result<T> with _$Result<T> {
  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(AppException error) = Failure<T>;
}

extension ResultX<T> on Result<T> {
  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get dataOrNull => switch (this) {
    Success(:final data) => data,
    Failure() => null,
  };

  AppException? get errorOrNull => switch (this) {
    Success() => null,
    Failure(:final error) => error,
  };

  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(AppException error) onFailure,
  }) => switch (this) {
    Success(:final data) => onSuccess(data),
    Failure(:final error) => onFailure(error),
  };

  Result<R> map<R>(R Function(T data) transform) => switch (this) {
    Success(:final data) => Result.success(transform(data)),
    Failure(:final error) => Result.failure(error),
  };
}
