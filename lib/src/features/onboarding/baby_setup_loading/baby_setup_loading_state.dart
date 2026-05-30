/// NIB-137 — phase enum for the post-consent baby-setup loading transition.
///
/// `loading` — petal animation visible, dwell timer running.
/// `ready` — min dwell elapsed; the screen will schedule its auto-route to
/// `/home`. Visually identical to `loading` (single Figma frame); the split
/// exists purely as the notification edge the screen listens on.
enum BabySetupLoadingPhase {
  loading,
  ready,
}
