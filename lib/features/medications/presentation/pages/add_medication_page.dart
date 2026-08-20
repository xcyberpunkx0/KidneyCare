import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_choice_chip.dart';
import '../../../../core/widgets/labeled_field_card.dart';
import '../../../../shared/domain/med_schedule.dart';
import '../../data/repository_impl/medications_repository_impl.dart';
import '../../domain/entities/new_medication.dart';
import '../controllers/add_medication_controller.dart';

/// Manual medicine entry — for prescriptions given verbally or lost, with
/// the same schedule vocabulary the rest of the app uses. With a
/// [medicationId] the same form corrects that stored medicine instead.
class AddMedicationPage extends ConsumerStatefulWidget {
  const AddMedicationPage({super.key, this.medicationId});

  final String? medicationId;

  @override
  ConsumerState<AddMedicationPage> createState() => _AddMedicationPageState();
}

class _AddMedicationPageState extends ConsumerState<AddMedicationPage> {
  final _name = TextEditingController();
  final _frequency = TextEditingController(text: '1-0-1');
  final _purpose = TextEditingController();
  final _doctor = TextEditingController();
  final _note = TextEditingController();
  final _interval = TextEditingController(text: '7');
  MedScheduleGroup _group = MedScheduleGroup.withFood;
  Set<MedTimingCue> _cues = {MedTimingCue.withFood};

  bool get _isEditing => widget.medicationId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) _prefill();
  }

  Future<void> _prefill() async {
    final med = await ref
        .read(medicationsRepositoryProvider)
        .getMedication(widget.medicationId!);
    if (med == null || !mounted) return;
    setState(() {
      _name.text = med.name;
      _frequency.text = med.frequencyCode;
      _purpose.text = med.purpose;
      _doctor.text = med.doctor;
      _note.text = med.scheduleNote;
      _group = med.scheduleGroup;
      _cues = _decodeCues(med.timingCuesJson);
      if (med.intervalDays != null) {
        _interval.text = '${med.intervalDays}';
      }
    });
  }

  Set<MedTimingCue> _decodeCues(String json) {
    final raw = jsonDecode(json);
    if (raw is! List) return {};
    return {
      for (final name in raw.whereType<String>())
        if (MedTimingCue.values.asNameMap().containsKey(name))
          MedTimingCue.values.byName(name),
    };
  }

  @override
  void dispose() {
    for (final controller in [
      _name,
      _frequency,
      _purpose,
      _doctor,
      _note,
      _interval,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final medication = NewMedication(
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
      intervalDays: _group == MedScheduleGroup.weekly
          ? int.tryParse(_interval.text.trim())
          : null,
    );
    final controller = ref.read(addMedicationProvider.notifier);
    final saved = _isEditing
        ? await controller.update(widget.medicationId!, medication)
        : await controller.save(medication);
    if (saved && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? context.l10n.medicineUpdated
                : context.l10n.medicineAdded,
          ),
        ),
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.message)));
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
            Text(
              _isEditing ? l10n.editMedicine : l10n.addAMedicine,
              style: typo.pageTitle.copyWith(fontSize: 24),
            ),
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
            if (_group == MedScheduleGroup.weekly) ...[
              const SizedBox(height: 9),
              LabeledFieldCard(
                label: l10n.repeatEveryDays,
                child: Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    for (final days in const [5, 7, 15, 30])
                      AppChoiceChip(
                        label: l10n.nDaysChip(days),
                        selected: int.tryParse(_interval.text.trim()) == days,
                        onTap: () => setState(() => _interval.text = '$days'),
                      ),
                    SizedBox(
                      width: 76,
                      child: TextField(
                        controller: _interval,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        style: typo.cardTitle.copyWith(
                          fontWeight: FontWeight.w500,
                          color: colors.ink,
                        ),
                        cursorColor: colors.accent,
                        decoration: InputDecoration(
                          isDense: true,
                          filled: true,
                          fillColor: colors.fieldBg,
                          hintText: '7',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: colors.fieldBorder,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: colors.accent,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
                      state.saving
                          ? l10n.saving
                          : _isEditing
                          ? l10n.saveChanges
                          : l10n.addMedicineButton,
                      style: typo.cardTitle.copyWith(
                        fontSize: 15,
                        color: colors.onAccent,
                      ),
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
