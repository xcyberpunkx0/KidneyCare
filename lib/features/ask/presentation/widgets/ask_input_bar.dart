import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Pill input with a round accent send button.
class AskInputBar extends StatelessWidget {
  const AskInputBar({
    super.key,
    required this.controller,
    required this.sending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool sending;
  final ValueChanged<String> onSend;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 8, 8, 8),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: colors.cardBorder),
        boxShadow: colors.navShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: !sending,
              textInputAction: TextInputAction.send,
              onSubmitted: onSend,
              style: typo.body.copyWith(fontSize: 13.5, color: colors.ink),
              cursorColor: colors.accent,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: l10n.askInputHint,
                hintStyle: typo.body.copyWith(
                  fontSize: 13.5,
                  color: colors.muted,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Semantics(
            button: true,
            label: l10n.sendQuestion,
            child: Material(
              color: colors.accent,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: sending ? null : () => onSend(controller.text),
                customBorder: const CircleBorder(),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: sending
                      ? Padding(
                          padding: const EdgeInsets.all(11),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colors.onAccent,
                          ),
                        )
                      : Icon(
                          Icons.arrow_forward,
                          size: 17,
                          color: colors.onAccent,
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
