import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/repository_impl/patient_repository_impl.dart';
import 'patient_setup_page.dart';

/// Loads the current patient and opens the setup form in edit mode.
class PatientEditPage extends ConsumerWidget {
  const PatientEditPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patient = ref.watch(patientProvider).value;
    if (patient == null) {
      return Scaffold(
        backgroundColor: context.colors.bgSection,
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return PatientSetupPage(existing: patient);
  }
}
