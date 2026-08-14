import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recora/core/theme/app_theme.dart';
import 'package:recora/features/capture/domain/entities/extraction.dart';
import 'package:recora/features/capture/presentation/widgets/review_field_card.dart';
import 'package:recora/l10n/app_localizations.dart';

Widget _host(Widget child) {
  return MaterialApp(
    theme: AppTheme.light(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: Center(child: child)),
  );
}

const _lowField = ExtractedField(
  key: 'medicine_1',
  label: 'MEDICINE 1',
  value: 'Wepox 10,000 IU',
  confidence: 0.67,
  note: 'Dose was hard to read — could be 4,000 IU.',
  alternatives: ['Frusemide'],
);

const _highField = ExtractedField(
  key: 'doctor',
  label: 'DOCTOR',
  value: 'Dr. Anand Menon',
  confidence: 0.98,
);

void main() {
  testWidgets('low-confidence field demands a check and shows the note',
      (tester) async {
    await tester.pumpWidget(_host(ReviewFieldCard(
      field: _lowField,
      checked: false,
      onChanged: (_) {},
      onChooseAlternative: (_) {},
    )));

    expect(find.text('67% · check'), findsOneWidget);
    expect(
      find.text('Dose was hard to read — could be 4,000 IU.'),
      findsOneWidget,
    );
    expect(find.widgetWithText(TextField, 'Wepox 10,000 IU'),
        findsOneWidget);
  });

  testWidgets('checked field flips the chip to verified state',
      (tester) async {
    await tester.pumpWidget(_host(ReviewFieldCard(
      field: _lowField,
      checked: true,
      onChanged: (_) {},
      onChooseAlternative: (_) {},
    )));

    expect(find.text('✓ checked'), findsOneWidget);
    expect(
      find.text('Dose was hard to read — could be 4,000 IU.'),
      findsNothing,
    );
  });

  testWidgets('high-confidence field shows a plain percentage, no helper',
      (tester) async {
    await tester.pumpWidget(_host(ReviewFieldCard(
      field: _highField,
      checked: true,
      onChanged: (_) {},
      onChooseAlternative: (_) {},
    )));

    expect(find.text('98%'), findsOneWidget);
    expect(find.textContaining('verify'), findsNothing);
  });

  testWidgets('tapping an alternative reports the chosen reading',
      (tester) async {
    String? chosen;
    await tester.pumpWidget(_host(ReviewFieldCard(
      field: _lowField,
      checked: false,
      onChanged: (_) {},
      onChooseAlternative: (value) => chosen = value,
    )));

    await tester.tap(find.text('Frusemide'));
    expect(chosen, 'Frusemide');
  });

  testWidgets('editing the field reports the new value', (tester) async {
    String? edited;
    await tester.pumpWidget(_host(ReviewFieldCard(
      field: _lowField,
      checked: false,
      onChanged: (value) => edited = value,
      onChooseAlternative: (_) {},
    )));

    await tester.enterText(find.byType(TextField), 'Wepox 4,000 IU');
    expect(edited, 'Wepox 4,000 IU');
  });
}
