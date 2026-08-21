import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_format_x.dart';
import '../../../../shared/domain/document_type.dart';

/// Details form for non-lab documents: the photo is kept exactly as
/// taken and the caregiver types a title, an optional doctor, and the
/// document date. No AI is involved. Shared by the single capture flow
/// and the batch import queue (which adds a [header] and [saveLabel]).
class ManualDetailsStep extends StatefulWidget {
  const ManualDetailsStep({
    super.key,
    required this.type,
    required this.saving,
    this.header,
    this.saveLabel,
    required this.onSave,
  });

  final DocumentType type;
  final bool saving;
  final Widget? header;
  final String? saveLabel;
  final void Function(String title, String doctor, DateTime date) onSave;

  @override
  State<ManualDetailsStep> createState() => _ManualDetailsStepState();
}

class _ManualDetailsStepState extends State<ManualDetailsStep> {
  final _titleController = TextEditingController();
  final _doctorController = TextEditingController();
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _date = DateTime(now.year, now.month, now.day);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _doctorController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  bool get _canSave =>
      !widget.saving && _titleController.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;

    final fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: colors.fieldBorder),
    );

    return Container(
      color: colors.bgSection,
      child: Column(
        children: [
          ?widget.header,
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 10),
              children: [
                Text(
                  widget.type.localizedLabel(l10n),
                  style: typo.pageTitle.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.manualDetailsHint,
                  style: typo.caption.copyWith(
                    fontSize: 11.5,
                    color: colors.muted,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  l10n.docTitleLabel,
                  style: typo.caption.copyWith(color: colors.muted),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: l10n.docTitleHint,
                    filled: true,
                    fillColor: colors.fieldBg,
                    border: fieldBorder,
                    enabledBorder: fieldBorder,
                    focusedBorder: fieldBorder.copyWith(
                      borderSide: BorderSide(color: colors.accent),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  l10n.docDoctorOptionalLabel,
                  style: typo.caption.copyWith(color: colors.muted),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _doctorController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: colors.fieldBg,
                    border: fieldBorder,
                    enabledBorder: fieldBorder,
                    focusedBorder: fieldBorder.copyWith(
                      borderSide: BorderSide(color: colors.accent),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  l10n.docDateLabel,
                  style: typo.caption.copyWith(color: colors.muted),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Material(
                    color: colors.fieldBg,
                    borderRadius: BorderRadius.circular(99),
                    child: InkWell(
                      onTap: widget.saving ? null : _pickDate,
                      borderRadius: BorderRadius.circular(99),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(color: colors.fieldBorder),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.event_outlined,
                                size: 17, color: colors.ink),
                            const SizedBox(width: 8),
                            Text(
                              _date.monthDayYear,
                              style: typo.bodySmall.copyWith(
                                fontWeight: FontWeight.w500,
                                color: colors.ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
              child: Semantics(
                button: true,
                enabled: _canSave,
                label: widget.saveLabel ?? l10n.saveDocument,
                child: Material(
                  color: _canSave
                      ? colors.accent
                      : colors.accent.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(99),
                  child: InkWell(
                    onTap: _canSave
                        ? () => widget.onSave(
                              _titleController.text.trim(),
                              _doctorController.text.trim(),
                              _date,
                            )
                        : null,
                    borderRadius: BorderRadius.circular(99),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Center(
                        child: Text(
                          widget.saving
                              ? l10n.saving
                              : widget.saveLabel ?? l10n.saveDocument,
                          style: typo.cardTitle.copyWith(
                            fontSize: 15,
                            color: colors.onAccent,
                          ),
                        ),
                      ),
                    ),
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
