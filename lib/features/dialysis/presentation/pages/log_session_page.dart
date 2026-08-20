import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_format_x.dart';
import '../../../../core/widgets/app_choice_chip.dart';
import '../../../../core/widgets/labeled_field_card.dart';
import '../../data/repository_impl/dialysis_repository_impl.dart';
import '../../domain/entities/session_log.dart';
import '../controllers/log_session_controller.dart';

/// Log a completed dialysis session: weights, ultrafiltration, BP and how
/// it went. Everything is optional except duration — record what you know.
/// With a [sessionId] the same form edits that logged session instead.
class LogSessionPage extends ConsumerStatefulWidget {
  const LogSessionPage({super.key, this.sessionId});

  final String? sessionId;

  @override
  ConsumerState<LogSessionPage> createState() => _LogSessionPageState();
}

class _LogSessionPageState extends ConsumerState<LogSessionPage> {
  final _preWeight = TextEditingController();
  final _postWeight = TextEditingController();
  final _uf = TextEditingController();
  final _systolic = TextEditingController();
  final _diastolic = TextEditingController();
  final _note = TextEditingController();
  double _hours = 4;
  DateTime _completedAt = DateTime.now();

  bool get _isEditing => widget.sessionId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) _prefill();
  }

  Future<void> _prefill() async {
    final log = await ref
        .read(dialysisRepositoryProvider)
        .getSessionLog(widget.sessionId!);
    if (log == null || !mounted) return;
    setState(() {
      _completedAt = log.completedAt;
      _hours = log.durationHours;
      _preWeight.text = _num(log.preWeightKg);
      _postWeight.text = _num(log.postWeightKg);
      _uf.text = _num(log.ultrafiltrationL);
      _systolic.text = _wholeNum(log.systolic);
      _diastolic.text = _wholeNum(log.diastolic);
      _note.text = log.note;
    });
  }

  String _num(double? value) => value == null ? '' : '$value';

  String _wholeNum(double? value) => value == null ? '' : '${value.toInt()}';

  /// Quick-note suggestions; the selected chip's localized text is
  /// written into the note field as user data.
  List<String> _noteChips(AppLocalizations l10n) => [
    l10n.noteNoCramps,
    l10n.noteCramps,
    l10n.noteBpDipped,
    l10n.noteFeltWeak,
    l10n.noteWentWell,
  ];

  @override
  void dispose() {
    for (final controller in [
      _preWeight, _postWeight, _uf, _systolic, _diastolic, _note, //
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _completedAt,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      helpText: context.l10n.sessionDateDialogTitle,
    );
    if (picked != null) setState(() => _completedAt = picked);
  }

  Future<void> _save() async {
    final log = SessionLog(
      completedAt: _completedAt,
      durationHours: _hours,
      preWeightKg: double.tryParse(_preWeight.text.trim()),
      postWeightKg: double.tryParse(_postWeight.text.trim()),
      ultrafiltrationL: double.tryParse(_uf.text.trim()),
      systolic: double.tryParse(_systolic.text.trim()),
      diastolic: double.tryParse(_diastolic.text.trim()),
      note: _note.text.trim(),
    );
    final controller = ref.read(logSessionProvider.notifier);
    final saved = _isEditing
        ? await controller.update(widget.sessionId!, log)
        : await controller.save(log);
    if (saved && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? context.l10n.sessionUpdated
                : context.l10n.sessionLogged,
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
    final state = ref.watch(logSessionProvider);

    ref.listen(logSessionProvider, (previous, next) {
      final failure = next.failure;
      if (failure != null && failure != previous?.failure) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.message)));
        ref.read(logSessionProvider.notifier).dismissFailure();
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
              _isEditing ? l10n.editSession : l10n.logASession,
              style: typo.pageTitle.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.logSessionCopy,
              style: typo.body.copyWith(color: colors.muted),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Text(
                  l10n.sessionDate,
                  style: typo.overline.copyWith(
                    fontSize: 10.5,
                    color: colors.muted,
                  ),
                ),
                const SizedBox(width: 12),
                Semantics(
                  button: true,
                  label: l10n.changeSessionDate(_completedAt.monthDayYear),
                  child: Material(
                    color: colors.fieldBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: colors.fieldBorder, width: 1.5),
                    ),
                    child: InkWell(
                      onTap: _pickDate,
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
                              _completedAt.monthDayYear,
                              style: typo.number(
                                13.5,
                                weight: FontWeight.w600,
                                color: colors.ink,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.event_outlined,
                              size: 14,
                              color: colors.muted,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            LabeledFieldCard(
              label: l10n.duration,
              child: Wrap(
                spacing: 7,
                children: [
                  for (final hours in const [3.0, 3.5, 4.0, 4.5, 5.0])
                    AppChoiceChip(
                      label: hours % 1 == 0 ? '${hours.toInt()} h' : '$hours h',
                      selected: _hours == hours,
                      onTap: () => setState(() => _hours = hours),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 9),
            Row(
              children: [
                Expanded(
                  child: LabeledFieldCard(
                    label: l10n.preWeightKgLabel,
                    controller: _preWeight,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: LabeledFieldCard(
                    label: l10n.postWeightKgLabel,
                    controller: _postWeight,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            Row(
              children: [
                Expanded(
                  child: LabeledFieldCard(
                    label: l10n.ufRemoved,
                    controller: _uf,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: LabeledFieldCard(
                    label: l10n.bpSys,
                    controller: _systolic,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: LabeledFieldCard(
                    label: l10n.bpDia,
                    controller: _diastolic,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            LabeledFieldCard(
              label: l10n.howDidItGo,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      for (final chip in _noteChips(l10n))
                        AppChoiceChip(
                          label: chip,
                          selected: _note.text == chip,
                          onTap: () => setState(() => _note.text = chip),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _note,
                    style: typo.cardTitle.copyWith(color: colors.ink),
                    cursorColor: colors.accent,
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: colors.fieldBg,
                      hintText: l10n.orTypeNote,
                      hintStyle: typo.cardTitle.copyWith(color: colors.muted),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colors.fieldBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colors.accent,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
                          : l10n.saveSession,
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
