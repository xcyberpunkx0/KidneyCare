import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../controllers/batch_import_controller.dart';
import '../widgets/batch_review_step.dart';
import '../widgets/batch_setup_step.dart';
import '../widgets/batch_summary_step.dart';

/// Full-screen batch import: pick a pile of photos/PDFs, then extract
/// and review them one by one from a queue.
class BatchImportPage extends ConsumerWidget {
  const BatchImportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(batchImportProvider);
    final controller = ref.read(batchImportProvider.notifier);

    ref.listen(batchImportProvider, (previous, next) {
      final failure = next.failure;
      if (failure != null && failure != previous?.failure) {
        showAppSnackBar(context, failure.message);
        controller.dismissFailure();
      }
    });

    return Scaffold(
      backgroundColor: context.colors.bgSection,
      body: SafeArea(
        child: switch (state.phase) {
          BatchPhase.setup => const BatchSetupStep(),
          BatchPhase.running => const BatchReviewStep(),
          BatchPhase.summary => const BatchSummaryStep(),
        },
      ),
    );
  }
}
