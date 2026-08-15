/// Lifecycle of an insurance reimbursement claim.
///
/// Persisted by name via Drift's `textEnum` — never rename or reorder
/// values once released.
enum ClaimStatus {
  /// Collecting bills; nothing sent to the insurer yet.
  draft,

  /// Handed to the insurer/TPA; awaiting a decision.
  submitted,

  /// Fully approved and paid out.
  approved,

  /// Paid, but less than the claimed amount.
  partiallySettled,

  /// Declined. May be reopened as [draft] for resubmission.
  rejected;

  /// Whether this claim has reached an end state.
  bool get isOutcome =>
      this == approved || this == partiallySettled || this == rejected;

  /// Legal moves: draft → submitted → outcome; rejected → draft.
  bool canTransitionTo(ClaimStatus next) => switch ((this, next)) {
        (draft, submitted) => true,
        (submitted, approved) ||
        (submitted, partiallySettled) ||
        (submitted, rejected) =>
          true,
        (rejected, draft) => true,
        _ => false,
      };
}
