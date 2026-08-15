import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/storage/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_format_x.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../shared/domain/claim_money.dart';
import '../../../../shared/domain/claim_status.dart';

/// One claim in the list: title, status chip, document count, money line.
class ClaimCard extends StatelessWidget {
  const ClaimCard({
    super.key,
    required this.claim,
    required this.docCount,
    this.onTap,
  });

  final Claim claim;
  final int docCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;

    final money = switch (claim.status) {
      ClaimStatus.draft => null,
      ClaimStatus.submitted => claim.claimedAmountPaise == null
          ? null
          : '${l10n.claimAmountClaimed} ${formatPaise(claim.claimedAmountPaise!)}',
      _ => claim.approvedAmountPaise == null
          ? null
          : '${l10n.claimAmountApproved} ${formatPaise(claim.approvedAmountPaise!)}',
    };
    final date = claim.settledOn ?? claim.submittedOn ?? claim.createdAt;

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  claim.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: typo.cardTitle,
                ),
              ),
              _StatusChip(status: claim.status),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            [
              l10n.claimDocCount(docCount),
              ?money,
              date.monthDay,
            ].join(' · '),
            style: typo.caption.copyWith(color: colors.muted),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

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
