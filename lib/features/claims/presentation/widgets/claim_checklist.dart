import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/storage/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// The claim's submission checklist: toggleable rows, inline add field,
/// per-row remove. Stateless over its callbacks so it tests in isolation.
class ClaimChecklist extends StatefulWidget {
  const ClaimChecklist({
    super.key,
    required this.items,
    required this.onToggle,
    required this.onAdd,
    required this.onRemove,
  });

  final List<ClaimChecklistItem> items;
  final void Function(ClaimChecklistItem item, bool isDone) onToggle;
  final ValueChanged<String> onAdd;
  final void Function(ClaimChecklistItem item) onRemove;

  @override
  State<ClaimChecklist> createState() => _ClaimChecklistState();
}

class _ClaimChecklistState extends State<ClaimChecklist> {
  final _add = TextEditingController();

  @override
  void dispose() {
    _add.dispose();
    super.dispose();
  }

  void _submit(String value) {
    final label = value.trim();
    if (label.isEmpty) return;
    widget.onAdd(label);
    _add.clear();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in widget.items)
          Row(
            children: [
              Checkbox(
                value: item.isDone,
                onChanged: (value) =>
                    widget.onToggle(item, value ?? false),
              ),
              Expanded(
                child: Text(
                  item.label,
                  style: typo.body.copyWith(
                    decoration:
                        item.isDone ? TextDecoration.lineThrough : null,
                    color: item.isDone ? colors.muted : colors.ink,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, size: 16, color: colors.muted),
                onPressed: () => widget.onRemove(item),
              ),
            ],
          ),
        TextField(
          controller: _add,
          style: typo.body,
          textInputAction: TextInputAction.done,
          onSubmitted: _submit,
          decoration: InputDecoration(
            hintText: context.l10n.claimChecklistAddHint,
            prefixIcon: Icon(Icons.add, size: 18, color: colors.muted),
          ),
        ),
      ],
    );
  }
}
