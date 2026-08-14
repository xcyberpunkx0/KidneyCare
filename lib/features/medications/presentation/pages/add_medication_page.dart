import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_choice_chip.dart';
import '../../../../core/widgets/labeled_field_card.dart';
import '../../../../shared/domain/med_schedule.dart';
import '../../domain/entities/new_medication.dart';
import '../controllers/add_medication_controller.dart';

/// Manual medicine entry — for prescriptions given verbally or lost, with
/// the same schedule vocabulary the rest of the app uses.
class AddMedicationPage extends ConsumerStatefulWidget {
  const AddMedicationPage({super.key});

  @override
  ConsumerState<AddMedicationPage> createState() =>
      _AddMedicationPageState();
}

class _AddMedicationPageState extends ConsumerState<AddMedicationPage> {
  final _name = TextEditingController();
  final _frequency = TextEditingController(text: '1-0-1');
  final _purpose = TextEditingController();
  final _doctor = TextEditingController();
  final _note = TextEditingController();
  MedScheduleGroup _group = MedScheduleGroup.withFood;
  final Set<MedTimingCue> _cues = {MedTimingCue.withFood};

  @override
  void dispose() {
    for (final controller in [_name, _frequency, _purpose, _doctor, _note]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final saved =
        await ref.read(addMedicationProvider.notifier).save(NewMedication(
              name: _name.text.trim(),
              frequencyCode: _frequency.text.trim().isEmpty
                  ? '—'
                  : _frequency.text.trim(),
              purpose: _purpose.text.trim(),
              doctor: _doctor.text.trim(),
              scheduleGroup: _group,
              timingCues: Set.of(_cues),
              scheduleNote: _note.text.trim(),
              startDate: DateTime.now(),
            ));
    if (saved && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.medicineAdded)),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;
    final state = ref.watch(addMedicationProvider);

    ref.listen(addMedicationProvider, (previous, next) {
      final failure = next.failure;
      if (failure != null && failure != previous?.failure) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(failure.message)));
        ref.read(addMedicationProvider.notifier).dismissFailure();
      }
    });

    return Scaffold(
      backgroundColor: colors.bgSection,
      appBar: AppBar(
        backgroundColor: colors.bgSection,
        leading: BackButton(color: colors.ink),
        toolbarHeight: 44,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
          children: [
            Text(l10n.addAMedicine,
                style: typo.pageTitle.copyWith(fontSize: 24)),
            const SizedBox(height: 4),
            Text(
              l10n.addMedicineCopy,
              style: typo.body.copyWith(color: colors.muted),
            ),
            const SizedBox(height: 16),
            LabeledFieldCard(
              label: l10n.medicineStrength,
              controller: _name,
              hint: l10n.medicineStrengthHint,
            ),
            const SizedBox(height: 9),
            Row(
              children: [
                Expanded(
                  child: LabeledFieldCard(
                    label: l10n.pattern,
                    controller: _frequency,
                    hint: '1-0-1',
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  flex: 2,
                  child: LabeledFieldCard(
                    label: l10n.purpose,
                    controller: _purpose,
                    hint: l10n.purposeHint,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            LabeledFieldCard(
              label: l10n.prescribedBy,
              controller: _doctor,
              hint: l10n.prescribedByHint,
            ),
            const SizedBox(height: 9),
            LabeledFieldCard(
              label: l10n.whenTaken,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      for (final group in MedScheduleGroup.values)
                        AppChoiceChip(
                          label: group.localizedLabel(l10n),
                          selected: _group == group,
                          onTap: () => setState(() => _group = group),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.timingCuesHint,
                    style: typo.caption.copyWith(color: colors.muted),
                  ),
                  const SizedBox(height: 7),
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      for (final cue in MedTimingCue.values)
                        AppChoiceChip(
                          label: cue.localizedLabel(l10n),
                          selected: _cues.contains(cue),
                          onTap: () => setState(() {
                            _cues.contains(cue)
                                ? _cues.remove(cue)
                                : _cues.add(cue);
                          }),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 9),
            LabeledFieldCard(
              label: l10n.instructions,
              controller: _note,
              hint: l10n.instructionsHint,
            ),
            const SizedBox(height: 18),
            Material(
              color: colors.accent,
              borderRadius: BorderRadius.circular(99),
              child: InkWell(
                onTap: state.saving ? null : _save,
                borderRadius: BorderRadius.circular(99),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Center(
                    child: Text(
                      state.saving ? l10n.saving : l10n.addMedicineButton,
                      style: typo.cardTitle
                          .copyWith(fontSize: 15, color: colors.onAccent),
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
