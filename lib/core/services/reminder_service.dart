import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../storage/app_database.dart';
import '../storage/database_provider.dart';
import '../storage/preferences_provider.dart';

/// Local reminders: one notification per pending dose today, and one
/// two hours before the next dialysis session.
///
/// Schedules are inexact (no exact-alarm permission needed) and are
/// rebuilt whenever doses or the session change, so marking a dose taken
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

/// Rebuilds the notification plan whenever doses, the next session, or
/// the toggle change. Watched once from the app root.
final reminderSyncProvider = Provider<void>((ref) {
  final enabled = ref.watch(remindersEnabledProvider);
  final doses = ref.watch(_todaysDosesProvider).value ?? const <Dose>[];
  final next = ref.watch(_nextSessionProvider).value;
  Future.microtask(() => ref.read(reminderServiceProvider).sync(
        enabled: enabled,
        todaysDoses: doses,
        nextSession: next,
      ));
});
