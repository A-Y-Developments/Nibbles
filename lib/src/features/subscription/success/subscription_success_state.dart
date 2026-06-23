/// Two-phase state for the post-purchase transition screen.
///
/// `loading` — petal animation + faint "Loading" label.
/// `success` — petal animation + "You all set!" label, before auto-route to
/// `/home`.
enum SubscriptionSuccessPhase { loading, success }
