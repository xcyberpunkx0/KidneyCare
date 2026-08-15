import 'package:flutter/material.dart';

import '../../shared/domain/timeline_event_type.dart';
import '../l10n/l10n_x.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_typography.dart';
import 'app_card.dart';

/// One record row: circular tinted icon, title, subtitle, date. Used for
/// "Recent records" on home and every entry of the medical timeline.
class RecordTile extends StatelessWidget {
  const RecordTile({
    super.key,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.dateLabel,
    this.highlightedSubtitlePart,
    this.onTap,
  });

  final TimelineEventType type;
  final String title;
  final String subtitle;
  final String dateLabel;

  /// Portion of [subtitle] to render in amber (e.g. "2 values off").
  final String? highlightedSubtitlePart;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final (icon, bg, fg) = _iconFor(type, colors);

    return AppCard(
      onTap: onTap,
      semanticLabel:
          '${type.localizedLabel(context.l10n)}: $title, $subtitle, '
          '$dateLabel',
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(icon, size: 16, color: fg),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: typo.cardTitle,
                ),
                const SizedBox(height: 1),
                _subtitleText(colors, typo),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            dateLabel,
            style: typo.caption.copyWith(color: colors.muted),
          ),
        ],
      ),
    );
  }

  Widget _subtitleText(AppColors colors, AppTypography typo) {
    final base = typo.caption.copyWith(color: colors.muted);
    final highlight = highlightedSubtitlePart;
    if (highlight == null || !subtitle.contains(highlight)) {
      return Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: base,
      );
    }
    final index = subtitle.indexOf(highlight);
    return Text.rich(
      TextSpan(
        text: subtitle.substring(0, index),
        style: base,
        children: [
          TextSpan(
            text: highlight,
            style: base.copyWith(
              color: colors.amber,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(text: subtitle.substring(index + highlight.length)),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  (IconData, Color, Color) _iconFor(TimelineEventType type, AppColors colors) {
    return switch (type) {
      TimelineEventType.labReport =>
        (Icons.science_outlined, colors.purpleBg, colors.purple),
      TimelineEventType.prescription ||
      TimelineEventType.medicationChange =>
        (Icons.medication_outlined, colors.greenBg, colors.green),
      TimelineEventType.dialysis =>
        (Icons.water_drop_outlined, colors.blueBg, colors.blue),
      TimelineEventType.admission =>
        (Icons.local_hospital_outlined, colors.orangeBg, colors.orange),
      TimelineEventType.discharge =>
        (Icons.assignment_outlined, colors.blueBg, colors.blue),
      TimelineEventType.procedure =>
        (Icons.healing_outlined, colors.orangeBg, colors.orange),
      TimelineEventType.doctorVisit =>
        (Icons.badge_outlined, colors.accentSoft, colors.onAccentSoft),
      TimelineEventType.bill =>
        (Icons.receipt_long_outlined, colors.purpleBg, colors.purple),
      TimelineEventType.symptom =>
        (Icons.monitor_heart_outlined, colors.amberBg, colors.amber),
      TimelineEventType.claim =>
        (Icons.receipt_long_outlined, colors.greenBg, colors.green),
    };
  }
}
