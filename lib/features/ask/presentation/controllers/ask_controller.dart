import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/app_failure.dart';
import '../../data/repository_impl/ask_repository_impl.dart';

/// Sending state of the Ask conversation.
class AskSendState {
  const AskSendState({this.sending = false, this.failure});

  final bool sending;
  final AppFailure? failure;
}

class AskController extends Notifier<AskSendState> {
  @override
  AskSendState build() => const AskSendState();

  Future<void> send(String question) async {
    final trimmed = question.trim();
    if (trimmed.isEmpty || state.sending) return;

    state = const AskSendState(sending: true);
    final result = await ref.read(askRepositoryProvider).ask(trimmed);
    state = result.when(
      ok: (_) => const AskSendState(),
      err: (failure) => AskSendState(failure: failure),
    );
  }

  void dismissFailure() => state = const AskSendState();
}

final askControllerProvider =
    NotifierProvider<AskController, AskSendState>(AskController.new);
