import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/router/app_router.dart';
import 'core/router/routes.dart';
import 'core/services/gemini_key_store.dart';
import 'core/storage/database_provider.dart';
import 'features/settings/presentation/controllers/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final geminiKey = await GeminiKeyStore.read();

  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      initialGeminiKeyProvider.overrideWithValue(geminiKey),
    ],
  );

  // First launch opens onboarding; once a patient exists the vault opens
  // straight to home.
  final patient =
      await container.read(databaseProvider).patientDao.getPatient();
  container
      .read(initialLocationProvider.notifier)
      .set(patient == null ? AppRoutes.onboarding : AppRoutes.home);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const RecoraApp(),
    ),
  );
}
