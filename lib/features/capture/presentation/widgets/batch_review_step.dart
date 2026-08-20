import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../controllers/batch_import_controller.dart';
import 'review_step.dart';

/// Reviews the queue one document at a time: the shared [ReviewStep]
/// once the current item's extraction is ready, a waiting state while it
/// is still being read, and a retry/skip card when it failed.
class BatchReviewStep extends ConsumerWidget {
  const BatchReviewStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(batchImportProvider);
    final controller = ref.read(batchImportProvider.notifier);
    final item = state.currentItem;
    if (item == null) return const SizedBox.shrink();

    final header = _QueueHeader(
      index: state.currentIndex + 1,
      total: state.items.length,
      sourceLabel: item.sourceLabel,
      onSkip: item.status == BatchItemStatus.failed
          ? controller.continueAfterFailure
          : controller.skipCurrent,
    );

    final draft = item.draft;
    return switch (item.status) {
      BatchItemStatus.ready ||
      BatchItemStatus.saved when draft != null =>
        ReviewStep(
          draft: draft,
          saving: state.saving,
          header: header,
          saveLabel: l10n.saveAndNext,
          onEdit: controller.editField,
          onChooseAlternative: controller.chooseAlternative,
          onSave: controller.saveCurrent,
        ),
      BatchItemStatus.failed => _FailedCard(
          header: header,
          message: item.failure?.message ?? l10n.extractionFailedTitle,
          onRetry: () => controller.retry(item.id),
        ),
      _ => _WaitingCard(header: header),
    };
  }
}

/// "Reviewing 2 of 12" with the source filename and a Skip action.
class _QueueHeader extends StatelessWidget {
  const _QueueHeader({
    required this.index,
    required this.total,
    required this.sourceLabel,
    required this.onSkip,
  });

  final int index;
  final int total;
  final String sourceLabel;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: Icon(Icons.close, color: colors.ink),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.reviewingItemOfTotal(index, total),
                  style: typo.sectionTitle,
                ),
                if (sourceLabel.isNotEmpty)
                  Text(
                    sourceLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: typo.caption.copyWith(color: colors.muted),
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: onSkip,
            child: Text(
              l10n.skipDocument,
              style: typo.cardTitle
                  .copyWith(fontSize: 13, color: colors.accent),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaitingCard extends StatelessWidget {
  const _WaitingCard({required this.header});

  final Widget header;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;
    return Column(
      children: [
        header,
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: colors.accent,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.waitingForExtraction,
                  style: typo.bodySmall.copyWith(color: colors.muted),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FailedCard extends StatelessWidget {
  const _FailedCard({
    required this.header,
    required this.message,
    required this.onRetry,
  });

  final Widget header;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;
    return Column(
      children: [
        header,
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 34),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 40, color: colors.amber),
                  const SizedBox(height: 12),
                  Text(
                    l10n.extractionFailedTitle,
                    textAlign: TextAlign.center,
                    style: typo.cardTitle.copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: typo.bodySmall.copyWith(color: colors.muted),
                  ),
                  const SizedBox(height: 18),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.accent,
                      foregroundColor: colors.onAccent,
                    ),
                    onPressed: onRetry,
                    child: Text(l10n.retryExtraction),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
