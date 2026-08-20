import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../controllers/batch_import_controller.dart';

/// Wraps up the batch: how many documents were saved/skipped/failed,
/// with a Retry per failed document and a Done button.
class BatchSummaryStep extends ConsumerWidget {
  const BatchSummaryStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;
    final state = ref.watch(batchImportProvider);
    final controller = ref.read(batchImportProvider.notifier);
    final failed = state.failedItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 26, 22, 10),
            children: [
              Icon(
                state.savedCount > 0
                    ? Icons.check_circle_outline
                    : Icons.info_outline,
                size: 44,
                color: state.savedCount > 0 ? colors.green : colors.muted,
              ),
              const SizedBox(height: 14),
              Text(
                l10n.importSummary,
                textAlign: TextAlign.center,
                style: typo.pageTitle.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 6),
              Text(
                [
                  l10n.nDocumentsSaved(state.savedCount),
                  if (state.skippedCount > 0)
                    l10n.nDocumentsSkipped(state.skippedCount),
                  if (failed.isNotEmpty) l10n.nDocumentsFailed(failed.length),
                ].join(' · '),
                textAlign: TextAlign.center,
                style: typo.bodySmall.copyWith(color: colors.muted),
              ),
              if (failed.isNotEmpty) ...[
                const SizedBox(height: 22),
                for (final item in failed)
                  Container(
                    margin: const EdgeInsets.only(bottom: 9),
                    padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
                    decoration: BoxDecoration(
                      color: colors.amberBg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline,
                            size: 18, color: colors.amber),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item.sourceLabel.isNotEmpty
                                ? item.sourceLabel
                                : (item.failure?.message ??
                                    l10n.extractionFailedTitle),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: typo.bodySmall
                                .copyWith(color: colors.amber),
                          ),
                        ),
                        TextButton(
                          onPressed: () => controller.retry(item.id),
                          child: Text(
                            l10n.retryExtraction,
                            style: typo.cardTitle.copyWith(
                                fontSize: 13, color: colors.accent),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
            child: Semantics(
              button: true,
              label: l10n.importDone,
              child: Material(
                color: colors.accent,
                borderRadius: BorderRadius.circular(99),
                child: InkWell(
                  onTap: () => context.pop(),
                  borderRadius: BorderRadius.circular(99),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Center(
                      child: Text(
                        l10n.importDone,
                        style: typo.cardTitle.copyWith(
                          fontSize: 15,
                          color: colors.onAccent,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
