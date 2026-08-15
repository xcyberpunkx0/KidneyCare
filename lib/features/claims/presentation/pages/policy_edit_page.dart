import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/storage/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/repository_impl/claims_repository_impl.dart';
import '../controllers/claims_providers.dart';

/// Edit (or create) the family's insurance policy: insurer, number, TPA
/// and the claim submission window that drives deadline reminders.
class PolicyEditPage extends ConsumerStatefulWidget {
  const PolicyEditPage({super.key});

  @override
  ConsumerState<PolicyEditPage> createState() => _PolicyEditPageState();
}

class _PolicyEditPageState extends ConsumerState<PolicyEditPage> {
  final _insurer = TextEditingController();
  final _number = TextEditingController();
  final _tpa = TextEditingController();
  final _window = TextEditingController(text: '30');
  String? _policyId;
  bool _loaded = false;
  String? _error;

  @override
  void dispose() {
    _insurer.dispose();
    _number.dispose();
    _tpa.dispose();
    _window.dispose();
    super.dispose();
  }

  void _prefill(List<InsurancePolicy> policies) {
    if (_loaded || policies.isEmpty) return;
    final policy = policies.first;
    _policyId = policy.id;
    _insurer.text = policy.insurerName;
    _number.text = policy.policyNumber;
    _tpa.text = policy.tpaName;
    _window.text = '${policy.claimWindowDays}';
    _loaded = true;
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final window = int.tryParse(_window.text.trim());
    if (_insurer.text.trim().isEmpty || _number.text.trim().isEmpty) {
      setState(() => _error = l10n.policyRequired);
      return;
    }
    if (window == null || window <= 0) {
      setState(() => _error = l10n.policyWindowInvalid);
      return;
    }
    final result = await ref.read(claimsRepositoryProvider).savePolicy(
          id: _policyId,
          insurerName: _insurer.text.trim(),
          policyNumber: _number.text.trim(),
          tpaName: _tpa.text.trim(),
          claimWindowDays: window,
        );
    if (!mounted) return;
    result.when(
      ok: (_) => Navigator.pop(context),
      err: (failure) => setState(() => _error = failure.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;
    ref.listen(policiesProvider, (_, next) {
      final policies = next.value;
      if (policies != null) setState(() => _prefill(policies));
    });
    _prefill(ref.watch(policiesProvider).value ?? const []);

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
            Text(l10n.policyTitle,
                style: typo.pageTitle.copyWith(fontSize: 25)),
            const SizedBox(height: 16),
            for (final (label, controller, keyboard) in [
              (l10n.policyInsurerLabel, _insurer, TextInputType.text),
              (l10n.policyNumberLabel, _number, TextInputType.text),
              (l10n.policyTpaLabel, _tpa, TextInputType.text),
              (l10n.policyWindowLabel, _window, TextInputType.number),
            ]) ...[
              TextField(
                controller: controller,
                keyboardType: keyboard,
                style: typo.body,
                decoration: InputDecoration(labelText: label),
              ),
              const SizedBox(height: 12),
            ],
            if (_error != null) ...[
              Text(_error!,
                  style: typo.caption.copyWith(color: colors.amber)),
              const SizedBox(height: 12),
            ],
            FilledButton(onPressed: _save, child: Text(l10n.save)),
          ],
        ),
      ),
    );
  }
}
