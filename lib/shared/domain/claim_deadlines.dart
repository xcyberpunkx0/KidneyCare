/// Deadline math for unclaimed bills. Pure so both the reminder service
/// and the claims UI share one definition of "expiring".
library;

/// Last day the insurer accepts the bill: bill date + submission window.
/// Calendar-day arithmetic (DST-proof), normalized to midnight.
DateTime claimDeadline(DateTime billDate, int windowDays) =>
    DateTime(billDate.year, billDate.month, billDate.day + windowDays);

/// Whole calendar days from [now] to the deadline; negative when overdue.
int daysUntilDeadline(DateTime billDate, int windowDays, DateTime now) {
  final deadline = claimDeadline(billDate, windowDays);
  final today = DateTime(now.year, now.month, now.day);
  return deadline.difference(today).inDays;
}

/// One scheduled "claim this bill" notification.
class BillReminder {
  const BillReminder({
    required this.id,
    required this.at,
    required this.billTitle,
    required this.daysLeft,
  });

  /// Notification id. Claims own the 1000+ range (doses count up from 1,
  /// the dialysis reminder is 900).
  final int id;
  final DateTime at;
  final String billTitle;
  final int daysLeft;
}

/// Builds the notification plan for unclaimed bills: 9 AM five days
/// before each deadline, or the next 9 AM when already inside that
/// window. Bills past their deadline are dropped — nagging about the
/// unfixable helps no one; the UI still lists them.
List<BillReminder> planBillReminders({
  required List<({String title, DateTime date})> bills,
  required int windowDays,
  required DateTime now,
}) {
  final plan = <BillReminder>[];
  var id = 1000;
  for (final bill in bills) {
    final deadline = claimDeadline(bill.date, windowDays);
    if (!deadline.isAfter(now)) continue;
    var at = DateTime(deadline.year, deadline.month, deadline.day - 5, 9);
    if (!at.isAfter(now)) {
      final todayNine = DateTime(now.year, now.month, now.day, 9);
      at = todayNine.isAfter(now)
          ? todayNine
          : todayNine.add(const Duration(days: 1));
    }
    if (!deadline.isAfter(at)) continue;
    plan.add(BillReminder(
      id: id++,
      at: at,
      billTitle: bill.title,
      daysLeft: deadline.difference(DateTime(at.year, at.month, at.day)).inDays,
    ));
  }
  return plan;
}

/// Shortest of a set of policy claim windows. An unclaimed bill isn't tied
/// to a policy yet, so callers judge urgency by the tightest window: a
/// reminder or deadline may fire early, never late. Callers pass raw ints
/// (e.g. `policies.map((p) => p.claimWindowDays)`) so this file stays free
/// of storage-layer imports.
int minClaimWindowDays(Iterable<int> windows) =>
    windows.reduce((a, b) => a < b ? a : b);
