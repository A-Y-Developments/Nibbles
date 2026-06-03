// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onboarding_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$OnboardingState {
  BabyNameInput get babyName => throw _privateConstructorUsedError;
  DateTime? get dob =>
      throw _privateConstructorUsedError; // NIB-83 Q1 gate. Null = not answered yet, true = pediatrician approved,
  // false = unsure. Not counted toward `signs_met` — see the result screen.
  bool? get pediatricianApproved =>
      throw _privateConstructorUsedError; // Seeded as a length-5 nullable list so the readiness screen can index
  // safely on first build; kept in sync with [readinessQuestionCount].
  List<bool?> get readinessAnswers => throw _privateConstructorUsedError;
  bool get isSubmitting => throw _privateConstructorUsedError;
  String? get submitErrorMessage => throw _privateConstructorUsedError;

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OnboardingStateCopyWith<OnboardingState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OnboardingStateCopyWith<$Res> {
  factory $OnboardingStateCopyWith(
    OnboardingState value,
    $Res Function(OnboardingState) then,
  ) = _$OnboardingStateCopyWithImpl<$Res, OnboardingState>;
  @useResult
  $Res call({
    BabyNameInput babyName,
    DateTime? dob,
    bool? pediatricianApproved,
    List<bool?> readinessAnswers,
    bool isSubmitting,
    String? submitErrorMessage,
  });
}

/// @nodoc
class _$OnboardingStateCopyWithImpl<$Res, $Val extends OnboardingState>
    implements $OnboardingStateCopyWith<$Res> {
  _$OnboardingStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? babyName = null,
    Object? dob = freezed,
    Object? pediatricianApproved = freezed,
    Object? readinessAnswers = null,
    Object? isSubmitting = null,
    Object? submitErrorMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            babyName: null == babyName
                ? _value.babyName
                : babyName // ignore: cast_nullable_to_non_nullable
                      as BabyNameInput,
            dob: freezed == dob
                ? _value.dob
                : dob // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            pediatricianApproved: freezed == pediatricianApproved
                ? _value.pediatricianApproved
                : pediatricianApproved // ignore: cast_nullable_to_non_nullable
                      as bool?,
            readinessAnswers: null == readinessAnswers
                ? _value.readinessAnswers
                : readinessAnswers // ignore: cast_nullable_to_non_nullable
                      as List<bool?>,
            isSubmitting: null == isSubmitting
                ? _value.isSubmitting
                : isSubmitting // ignore: cast_nullable_to_non_nullable
                      as bool,
            submitErrorMessage: freezed == submitErrorMessage
                ? _value.submitErrorMessage
                : submitErrorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OnboardingStateImplCopyWith<$Res>
    implements $OnboardingStateCopyWith<$Res> {
  factory _$$OnboardingStateImplCopyWith(
    _$OnboardingStateImpl value,
    $Res Function(_$OnboardingStateImpl) then,
  ) = __$$OnboardingStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    BabyNameInput babyName,
    DateTime? dob,
    bool? pediatricianApproved,
    List<bool?> readinessAnswers,
    bool isSubmitting,
    String? submitErrorMessage,
  });
}

/// @nodoc
class __$$OnboardingStateImplCopyWithImpl<$Res>
    extends _$OnboardingStateCopyWithImpl<$Res, _$OnboardingStateImpl>
    implements _$$OnboardingStateImplCopyWith<$Res> {
  __$$OnboardingStateImplCopyWithImpl(
    _$OnboardingStateImpl _value,
    $Res Function(_$OnboardingStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? babyName = null,
    Object? dob = freezed,
    Object? pediatricianApproved = freezed,
    Object? readinessAnswers = null,
    Object? isSubmitting = null,
    Object? submitErrorMessage = freezed,
  }) {
    return _then(
      _$OnboardingStateImpl(
        babyName: null == babyName
            ? _value.babyName
            : babyName // ignore: cast_nullable_to_non_nullable
                  as BabyNameInput,
        dob: freezed == dob
            ? _value.dob
            : dob // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        pediatricianApproved: freezed == pediatricianApproved
            ? _value.pediatricianApproved
            : pediatricianApproved // ignore: cast_nullable_to_non_nullable
                  as bool?,
        readinessAnswers: null == readinessAnswers
            ? _value._readinessAnswers
            : readinessAnswers // ignore: cast_nullable_to_non_nullable
                  as List<bool?>,
        isSubmitting: null == isSubmitting
            ? _value.isSubmitting
            : isSubmitting // ignore: cast_nullable_to_non_nullable
                  as bool,
        submitErrorMessage: freezed == submitErrorMessage
            ? _value.submitErrorMessage
            : submitErrorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$OnboardingStateImpl implements _OnboardingState {
  const _$OnboardingStateImpl({
    this.babyName = const BabyNameInput.pure(),
    this.dob,
    this.pediatricianApproved,
    final List<bool?> readinessAnswers = const <bool?>[
      null,
      null,
      null,
      null,
      null,
    ],
    this.isSubmitting = false,
    this.submitErrorMessage,
  }) : _readinessAnswers = readinessAnswers;

  @override
  @JsonKey()
  final BabyNameInput babyName;
  @override
  final DateTime? dob;
  // NIB-83 Q1 gate. Null = not answered yet, true = pediatrician approved,
  // false = unsure. Not counted toward `signs_met` — see the result screen.
  @override
  final bool? pediatricianApproved;
  // Seeded as a length-5 nullable list so the readiness screen can index
  // safely on first build; kept in sync with [readinessQuestionCount].
  final List<bool?> _readinessAnswers;
  // Seeded as a length-5 nullable list so the readiness screen can index
  // safely on first build; kept in sync with [readinessQuestionCount].
  @override
  @JsonKey()
  List<bool?> get readinessAnswers {
    if (_readinessAnswers is EqualUnmodifiableListView)
      return _readinessAnswers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_readinessAnswers);
  }

  @override
  @JsonKey()
  final bool isSubmitting;
  @override
  final String? submitErrorMessage;

  @override
  String toString() {
    return 'OnboardingState(babyName: $babyName, dob: $dob, pediatricianApproved: $pediatricianApproved, readinessAnswers: $readinessAnswers, isSubmitting: $isSubmitting, submitErrorMessage: $submitErrorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OnboardingStateImpl &&
            (identical(other.babyName, babyName) ||
                other.babyName == babyName) &&
            (identical(other.dob, dob) || other.dob == dob) &&
            (identical(other.pediatricianApproved, pediatricianApproved) ||
                other.pediatricianApproved == pediatricianApproved) &&
            const DeepCollectionEquality().equals(
              other._readinessAnswers,
              _readinessAnswers,
            ) &&
            (identical(other.isSubmitting, isSubmitting) ||
                other.isSubmitting == isSubmitting) &&
            (identical(other.submitErrorMessage, submitErrorMessage) ||
                other.submitErrorMessage == submitErrorMessage));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    babyName,
    dob,
    pediatricianApproved,
    const DeepCollectionEquality().hash(_readinessAnswers),
    isSubmitting,
    submitErrorMessage,
  );

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OnboardingStateImplCopyWith<_$OnboardingStateImpl> get copyWith =>
      __$$OnboardingStateImplCopyWithImpl<_$OnboardingStateImpl>(
        this,
        _$identity,
      );
}

abstract class _OnboardingState implements OnboardingState {
  const factory _OnboardingState({
    final BabyNameInput babyName,
    final DateTime? dob,
    final bool? pediatricianApproved,
    final List<bool?> readinessAnswers,
    final bool isSubmitting,
    final String? submitErrorMessage,
  }) = _$OnboardingStateImpl;

  @override
  BabyNameInput get babyName;
  @override
  DateTime? get dob; // NIB-83 Q1 gate. Null = not answered yet, true = pediatrician approved,
  // false = unsure. Not counted toward `signs_met` — see the result screen.
  @override
  bool? get pediatricianApproved; // Seeded as a length-5 nullable list so the readiness screen can index
  // safely on first build; kept in sync with [readinessQuestionCount].
  @override
  List<bool?> get readinessAnswers;
  @override
  bool get isSubmitting;
  @override
  String? get submitErrorMessage;

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OnboardingStateImplCopyWith<_$OnboardingStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
