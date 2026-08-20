import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/app_failure.dart';
import '../../../../core/utils/result.dart';
import '../../data/repository_impl/dialysis_repository_impl.dart';
import '../../domain/entities/session_log.dart';

@immutable
class LogSessionState {
  const LogSessionState({this.saving = false, this.failure});

  final bool saving;
  final AppFailure? failure;
}

/// Saves a completed dialysis session.
class LogSessionController extends Notifier<LogSessionState> {
  @override
  LogSessionState build() => const LogSessionState();

  Future<bool> save(SessionLog log) async {
    state = const LogSessionState(saving: true);
    final result = await ref.read(dialysisRepositoryProvider).logSession(log);
    return _finish(result);
  }

  /// Rewrites an already-logged session.
  Future<bool> update(String sessionId, SessionLog log) async {
    state = const LogSessionState(saving: true);
    final result = await ref
        .read(dialysisRepositoryProvider)
        .updateSession(sessionId, log);
    return _finish(result);
  }

  bool _finish(Result<void> result) {
    return result.when(
      ok: (_) {
        state = const LogSessionState();
        return true;
      },
      err: (failure) {
        state = LogSessionState(failure: failure);
        return false;
      },
    );
  }

  void dismissFailure() => state = const LogSessionState();
}

final logSessionProvider =
    NotifierProvider<LogSessionController, LogSessionState>(
      LogSessionController.new,
    );
