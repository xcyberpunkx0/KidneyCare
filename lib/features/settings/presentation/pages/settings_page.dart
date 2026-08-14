import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/services/gemini_key_store.dart';
import '../../../../core/services/reminder_service.dart';
import '../../../../core/services/vault_export.dart';
import '../../../../core/services/visit_summary_pdf.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_choice_chip.dart';
import '../controllers/locale_controller.dart';

/// Settings: patient details, emergency card, reminders, doctor-visit
/// summary, encrypted-vault backup export, and app info.
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _busy = false;

  Future<void> _editGeminiKey() async {
    final current = ref.read(geminiKeyProvider);
    final entered = await showDialog<String>(
      context: context,
      builder: (_) => _GeminiKeyDialog(current: current),
    );
    // null = cancelled; empty string = remove the stored key.
    if (entered == null) return;
    await ref.read(geminiKeyProvider.notifier).set(entered);
  }

  Future<void> _run(Future<Result<void>> Function() action) async {
    setState(() => _busy = true);
    final result = await action();
    if (!mounted) return;
    setState(() => _busy = false);
    result.when(
      ok: (_) {},
      err: (failure) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(failure.message))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;
    final remindersOn = ref.watch(remindersEnabledProvider);
    final locale = ref.watch(localeProvider);
    final geminiKeySet = ref.watch(geminiKeyProvider).isNotEmpty;

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
            Text(l10n.settings,
                style: typo.pageTitle.copyWith(fontSize: 25)),
            const SizedBox(height: 16),
            SettingsTile(
              icon: Icons.badge_outlined,
              title: l10n.patientDetails,
              subtitle: l10n.patientDetailsSub,
              onTap: () => context.pushNamed('patientEdit'),
            ),
            const SizedBox(height: 9),
            SettingsTile(
              icon: Icons.medical_information_outlined,
              title: l10n.emergencyCardTitle,
              subtitle: l10n.emergencyCardSub,
              onTap: () => context.pushNamed('emergencyCard'),
            ),
            const SizedBox(height: 9),
            SettingsTile(
              icon: Icons.notifications_outlined,
              title: l10n.reminders,
              subtitle: l10n.remindersSub,
              trailing: Switch(
                value: remindersOn,
                activeTrackColor: colors.accent,
                onChanged: (_) =>
                    ref.read(remindersEnabledProvider.notifier).toggle(),
              ),
            ),
            const SizedBox(height: 9),
            SettingsTile(
              icon: Icons.translate,
              title: l10n.language,
              subtitle: l10n.languageSub,
              below: Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  AppChoiceChip(
                    label: l10n.languageSystem,
                    selected: locale == null,
                    onTap: () =>
                        ref.read(localeProvider.notifier).set(null),
                  ),
                  AppChoiceChip(
                    label: 'English',
                    selected: locale == const Locale('en'),
                    onTap: () => ref
                        .read(localeProvider.notifier)
                        .set(const Locale('en')),
                  ),
                  AppChoiceChip(
                    label: 'हिन्दी',
                    selected: locale == const Locale('hi'),
                    onTap: () => ref
                        .read(localeProvider.notifier)
                        .set(const Locale('hi')),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 9),
            SettingsTile(
              icon: Icons.auto_awesome_outlined,
              title: l10n.geminiKeyTitle,
              subtitle:
                  geminiKeySet ? l10n.geminiKeySubOn : l10n.geminiKeySubOff,
              onTap: _editGeminiKey,
            ),
            const SizedBox(height: 9),
            SettingsTile(
              icon: Icons.picture_as_pdf_outlined,
              title: _busy ? l10n.preparing : l10n.visitSummary,
              subtitle: l10n.visitSummarySub,
              onTap: _busy
                  ? null
                  : () =>
                      _run(ref.read(visitSummaryPdfProvider).shareSummary),
            ),
            const SizedBox(height: 9),
            SettingsTile(
              icon: Icons.ios_share_outlined,
              title: _busy ? l10n.preparing : l10n.exportBackup,
              subtitle: l10n.exportBackupSub,
              onTap: _busy
                  ? null
                  : () => _run(ref.read(vaultExportProvider).exportAndShare),
            ),
            const SizedBox(height: 9),
            SettingsTile(
              icon: Icons.lock_outline,
              title: l10n.encryptionTitle,
              subtitle: l10n.encryptionSub,
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'KidneyCare',
                style: typo.caption.copyWith(color: colors.muted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One row of the settings list: tinted icon, title, subtitle, and either
/// a chevron (tappable) or a custom [trailing] control. An optional
/// [below] widget renders as a second row under the tile content.
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
    this.below,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Widget? below;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colors.accentSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 17, color: colors.onAccentSoft),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: typo.cardTitle),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      style: typo.caption.copyWith(color: colors.muted),
                    ),
                  ],
                ),
              ),
              if (trailing != null)
                trailing!
              else if (onTap != null)
                Icon(Icons.chevron_right,
                    size: 18, color: colors.muted),
            ],
          ),
          if (below != null) ...[
            const SizedBox(height: 10),
            below!,
          ],
        ],
      ),
    );
  }
}

/// Paste-your-own Gemini key dialog. Pops with the entered text, an empty
/// string for "remove", or null when cancelled. Owns the text controller
/// so it survives the dialog's exit animation.
class _GeminiKeyDialog extends StatefulWidget {
  const _GeminiKeyDialog({required this.current});

  final String current;

  @override
  State<_GeminiKeyDialog> createState() => _GeminiKeyDialogState();
}

class _GeminiKeyDialogState extends State<_GeminiKeyDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.current);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;

    return AlertDialog(
      backgroundColor: colors.card,
      title: Text(l10n.geminiKeyTitle, style: typo.cardTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            autocorrect: false,
            enableSuggestions: false,
            style: typo.body,
            decoration: InputDecoration(hintText: l10n.geminiKeyHint),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.geminiKeyHelp,
            style: typo.caption.copyWith(color: colors.muted),
          ),
        ],
      ),
      actions: [
        if (widget.current.isNotEmpty)
          TextButton(
            onPressed: () => Navigator.pop(context, ''),
            child: Text(l10n.geminiKeyRemove),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
