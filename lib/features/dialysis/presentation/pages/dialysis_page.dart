import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/router/app_shell.dart';
import '../../../../core/storage/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_format_x.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../home/presentation/widgets/dialysis_hero_card.dart';

import '../controllers/dialysis_providers.dart';

/// Dialysis — the schedule and every completed session, newest first.
class DialysisPage extends ConsumerWidget {
  const DialysisPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;
    final next = ref.watch(nextSessionProvider).value;
    final last = ref.watch(lastSessionProvider).value;
    final history =
        ref.watch(sessionHistoryProvider).value ?? const <DialysisSession>[];

    return Scaffold(
      backgroundColor: colors.bgSection,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: AppShell.navClearance),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.dialysis,
                      style: typo.pageTitle.copyWith(fontSize: 25),
                    ),
                  ),
                  Text(
                    l10n.nLogged(history.length),
                    style: typo.bodySmall.copyWith(color: colors.muted),
                  ),
                  const SizedBox(width: 10),
                  _LogButton(
                      onTap: () => context.pushNamed('sessionLog')),
                ],
              ),
            ),
            DialysisHeroCard(next: next, last: last),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 10, 22, 6),
              child: Text(
                l10n.sessionHistory,
                style: typo.sectionTitle.copyWith(fontSize: 15),
              ),
            ),
            if (history.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: EmptyState(
                  icon: Icons.water_drop_outlined,
                  title: l10n.noSessionsTitle,
                  message: l10n.noSessionsMessage,
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Column(
                  children: [
                    for (final session in history) ...[
                      _SessionCard(session: session),
                      const SizedBox(height: 8),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LogButton extends StatelessWidget {
  const _LogButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      button: true,
      label: context.l10n.logASession,
      child: Material(
        color: colors.accentSoft,
        shape: const StadiumBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, size: 14, color: colors.onAccentSoft),
                const SizedBox(width: 3),
                Text(
                  context.l10n.log,
                  style: context.typo.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.onAccentSoft,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session});

  final DialysisSession session;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final duration = session.durationHours;

    final details = <String>[
      if (session.ultrafiltrationL != null)
        'UF ${session.ultrafiltrationL!.toStringAsFixed(1)} L',
      if (session.preWeightKg != null && session.postWeightKg != null)
        '${session.preWeightKg!.toStringAsFixed(1)} → '
            '${session.postWeightKg!.toStringAsFixed(1)} kg',
      if (session.note.isNotEmpty) session.note,
    ];

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.blueBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.water_drop_outlined,
                size: 18, color: colors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.scheduledAt.monthDayYear,
                  style: typo.cardTitle.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 1),
                Text(
                  details.isEmpty
                      ? context.l10n.logged
                      : details.join(' · '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: typo.caption.copyWith(color: colors.muted),
                ),
              ],
            ),
          ),
          if (duration != null) ...[
            const SizedBox(width: 8),
            Text(
              duration % 1 == 0
                  ? '${duration.toInt()} h'
                  : '${duration.toStringAsFixed(1)} h',
              style: typo.number(13,
                  weight: FontWeight.w600, color: colors.blue),
            ),
          ],
        ],
      ),
    );
  }
}
