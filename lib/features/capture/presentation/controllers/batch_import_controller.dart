import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/pdf_import.dart';
import '../../../../core/services/photo_picker.dart';
import '../../../../core/services/scan_page.dart';
import '../../../../core/utils/app_failure.dart';
import '../../../../shared/domain/document_type.dart';
import '../../data/repository_impl/capture_repository_impl.dart';
import 'review_draft.dart';

enum BatchPhase { setup, running, summary }

enum BatchItemStatus { pending, extracting, ready, failed, saved, skipped }

/// One document in the import queue: its page images plus how far it has
/// come through extract → review → save.
@immutable
class BatchItem {
  const BatchItem({
    required this.id,
    required this.sourceLabel,
    required this.pages,
    this.type = DocumentType.labReport,
    this.status = BatchItemStatus.pending,
    this.draft,
    this.failure,
    this.combined = false,
  });

  final String id;

  /// Short origin hint shown on tiles: a PDF's filename or "Photo".
  final String sourceLabel;
  final List<ScanPage> pages;

  /// What the caregiver said this document is. Only lab reports are sent
  /// for AI extraction; everything else is stored as photographed.
  final DocumentType type;

  final BatchItemStatus status;
  final ReviewDraft? draft;
  final AppFailure? failure;

  /// True when the user combined several photos into this item — only
  /// those can be ungrouped again.
  final bool combined;

  bool get isDone =>
      status == BatchItemStatus.saved || status == BatchItemStatus.skipped;

  BatchItem copyWith({
    DocumentType? type,
    BatchItemStatus? status,
    ReviewDraft? draft,
    AppFailure? failure,
    bool clearFailure = false,
  }) {
    return BatchItem(
      id: id,
      sourceLabel: sourceLabel,
      pages: pages,
      type: type ?? this.type,
      status: status ?? this.status,
      draft: draft ?? this.draft,
      failure: clearFailure ? null : failure ?? this.failure,
      combined: combined,
    );
  }
}

/// Immutable state of the batch import flow. The queue lives only in
/// memory — closing the app mid-import loses unreviewed items, which is
/// acceptable for now since every saved item is already in the vault.
@immutable
class BatchImportState {
  const BatchImportState({
    this.phase = BatchPhase.setup,
    this.items = const [],
    this.currentIndex = 0,
    this.selection = const {},
    this.saving = false,
    this.failure,
  });

  final BatchPhase phase;
  final List<BatchItem> items;

  /// Index of the item under review while [phase] is [BatchPhase.running].
  final int currentIndex;

  /// Item ids selected on the setup screen for combining into one
  /// document. Empty means selection mode is off.
  final Set<String> selection;

  /// True while the current item is being persisted.
  final bool saving;
  final AppFailure? failure;

  BatchItem? get currentItem =>
      phase == BatchPhase.running && currentIndex < items.length
          ? items[currentIndex]
          : null;

  int get savedCount =>
      items.where((i) => i.status == BatchItemStatus.saved).length;
  int get skippedCount =>
      items.where((i) => i.status == BatchItemStatus.skipped).length;
  List<BatchItem> get failedItems =>
      [for (final i in items) if (i.status == BatchItemStatus.failed) i];

  BatchImportState copyWith({
    BatchPhase? phase,
    List<BatchItem>? items,
    int? currentIndex,
    Set<String>? selection,
    bool? saving,
    AppFailure? failure,
    bool clearFailure = false,
  }) {
    return BatchImportState(
      phase: phase ?? this.phase,
      items: items ?? this.items,
      currentIndex: currentIndex ?? this.currentIndex,
      selection: selection ?? this.selection,
      saving: saving ?? this.saving,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }
}

/// Drives the batch import: pick many photos/PDFs → extract one by one →
/// review each from the queue → summary. Extraction runs ahead in the
/// background so the caregiver reviews item 1 while item 2 extracts.
class BatchImportController extends Notifier<BatchImportState> {
  static const maxItems = 25;

  var _itemSeq = 0;
  var _loopRunning = false;
  var _disposed = false;

  @override
  BatchImportState build() {
    ref.onDispose(() => _disposed = true);
    return const BatchImportState();
  }

  // ── Setup ────────────────────────────────────────────────────────────

  Future<void> addPhotos() async {
    try {
      final photos =
          await ref.read(photoPickerProvider).pickManyFromGallery();
      if (photos.isEmpty) return;
      _addItems([
        for (final bytes in photos)
          BatchItem(
            id: 'item-${_itemSeq++}',
            sourceLabel: '',
            pages: [ScanPage.jpeg(bytes)],
          ),
      ]);
    } on AppFailure catch (failure) {
      state = state.copyWith(failure: failure);
    }
  }

  Future<void> addPdfs() async {
    try {
      final pdfs = await ref.read(pdfImportProvider).pickPdfs();
      final items = <BatchItem>[];
      for (final pdf in pdfs) {
        // One unreadable file must not sink the rest of the batch.
        try {
          final pages = await ref.read(pdfImportProvider).rasterize(pdf);
          items.add(BatchItem(
            id: 'item-${_itemSeq++}',
            sourceLabel: pdf.name,
            pages: pages,
          ));
        } on AppFailure catch (failure) {
          state = state.copyWith(failure: failure);
        }
      }
      if (items.isNotEmpty) _addItems(items);
    } on AppFailure catch (failure) {
      state = state.copyWith(failure: failure);
    }
  }

  void _addItems(List<BatchItem> items) {
    final room = maxItems - state.items.length;
    if (items.length > room) {
      state = state.copyWith(
        failure: const ValidationFailure(
          message: 'An import can hold up to $maxItems documents at a '
              'time. Please import the rest in a second round.',
        ),
      );
    }
    state = state.copyWith(
      items: [...state.items, ...items.take(room)],
    );
  }

  void removeItem(String id) {
    state = state.copyWith(
      items: [for (final i in state.items) if (i.id != id) i],
      selection: {...state.selection}..remove(id),
    );
  }

  void toggleSelect(String id) {
    final selection = {...state.selection};
    if (!selection.remove(id)) selection.add(id);
    state = state.copyWith(selection: selection);
  }

  void clearSelection() => state = state.copyWith(selection: const {});

  void setItemType(String id, DocumentType type) =>
      _updateItem(id, (i) => i.copyWith(type: type));

  void setTypeForAll(DocumentType type) {
    state = state.copyWith(
      items: [for (final i in state.items) i.copyWith(type: type)],
    );
  }

  /// Merges the selected photo items into one multi-page document, in
  /// pick order. PDFs cannot be part of a combination.
  void combineSelected() {
    final selected = [
      for (final i in state.items)
        if (state.selection.contains(i.id)) i,
    ];
    if (selected.length < 2) return;
    final combined = BatchItem(
      id: 'item-${_itemSeq++}',
      sourceLabel: '',
      pages: [for (final i in selected) ...i.pages],
      type: selected.first.type,
      combined: true,
    );
    final items = <BatchItem>[];
    var inserted = false;
    for (final item in state.items) {
      if (state.selection.contains(item.id)) {
        if (!inserted) {
          items.add(combined);
          inserted = true;
        }
      } else {
        items.add(item);
      }
    }
    state = state.copyWith(items: items, selection: const {});
  }

  /// Splits a combined item back into one item per page.
  void ungroup(String id) {
    final items = <BatchItem>[];
    for (final item in state.items) {
      if (item.id == id && item.combined) {
        for (final page in item.pages) {
          items.add(BatchItem(
            id: 'item-${_itemSeq++}',
            sourceLabel: '',
            pages: [page],
            type: item.type,
          ));
        }
      } else {
        items.add(item);
      }
    }
    state = state.copyWith(items: items);
  }

  // ── Extraction queue ─────────────────────────────────────────────────

  void start() {
    if (state.items.isEmpty) return;
    state = state.copyWith(
      phase: BatchPhase.running,
      currentIndex: 0,
      selection: const {},
      clearFailure: true,
      // Non-lab documents skip extraction entirely: they are ready for
      // their details form the moment the queue starts.
      items: [
        for (final i in state.items)
          i.type == DocumentType.labReport
              ? i
              : i.copyWith(status: BatchItemStatus.ready),
      ],
    );
    _runExtractionLoop();
  }

  Future<void> _runExtractionLoop() async {
    if (_loopRunning) return;
    _loopRunning = true;
    try {
      while (!_disposed) {
        final index = state.items.indexWhere((i) =>
            i.status == BatchItemStatus.pending &&
            i.type == DocumentType.labReport);
        if (index == -1) return;
        final item = state.items[index];
        _updateItem(item.id,
            (i) => i.copyWith(status: BatchItemStatus.extracting));
        final result =
            await ref.read(captureRepositoryProvider).extract(item.pages);
        if (_disposed) return;
        result.when(
          ok: (extraction) => _updateItem(
            item.id,
            (i) => i.copyWith(
              status: BatchItemStatus.ready,
              draft: ReviewDraft(extraction: extraction),
              clearFailure: true,
            ),
          ),
          err: (failure) => _updateItem(
            item.id,
            (i) => i.copyWith(
              status: BatchItemStatus.failed,
              failure: failure,
            ),
          ),
        );
      }
    } finally {
      _loopRunning = false;
    }
  }

  void _updateItem(String id, BatchItem Function(BatchItem) update) {
    state = state.copyWith(
      items: [for (final i in state.items) i.id == id ? update(i) : i],
    );
  }

  // ── Review ───────────────────────────────────────────────────────────

  void editField(String key, String value) =>
      _updateDraft((draft) => draft.edit(key, value));

  void confirmField(String key) =>
      _updateDraft((draft) => draft.confirm(key));

  void chooseAlternative(String key, String value) =>
      _updateDraft((draft) => draft.chooseAlternative(key, value));

  void _updateDraft(ReviewDraft Function(ReviewDraft) update) {
    final item = state.currentItem;
    final draft = item?.draft;
    if (item == null || draft == null) return;
    _updateItem(item.id, (i) => i.copyWith(draft: update(draft)));
  }

  void skipCurrent() {
    final item = state.currentItem;
    if (item == null) return;
    _updateItem(item.id, (i) => i.copyWith(status: BatchItemStatus.skipped));
    _advance();
  }

  Future<void> saveCurrent() async {
    final item = state.currentItem;
    final draft = item?.draft;
    if (item == null || draft == null || state.saving) return;
    if (!draft.allChecked) {
      state = state.copyWith(
        failure: ValidationFailure(
          message: '${draft.uncheckedCount} field(s) still need a check '
              'before saving.',
        ),
      );
      return;
    }

    state = state.copyWith(saving: true, clearFailure: true);
    final result = await ref.read(captureRepositoryProvider).saveReviewed(
        pages: item.pages, reviewed: draft.reviewedResult());
    if (_disposed) return;
    result.when(
      ok: (_) {
        _updateItem(
            item.id, (i) => i.copyWith(status: BatchItemStatus.saved));
        state = state.copyWith(saving: false);
        _advance();
      },
      err: (failure) {
        state = state.copyWith(saving: false, failure: failure);
      },
    );
  }

  /// Persists the current non-lab item with the typed details.
  Future<void> saveCurrentManual({
    required String title,
    String doctor = '',
    required DateTime documentDate,
  }) async {
    final item = state.currentItem;
    if (item == null || state.saving) return;

    state = state.copyWith(saving: true, clearFailure: true);
    final result = await ref.read(captureRepositoryProvider).saveManual(
          pages: item.pages,
          type: item.type,
          title: title,
          doctor: doctor,
          documentDate: documentDate,
        );
    if (_disposed) return;
    result.when(
      ok: (_) {
        _updateItem(
            item.id, (i) => i.copyWith(status: BatchItemStatus.saved));
        state = state.copyWith(saving: false);
        _advance();
      },
      err: (failure) {
        state = state.copyWith(saving: false, failure: failure);
      },
    );
  }

  /// Moves to the next item still awaiting review (in order), or to the
  /// summary when none is left. An item that is still pending/extracting
  /// keeps the review screen in its waiting state.
  void _advance() {
    final index = state.items.indexWhere(
      (i) =>
          !i.isDone &&
          i.status != BatchItemStatus.failed,
    );
    if (index == -1) {
      state = state.copyWith(phase: BatchPhase.summary);
    } else {
      state = state.copyWith(currentIndex: index);
    }
  }

  /// Re-queues a failed item and returns to reviewing it.
  void retry(String id) {
    _updateItem(
      id,
      (i) => i.copyWith(status: BatchItemStatus.pending, clearFailure: true),
    );
    final index = state.items.indexWhere((i) => i.id == id);
    state = state.copyWith(
      phase: BatchPhase.running,
      currentIndex: index,
      clearFailure: true,
    );
    _runExtractionLoop();
  }

  /// Moves past the current failed item (it stays failed for the summary).
  void continueAfterFailure() {
    final item = state.currentItem;
    if (item == null) return;
    final index = state.items.indexWhere(
      (i) => !i.isDone && i.status != BatchItemStatus.failed && i != item,
    );
    if (index == -1) {
      state = state.copyWith(phase: BatchPhase.summary);
    } else {
      state = state.copyWith(currentIndex: index);
    }
  }

  void dismissFailure() => state = state.copyWith(clearFailure: true);
}

final batchImportProvider = NotifierProvider.autoDispose<
    BatchImportController, BatchImportState>(BatchImportController.new);
