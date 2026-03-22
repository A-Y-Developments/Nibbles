// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'baby_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BabyResponseImpl _$$BabyResponseImplFromJson(Map<String, dynamic> json) =>
    _$BabyResponseImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      dateOfBirth: json['date_of_birth'] as String,
      gender: json['gender'] as String,
      onboardingCompleted: json['onboarding_completed'] as bool,
    );

Map<String, dynamic> _$$BabyResponseImplToJson(_$BabyResponseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'name': instance.name,
      'date_of_birth': instance.dateOfBirth,
      'gender': instance.gender,
      'onboarding_completed': instance.onboardingCompleted,
    };
