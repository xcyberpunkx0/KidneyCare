import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether the ended-medicines section is expanded.
class ShowEndedController extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

final showEndedProvider =
    NotifierProvider<ShowEndedController, bool>(ShowEndedController.new);
