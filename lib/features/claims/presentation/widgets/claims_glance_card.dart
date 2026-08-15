import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/storage/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/domain/claim_deadlines.dart';
import '../controllers/claims_providers.dart';

/// Home's claims nudge: bills whose claim window is closing (≤ 7 days)
/// and submitted claims waiting > 30 days. Invisible when neither exists.
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

    final expiring = policies.isEmpty
        ? const <Document>[]
        : bills
            .where((b) =>
                daysUntilDeadline(b.documentDate,
                    policies.first.claimWindowDays, now) <=
                7)
            .toList();
    final stale = staleSubmitted(claims, now);

    final lines = <String>[
      for (final bill in expiring.take(2))
        switch (daysUntilDeadline(
            bill.documentDate, policies.first.claimWindowDays, now)) {
          < 0 => '${bill.title} — ${l10n.claimOverdue}',
          final days => '${bill.title} — ${l10n.claimDaysLeft(days)}',
        },
      for (final claim in stale.take(2))
        '${claim.title} — '
            '${l10n.claimAwaitingLong(now.difference(claim.submittedOn!).inDays)}',
    ];
    if (lines.isEmpty) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => context.pushNamed(AppRoutes.claimsName),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: colors.amberBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.amberBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.claimGlanceTitle(lines.length),
              style:
                  typo.overline.copyWith(fontSize: 11, color: colors.amber),
            ),
            for (final line in lines) ...[
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
      ),
    );
  }
}
