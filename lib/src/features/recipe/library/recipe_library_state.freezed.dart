// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recipe_library_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$RecipeLibraryState {
  List<RecipeSection> get sections => throw _privateConstructorUsedError;

  /// Create a copy of RecipeLibraryState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecipeLibraryStateCopyWith<RecipeLibraryState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecipeLibraryStateCopyWith<$Res> {
  factory $RecipeLibraryStateCopyWith(
    RecipeLibraryState value,
    $Res Function(RecipeLibraryState) then,
  ) = _$RecipeLibraryStateCopyWithImpl<$Res, RecipeLibraryState>;
  @useResult
  $Res call({List<RecipeSection> sections});
}

/// @nodoc
class _$RecipeLibraryStateCopyWithImpl<$Res, $Val extends RecipeLibraryState>
    implements $RecipeLibraryStateCopyWith<$Res> {
  _$RecipeLibraryStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecipeLibraryState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? sections = null}) {
    return _then(
      _value.copyWith(
            sections: null == sections
                ? _value.sections
                : sections // ignore: cast_nullable_to_non_nullable
                      as List<RecipeSection>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RecipeLibraryStateImplCopyWith<$Res>
    implements $RecipeLibraryStateCopyWith<$Res> {
  factory _$$RecipeLibraryStateImplCopyWith(
    _$RecipeLibraryStateImpl value,
    $Res Function(_$RecipeLibraryStateImpl) then,
  ) = __$$RecipeLibraryStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<RecipeSection> sections});
}

/// @nodoc
class __$$RecipeLibraryStateImplCopyWithImpl<$Res>
    extends _$RecipeLibraryStateCopyWithImpl<$Res, _$RecipeLibraryStateImpl>
    implements _$$RecipeLibraryStateImplCopyWith<$Res> {
  __$$RecipeLibraryStateImplCopyWithImpl(
    _$RecipeLibraryStateImpl _value,
    $Res Function(_$RecipeLibraryStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RecipeLibraryState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? sections = null}) {
    return _then(
      _$RecipeLibraryStateImpl(
        sections: null == sections
            ? _value._sections
            : sections // ignore: cast_nullable_to_non_nullable
                  as List<RecipeSection>,
      ),
    );
  }
}

/// @nodoc

class _$RecipeLibraryStateImpl implements _RecipeLibraryState {
  const _$RecipeLibraryStateImpl({required final List<RecipeSection> sections})
    : _sections = sections;

  final List<RecipeSection> _sections;
  @override
  List<RecipeSection> get sections {
    if (_sections is EqualUnmodifiableListView) return _sections;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sections);
  }

  @override
  String toString() {
    return 'RecipeLibraryState(sections: $sections)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecipeLibraryStateImpl &&
            const DeepCollectionEquality().equals(other._sections, _sections));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_sections));

  /// Create a copy of RecipeLibraryState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecipeLibraryStateImplCopyWith<_$RecipeLibraryStateImpl> get copyWith =>
      __$$RecipeLibraryStateImplCopyWithImpl<_$RecipeLibraryStateImpl>(
        this,
        _$identity,
      );
}

abstract class _RecipeLibraryState implements RecipeLibraryState {
  const factory _RecipeLibraryState({
    required final List<RecipeSection> sections,
  }) = _$RecipeLibraryStateImpl;

  @override
  List<RecipeSection> get sections;

  /// Create a copy of RecipeLibraryState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecipeLibraryStateImplCopyWith<_$RecipeLibraryStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$RecipeSection {
  String get title => throw _privateConstructorUsedError;
  List<Recipe> get recipes => throw _privateConstructorUsedError;

  /// Create a copy of RecipeSection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecipeSectionCopyWith<RecipeSection> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecipeSectionCopyWith<$Res> {
  factory $RecipeSectionCopyWith(
    RecipeSection value,
    $Res Function(RecipeSection) then,
  ) = _$RecipeSectionCopyWithImpl<$Res, RecipeSection>;
  @useResult
  $Res call({String title, List<Recipe> recipes});
}

/// @nodoc
class _$RecipeSectionCopyWithImpl<$Res, $Val extends RecipeSection>
    implements $RecipeSectionCopyWith<$Res> {
  _$RecipeSectionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecipeSection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? title = null, Object? recipes = null}) {
    return _then(
      _value.copyWith(
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            recipes: null == recipes
                ? _value.recipes
                : recipes // ignore: cast_nullable_to_non_nullable
                      as List<Recipe>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RecipeSectionImplCopyWith<$Res>
    implements $RecipeSectionCopyWith<$Res> {
  factory _$$RecipeSectionImplCopyWith(
    _$RecipeSectionImpl value,
    $Res Function(_$RecipeSectionImpl) then,
  ) = __$$RecipeSectionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String title, List<Recipe> recipes});
}

/// @nodoc
class __$$RecipeSectionImplCopyWithImpl<$Res>
    extends _$RecipeSectionCopyWithImpl<$Res, _$RecipeSectionImpl>
    implements _$$RecipeSectionImplCopyWith<$Res> {
  __$$RecipeSectionImplCopyWithImpl(
    _$RecipeSectionImpl _value,
    $Res Function(_$RecipeSectionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RecipeSection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? title = null, Object? recipes = null}) {
    return _then(
      _$RecipeSectionImpl(
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        recipes: null == recipes
            ? _value._recipes
            : recipes // ignore: cast_nullable_to_non_nullable
                  as List<Recipe>,
      ),
    );
  }
}

/// @nodoc

class _$RecipeSectionImpl implements _RecipeSection {
  const _$RecipeSectionImpl({
    required this.title,
    required final List<Recipe> recipes,
  }) : _recipes = recipes;

  @override
  final String title;
  final List<Recipe> _recipes;
  @override
  List<Recipe> get recipes {
    if (_recipes is EqualUnmodifiableListView) return _recipes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recipes);
  }

  @override
  String toString() {
    return 'RecipeSection(title: $title, recipes: $recipes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecipeSectionImpl &&
            (identical(other.title, title) || other.title == title) &&
            const DeepCollectionEquality().equals(other._recipes, _recipes));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    title,
    const DeepCollectionEquality().hash(_recipes),
  );

  /// Create a copy of RecipeSection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecipeSectionImplCopyWith<_$RecipeSectionImpl> get copyWith =>
      __$$RecipeSectionImplCopyWithImpl<_$RecipeSectionImpl>(this, _$identity);
}

abstract class _RecipeSection implements RecipeSection {
  const factory _RecipeSection({
    required final String title,
    required final List<Recipe> recipes,
  }) = _$RecipeSectionImpl;

  @override
  String get title;
  @override
  List<Recipe> get recipes;

  /// Create a copy of RecipeSection
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecipeSectionImplCopyWith<_$RecipeSectionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
