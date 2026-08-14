import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/router/app_shell.dart';
import '../../../../core/storage/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_format_x.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/record_tile.dart';
import '../controllers/timeline_controller.dart';

/// The full medical timeline: reverse-chronological, grouped by month,
/// lazily paged.
class TimelinePage extends ConsumerStatefulWidget {
  const TimelinePage({super.key});

  @override
  ConsumerState<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends ConsumerState<TimelinePage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_maybeLoadMore);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_maybeLoadMore);
    _scrollController.dispose();
    super.dispose();
  }

  void _maybeLoadMore() {
    final position = _scrollController.position;
    if (position.pixels > position.maxScrollExtent - 400) {
      ref.read(timelineProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;
    final state = ref.watch(timelineProvider);
    final rows = _buildRows(state.events);

    return Scaffold(
      backgroundColor: colors.bgSection,
      appBar: AppBar(
        backgroundColor: colors.bgSection,
        leading: BackButton(color: colors.ink),
        toolbarHeight: 44,
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: state.events.isEmpty && !state.loading
            ? EmptyState(
                icon: Icons.timeline_outlined,
                title: l10n.timelineEmptyTitle,
                message: l10n.timelineEmptyMessage,
              )
            : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, AppShell.navClearance),
                itemCount: rows.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        l10n.timeline,
                        style: typo.pageTitle.copyWith(fontSize: 25),
                      ),
                    );
                  }
                  final row = rows[index - 1];
                  return switch (row) {
                    _MonthHeader(:final label) => Padding(
                        padding: const EdgeInsets.fromLTRB(2, 14, 2, 8),
                        child: Text(
                          label,
                          style: typo.overline.copyWith(
                            fontSize: 11,
                            color: colors.muted,
                          ),
                        ),
                      ),
                    _EventRow(:final event) => Padding(
                        padding: const EdgeInsets.only(bottom: 7),
                        child: RecordTile(
                          type: event.type,
                          title: event.title,
                          subtitle: event.subtitle,
                          dateLabel: event.occurredAt.monthDay,
                          onTap: event.documentId == null
                              ? null
                              : () => context.pushNamed(
                                    'documentViewer',
                                    pathParameters: {
                                      'id': event.documentId!,
                                    },
                                  ),
                        ),
                      ),
                  };
                },
              ),
      ),
    );
  }

  List<_TimelineRow> _buildRows(List<TimelineEvent> events) {
    final rows = <_TimelineRow>[];
    String? currentMonth;
    for (final event in events) {
      final month = event.occurredAt.monthGroupLabel;
      if (month != currentMonth) {
        currentMonth = month;
        rows.add(_MonthHeader(month));
      }
      rows.add(_EventRow(event));
    }
    return rows;
  }
}

sealed class _TimelineRow {
  const _TimelineRow();
}

class _MonthHeader extends _TimelineRow {
  const _MonthHeader(this.label);

  final String label;
}

class _EventRow extends _TimelineRow {
  const _EventRow(this.event);

  final TimelineEvent event;
}
