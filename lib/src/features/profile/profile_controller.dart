import 'package:nibbles/src/common/services/baby_profile_service.dart';
import 'package:nibbles/src/features/profile/profile_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_controller.g.dart';

/// `babyId` is retained on the family for back-compat with
/// `profile_edit_screen.dart` which still calls
/// `ref.invalidate(profileControllerProvider(widget.babyId))`. The id itself
/// is not consumed here — `BabyProfileService.getBaby()` resolves the active
/// baby from the auth session.
@riverpod
class ProfileController extends _$ProfileController {
  @override
  Future<ProfileState> build(String babyId) async {
    final baby = await ref.read(babyProfileServiceProvider).getBaby();

    // SubscriptionService is M2-deferred (NIB-73). Stub the label until the
    // paywall ships.
    final subscriptionLabel = baby == null ? null : 'No Subscription';

    return ProfileState(
      baby: baby,
      subscriptionLabel: subscriptionLabel,
    );
  }
}
