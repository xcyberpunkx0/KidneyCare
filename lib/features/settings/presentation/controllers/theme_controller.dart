import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/preferences_provider.dart';

export '../../../../core/storage/preferences_provider.dart'
    show sharedPreferencesProvider;

/// Persisted light/dark preference. The moon/sun toggle on the home header
/// drives this; system setting is respected until the user chooses.
class ThemeModeController extends Notifier<ThemeMode> {
  static const _prefKey = 'theme_mode';

  @override
  ThemeMode build() {
    final stored = ref.read(sharedPreferencesProvider).getString(_prefKey);
    return switch (stored) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  void toggle(Brightness current) {
    final next =
        current == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
    state = next;
    ref
        .read(sharedPreferencesProvider)
        .setString(_prefKey, next == ThemeMode.dark ? 'dark' : 'light');
  }
}

final themeModeProvider =
    NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);
