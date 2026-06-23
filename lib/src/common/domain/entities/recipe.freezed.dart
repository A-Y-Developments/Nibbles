// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recipe.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Recipe _$RecipeFromJson(Map<String, dynamic> json) {
  return _Recipe.fromJson(json);
}

/// @nodoc
mixin _$Recipe {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get ageRange => throw _privateConstructorUsedError;
  List<String> get allergenTags => throw _privateConstructorUsedError;
  List<Ingredient> get ingredients => throw _privateConstructorUsedError;
  List<String> get steps => throw _privateConstructorUsedError;
  String get howToServe => throw _privateConstructorUsedError;
  String? get makes => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get thumbnailUrl => throw _privateConstructorUsedError;
  List<String> get nutritionTags => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  List<String>? get utensils => throw _privateConstructorUsedError;
  String? get storageNote => throw _privateConstructorUsedError;
  String? get freezerNote => throw _privateConstructorUsedError;
  String? get textureTip => throw _privateConstructorUsedError;
  String? get whyThisMeal => throw _privateConstructorUsedError;

  /// Serializes this Recipe to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Recipe
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecipeCopyWith<Recipe> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecipeCopyWith<$Res> {
  factory $RecipeCopyWith(Recipe value, $Res Function(Recipe) then) =
      _$RecipeCopyWithImpl<$Res, Recipe>;
  @useResult
  $Res call({
    String id,
    String title,
    String ageRange,
    List<String> allergenTags,
    List<Ingredient> ingredients,
    List<String> steps,
    String howToServe,
    String? makes,
    String? notes,
    String? thumbnailUrl,
    List<String> nutritionTags,
    String? category,
    List<String>? utensils,
    String? storageNote,
    String? freezerNote,
    String? textureTip,
    String? whyThisMeal,
  });
}

/// @nodoc
class _$RecipeCopyWithImpl<$Res, $Val extends Recipe>
    implements $RecipeCopyWith<$Res> {
  _$RecipeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Recipe
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? ageRange = null,
    Object? allergenTags = null,
    Object? ingredients = null,
    Object? steps = null,
    Object? howToServe = null,
    Object? makes = freezed,
    Object? notes = freezed,
    Object? thumbnailUrl = freezed,
    Object? nutritionTags = null,
    Object? category = freezed,
    Object? utensils = freezed,
    Object? storageNote = freezed,
    Object? freezerNote = freezed,
    Object? textureTip = freezed,
    Object? whyThisMeal = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            ageRange: null == ageRange
                ? _value.ageRange
                : ageRange // ignore: cast_nullable_to_non_nullable
                      as String,
            allergenTags: null == allergenTags
                ? _value.allergenTags
                : allergenTags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            ingredients: null == ingredients
                ? _value.ingredients
                : ingredients // ignore: cast_nullable_to_non_nullable
                      as List<Ingredient>,
            steps: null == steps
                ? _value.steps
                : steps // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            howToServe: null == howToServe
                ? _value.howToServe
                : howToServe // ignore: cast_nullable_to_non_nullable
                      as String,
            makes: freezed == makes
                ? _value.makes
                : makes // ignore: cast_nullable_to_non_nullable
                      as String?,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            thumbnailUrl: freezed == thumbnailUrl
                ? _value.thumbnailUrl
                : thumbnailUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            nutritionTags: null == nutritionTags
                ? _value.nutritionTags
                : nutritionTags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            category: freezed == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String?,
            utensils: freezed == utensils
                ? _value.utensils
                : utensils // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            storageNote: freezed == storageNote
                ? _value.storageNote
                : storageNote // ignore: cast_nullable_to_non_nullable
                      as String?,
            freezerNote: freezed == freezerNote
                ? _value.freezerNote
                : freezerNote // ignore: cast_nullable_to_non_nullable
                      as String?,
            textureTip: freezed == textureTip
                ? _value.textureTip
                : textureTip // ignore: cast_nullable_to_non_nullable
                      as String?,
            whyThisMeal: freezed == whyThisMeal
                ? _value.whyThisMeal
                : whyThisMeal // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RecipeImplCopyWith<$Res> implements $RecipeCopyWith<$Res> {
  factory _$$RecipeImplCopyWith(
    _$RecipeImpl value,
    $Res Function(_$RecipeImpl) then,
  ) = __$$RecipeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String ageRange,
    List<String> allergenTags,
    List<Ingredient> ingredients,
    List<String> steps,
    String howToServe,
    String? makes,
    String? notes,
    String? thumbnailUrl,
    List<String> nutritionTags,
    String? category,
    List<String>? utensils,
    String? storageNote,
    String? freezerNote,
    String? textureTip,
    String? whyThisMeal,
  });
}

/// @nodoc
class __$$RecipeImplCopyWithImpl<$Res>
    extends _$RecipeCopyWithImpl<$Res, _$RecipeImpl>
    implements _$$RecipeImplCopyWith<$Res> {
  __$$RecipeImplCopyWithImpl(
    _$RecipeImpl _value,
    $Res Function(_$RecipeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Recipe
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? ageRange = null,
    Object? allergenTags = null,
    Object? ingredients = null,
    Object? steps = null,
    Object? howToServe = null,
    Object? makes = freezed,
    Object? notes = freezed,
    Object? thumbnailUrl = freezed,
    Object? nutritionTags = null,
    Object? category = freezed,
    Object? utensils = freezed,
    Object? storageNote = freezed,
    Object? freezerNote = freezed,
    Object? textureTip = freezed,
    Object? whyThisMeal = freezed,
  }) {
    return _then(
      _$RecipeImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        ageRange: null == ageRange
            ? _value.ageRange
            : ageRange // ignore: cast_nullable_to_non_nullable
                  as String,
        allergenTags: null == allergenTags
            ? _value._allergenTags
            : allergenTags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        ingredients: null == ingredients
            ? _value._ingredients
            : ingredients // ignore: cast_nullable_to_non_nullable
                  as List<Ingredient>,
        steps: null == steps
            ? _value._steps
            : steps // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        howToServe: null == howToServe
            ? _value.howToServe
            : howToServe // ignore: cast_nullable_to_non_nullable
                  as String,
        makes: freezed == makes
            ? _value.makes
            : makes // ignore: cast_nullable_to_non_nullable
                  as String?,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        thumbnailUrl: freezed == thumbnailUrl
            ? _value.thumbnailUrl
            : thumbnailUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        nutritionTags: null == nutritionTags
            ? _value._nutritionTags
            : nutritionTags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        category: freezed == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String?,
        utensils: freezed == utensils
            ? _value._utensils
            : utensils // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        storageNote: freezed == storageNote
            ? _value.storageNote
            : storageNote // ignore: cast_nullable_to_non_nullable
                  as String?,
        freezerNote: freezed == freezerNote
            ? _value.freezerNote
            : freezerNote // ignore: cast_nullable_to_non_nullable
                  as String?,
        textureTip: freezed == textureTip
            ? _value.textureTip
            : textureTip // ignore: cast_nullable_to_non_nullable
                  as String?,
        whyThisMeal: freezed == whyThisMeal
            ? _value.whyThisMeal
            : whyThisMeal // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RecipeImpl implements _Recipe {
  const _$RecipeImpl({
    required this.id,
    required this.title,
    required this.ageRange,
    required final List<String> allergenTags,
    required final List<Ingredient> ingredients,
    required final List<String> steps,
    required this.howToServe,
    this.makes,
    this.notes,
    this.thumbnailUrl,
    final List<String> nutritionTags = const <String>[],
    this.category,
    final List<String>? utensils,
    this.storageNote,
    this.freezerNote,
    this.textureTip,
    this.whyThisMeal,
  }) : _allergenTags = allergenTags,
       _ingredients = ingredients,
       _steps = steps,
       _nutritionTags = nutritionTags,
       _utensils = utensils;

  factory _$RecipeImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecipeImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String ageRange;
  final List<String> _allergenTags;
  @override
  List<String> get allergenTags {
    if (_allergenTags is EqualUnmodifiableListView) return _allergenTags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_allergenTags);
  }

  final List<Ingredient> _ingredients;
  @override
  List<Ingredient> get ingredients {
    if (_ingredients is EqualUnmodifiableListView) return _ingredients;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_ingredients);
  }

  final List<String> _steps;
  @override
  List<String> get steps {
    if (_steps is EqualUnmodifiableListView) return _steps;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_steps);
  }

  @override
  final String howToServe;
  @override
  final String? makes;
  @override
  final String? notes;
  @override
  final String? thumbnailUrl;
  final List<String> _nutritionTags;
  @override
  @JsonKey()
  List<String> get nutritionTags {
    if (_nutritionTags is EqualUnmodifiableListView) return _nutritionTags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_nutritionTags);
  }

  @override
  final String? category;
  final List<String>? _utensils;
  @override
  List<String>? get utensils {
    final value = _utensils;
    if (value == null) return null;
    if (_utensils is EqualUnmodifiableListView) return _utensils;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? storageNote;
  @override
  final String? freezerNote;
  @override
  final String? textureTip;
  @override
  final String? whyThisMeal;

  @override
  String toString() {
    return 'Recipe(id: $id, title: $title, ageRange: $ageRange, allergenTags: $allergenTags, ingredients: $ingredients, steps: $steps, howToServe: $howToServe, makes: $makes, notes: $notes, thumbnailUrl: $thumbnailUrl, nutritionTags: $nutritionTags, category: $category, utensils: $utensils, storageNote: $storageNote, freezerNote: $freezerNote, textureTip: $textureTip, whyThisMeal: $whyThisMeal)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecipeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.ageRange, ageRange) ||
                other.ageRange == ageRange) &&
            const DeepCollectionEquality().equals(
              other._allergenTags,
              _allergenTags,
            ) &&
            const DeepCollectionEquality().equals(
              other._ingredients,
              _ingredients,
            ) &&
            const DeepCollectionEquality().equals(other._steps, _steps) &&
            (identical(other.howToServe, howToServe) ||
                other.howToServe == howToServe) &&
            (identical(other.makes, makes) || other.makes == makes) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            const DeepCollectionEquality().equals(
              other._nutritionTags,
              _nutritionTags,
            ) &&
            (identical(other.category, category) ||
                other.category == category) &&
            const DeepCollectionEquality().equals(other._utensils, _utensils) &&
            (identical(other.storageNote, storageNote) ||
                other.storageNote == storageNote) &&
            (identical(other.freezerNote, freezerNote) ||
                other.freezerNote == freezerNote) &&
            (identical(other.textureTip, textureTip) ||
                other.textureTip == textureTip) &&
            (identical(other.whyThisMeal, whyThisMeal) ||
                other.whyThisMeal == whyThisMeal));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    ageRange,
    const DeepCollectionEquality().hash(_allergenTags),
    const DeepCollectionEquality().hash(_ingredients),
    const DeepCollectionEquality().hash(_steps),
    howToServe,
    makes,
    notes,
    thumbnailUrl,
    const DeepCollectionEquality().hash(_nutritionTags),
    category,
    const DeepCollectionEquality().hash(_utensils),
    storageNote,
    freezerNote,
    textureTip,
    whyThisMeal,
  );

  /// Create a copy of Recipe
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecipeImplCopyWith<_$RecipeImpl> get copyWith =>
      __$$RecipeImplCopyWithImpl<_$RecipeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RecipeImplToJson(this);
  }
}

abstract class _Recipe implements Recipe {
  const factory _Recipe({
    required final String id,
    required final String title,
    required final String ageRange,
    required final List<String> allergenTags,
    required final List<Ingredient> ingredients,
    required final List<String> steps,
    required final String howToServe,
    final String? makes,
    final String? notes,
    final String? thumbnailUrl,
    final List<String> nutritionTags,
    final String? category,
    final List<String>? utensils,
    final String? storageNote,
    final String? freezerNote,
    final String? textureTip,
    final String? whyThisMeal,
  }) = _$RecipeImpl;

  factory _Recipe.fromJson(Map<String, dynamic> json) = _$RecipeImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get ageRange;
  @override
  List<String> get allergenTags;
  @override
  List<Ingredient> get ingredients;
  @override
  List<String> get steps;
  @override
  String get howToServe;
  @override
  String? get makes;
  @override
  String? get notes;
  @override
  String? get thumbnailUrl;
  @override
  List<String> get nutritionTags;
  @override
  String? get category;
  @override
  List<String>? get utensils;
  @override
  String? get storageNote;
  @override
  String? get freezerNote;
  @override
  String? get textureTip;
  @override
  String? get whyThisMeal;

  /// Create a copy of Recipe
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecipeImplCopyWith<_$RecipeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
