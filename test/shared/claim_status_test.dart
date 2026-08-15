import 'package:flutter_test/flutter_test.dart';
import 'package:recora/shared/domain/claim_status.dart';

void main() {
  group('ClaimStatus.canTransitionTo', () {
    test('draft can only be submitted', () {
      expect(ClaimStatus.draft.canTransitionTo(ClaimStatus.submitted), isTrue);
      expect(ClaimStatus.draft.canTransitionTo(ClaimStatus.approved), isFalse);
      expect(ClaimStatus.draft.canTransitionTo(ClaimStatus.rejected), isFalse);
      expect(ClaimStatus.draft.canTransitionTo(ClaimStatus.draft), isFalse);
    });

    test('submitted can reach every outcome and nothing else', () {
      expect(
          ClaimStatus.submitted.canTransitionTo(ClaimStatus.approved), isTrue);
      expect(
          ClaimStatus.submitted.canTransitionTo(ClaimStatus.partiallySettled),
          isTrue);
      expect(
          ClaimStatus.submitted.canTransitionTo(ClaimStatus.rejected), isTrue);
      expect(ClaimStatus.submitted.canTransitionTo(ClaimStatus.draft), isFalse);
    });

    test('rejected can reopen as draft; settled outcomes are terminal', () {
      expect(ClaimStatus.rejected.canTransitionTo(ClaimStatus.draft), isTrue);
      expect(
          ClaimStatus.rejected.canTransitionTo(ClaimStatus.submitted), isFalse);
      for (final next in ClaimStatus.values) {
        expect(ClaimStatus.approved.canTransitionTo(next), isFalse);
        expect(ClaimStatus.partiallySettled.canTransitionTo(next), isFalse);
      }
    });

    test('isOutcome covers exactly the three end states', () {
      expect(ClaimStatus.draft.isOutcome, isFalse);
      expect(ClaimStatus.submitted.isOutcome, isFalse);
      expect(ClaimStatus.approved.isOutcome, isTrue);
      expect(ClaimStatus.partiallySettled.isOutcome, isTrue);
      expect(ClaimStatus.rejected.isOutcome, isTrue);
    });
  });
}
