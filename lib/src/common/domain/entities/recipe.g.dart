// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RecipeImpl _$$RecipeImplFromJson(Map<String, dynamic> json) => _$RecipeImpl(
  id: json['id'] as String,
  title: json['title'] as String,
  ageRange: json['ageRange'] as String,
  allergenTags: (json['allergenTags'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  ingredients: (json['ingredients'] as List<dynamic>)
      .map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
      .toList(),
  steps: (json['steps'] as List<dynamic>).map((e) => e as String).toList(),
  howToServe: json['howToServe'] as String,
  notes: json['notes'] as String?,
  thumbnailUrl: json['thumbnailUrl'] as String?,
);

Map<String, dynamic> _$$RecipeImplToJson(_$RecipeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'ageRange': instance.ageRange,
      'allergenTags': instance.allergenTags,
      'ingredients': instance.ingredients,
      'steps': instance.steps,
      'howToServe': instance.howToServe,
      'notes': instance.notes,
      'thumbnailUrl': instance.thumbnailUrl,
    };
