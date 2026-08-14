import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/storage/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Collapsible "Ended medicines" section: a dashed-outline toggle when
/// collapsed, faded strikethrough cards when expanded.
class EndedMedsSection extends StatelessWidget {
  const EndedMedsSection({
    super.key,
    required this.medications,
    required this.expanded,
    required this.onToggle,
  });

  final List<Medication> medications;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;

    if (medications.isEmpty) return const SizedBox.shrink();

    if (!expanded) {
      return Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Semantics(
          button: true,
          expanded: false,
          child: InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colors.muted.withValues(alpha: 0.8),
                  width: 1.5,
                  style: BorderStyle.solid,
                ),
              ),
              child: Text(
                l10n.endedMedicinesCollapsed(medications.length),
                textAlign: TextAlign.center,
                style: typo.bodySmall.copyWith(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: colors.muted,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          button: true,
          expanded: true,
          child: InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Text(
                l10n.endedMedicinesExpanded,
                style: typo.bodySmall.copyWith(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: colors.muted,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 9),
        for (final med in medications) ...[
          _EndedCard(medication: med),
          const SizedBox(height: 9),
        ],
      ],
    );
  }
}

class _EndedCard extends StatelessWidget {
  const _EndedCard({required this.medication});

  final Medication medication;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;
    final endDate = medication.endDate;
    final endLabel = endDate == null
        ? l10n.ended
        : l10n.endedOn(DateFormat('MMM y').format(endDate));
    final byDoctor =
        medication.doctor.isEmpty ? '' : ' · ${medication.doctor}';

    return Opacity(
      opacity: 0.6,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: colors.cardTranslucent,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: colors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors.divider,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medication.name,
                    style: typo.cardTitle.copyWith(
                      fontSize: 14,
                      color: colors.muted,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: colors.muted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$endLabel$byDoctor',
                    style: typo.bodySmall.copyWith(color: colors.muted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
