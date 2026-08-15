import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../shared/domain/claim_deadlines.dart';
import '../storage/app_database.dart';
import '../storage/database_provider.dart';
import '../storage/preferences_provider.dart';

/// Local reminders: one notification per pending dose today, one two
/// hours before the next dialysis session, and one five days before an
/// unclaimed bill's insurance claim window closes.
///
/// Schedules are inexact (no exact-alarm permission needed) and are
/// rebuilt whenever doses, the session, or the unclaimed-bills/policies
/// change, so marking a dose taken or attaching a bill to a claim
/// silences its reminder.
class ReminderService {
  ReminderService(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  static const _doseChannel = AndroidNotificationDetails(
    'doses',
    'Medicine reminders',
    channelDescription: 'A reminder for each scheduled dose',
    importance: Importance.high,
    priority: Priority.high,
  );

  static const _sessionChannel = AndroidNotificationDetails(
    'dialysis',
    'Dialysis reminders',
    channelDescription: 'Reminder before each dialysis session',
    importance: Importance.high,
    priority: Priority.high,
  );

  static const _claimChannel = AndroidNotificationDetails(
    'claims',
    'Insurance claim reminders',
    channelDescription:
        'A reminder before an unclaimed bill passes its claim window',
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
  );

  bool _initialized = false;

  /// Prepares the plugin and asks for notification permission (a no-op
  /// below Android 13).
  Future<void> initialize() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    _initialized = true;
  }

  /// Replaces all scheduled reminders with the current plan.
  Future<void> sync({
    required bool enabled,
    required List<Dose> todaysDoses,
    required DialysisSession? nextSession,
    required List<BillReminder> billReminders,
  }) async {
    try {
      await initialize();
      await _plugin.cancelAll();
      if (!enabled) return;

      final now = DateTime.now();
      var id = 1;
      for (final dose in todaysDoses) {
        if (dose.taken) continue;
        final at = _doseTime(dose, now);
        if (at == null || !at.isAfter(now)) continue;
        await _schedule(
          id: id++,
          at: at,
          title: 'Medicine time — ${dose.medicationLabel}',
          body: 'Scheduled for ${dose.timeLabel}. '
              'Mark it given in KidneyCare once taken.',
          details: const NotificationDetails(android: _doseChannel),
        );
      }

      final session = nextSession?.scheduledAt;
      if (session != null) {
        final at = session.subtract(const Duration(hours: 2));
        if (at.isAfter(now)) {
          await _schedule(
            id: 900,
            at: at,
            title: 'Dialysis in 2 hours',
            body: 'Session at the centre — time to get ready.',
            details:
                const NotificationDetails(android: _sessionChannel),
          );
        }
      }

      for (final reminder in billReminders) {
        if (!reminder.at.isAfter(now)) continue;
        await _schedule(
          id: reminder.id,
          at: reminder.at,
          title: 'Bill not claimed yet — ${reminder.billTitle}',
          body: '${reminder.daysLeft} days left in the claim window. '
              'Attach it to a claim in KidneyCare.',
          details: const NotificationDetails(android: _claimChannel),
        );
      }
    } catch (error) {
      // Reminders are best-effort; a scheduling failure must never take
      // the app down.
      debugPrint('Reminder sync failed: $error');
    }
  }

  Future<void> _schedule({
    required int id,
    required DateTime at,
    required String title,
    required String body,
    required NotificationDetails details,
  }) {
    return _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(at, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// "7 AM" / "1 PM" / "12 PM" → today's DateTime, else null.
  DateTime? _doseTime(Dose dose, DateTime today) {
    final match =
        RegExp(r'^(\d{1,2})\s*(AM|PM)$', caseSensitive: false)
            .firstMatch(dose.timeLabel.trim());
    if (match == null) return null;
    var hour = int.parse(match.group(1)!);
    final isPm = match.group(2)!.toUpperCase() == 'PM';
    if (hour == 12) hour = 0;
    if (isPm) hour += 12;
    return DateTime(today.year, today.month, today.day, hour);
  }
}

final reminderServiceProvider = Provider<ReminderService>((ref) {
  return ReminderService(FlutterLocalNotificationsPlugin());
});

/// Whether reminders are on. Defaults to enabled; persisted across runs.
class RemindersEnabledController extends Notifier<bool> {
  static const _prefKey = 'reminders_enabled';

  @override
  bool build() {
    return ref.read(sharedPreferencesProvider).getBool(_prefKey) ?? true;
  }

  void toggle() {
    state = !state;
    ref.read(sharedPreferencesProvider).setBool(_prefKey, state);
  }
}

final remindersEnabledProvider =
    NotifierProvider<RemindersEnabledController, bool>(
  RemindersEnabledController.new,
);

final _todaysDosesProvider = StreamProvider<List<Dose>>((ref) {
  return ref.watch(databaseProvider).doseDao.watchForDay(DateTime.now());
});

final _nextSessionProvider = StreamProvider<DialysisSession?>((ref) {
  return ref
      .watch(databaseProvider)
      .dialysisDao
      .watchNextSession(DateTime.now());
});

final _unclaimedBillsForRemindersProvider =
    StreamProvider<List<Document>>((ref) {
  return ref.watch(databaseProvider).claimDao.watchUnclaimedBills();
});

final _policiesForRemindersProvider =
    StreamProvider<List<InsurancePolicy>>((ref) {
  return ref.watch(databaseProvider).claimDao.watchPolicies();
});

/// Rebuilds the notification plan whenever doses, the next session, the
/// unclaimed bills / policies, or the toggle change. Watched once from
/// the app root.
final reminderSyncProvider = Provider<void>((ref) {
  final enabled = ref.watch(remindersEnabledProvider);
  final doses = ref.watch(_todaysDosesProvider).value ?? const <Dose>[];
  final next = ref.watch(_nextSessionProvider).value;
  final bills =
      ref.watch(_unclaimedBillsForRemindersProvider).value ?? const [];
  final policies =
      ref.watch(_policiesForRemindersProvider).value ?? const [];
  final billReminders = policies.isEmpty
      ? const <BillReminder>[]
      : planBillReminders(
          bills: [
            for (final bill in bills)
              (title: bill.title, date: bill.documentDate),
          ],
          // An unclaimed bill isn't tied to a policy yet, so use the
          // shortest claim window: a reminder may fire early, never late.
          windowDays: policies
              .map((p) => p.claimWindowDays)
              .reduce((a, b) => a < b ? a : b),
          now: DateTime.now(),
        );
  Future.microtask(() => ref.read(reminderServiceProvider).sync(
        enabled: enabled,
        todaysDoses: doses,
        nextSession: next,
        billReminders: billReminders,
      ));
});
