// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'allergen.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AllergenImpl _$$AllergenImplFromJson(Map<String, dynamic> json) =>
    _$AllergenImpl(
      key: json['key'] as String,
      name: json['name'] as String,
      sequenceOrder: (json['sequenceOrder'] as num).toInt(),
      emoji: json['emoji'] as String,
    );

Map<String, dynamic> _$$AllergenImplToJson(_$AllergenImpl instance) =>
    <String, dynamic>{
      'key': instance.key,
      'name': instance.name,
      'sequenceOrder': instance.sequenceOrder,
      'emoji': instance.emoji,
    };
