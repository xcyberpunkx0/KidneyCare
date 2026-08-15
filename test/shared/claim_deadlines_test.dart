import 'package:flutter_test/flutter_test.dart';
import 'package:recora/shared/domain/claim_deadlines.dart';

void main() {
  final now = DateTime(2026, 8, 15, 12); // fixed "today", noon

  group('claimDeadline / daysUntilDeadline', () {
    test('deadline is billDate + window, date arithmetic not duration', () {
      expect(claimDeadline(DateTime(2026, 8, 1), 30), DateTime(2026, 8, 31));
    });

    test('daysUntilDeadline counts calendar days and goes negative', () {
      expect(daysUntilDeadline(DateTime(2026, 8, 1), 30, now), 16);
      expect(daysUntilDeadline(DateTime(2026, 7, 1), 30, now), lessThan(0));
    });
  });

  group('planBillReminders', () {
    test('schedules 9 AM five days before the deadline, ids from 1000', () {
      final plan = planBillReminders(
        bills: [(title: 'Dialysis bill', date: DateTime(2026, 8, 1))],
        windowDays: 30,
        now: now,
      );
      expect(plan, hasLength(1));
      expect(plan.single.id, 1000);
      expect(plan.single.at, DateTime(2026, 8, 26, 9));
      expect(plan.single.daysLeft, 5);
    });

    test('inside the 5-day window it fires at the next 9 AM instead', () {
      final plan = planBillReminders(
        bills: [(title: 'Late bill', date: DateTime(2026, 7, 20))],
        windowDays: 30, // deadline Aug 19; minus 5 days is already past
        now: now, // Aug 15 noon → next 9 AM is Aug 16
      );
      expect(plan.single.at, DateTime(2026, 8, 16, 9));
    });

    test('bills past their deadline are silent (UI-only)', () {
      final plan = planBillReminders(
        bills: [(title: 'Expired bill', date: DateTime(2026, 6, 1))],
        windowDays: 30,
        now: now,
      );
      expect(plan, isEmpty);
    });

    test('ids increment per bill', () {
      final plan = planBillReminders(
        bills: [
          (title: 'A', date: DateTime(2026, 8, 1)),
          (title: 'B', date: DateTime(2026, 8, 5)),
        ],
        windowDays: 30,
        now: now,
      );
      expect(plan.map((r) => r.id), [1000, 1001]);
    });
  });
}
