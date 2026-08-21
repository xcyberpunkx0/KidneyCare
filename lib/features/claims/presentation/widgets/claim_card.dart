import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/storage/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_format_x.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../shared/domain/claim_money.dart';
import '../../../../shared/domain/claim_status.dart';
import 'claim_status_chip.dart';

/// One claim in the list: title, status chip, a draft → submitted → done
/// progress bar, the money in plain words, then doc count and date.
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
          : l10n.claimMoneyWaiting(formatPaise(claim.claimedAmountPaise!)),
      ClaimStatus.partiallySettled => switch ((
          claim.approvedAmountPaise,
          claim.claimedAmountPaise
        )) {
          (null, _) => null,
          (final int approved, null) =>
            l10n.claimMoneyRecovered(formatPaise(approved)),
          (final int approved, final int claimed) => l10n
              .claimMoneyRecoveredOf(formatPaise(approved), formatPaise(claimed)),
        },
      ClaimStatus.approved => claim.approvedAmountPaise == null
          ? null
          : l10n.claimMoneyRecovered(formatPaise(claim.approvedAmountPaise!)),
      ClaimStatus.rejected => claim.claimedAmountPaise == null
          ? null
          : l10n.claimMoneyRejected(formatPaise(claim.claimedAmountPaise!)),
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
              ClaimStatusChip(status: claim.status),
            ],
          ),
          const SizedBox(height: 8),
          _ProgressBar(status: claim.status),
          const SizedBox(height: 6),
          if (money != null) ...[
            Text(
              money,
              style: typo.caption.copyWith(
                color: _progressColor(claim.status, colors),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
          ],
          Text(
            [l10n.claimDocCount(docCount), date.monthDay].join(' · '),
            style: typo.caption.copyWith(color: colors.muted),
          ),
        ],
      ),
    );
  }
}

/// The stage a claim's money line and progress bar are tinted with.
Color _progressColor(ClaimStatus status, AppColors colors) {
  return switch (status) {
    ClaimStatus.draft => colors.muted,
    ClaimStatus.submitted => colors.blue,
    ClaimStatus.approved || ClaimStatus.partiallySettled => colors.green,
    ClaimStatus.rejected => colors.orange,
  };
}

/// Three segments for the claim's journey: getting ready → with the
/// insurer → done. Rejected fills all three in orange so "over, but not
/// paid" is visible without reading.
class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.status});

  final ClaimStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final filled = switch (status) {
      ClaimStatus.draft => 1,
      ClaimStatus.submitted => 2,
      _ => 3,
    };
    final fill = _progressColor(status, colors);
    return Row(
      children: [
        for (var segment = 0; segment < 3; segment++) ...[
          if (segment > 0) const SizedBox(width: 4),
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: segment < filled ? fill : colors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
