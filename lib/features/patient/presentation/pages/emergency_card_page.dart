import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/storage/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../medications/data/repository_impl/medications_repository_impl.dart';
import '../../data/repository_impl/patient_repository_impl.dart';

/// The emergency card: everything an unfamiliar doctor needs in the first
/// minute — condition, blood group, allergies, key medicines, contact.
/// Shareable as plain text so it works over any messenger.
class EmergencyCardPage extends ConsumerWidget {
  const EmergencyCardPage({super.key});

  String _cardText(Patient patient, List<Medication> meds) {
    // Share text stays English for medical staff.
    final lines = [
      'EMERGENCY MEDICAL CARD',
      '${patient.name}, ${patient.age}',
      patient.conditionSummary,
      if (patient.comorbidities.isNotEmpty)
        'Also has: ${patient.comorbidities}',
      if (patient.bloodGroup.isNotEmpty)
        'Blood group: ${patient.bloodGroup}',
      'Allergies: '
          '${patient.allergies.isEmpty ? 'none known' : patient.allergies}',
      if (patient.dialysisCenter.isNotEmpty)
        'Dialysis centre: ${patient.dialysisCenter}',
      if (meds.isNotEmpty)
        'Medicines: ${meds.map((m) => m.name).join(', ')}',
      if (patient.emergencyContact.isNotEmpty)
        'Emergency contact: ${patient.emergencyContact}',
      '— shared from KidneyCare',
    ];
    return lines.join('\n');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;
    final patient = ref.watch(patientProvider).value;
    final meds =
        ref.watch(activeMedicationsProvider).value ?? const <Medication>[];

    return Scaffold(
      backgroundColor: colors.bgSection,
      appBar: AppBar(
        backgroundColor: colors.bgSection,
        leading: BackButton(color: colors.ink),
        toolbarHeight: 44,
      ),
      body: SafeArea(
        child: patient == null
            ? EmptyState(
                icon: Icons.medical_information_outlined,
                title: l10n.noPatientTitle,
                message: l10n.noPatientMessage,
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
                children: [
                  Text(l10n.emergencyCardTitle,
                      style: typo.pageTitle.copyWith(fontSize: 24)),
                  const SizedBox(height: 4),
                  Text(
                    l10n.emergencyCardCopy,
                    style: typo.body.copyWith(color: colors.muted),
                  ),
                  const SizedBox(height: 16),
                  _CardBody(patient: patient, meds: meds),
                  const SizedBox(height: 18),
                  Material(
                    color: colors.accent,
                    borderRadius: BorderRadius.circular(99),
                    child: InkWell(
                      onTap: () => Share.share(
                        _cardText(patient, meds),
                        subject: 'Emergency medical card — '
                            '${patient.name}',
                      ),
                      borderRadius: BorderRadius.circular(99),
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: 15),
                        child: Center(
                          child: Text(
                            l10n.shareCard,
                            style: typo.cardTitle.copyWith(
                                fontSize: 15, color: colors.onAccent),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _CardBody extends StatelessWidget {
  const _CardBody({required this.patient, required this.meds});

  final Patient patient;
  final List<Medication> meds;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;

    return Container(
      decoration: BoxDecoration(
        gradient: colors.brandGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: colors.heroShadow,
      ),
      padding: const EdgeInsets.all(2.5),
      child: Container(
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(26),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(patient.name,
                          style: typo.pageTitle.copyWith(fontSize: 20)),
                      Text(
                        '${patient.age} · ${patient.conditionSummary}',
                        style:
                            typo.bodySmall.copyWith(color: colors.muted),
                      ),
                    ],
                  ),
                ),
                if (patient.bloodGroup.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: colors.criticalBg,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      patient.bloodGroup,
                      style: typo.number(18, color: colors.critical),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            if (patient.comorbidities.isNotEmpty)
              _InfoRow(
                label: l10n.otherConditionsLabel,
                value: patient.comorbidities,
                emphasized: true,
              ),
            _InfoRow(
              label: l10n.allergiesLabel,
              value: patient.allergies.isEmpty
                  ? l10n.noneKnown
                  : patient.allergies,
              emphasized: patient.allergies.isNotEmpty,
            ),
            if (patient.dialysisCenter.isNotEmpty)
              _InfoRow(
                  label: l10n.dialysisCentreLabel,
                  value: patient.dialysisCenter),
            if (meds.isNotEmpty)
              _InfoRow(
                label: l10n.medicinesLabel,
                value: meds.map((m) => m.name).join(' · '),
              ),
            if (patient.emergencyContact.isNotEmpty)
              _InfoRow(
                  label: l10n.emergencyContactLabel,
                  value: patient.emergencyContact),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: typo.overline
                .copyWith(fontSize: 9.5, color: colors.muted),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: typo.cardTitle.copyWith(
              color: emphasized ? colors.critical : colors.ink,
              fontWeight:
                  emphasized ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
