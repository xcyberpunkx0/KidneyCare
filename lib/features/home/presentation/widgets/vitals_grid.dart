import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/widgets/metric_tile.dart';
import '../../domain/entities/vital_reading.dart';

/// Three-column grid of summary metric tiles.
class VitalsGrid extends StatelessWidget {
  const VitalsGrid({super.key, required this.readings, this.onTileTap});

  final List<VitalReading> readings;
  final void Function(VitalReading reading)? onTileTap;

  String _label(AppLocalizations l10n, VitalKind kind) => switch (kind) {
        VitalKind.dryWeight => l10n.vitalDryWeight,
        VitalKind.hemoglobin => l10n.vitalHb,
        VitalKind.potassium => l10n.vitalPotassium,
        VitalKind.bloodPressure => l10n.vitalBpToday,
        VitalKind.albumin => l10n.vitalAlbumin,
        VitalKind.activeMeds => l10n.vitalActiveMeds,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: GridView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: readings.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          mainAxisExtent: 68,
        ),
        itemBuilder: (context, index) {
          final reading = readings[index];
          final tile = MetricTile(
            label: _label(l10n, reading.kind),
            value: reading.value,
            abnormal: reading.abnormal,
            trend: reading.trend,
            deltaNote: reading.deltaNote,
          );
          if (reading.metricCode == null || onTileTap == null) return tile;
          return GestureDetector(
            onTap: () => onTileTap!(reading),
            child: tile,
          );
        },
      ),
    );
  }
}
