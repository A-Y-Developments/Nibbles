import 'package:freezed_annotation/freezed_annotation.dart';

part 'guidance_tip.freezed.dart';

@freezed
class GuidanceTip with _$GuidanceTip {
  const factory GuidanceTip({
    required String id,
    required String iconKey,
    required String title,
    required String body,
  }) = _GuidanceTip;
}
