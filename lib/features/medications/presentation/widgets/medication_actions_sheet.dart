import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/storage/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/repository_impl/medications_repository_impl.dart';

/// The ⋮ / long-press menu on a medication card: correct a wrongly
/// entered medicine, mark it ended, or delete it outright.
Future<void> showMedicationActions(
  BuildContext context,
  WidgetRef ref,
  Medication medication,
) {
  final l10n = context.l10n;
  final isEnded = medication.endDate != null;
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: context.colors.bgSection,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 6),
            child: Text(
              medication.name,
              style: context.typo.sectionTitle.copyWith(fontSize: 15),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.edit_outlined, size: 20),
            title: Text(l10n.editMedicine),
            onTap: () {
              Navigator.pop(sheetContext);
              context.pushNamed(
                'addMedication',
                queryParameters: {'id': medication.id},
              );
            },
          ),
          if (!isEnded)
            ListTile(
              leading: const Icon(Icons.event_busy_outlined, size: 20),
              title: Text(l10n.endMedicine),
              onTap: () async {
                Navigator.pop(sheetContext);
                await ref
                    .read(medicationsRepositoryProvider)
                    .endMedication(medication.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(l10n.medicineEnded)));
                }
              },
            ),
          ListTile(
            leading: const Icon(Icons.delete_outline, size: 20),
            title: Text(l10n.deleteMedicine),
            onTap: () {
              Navigator.pop(sheetContext);
              _confirmDelete(context, ref, medication);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

Future<void> _confirmDelete(
  BuildContext context,
  WidgetRef ref,
  Medication medication,
) async {
  final l10n = context.l10n;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      content: Text(l10n.deleteMedicineConfirm),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(l10n.deleteMedicine),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  await ref.read(medicationsRepositoryProvider).deleteMedication(medication.id);
  if (context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.medicineDeleted)));
  }
}
