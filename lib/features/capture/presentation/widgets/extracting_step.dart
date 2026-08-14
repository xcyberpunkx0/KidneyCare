import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// The reassuring wait state while Gemini reads the document.
class ExtractingStep extends StatelessWidget {
  const ExtractingStep({super.key, this.patientName});

  final String? patientName;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;
    final name = patientName ?? l10n.thePatient;

    return Container(
      color: colors.bgSection,
      padding: const EdgeInsets.symmetric(horizontal: 36),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 52,
            height: 52,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              color: colors.accent,
              backgroundColor: colors.divider,
            ),
          ),
          const SizedBox(height: 26),
          Text(
            l10n.readingDocument,
            style: typo.pageTitle.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: Text(
              l10n.extractReassurance(name),
              textAlign: TextAlign.center,
              style: typo.body.copyWith(
                fontSize: 13.5,
                height: 1.6,
                color: colors.muted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
