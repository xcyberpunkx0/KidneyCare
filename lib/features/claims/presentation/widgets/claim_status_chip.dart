import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/domain/claim_status.dart';

/// Colored status pill, shared by the claims list and the detail page so
/// a claim reads the same way everywhere it appears.
class ClaimStatusChip extends StatelessWidget {
  const ClaimStatusChip({super.key, required this.status});

  final ClaimStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final (bg, fg) = switch (status) {
      ClaimStatus.draft => (colors.card, colors.muted),
      ClaimStatus.submitted => (colors.blueBg, colors.blue),
      ClaimStatus.approved => (colors.greenBg, colors.green),
      ClaimStatus.partiallySettled => (colors.amberBg, colors.amber),
      ClaimStatus.rejected => (colors.orangeBg, colors.orange),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        status.localizedLabel(context.l10n),
        style: typo.caption
            .copyWith(color: fg, fontWeight: FontWeight.w600, fontSize: 11),
      ),
    );
  }
}
