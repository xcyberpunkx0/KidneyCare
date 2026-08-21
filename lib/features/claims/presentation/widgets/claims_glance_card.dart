import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/storage/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/domain/claim_deadlines.dart';
import '../../../../shared/domain/claim_money.dart';
import '../../../../shared/domain/claim_status.dart';
import '../controllers/claims_providers.dart';

/// Home's doorway to claims — always visible so the feature is findable.
/// Amber when something needs acting on (bills whose claim window is
/// closing, submitted claims waiting > 30 days), a neutral summary while
/// claims are simply in flight, and a quiet teaser when nothing is
/// tracked yet. Tapping any state opens the claims page.
class ClaimsGlanceCard extends ConsumerWidget {
  const ClaimsGlanceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;
    final now = DateTime.now();

    final bills =
        ref.watch(unclaimedBillsProvider).value ?? const <Document>[];
    final claims = ref.watch(claimsListProvider).value ?? const <Claim>[];
    final policies =
        ref.watch(policiesProvider).value ?? const <InsurancePolicy>[];

    // Same rule as reminder scheduling: an unclaimed bill isn't tied to
    // a policy yet, so judge urgency by the shortest claim window.
    final windowDays = policies.isEmpty
        ? 0
        : minClaimWindowDays(policies.map((p) => p.claimWindowDays));
    final expiring = policies.isEmpty
        ? const <Document>[]
        : bills
            .where((b) =>
                daysUntilDeadline(b.documentDate, windowDays, now) <= 7)
            .toList();
    final stale = staleSubmitted(claims, now);

    final urgentLines = <String>[
      for (final bill in expiring.take(2))
        switch (daysUntilDeadline(bill.documentDate, windowDays, now)) {
          < 0 => '${bill.title} — ${l10n.claimOverdue}',
          final days => '${bill.title} — ${l10n.claimDaysLeft(days)}',
        },
      for (final claim in stale.take(2))
        '${claim.title} — '
            '${l10n.claimAwaitingLong(now.difference(claim.submittedOn!).inDays)}',
    ];

    if (urgentLines.isNotEmpty) {
      return _shell(
        context,
        bg: colors.amberBg,
        border: colors.amberBorder,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.claimGlanceTitle(expiring.length + stale.length),
              style:
                  typo.overline.copyWith(fontSize: 11, color: colors.amber),
            ),
            for (final line in urgentLines) ...[
              const SizedBox(height: 5),
              Text(
                line,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: typo.bodySmall.copyWith(
                  fontSize: 12.5,
                  color: colors.ink.withValues(alpha: 0.8),
                ),
              ),
            ],
          ],
        ),
      );
    }

    final open = claims.where((c) => !c.status.isOutcome).toList();
    if (open.isNotEmpty) {
      final submitted =
          open.where((c) => c.status == ClaimStatus.submitted).toList();
      final drafts = open.length - submitted.length;
      var awaiting = 0;
      for (final claim in submitted) {
        awaiting += claim.claimedAmountPaise ?? 0;
      }
      final summary = [
        if (submitted.isNotEmpty)
          l10n.claimGlanceWithInsurer(submitted.length),
        if (awaiting > 0) l10n.claimGlanceAwaiting(formatPaise(awaiting)),
        if (drafts > 0) l10n.claimGlanceGettingReady(drafts),
      ].join(' · ');
      return _shell(
        context,
        bg: colors.card,
        border: colors.cardBorder,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.claimGlanceTitle(open.length),
              style:
                  typo.overline.copyWith(fontSize: 11, color: colors.muted),
            ),
            const SizedBox(height: 5),
            Text(
              summary,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: typo.bodySmall.copyWith(
                fontSize: 12.5,
                color: colors.ink.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      );
    }

    return _shell(
      context,
      bg: colors.card,
      border: colors.cardBorder,
      child: Row(
        children: [
          Icon(Icons.receipt_long_outlined, size: 16, color: colors.muted),
          const SizedBox(width: 8),
          Text(
            l10n.claimGlanceTeaser,
            style: typo.bodySmall
                .copyWith(fontSize: 12.5, color: colors.muted),
          ),
        ],
      ),
    );
  }

  Widget _shell(
    BuildContext context, {
    required Color bg,
    required Color border,
    required Widget child,
  }) {
    return GestureDetector(
      onTap: () => context.pushNamed(AppRoutes.claimsName),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border),
        ),
        child: child,
      ),
    );
  }
}
