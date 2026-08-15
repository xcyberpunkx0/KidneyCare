import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/storage/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_format_x.dart';
import '../../../../shared/domain/document_type.dart';
import '../../../documents/data/repository_impl/documents_repository_impl.dart';
import '../controllers/claim_edit_controller.dart';
import '../controllers/claims_providers.dart';

/// Create a claim (or edit a draft): title, policy, and a document picker
/// with unclaimed bills pre-selected.
class ClaimEditPage extends ConsumerStatefulWidget {
  const ClaimEditPage({super.key, this.claimId});

  /// Id of the draft claim being edited; null when creating a new one.
  final String? claimId;

  @override
  ConsumerState<ClaimEditPage> createState() => _ClaimEditPageState();
}

class _ClaimEditPageState extends ConsumerState<ClaimEditPage> {
  final _title = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  /// New claim: pre-select every unclaimed bill. Edit: load the draft's
  /// current title and attachments once streams deliver.
  ///
  /// The actual `preselect` call is deferred to a microtask: Riverpod
  /// forbids mutating a provider's state from within another widget's
  /// `build`, and calling it synchronously here can collide with an
  /// in-flight async transition on `unclaimedBillsProvider` /
  /// `policiesProvider` / `claimProvider` (e.g. their first stream emission
  /// resolving during the same frame).
  void _initialize() {
    if (_initialized) return;
    if (widget.claimId == null) {
      final unclaimed = ref.read(unclaimedBillsProvider).value;
      final policies = ref.read(policiesProvider).value;
      if (unclaimed == null || policies == null) return;
      _initialized = true;
      final ids = unclaimed.map((d) => d.id).toSet();
      // Auto-select only when there's exactly one policy; with none or
      // several, leave the choice to the caregiver.
      final policyId = policies.length == 1 ? policies.first.id : null;
      Future.microtask(() {
        if (!mounted) return;
        ref
            .read(claimEditControllerProvider.notifier)
            .preselect(ids, '', policyId);
      });
    } else {
      final claim = ref.read(claimProvider(widget.claimId!)).value;
      final docs = ref.read(claimDocumentsProvider(widget.claimId!)).value;
      if (claim == null || docs == null) return;
      _initialized = true;
      _title.text = claim.title;
      final ids = docs.map((d) => d.id).toSet();
      Future.microtask(() {
        if (!mounted) return;
        ref
            .read(claimEditControllerProvider.notifier)
            .preselect(ids, claim.title, claim.policyId);
      });
    }
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final saved =
        await ref.read(claimEditControllerProvider.notifier).save(
      claimId: widget.claimId,
      emptyTitleMessage: l10n.claimTitleRequired,
      checklistLabels: widget.claimId != null
          ? const []
          : [
              l10n.checklistClaimForm,
              l10n.checklistOriginalBills,
              l10n.checklistPrescriptionCopy,
              l10n.checklistLabReports,
              l10n.checklistPolicyIdCopy,
            ],
    );
    if (saved && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;

    if (widget.claimId != null) {
      ref.watch(claimProvider(widget.claimId!));
      ref.watch(claimDocumentsProvider(widget.claimId!));
    }
    ref.watch(unclaimedBillsProvider);
    final policies =
        ref.watch(policiesProvider).value ?? const <InsurancePolicy>[];
    final documents =
        ref.watch(allDocumentsProvider).value ?? const <Document>[];
    _initialize();
    final state = ref.watch(claimEditControllerProvider);

    // Bills first (the usual attachments), then everything else.
    final ordered = [
      ...documents.where((d) => d.type == DocumentType.bill),
      ...documents.where((d) => d.type != DocumentType.bill),
    ];

    return Scaffold(
      backgroundColor: colors.bgSection,
      appBar: AppBar(
        backgroundColor: colors.bgSection,
        leading: BackButton(color: colors.ink),
        toolbarHeight: 44,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
          children: [
            Text(
              widget.claimId == null ? l10n.claimNew : l10n.claimEdit,
              style: typo.pageTitle.copyWith(fontSize: 25),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _title,
              style: typo.body,
              onChanged: ref
                  .read(claimEditControllerProvider.notifier)
                  .setTitle,
              decoration: InputDecoration(
                labelText: l10n.claimTitleLabel,
                hintText: l10n.claimTitleHint,
              ),
            ),
            const SizedBox(height: 14),
            if (policies.isEmpty)
              Text(l10n.claimNoPolicyYet,
                  style: typo.caption.copyWith(color: colors.muted))
            else if (policies.length == 1)
              Text(
                '${l10n.claimPolicyLabel}: ${_policyLabel(policies.first)}',
                style: typo.body,
              )
            else
              DropdownButtonFormField<String?>(
                // DropdownButtonFormField only applies `initialValue` once
                // per FormField instance; keying it on the resolved value
                // forces a fresh instance (and a fresh initial value) when
                // the selection changes from outside the dropdown itself
                // (e.g. the edit-draft preselect).
                key: ValueKey(
                  policies.any((p) => p.id == state.policyId)
                      ? state.policyId
                      : null,
                ),
                initialValue: policies.any((p) => p.id == state.policyId)
                    ? state.policyId
                    : null,
                style: typo.body,
                decoration: InputDecoration(labelText: l10n.claimPolicyLabel),
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(l10n.claimPolicyNone),
                  ),
                  for (final policy in policies)
                    DropdownMenuItem<String?>(
                      value: policy.id,
                      child: Text(_policyLabel(policy)),
                    ),
                ],
                onChanged: (value) => ref
                    .read(claimEditControllerProvider.notifier)
                    .setPolicy(value),
              ),
            const SizedBox(height: 14),
            Text(l10n.claimPickDocuments, style: typo.cardTitle),
            Text(l10n.claimPickDocumentsSub,
                style: typo.caption.copyWith(color: colors.muted)),
            const SizedBox(height: 6),
            for (final doc in ordered)
              CheckboxListTile(
                value: state.selectedDocumentIds.contains(doc.id),
                onChanged: (_) => ref
                    .read(claimEditControllerProvider.notifier)
                    .toggleDocument(doc.id),
                dense: true,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(doc.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: typo.body),
                subtitle: Text(
                  '${doc.type.localizedLabel(l10n)} · '
                  '${doc.documentDate.monthDay}',
                  style: typo.caption.copyWith(color: colors.muted),
                ),
              ),
            if (state.error != null) ...[
              const SizedBox(height: 8),
              Text(state.error!,
                  style: typo.caption.copyWith(color: colors.amber)),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: state.saving ? null : _save,
              child: Text(state.saving ? l10n.saving : l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Star Health · POL-1" — how a policy is displayed for selection.
String _policyLabel(InsurancePolicy policy) =>
    '${policy.insurerName} · ${policy.policyNumber}';
