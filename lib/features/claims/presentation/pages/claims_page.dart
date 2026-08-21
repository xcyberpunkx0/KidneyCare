import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/storage/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../shared/domain/claim_deadlines.dart';
import '../../../../shared/domain/claim_money.dart';
import '../../../../shared/domain/claim_status.dart';
import '../controllers/claims_providers.dart';
import '../widgets/claim_card.dart';

/// All claims: YTD money strip, unclaimed-bills chip, then claims grouped
/// into needs-attention / in-progress / history.
class ClaimsPage extends ConsumerWidget {
  const ClaimsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;

    final claims = ref.watch(claimsListProvider).value ?? const <Claim>[];
    final links =
        ref.watch(claimLinksProvider).value ?? const <ClaimDocument>[];
    final unclaimed =
        ref.watch(unclaimedBillsProvider).value ?? const <Document>[];
    final now = DateTime.now();

    final docCounts = <String, int>{};
    for (final link in links) {
      docCounts[link.claimId] = (docCounts[link.claimId] ?? 0) + 1;
    }

    final stale = staleSubmitted(claims, now).map((c) => c.id).toSet();
    final attention = claims
        .where((c) => c.status == ClaimStatus.draft || stale.contains(c.id))
        .toList();
    final inProgress = claims
        .where((c) =>
            c.status == ClaimStatus.submitted && !stale.contains(c.id))
        .toList();
    final history = claims.where((c) => c.status.isOutcome).toList();
    final totals = ytdTotals(claims, now);

    return Scaffold(
      backgroundColor: colors.bgSection,
      appBar: AppBar(
        backgroundColor: colors.bgSection,
        leading: BackButton(color: colors.ink),
        toolbarHeight: 44,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed('claimEdit'),
        label: Text(l10n.claimNew),
        icon: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: claims.isEmpty && unclaimed.isEmpty
            ? EmptyState(
                icon: Icons.receipt_long_outlined,
                title: l10n.claimsEmptyTitle,
                message: l10n.claimsEmpty,
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 96),
                children: [
                  Text(l10n.claimsTitle,
                      style: typo.pageTitle.copyWith(fontSize: 25)),
                  const SizedBox(height: 10),
                  _YtdSummaryCard(totals: totals),
                  if (unclaimed.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _UnclaimedStrip(bills: unclaimed),
                  ],
                  for (final (title, group) in [
                    (l10n.claimSectionAttention, attention),
                    (l10n.claimSectionInProgress, inProgress),
                    (l10n.claimSectionHistory, history),
                  ])
                    if (group.isNotEmpty) ...[
                      SectionHeader(title: title),
                      for (final claim in group) ...[
                        ClaimCard(
                          claim: claim,
                          docCount: docCounts[claim.id] ?? 0,
                          onTap: () => context.pushNamed(
                            'claimDetail',
                            pathParameters: {'id': claim.id},
                          ),
                        ),
                        const SizedBox(height: 7),
                      ],
                    ],
                ],
              ),
      ),
    );
  }
}

/// The year's two headline numbers, side by side: what was asked from
/// the insurer and what actually came back.
class _YtdSummaryCard extends StatelessWidget {
  const _YtdSummaryCard({required this.totals});

  final ({int claimedPaise, int recoveredPaise}) totals;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;

    Widget cell(String label, int paise, Color amountColor) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: typo.caption.copyWith(color: colors.muted)),
            const SizedBox(height: 3),
            Text(
              formatPaise(paise),
              style: typo.number(19,
                  weight: FontWeight.w700, color: amountColor),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Row(
        children: [
          cell(l10n.claimsYtdClaimed, totals.claimedPaise, colors.ink),
          cell(
            l10n.claimsYtdRecovered,
            totals.recoveredPaise,
            totals.recoveredPaise > 0 ? colors.green : colors.ink,
          ),
        ],
      ),
    );
  }
}

/// Amber strip listing bills not yet in any claim, with days-left labels
/// when a policy defines the window.
class _UnclaimedStrip extends ConsumerWidget {
  const _UnclaimedStrip({required this.bills});

  final List<Document> bills;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;
    final policies =
        ref.watch(policiesProvider).value ?? const <InsurancePolicy>[];
    final windowDays = policies.isEmpty
        ? null
        : minClaimWindowDays(policies.map((p) => p.claimWindowDays));
    final now = DateTime.now();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colors.amberBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.amberBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.unclaimedBillsChip(bills.length),
            style: typo.overline.copyWith(fontSize: 11, color: colors.amber),
          ),
          for (final bill in bills.take(3)) ...[
            const SizedBox(height: 5),
            Text(
              windowDays == null
                  ? bill.title
                  : switch (
                      daysUntilDeadline(bill.documentDate, windowDays, now)) {
                      < 0 => '${bill.title} — ${l10n.claimOverdue}',
                      final days =>
                        '${bill.title} — ${l10n.claimDaysLeft(days)}',
                    },
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: typo.caption.copyWith(color: colors.ink),
            ),
          ],
        ],
      ),
    );
  }
}
