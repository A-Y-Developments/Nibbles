import 'package:nibbles/src/common/data/sources/remote/config/app_exception.dart';
import 'package:nibbles/src/common/data/sources/remote/config/result.dart';
import 'package:nibbles/src/common/domain/entities/allergen_board_item.dart';
import 'package:nibbles/src/common/domain/enums/allergen_status.dart';
import 'package:nibbles/src/common/services/allergen_service.dart';
import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/features/profile/profile_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_controller.g.dart';

@riverpod
class ProfileController extends _$ProfileController {
  @override
  Future<ProfileState> build(String babyId) async {
    final baby = await ref.read(babyProfileServiceProvider).getBaby();
    if (baby == null) throw const UnknownException('Baby profile not found.');

    final boardResult = await ref
        .read(allergenServiceProvider)
        .getAllergenBoardSummary(babyId);
    if (boardResult.isFailure) throw boardResult.errorOrNull!;

    final safeAllergens = boardResult.dataOrNull!
        .where((AllergenBoardItem i) => i.status == AllergenStatus.safe)
        .toList();

    return ProfileState(
      baby: baby,
      safeAllergens: safeAllergens,
      subscriptionLabel: 'Trial', // Subscription (M2) deferred
    );
  }
}
