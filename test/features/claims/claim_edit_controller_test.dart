import 'package:flutter_test/flutter_test.dart';
import 'package:recora/features/claims/presentation/controllers/claim_edit_controller.dart';

void main() {
  test('validate: empty title is rejected, trimmed title accepted', () {
    expect(ClaimEditController.validateTitle('   '), isFalse);
    expect(ClaimEditController.validateTitle('August bundle'), isTrue);
  });

  test('toggling ids in a selection set', () {
    const state = ClaimEditState(
      title: '',
      selectedDocumentIds: {'a'},
    );
    final toggledOn = state.withToggled('b');
    expect(toggledOn.selectedDocumentIds, {'a', 'b'});
    final toggledOff = toggledOn.withToggled('a');
    expect(toggledOff.selectedDocumentIds, {'b'});
  });
}
