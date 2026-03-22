import 'package:freezed_annotation/freezed_annotation.dart';

part 'allergen.freezed.dart';
part 'allergen.g.dart';

@freezed
class Allergen with _$Allergen {
  const factory Allergen({
    required String key,
    required String name,
    required int sequenceOrder,
    required String emoji,
  }) = _Allergen;

  factory Allergen.fromJson(Map<String, dynamic> json) =>
      _$AllergenFromJson(json);
}
