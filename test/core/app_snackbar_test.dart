import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recora/core/utils/app_snackbar.dart';

Widget _host({required bool accessibleNavigation}) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(accessibleNavigation: accessibleNavigation),
      child: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showAppSnackBar(
              context,
              'Transfer 10000 marked given',
              actionLabel: 'Undo',
              onAction: () {},
            ),
            child: const Text('show'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets(
      'an undo snackbar dismisses itself even when an accessibility '
      'service would normally pin it', (tester) async {
    await tester.pumpWidget(_host(accessibleNavigation: true));
    await tester.tap(find.text('show'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Transfer 10000 marked given'), findsOneWidget);

    // Our own timer closes it at 3 s; allow the exit animation to run.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('Transfer 10000 marked given'), findsNothing);
  });

  testWidgets('a second snackbar is not cut short by the first one\'s timer',
      (tester) async {
    await tester.pumpWidget(_host(accessibleNavigation: false));
    await tester.tap(find.text('show'));
    await tester.pump(const Duration(seconds: 2));
    await tester.tap(find.text('show'));
    await tester.pump();

    // 1.5 s after the second show — the first timer (due at 3 s) must
    // not have dismissed the replacement bubble.
    await tester.pump(const Duration(milliseconds: 1500));
    expect(find.text('Transfer 10000 marked given'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Transfer 10000 marked given'), findsNothing);
  });
}
