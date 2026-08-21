import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/domain/document_type.dart';
import '../controllers/batch_import_controller.dart';
import 'type_pick_step.dart';

/// Assembling the queue: picked documents as a tile grid, with
/// long-press selection to combine several photos into one multi-page
/// document, then a Start button.
class BatchSetupStep extends ConsumerWidget {
  const BatchSetupStep({super.key});

  Future<void> showAddSheet(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final controller = ref.read(batchImportProvider.notifier);
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.importPhotos),
              onTap: () {
                Navigator.pop(sheetContext);
                controller.addPhotos();
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_outlined),
              title: Text(l10n.importPdfFiles),
              onTap: () {
                Navigator.pop(sheetContext);
                controller.addPdfs();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;
    final state = ref.watch(batchImportProvider);
    final controller = ref.read(batchImportProvider.notifier);
    final selecting = state.selection.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 4, 14, 0),
          child: Row(
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: Icon(Icons.close, color: colors.ink),
              ),
              Expanded(
                child: Text(
                  l10n.importDocuments,
                  style: typo.pageTitle.copyWith(fontSize: 20),
                ),
              ),
              Text(
                selecting
                    ? l10n.nSelected(state.selection.length)
                    : l10n.nItemsToImport(state.items.length),
                style: typo.bodySmall.copyWith(color: colors.muted),
              ),
            ],
          ),
        ),
        Expanded(
          child: state.items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.file_upload_outlined,
                          size: 42, color: colors.muted),
                      const SizedBox(height: 10),
                      Text(
                        l10n.importEmptyMessage,
                        textAlign: TextAlign.center,
                        style:
                            typo.bodySmall.copyWith(color: colors.muted),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    mainAxisExtent: 132,
                  ),
                  itemCount: state.items.length,
                  itemBuilder: (context, index) => _ItemTile(
                    item: state.items[index],
                    selected:
                        state.selection.contains(state.items[index].id),
                    selecting: selecting,
                  ),
                ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 12),
            child: selecting
                ? Row(
                    children: [
                      Expanded(
                        child: _PillButton(
                          label: l10n.combineIntoOneDocument,
                          filled: true,
                          enabled: state.selection.length >= 2,
                          onTap: controller.combineSelected,
                        ),
                      ),
                      const SizedBox(width: 10),
                      _PillButton(
                        label: l10n.cancel,
                        filled: false,
                        onTap: controller.clearSelection,
                      ),
                    ],
                  )
                : Row(
                    children: [
                      _PillButton(
                        label: l10n.addMore,
                        filled: false,
                        onTap: () => showAddSheet(context, ref),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _PillButton(
                          label: l10n.startImport,
                          filled: true,
                          enabled: state.items.isNotEmpty,
                          onTap: controller.start,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

class _ItemTile extends ConsumerWidget {
  const _ItemTile({
    required this.item,
    required this.selected,
    required this.selecting,
  });

  final BatchItem item;
  final bool selected;
  final bool selecting;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;
    final controller = ref.read(batchImportProvider.notifier);
    // Only single photos can join a combination; PDFs and already
    // combined items stay as they are.
    final selectable = item.pages.length == 1 && !item.combined;

    Future<void> showTypeSheet() {
      return showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (sheetContext) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final type in DocumentType.values)
                ListTile(
                  leading: Icon(TypePickStep.icons[type]),
                  title: Text(type.localizedLabel(l10n)),
                  trailing: type == item.type
                      ? Icon(Icons.check, color: colors.accent)
                      : null,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    controller.setItemType(item.id, type);
                  },
                ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.copy_all_outlined),
                title: Text(l10n.applyTypeToAll),
                onTap: () {
                  Navigator.pop(sheetContext);
                  controller.setTypeForAll(item.type);
                },
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onLongPress: selectable ? () => controller.toggleSelect(item.id) : null,
      onTap: selecting && selectable
          ? () => controller.toggleSelect(item.id)
          : null,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? colors.accent : colors.cardBorder,
            width: selected ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.memory(
              item.pages.first.bytes,
              fit: BoxFit.cover,
              gaplessPlayback: true,
            ),
            // Always-visible type badge; tapping it opens the type sheet.
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Semantics(
                button: true,
                label: l10n.changeDocType,
                child: InkWell(
                  onTap: selecting ? null : showTypeSheet,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 3),
                    color: Colors.black.withValues(alpha: 0.55),
                    child: Row(
                      children: [
                        Icon(TypePickStep.icons[item.type],
                            size: 12, color: Colors.white),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            [
                              item.type.localizedLabel(l10n),
                              if (item.sourceLabel.isNotEmpty)
                                item.sourceLabel,
                              if (item.pages.length > 1)
                                l10n.nPages(item.pages.length),
                            ].join(' · '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: typo.caption
                                .copyWith(fontSize: 10, color: Colors.white),
                          ),
                        ),
                        if (!selecting)
                          const Icon(Icons.arrow_drop_down,
                              size: 14, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 2,
              right: 2,
              child: selecting
                  ? (selectable
                      ? Icon(
                          selected
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          size: 20,
                          color: selected ? colors.accent : Colors.white,
                        )
                      : const SizedBox.shrink())
                  : _TileAction(
                      icon: Icons.close,
                      label: l10n.removeDocument,
                      onTap: () => controller.removeItem(item.id),
                    ),
            ),
            if (!selecting && item.combined)
              Positioned(
                top: 2,
                left: 2,
                child: _TileAction(
                  icon: Icons.call_split,
                  label: l10n.ungroupPages,
                  onTap: () => controller.ungroup(item.id),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TileAction extends StatelessWidget {
  const _TileAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 14, color: Colors.white),
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.filled,
    required this.onTap,
    this.enabled = true,
  });

  final String label;
  final bool filled;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: Material(
        color: filled
            ? (enabled ? colors.accent : colors.muted)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(99),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(99),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
            decoration: filled
                ? null
                : BoxDecoration(
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: colors.cardBorder),
                  ),
            child: Center(
              child: Text(
                label,
                style: typo.cardTitle.copyWith(
                  fontSize: 14,
                  color: filled ? colors.onAccent : colors.ink,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
