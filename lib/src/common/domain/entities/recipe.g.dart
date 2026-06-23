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
  makes: json['makes'] as String?,
  notes: json['notes'] as String?,
  thumbnailUrl: json['thumbnailUrl'] as String?,
  nutritionTags:
      (json['nutritionTags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  category: json['category'] as String?,
  utensils: (json['utensils'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  storageNote: json['storageNote'] as String?,
  freezerNote: json['freezerNote'] as String?,
  textureTip: json['textureTip'] as String?,
  whyThisMeal: json['whyThisMeal'] as String?,
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
      'makes': instance.makes,
      'notes': instance.notes,
      'thumbnailUrl': instance.thumbnailUrl,
      'nutritionTags': instance.nutritionTags,
      'category': instance.category,
      'utensils': instance.utensils,
      'storageNote': instance.storageNote,
      'freezerNote': instance.freezerNote,
      'textureTip': instance.textureTip,
      'whyThisMeal': instance.whyThisMeal,
    };
