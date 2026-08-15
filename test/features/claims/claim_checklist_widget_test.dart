import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recora/core/storage/app_database.dart';
import 'package:recora/core/theme/app_theme.dart';
import 'package:recora/features/claims/presentation/widgets/claim_checklist.dart';
import 'package:recora/l10n/app_localizations.dart';

Widget _host(Widget child) {
  return MaterialApp(
    theme: AppTheme.light(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

ClaimChecklistItem _item(String id, String label, {bool done = false}) {
  return ClaimChecklistItem(
      id: id, claimId: 'c1', label: label, isDone: done, sortOrder: 0);
}

void main() {
  testWidgets('renders items with their done state and reports toggles',
      (tester) async {
    ClaimChecklistItem? toggled;
    bool? toggledTo;
    await tester.pumpWidget(_host(ClaimChecklist(
      items: [_item('i1', 'Claim form'), _item('i2', 'Bills', done: true)],
      onToggle: (item, done) {
        toggled = item;
        toggledTo = done;
      },
      onAdd: (_) {},
      onRemove: (_) {},
    )));

    expect(find.text('Claim form'), findsOneWidget);
    expect(find.text('Bills'), findsOneWidget);

    await tester.tap(find.byType(Checkbox).first);
    expect(toggled!.id, 'i1');
    expect(toggledTo, isTrue);
  });

  testWidgets('typing a new item and submitting reports onAdd',
      (tester) async {
    String? added;
    await tester.pumpWidget(_host(ClaimChecklist(
      items: const [],
      onToggle: (_, _) {},
      onAdd: (label) => added = label,
      onRemove: (_) {},
    )));

    await tester.enterText(find.byType(TextField), 'Aadhaar copy');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    expect(added, 'Aadhaar copy');
  });

  testWidgets('remove button reports the item', (tester) async {
    ClaimChecklistItem? removed;
    await tester.pumpWidget(_host(ClaimChecklist(
      items: [_item('i1', 'Claim form')],
      onToggle: (_, _) {},
      onAdd: (_) {},
      onRemove: (item) => removed = item,
    )));

    await tester.tap(find.byIcon(Icons.close));
    expect(removed!.id, 'i1');
  });
}
