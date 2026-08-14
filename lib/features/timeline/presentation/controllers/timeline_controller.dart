import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/app_database.dart';
import '../../../../core/storage/database_provider.dart';

/// Paged timeline state. Events load newest-first in pages so years of
/// history never sit in memory at once.
@immutable
class TimelineState {
  const TimelineState({
    this.events = const [],
    this.loading = false,
    this.exhausted = false,
  });

  final List<TimelineEvent> events;
  final bool loading;
  final bool exhausted;

  TimelineState copyWith({
    List<TimelineEvent>? events,
    bool? loading,
    bool? exhausted,
  }) {
    return TimelineState(
      events: events ?? this.events,
      loading: loading ?? this.loading,
      exhausted: exhausted ?? this.exhausted,
    );
  }
}

class TimelineController extends Notifier<TimelineState> {
  static const _pageSize = 30;

  @override
  TimelineState build() {
    Future.microtask(loadMore);
    return const TimelineState(loading: true);
  }

  Future<void> loadMore() async {
    if (state.exhausted) return;
    final page = await ref
        .read(databaseProvider)
        .timelineDao
        .getPage(limit: _pageSize, offset: state.events.length);
    state = state.copyWith(
      events: [...state.events, ...page],
      loading: false,
      exhausted: page.length < _pageSize,
    );
  }

  /// Reloads from the top, e.g. after a new capture is saved.
  Future<void> refresh() async {
    final page = await ref
        .read(databaseProvider)
        .timelineDao
        .getPage(limit: _pageSize, offset: 0);
    state = TimelineState(
      events: page,
      exhausted: page.length < _pageSize,
    );
  }
}

final timelineProvider =
    NotifierProvider.autoDispose<TimelineController, TimelineState>(
  TimelineController.new,
);
