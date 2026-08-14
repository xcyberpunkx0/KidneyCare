import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/storage/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_format_x.dart';

/// The pinned "next dialysis" hero card with a countdown progress ring.
class DialysisHeroCard extends StatelessWidget {
  const DialysisHeroCard({super.key, required this.next, required this.last});

  final DialysisSession? next;
  final DialysisSession? last;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;
    final now = DateTime.now();

    final title = next == null
        ? l10n.notScheduled
        : next!.scheduledAt.weekdayTime;
    final hours = next?.scheduledAt.difference(now).inHours ?? 0;
    final countdown = next == null
        ? ''
        : ' · ${hours <= 0 ? l10n.now : l10n.inHours(hours)}';
    final lastLine = _lastSessionLine(l10n);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        gradient: colors.heroBg,
        borderRadius: BorderRadius.circular(AppRadius.hero),
        border: Border.all(color: colors.heroBorder),
        boxShadow: colors.heroShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.nextDialysis,
                  style: typo.overline.copyWith(
                    fontSize: 10,
                    color: colors.heroLabel,
                  ),
                ),
                const SizedBox(height: 3),
                Text.rich(
                  TextSpan(
                    text: title,
                    children: [
                      TextSpan(
                        text: countdown,
                        style: typo.bodySmall.copyWith(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: colors.heroMuted,
                        ),
                      ),
                    ],
                  ),
                  style: typo.number(18, color: colors.heroInk),
                ),
                const SizedBox(height: 2),
                Text(
                  lastLine,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: typo.caption.copyWith(color: colors.heroMuted),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 50,
            height: 50,
            child: CustomPaint(
              painter: _RingPainter(
                progress: _intervalProgress(now),
                trackColor: colors.heroRingBg,
                ringColor: colors.heroRing,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _lastSessionLine(AppLocalizations l10n) {
    if (next == null && last == null) {
      return l10n.addScheduleHint;
    }
    final center = next?.center ?? last?.center ?? '';
    if (last == null) return center;
    final uf = last!.ultrafiltrationL;
    final parts = [
      last!.scheduledAt.weekdayTime.split(',').first,
      if (uf != null) 'UF ${uf.toStringAsFixed(1)} L',
      if (last!.note.isNotEmpty) last!.note,
    ];
    return '$center · ${l10n.lastSession(parts.join(', '))}';
  }

  /// Fraction of the inter-session interval already elapsed.
  double _intervalProgress(DateTime now) {
    if (next == null || last == null) return 0;
    final total = next!.scheduledAt.difference(last!.scheduledAt).inMinutes;
    if (total <= 0) return 0;
    final elapsed = now.difference(last!.scheduledAt).inMinutes;
    return (elapsed / total).clamp(0.0, 1.0);
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.trackColor,
    required this.ringColor,
  });

  final double progress;
  final Color trackColor;
  final Color ringColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    const strokeWidth = 5.0;
    final radius = size.width / 2 - strokeWidth / 2;

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = trackColor;
    canvas.drawCircle(center, radius, track);

    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = ringColor;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      ring,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.ringColor != ringColor ||
      oldDelegate.trackColor != trackColor;
}
