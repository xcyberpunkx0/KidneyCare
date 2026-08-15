import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/storage/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_format_x.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../shared/domain/claim_money.dart';
import '../../../../shared/domain/claim_status.dart';
import '../../data/repository_impl/claims_repository_impl.dart';
import '../controllers/claims_providers.dart';
import '../widgets/claim_checklist.dart';

/// One claim: status trail, amounts, attached documents, checklist, and
/// the status-appropriate primary action.
class ClaimDetailPage extends ConsumerWidget {
  const ClaimDetailPage({super.key, required this.claimId});

  final String claimId;

  Future<void> _showResult(
      BuildContext context, Future<Result<void>> future) async {
    final messenger = ScaffoldMessenger.of(context);
    final result = await future;
    result.when(
      ok: (_) {},
      err: (failure) =>
          messenger.showSnackBar(SnackBar(content: Text(failure.message))),
    );
  }

  Future<void> _markSubmitted(BuildContext context, WidgetRef ref,
      Claim claim, List<Document> documents) async {
    // The repo also guards this, but a snackbar with the localized
    // message beats surfacing the repo's English failure text.
    if (documents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.claimNoDocsError)),
      );
      return;
    }
    final entered =
        await showDialog<({int paise, String ref, DateTime submittedOn})>(
      context: context,
      builder: (_) => const _SubmitDialog(),
    );
    if (entered == null || !context.mounted) return;
    await _showResult(
      context,
      ref.read(claimsRepositoryProvider).markSubmitted(
            claimId: claim.id,
            submittedOn: entered.submittedOn,
            claimedAmountPaise: entered.paise,
            insurerRef: entered.ref,
          ),
    );
  }

  Future<void> _recordOutcome(
      BuildContext context, WidgetRef ref, Claim claim) async {
    final entered = await showDialog<
        ({ClaimStatus outcome, int? paise, DateTime settledOn})>(
      context: context,
      builder: (_) =>
          _OutcomeDialog(claimedPaise: claim.claimedAmountPaise),
    );
    if (entered == null || !context.mounted) return;
    await _showResult(
      context,
      ref.read(claimsRepositoryProvider).recordOutcome(
            claimId: claim.id,
            outcome: entered.outcome,
            settledOn: entered.settledOn,
            approvedAmountPaise: entered.paise,
          ),
    );
  }

  Future<void> _delete(
      BuildContext context, WidgetRef ref, Claim claim) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: Text(l10n.claimDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.claimDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await ref.read(claimsRepositoryProvider).deleteClaim(claim.id);
    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;
    final claim = ref.watch(claimProvider(claimId)).value;
    final documents =
        ref.watch(claimDocumentsProvider(claimId)).value ?? const [];
    final checklist =
        ref.watch(claimChecklistProvider(claimId)).value ?? const [];

    if (claim == null) {
      return Scaffold(
        backgroundColor: colors.bgSection,
        appBar: AppBar(
            backgroundColor: colors.bgSection,
            leading: BackButton(color: colors.ink)),
        body: const SizedBox.shrink(),
      );
    }
    final repo = ref.read(claimsRepositoryProvider);

    return Scaffold(
      backgroundColor: colors.bgSection,
      appBar: AppBar(
        backgroundColor: colors.bgSection,
        leading: BackButton(color: colors.ink),
        toolbarHeight: 44,
        actions: [
          if (claim.status == ClaimStatus.draft) ...[
            IconButton(
              icon: Icon(Icons.edit_outlined, color: colors.ink, size: 20),
              onPressed: () => context.pushNamed('claimEdit',
                  queryParameters: {'id': claim.id}),
            ),
            IconButton(
              icon:
                  Icon(Icons.delete_outline, color: colors.ink, size: 20),
              onPressed: () => _delete(context, ref, claim),
            ),
          ],
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(claim.title,
                      style: typo.pageTitle.copyWith(fontSize: 25)),
                ),
                const SizedBox(width: 8),
                _StatusChip(status: claim.status),
              ],
            ),
            const SizedBox(height: 10),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _line(typo, colors, l10n.claimCreatedOn,
                      claim.createdAt.monthDay),
                  if (claim.submittedOn != null)
                    _line(typo, colors, l10n.claimSubmittedOn,
                        claim.submittedOn!.monthDay),
                  if (claim.settledOn != null)
                    _line(typo, colors, l10n.claimSettledOn,
                        claim.settledOn!.monthDay),
                  if (claim.claimedAmountPaise != null)
                    _line(typo, colors, l10n.claimAmountClaimed,
                        formatPaise(claim.claimedAmountPaise!)),
                  if (claim.approvedAmountPaise != null)
                    _line(typo, colors, l10n.claimAmountApproved,
                        formatPaise(claim.approvedAmountPaise!)),
                  if (claim.insurerRef.isNotEmpty)
                    _line(typo, colors, l10n.claimInsurerRefLabel,
                        claim.insurerRef),
                  if (claim.note.isNotEmpty)
                    _line(typo, colors, l10n.claimNotesLabel, claim.note),
                ],
              ),
            ),
            SectionHeader(title: l10n.claimDocumentsSection),
            for (final doc in documents)
              AppCard(
                onTap: () => context.pushNamed('documentViewer',
                    pathParameters: {'id': doc.id}),
                child: Row(
                  children: [
                    Icon(Icons.description_outlined,
                        size: 18, color: colors.muted),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(doc.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: typo.body),
                    ),
                    Text(doc.documentDate.monthDay,
                        style:
                            typo.caption.copyWith(color: colors.muted)),
                  ],
                ),
              ),
            SectionHeader(title: l10n.claimChecklistSection),
            ClaimChecklist(
              items: checklist,
              onToggle: (item, done) => repo.setChecklistItemDone(
                  item.id, item.claimId, item.label, item.sortOrder, done),
              onAdd: (label) => repo.addChecklistItem(claim.id, label),
              onRemove: (item) => repo.removeChecklistItem(item.id),
            ),
            const SizedBox(height: 20),
            switch (claim.status) {
              ClaimStatus.draft => FilledButton(
                  onPressed: () =>
                      _markSubmitted(context, ref, claim, documents),
                  child: Text(l10n.claimMarkSubmitted),
                ),
              ClaimStatus.submitted => FilledButton(
                  onPressed: () => _recordOutcome(context, ref, claim),
                  child: Text(l10n.claimRecordOutcome),
                ),
              ClaimStatus.rejected => OutlinedButton(
                  onPressed: () =>
                      _showResult(context, repo.reopenAsDraft(claim.id)),
                  child: Text(l10n.claimReopen),
                ),
              _ => const SizedBox.shrink(),
            },
          ],
        ),
      ),
    );
  }

  Widget _line(
      AppTypography typo, AppColors colors, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: typo.caption.copyWith(color: colors.muted)),
          Text(value, style: typo.body),
        ],
      ),
    );
  }
}

/// Colored status pill, matching [ClaimCard]'s status presentation so a
/// claim reads the same way in the list and on its detail page.
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final ClaimStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final (bg, fg) = switch (status) {
      ClaimStatus.draft => (colors.card, colors.muted),
      ClaimStatus.submitted => (colors.blueBg, colors.blue),
      ClaimStatus.approved => (colors.greenBg, colors.green),
      ClaimStatus.partiallySettled => (colors.amberBg, colors.amber),
      ClaimStatus.rejected => (colors.orangeBg, colors.orange),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        status.localizedLabel(context.l10n),
        style: typo.caption
            .copyWith(color: fg, fontWeight: FontWeight.w600, fontSize: 11),
      ),
    );
  }
}

/// Submission date defaults to today but is editable — bills are often
/// entered a few days after they were actually posted to the insurer.
/// The dialog also collects amount and the insurer's claim number.
class _SubmitDialog extends StatefulWidget {
  const _SubmitDialog();

  @override
  State<_SubmitDialog> createState() => _SubmitDialogState();
}

class _SubmitDialogState extends State<_SubmitDialog> {
  final _amount = TextEditingController();
  final _ref = TextEditingController();
  DateTime _submittedOn = DateTime.now();
  String? _error;

  @override
  void dispose() {
    _amount.dispose();
    _ref.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _submittedOn,
      firstDate: DateTime(2020, 1, 1),
      lastDate: DateTime.now(),
      helpText: context.l10n.claimSubmittedOn,
    );
    if (picked != null) setState(() => _submittedOn = picked);
  }

  void _confirm() {
    final paise = parsePaise(_amount.text);
    if (paise == null) {
      setState(() => _error = context.l10n.claimAmountInvalid);
      return;
    }
    Navigator.pop(context,
        (paise: paise, ref: _ref.text.trim(), submittedOn: _submittedOn));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final typo = context.typo;
    return AlertDialog(
      title: Text(l10n.claimMarkSubmitted, style: typo.cardTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DateField(
            label: l10n.claimSubmittedOn,
            date: _submittedOn,
            onTap: _pickDate,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _amount,
            autofocus: true,
            keyboardType: TextInputType.number,
            style: typo.body,
            decoration: InputDecoration(
              labelText: l10n.claimAmountClaimed,
              hintText: l10n.claimAmountHint,
              errorText: _error,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _ref,
            style: typo.body,
            decoration:
                InputDecoration(labelText: l10n.claimInsurerRefLabel),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _confirm, child: Text(l10n.save)),
      ],
    );
  }
}

class _OutcomeDialog extends StatefulWidget {
  const _OutcomeDialog({required this.claimedPaise});

  final int? claimedPaise;

  @override
  State<_OutcomeDialog> createState() => _OutcomeDialogState();
}

class _OutcomeDialogState extends State<_OutcomeDialog> {
  final _amount = TextEditingController();
  ClaimStatus _outcome = ClaimStatus.approved;
  DateTime _settledOn = DateTime.now();
  String? _error;
  String? _warning;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _settledOn,
      firstDate: DateTime(2020, 1, 1),
      lastDate: DateTime.now(),
      helpText: context.l10n.claimSettledOn,
    );
    if (picked != null) setState(() => _settledOn = picked);
  }

  void _confirm() {
    final l10n = context.l10n;
    int? paise;
    if (_outcome != ClaimStatus.rejected) {
      paise = parsePaise(_amount.text);
      if (paise == null) {
        setState(() => _error = l10n.claimAmountInvalid);
        return;
      }
      // Warn, don't block — partial settlements have quirky math.
      final claimed = widget.claimedPaise;
      if (claimed != null && paise > claimed && _warning == null) {
        setState(() => _warning = l10n.claimApprovedExceedsWarning);
        return;
      }
    }
    Navigator.pop(
        context, (outcome: _outcome, paise: paise, settledOn: _settledOn));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final typo = context.typo;
    final colors = context.colors;
    return AlertDialog(
      title: Text(l10n.claimRecordOutcome, style: typo.cardTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DateField(
            label: l10n.claimSettledOn,
            date: _settledOn,
            onTap: _pickDate,
          ),
          const SizedBox(height: 10),
          RadioGroup<ClaimStatus>(
            groupValue: _outcome,
            onChanged: (value) =>
                setState(() => _outcome = value ?? _outcome),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final (outcome, label) in [
                  (ClaimStatus.approved, l10n.claimOutcomeApproved),
                  (ClaimStatus.partiallySettled, l10n.claimOutcomePartial),
                  (ClaimStatus.rejected, l10n.claimOutcomeRejected),
                ])
                  RadioListTile<ClaimStatus>(
                    value: outcome,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(label, style: typo.body),
                  ),
              ],
            ),
          ),
          if (_outcome != ClaimStatus.rejected)
            TextField(
              controller: _amount,
              keyboardType: TextInputType.number,
              style: typo.body,
              decoration: InputDecoration(
                labelText: l10n.claimAmountApproved,
                hintText: l10n.claimAmountHint,
                errorText: _error,
              ),
            ),
          if (_warning != null) ...[
            const SizedBox(height: 8),
            Text(_warning!,
                style: typo.caption.copyWith(color: colors.amber)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _confirm, child: Text(l10n.save)),
      ],
    );
  }
}

/// Label + tappable date pill, used by the submit and outcome dialogs so
/// the recorded date isn't silently forced to "now".
class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  final String label;
  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: typo.body),
        Semantics(
          button: true,
          label: '$label ${date.monthDayYear}',
          child: Material(
            color: colors.fieldBg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: colors.fieldBorder, width: 1.5),
            ),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      date.monthDayYear,
                      style: typo.number(13.5,
                          weight: FontWeight.w600, color: colors.ink),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.event_outlined, size: 14, color: colors.muted),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
