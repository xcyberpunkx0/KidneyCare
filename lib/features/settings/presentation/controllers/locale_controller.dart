import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/preferences_provider.dart';

/// Persisted language preference. English by default; the caregiver can
/// switch to Hindi or device-following ("System") from settings.
class LocaleController extends Notifier<Locale?> {
  static const _prefKey = 'locale';

  @override
  Locale? build() {
    final stored = ref.read(sharedPreferencesProvider).getString(_prefKey);
    if (stored == null) return const Locale('en');
    return stored.isEmpty ? null : Locale(stored);
  }

  void set(Locale? locale) {
    state = locale;
    // Empty string = explicit "follow the device"; absent = default (en).
    ref
        .read(sharedPreferencesProvider)
        .setString(_prefKey, locale?.languageCode ?? '');
  }
}

final localeProvider =
    NotifierProvider<LocaleController, Locale?>(LocaleController.new);
