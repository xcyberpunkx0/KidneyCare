import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/storage/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_choice_chip.dart';
import '../../../../core/widgets/labeled_field_card.dart';
import '../../domain/entities/patient_profile.dart';
import '../controllers/patient_setup_controller.dart';

/// Patient details form: shown at first launch (onboarding) and again
/// from settings for edits. Each dialysis day carries its own session
/// time, since schedules often differ between days.
class PatientSetupPage extends ConsumerStatefulWidget {
  const PatientSetupPage({super.key, this.existing});

  /// When set, the form edits this patient instead of onboarding.
  final Patient? existing;

  bool get isOnboarding => existing == null;

  @override
  ConsumerState<PatientSetupPage> createState() => _PatientSetupPageState();
}

class _PatientSetupPageState extends ConsumerState<PatientSetupPage> {
  late final TextEditingController _name;
  late final TextEditingController _age;
  late final TextEditingController _condition;
  late final TextEditingController _center;
  late final TextEditingController _dryWeight;
  late final TextEditingController _allergies;
  late final TextEditingController _emergencyContact;
  late final TextEditingController _otherConditions;
  String _bloodGroup = '';
  final Set<String> _comorbidities = {};

  static const _bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-',
  ];

  /// Canonical English comorbidity names — stored and shared in English
  /// so emergency staff and reports read them unambiguously; the chips
  /// display localized labels.
  static const _commonComorbidities = [
    'Diabetes',
    'Hypertension',
    'Heart disease',
    'Thyroid disorder',
    'Chronic pancreatitis',
  ];

  String _comorbidityLabel(AppLocalizations l10n, String canonical) =>
      switch (canonical) {
        'Diabetes' => l10n.comorbidityDiabetes,
        'Hypertension' => l10n.comorbidityHypertension,
        'Heart disease' => l10n.comorbidityHeartDisease,
        'Thyroid disorder' => l10n.comorbidityThyroid,
        _ => l10n.comorbidityPancreatitis,
      };

  /// Weekday → session start in minutes past midnight.
  late final Map<int, int> _schedule;

  static const _defaultMinutes = 7 * 60;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _name = TextEditingController(text: existing?.name ?? '');
    _age = TextEditingController(text: existing?.age.toString() ?? '');
    _condition = TextEditingController(
        text: existing?.conditionSummary.split(',').first ?? 'CKD-5');
    _center = TextEditingController(text: existing?.dialysisCenter ?? '');
    _dryWeight = TextEditingController(
        text: existing?.dryWeightKg.toStringAsFixed(1) ?? '');
    _allergies = TextEditingController(text: existing?.allergies ?? '');
    _emergencyContact =
        TextEditingController(text: existing?.emergencyContact ?? '');
    _bloodGroup = existing?.bloodGroup ?? '';
    final stored = (existing?.comorbidities ?? '')
        .split(',')
        .map((entry) => entry.trim())
        .where((entry) => entry.isNotEmpty);
    final extras = <String>[];
    for (final entry in stored) {
      _commonComorbidities.contains(entry)
          ? _comorbidities.add(entry)
          : extras.add(entry);
    }
    _otherConditions = TextEditingController(text: extras.join(', '));
    _schedule = existing == null
        ? {
            DateTime.monday: _defaultMinutes,
            DateTime.wednesday: _defaultMinutes,
            DateTime.friday: _defaultMinutes,
          }
        : PatientProfile.scheduleFromJson(existing.scheduleJson);
  }

  @override
  void dispose() {
    for (final controller in [
      _name, _age, _condition, _center, _dryWeight, //
      _allergies, _emergencyContact, _otherConditions,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickTime(int day) async {
    final current = _schedule[day] ?? _defaultMinutes;
    final l10n = context.l10n;
    final picked = await showTimePicker(
      context: context,
      initialTime:
          TimeOfDay(hour: current ~/ 60, minute: current % 60),
      helpText: l10n.sessionTimeOn(localizedWeekday(l10n, day)),
    );
    if (picked != null) {
      setState(() => _schedule[day] = picked.hour * 60 + picked.minute);
    }
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    final age = int.tryParse(_age.text.trim());
    final dryWeight = double.tryParse(_dryWeight.text.trim());
    if (name.isEmpty || age == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(context.l10n.fillNameAge),
      ));
      return;
    }
    final saved =
        await ref.read(patientSetupProvider.notifier).save(PatientProfile(
              name: name,
              age: age,
              condition: _condition.text.trim(),
              schedule: Map.of(_schedule),
              center: _center.text.trim(),
              dryWeightKg: dryWeight ?? 0,
              bloodGroup: _bloodGroup,
              allergies: _allergies.text.trim(),
              emergencyContact: _emergencyContact.text.trim(),
              comorbidities: [
                for (final canonical in _commonComorbidities)
                  if (_comorbidities.contains(canonical)) canonical,
                ..._otherConditions.text
                    .split(',')
                    .map((entry) => entry.trim())
                    .where((entry) => entry.isNotEmpty),
              ].join(', '),
            ));
    if (saved && mounted) {
      if (widget.isOnboarding) {
        context.go(AppRoutes.home);
      } else {
        context.pop();
      }
    }
  }

  Future<void> _exploreDemo() async {
    final seeded =
        await ref.read(patientSetupProvider.notifier).exploreWithSampleData();
    if (seeded && mounted) context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;
    final state = ref.watch(patientSetupProvider);

    ref.listen(patientSetupProvider, (previous, next) {
      final failure = next.failure;
      if (failure != null && failure != previous?.failure) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(failure.message)));
        ref.read(patientSetupProvider.notifier).dismissFailure();
      }
    });

    return Scaffold(
      backgroundColor: colors.bgSection,
      appBar: widget.isOnboarding
          ? null
          : AppBar(
              backgroundColor: colors.bgSection,
              leading: BackButton(color: colors.ink),
              toolbarHeight: 44,
            ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
          children: [
            Text(
              widget.isOnboarding
                  ? l10n.setUpVault
                  : l10n.patientDetails,
              style: typo.pageTitle.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 4),
            Text(
              widget.isOnboarding
                  ? l10n.setUpVaultCopy
                  : l10n.patientEditCopy,
              style: typo.body.copyWith(color: colors.muted),
            ),
            const SizedBox(height: 16),
            LabeledFieldCard(label: l10n.fullName, controller: _name,
                hint: l10n.fullNameHint),
            const SizedBox(height: 9),
            Row(
              children: [
                Expanded(
                  child: LabeledFieldCard(
                    label: l10n.age,
                    controller: _age,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  flex: 2,
                  child: LabeledFieldCard(
                    label: l10n.condition,
                    controller: _condition,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            LabeledFieldCard(
              label: l10n.otherConditions,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      for (final canonical in _commonComorbidities)
                        AppChoiceChip(
                          label: _comorbidityLabel(l10n, canonical),
                          selected: _comorbidities.contains(canonical),
                          onTap: () => setState(() {
                            _comorbidities.contains(canonical)
                                ? _comorbidities.remove(canonical)
                                : _comorbidities.add(canonical);
                          }),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _otherConditions,
                    style: typo.cardTitle.copyWith(
                      fontWeight: FontWeight.w500,
                      color: colors.ink,
                    ),
                    cursorColor: colors.accent,
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: colors.fieldBg,
                      hintText: l10n.otherConditionsHint,
                      hintStyle: typo.cardTitle.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colors.muted,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: colors.fieldBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: colors.accent, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 9),
            LabeledFieldCard(
              label: l10n.dialysisSchedule,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      for (final day in PatientProfile.dayNames.keys)
                        AppChoiceChip(
                          label: localizedWeekday(l10n, day),
                          selected: _schedule.containsKey(day),
                          onTap: () => setState(() {
                            _schedule.containsKey(day)
                                ? _schedule.remove(day)
                                : _schedule[day] = _defaultMinutes;
                          }),
                        ),
                    ],
                  ),
                  if (_schedule.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      l10n.tapTimeHint,
                      style: typo.caption.copyWith(color: colors.muted),
                    ),
                    const SizedBox(height: 4),
                    for (final day in _schedule.keys.toList()..sort())
                      _DayTimeRow(
                        dayLabel: localizedWeekday(l10n, day),
                        minutes: _schedule[day]!,
                        onTap: () => _pickTime(day),
                      ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 9),
            LabeledFieldCard(label: l10n.dialysisCentre,
                controller: _center,
                hint: l10n.dialysisCentreHint),
            const SizedBox(height: 9),
            LabeledFieldCard(
              label: l10n.dryWeightKgLabel,
              controller: _dryWeight,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 9),
            LabeledFieldCard(
              label: l10n.bloodGroup,
              child: Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  for (final group in _bloodGroups)
                    AppChoiceChip(
                      label: group,
                      selected: _bloodGroup == group,
                      onTap: () => setState(() =>
                          _bloodGroup = _bloodGroup == group ? '' : group),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 9),
            LabeledFieldCard(
              label: l10n.allergies,
              controller: _allergies,
              hint: l10n.allergiesHint,
            ),
            const SizedBox(height: 9),
            LabeledFieldCard(
              label: l10n.emergencyContact,
              controller: _emergencyContact,
              hint: l10n.emergencyContactHint,
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
                          : widget.isOnboarding
                              ? l10n.createVault
                              : l10n.saveChanges,
                      style: typo.cardTitle
                          .copyWith(fontSize: 15, color: colors.onAccent),
                    ),
                  ),
                ),
              ),
            ),
            if (widget.isOnboarding) ...[
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: state.saving ? null : _exploreDemo,
                  child: Text(
                    l10n.exploreSampleData,
                    style: typo.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.accent,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// One "Mon · 7:00 AM" row; tapping the time pill opens the time picker.
class _DayTimeRow extends StatelessWidget {
  const _DayTimeRow({
    required this.dayLabel,
    required this.minutes,
    required this.onTap,
  });

  final String dayLabel;
  final int minutes;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final time = TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(
              dayLabel,
              style: typo.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.ink,
              ),
            ),
          ),
          Semantics(
            button: true,
            label: context.l10n
                .changeSessionTime(dayLabel, time.format(context)),
            child: Material(
              color: colors.fieldBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: colors.fieldBorder, width: 1.5),
              ),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        time.format(context),
                        style: typo.number(13.5,
                            weight: FontWeight.w600, color: colors.ink),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.schedule,
                          size: 14, color: colors.muted),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
