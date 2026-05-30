// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'starting_guide_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$StartingGuideState {
  List<GuideArticle> get articles => throw _privateConstructorUsedError;

  /// Create a copy of StartingGuideState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StartingGuideStateCopyWith<StartingGuideState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StartingGuideStateCopyWith<$Res> {
  factory $StartingGuideStateCopyWith(
    StartingGuideState value,
    $Res Function(StartingGuideState) then,
  ) = _$StartingGuideStateCopyWithImpl<$Res, StartingGuideState>;
  @useResult
  $Res call({List<GuideArticle> articles});
}

/// @nodoc
class _$StartingGuideStateCopyWithImpl<$Res, $Val extends StartingGuideState>
    implements $StartingGuideStateCopyWith<$Res> {
  _$StartingGuideStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StartingGuideState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? articles = null}) {
    return _then(
      _value.copyWith(
            articles: null == articles
                ? _value.articles
                : articles // ignore: cast_nullable_to_non_nullable
                      as List<GuideArticle>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StartingGuideStateImplCopyWith<$Res>
    implements $StartingGuideStateCopyWith<$Res> {
  factory _$$StartingGuideStateImplCopyWith(
    _$StartingGuideStateImpl value,
    $Res Function(_$StartingGuideStateImpl) then,
  ) = __$$StartingGuideStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<GuideArticle> articles});
}

/// @nodoc
class __$$StartingGuideStateImplCopyWithImpl<$Res>
    extends _$StartingGuideStateCopyWithImpl<$Res, _$StartingGuideStateImpl>
    implements _$$StartingGuideStateImplCopyWith<$Res> {
  __$$StartingGuideStateImplCopyWithImpl(
    _$StartingGuideStateImpl _value,
    $Res Function(_$StartingGuideStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StartingGuideState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? articles = null}) {
    return _then(
      _$StartingGuideStateImpl(
        articles: null == articles
            ? _value._articles
            : articles // ignore: cast_nullable_to_non_nullable
                  as List<GuideArticle>,
      ),
    );
  }
}

/// @nodoc

class _$StartingGuideStateImpl implements _StartingGuideState {
  const _$StartingGuideStateImpl({
    final List<GuideArticle> articles = const <GuideArticle>[],
  }) : _articles = articles;

  final List<GuideArticle> _articles;
  @override
  @JsonKey()
  List<GuideArticle> get articles {
    if (_articles is EqualUnmodifiableListView) return _articles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_articles);
  }

  @override
  String toString() {
    return 'StartingGuideState(articles: $articles)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StartingGuideStateImpl &&
            const DeepCollectionEquality().equals(other._articles, _articles));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_articles));

  /// Create a copy of StartingGuideState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StartingGuideStateImplCopyWith<_$StartingGuideStateImpl> get copyWith =>
      __$$StartingGuideStateImplCopyWithImpl<_$StartingGuideStateImpl>(
        this,
        _$identity,
      );
}

abstract class _StartingGuideState implements StartingGuideState {
  const factory _StartingGuideState({final List<GuideArticle> articles}) =
      _$StartingGuideStateImpl;

  @override
  List<GuideArticle> get articles;

  /// Create a copy of StartingGuideState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StartingGuideStateImplCopyWith<_$StartingGuideStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
