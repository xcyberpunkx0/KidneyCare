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
  MedFoodRelation _food = MedFoodRelation.withFood;
  Set<MedTimeOfDay> _times = {MedTimeOfDay.morning};
  MedFrequency _freq = MedFrequency.daily;

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
      _food = med.foodRelation;
      _times = _decodeTimes(med.timeOfDayJson);
      _freq = med.frequency;
      if (med.intervalDays != null) {
        _interval.text = '${med.intervalDays}';
      }
    });
  }

  Set<MedTimeOfDay> _decodeTimes(String json) {
    final raw = jsonDecode(json);
    if (raw is! List) return {};
    return {
      for (final name in raw.whereType<String>())
        if (MedTimeOfDay.values.asNameMap().containsKey(name))
          MedTimeOfDay.values.byName(name),
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
      foodRelation: _food,
      timesOfDay: Set.of(_times),
      frequency: _freq,
      scheduleNote: _note.text.trim(),
      startDate: DateTime.now(),
      intervalDays: _freq == MedFrequency.everyNDays
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
              label: l10n.foodRelationLabel,
              child: Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  for (final food in MedFoodRelation.values)
                    AppChoiceChip(
                      label: food.localizedLabel(l10n),
                      selected: _food == food,
                      onTap: () => setState(() => _food = food),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 9),
            LabeledFieldCard(
              label: l10n.timeOfDayLabel,
              child: Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  for (final time in MedTimeOfDay.values)
                    AppChoiceChip(
                      label: time.localizedLabel(l10n),
                      selected: _times.contains(time),
                      onTap: () => setState(() {
                        _times.contains(time)
                            ? _times.remove(time)
                            : _times.add(time);
                      }),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 9),
            LabeledFieldCard(
              label: l10n.howOftenLabel,
              child: Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  for (final freq in MedFrequency.values)
                    AppChoiceChip(
                      label: freq.localizedLabel(l10n),
                      selected: _freq == freq,
                      onTap: () => setState(() => _freq = freq),
                    ),
                ],
              ),
            ),
            if (_freq == MedFrequency.everyNDays) ...[
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
