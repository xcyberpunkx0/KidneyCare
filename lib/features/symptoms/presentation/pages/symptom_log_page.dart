import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_choice_chip.dart';
import '../../../../core/widgets/labeled_field_card.dart';
import '../controllers/symptom_log_controller.dart';

/// Ten-second symptom entry: tap what you observed, optionally add a
/// note, save. It lands on the timeline for the next doctor visit.
class SymptomLogPage extends ConsumerStatefulWidget {
  const SymptomLogPage({super.key});

  @override
  ConsumerState<SymptomLogPage> createState() => _SymptomLogPageState();
}

class _SymptomLogPageState extends ConsumerState<SymptomLogPage> {
  final _note = TextEditingController();
  final Set<String> _selected = {};

  /// Symptom chip labels; the selected localized labels are what gets
  /// saved to the timeline as user data.
  List<String> _symptoms(AppLocalizations l10n) => [
        l10n.symptomFatigue,
        l10n.symptomCramps,
        l10n.symptomSwelling,
        l10n.symptomBreathlessness,
        l10n.symptomNausea,
        l10n.symptomDizziness,
        l10n.symptomLowBp,
        l10n.symptomFever,
        l10n.symptomItching,
        l10n.symptomPoorAppetite,
        l10n.symptomChestDiscomfort,
        l10n.symptomAccessSitePain,
      ];

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final saved = await ref
        .read(symptomLogProvider.notifier)
        .save(symptoms: _selected, note: _note.text);
    if (saved && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.notedOnTimeline)),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;
    final state = ref.watch(symptomLogProvider);

    ref.listen(symptomLogProvider, (previous, next) {
      final failure = next.failure;
      if (failure != null && failure != previous?.failure) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(failure.message)));
        ref.read(symptomLogProvider.notifier).dismissFailure();
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
            Text(l10n.logASymptom,
                style: typo.pageTitle.copyWith(fontSize: 24)),
            const SizedBox(height: 4),
            Text(
              l10n.logSymptomCopy,
              style: typo.body.copyWith(color: colors.muted),
            ),
            const SizedBox(height: 16),
            LabeledFieldCard(
              label: l10n.observed,
              child: Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  for (final symptom in _symptoms(l10n))
                    AppChoiceChip(
                      label: symptom,
                      selected: _selected.contains(symptom),
                      onTap: () => setState(() {
                        _selected.contains(symptom)
                            ? _selected.remove(symptom)
                            : _selected.add(symptom);
                      }),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 9),
            LabeledFieldCard(
              label: l10n.note,
              controller: _note,
              hint: l10n.symptomNoteHint,
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
                      state.saving ? l10n.saving : l10n.saveToTimeline,
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
