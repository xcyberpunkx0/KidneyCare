import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../documents/data/repository_impl/documents_repository_impl.dart';
import '../../data/repository_impl/ask_repository_impl.dart';
import '../controllers/ask_controller.dart';
import '../widgets/ask_bubbles.dart';
import '../widgets/ask_input_bar.dart';

/// Ask — a chat over the patient's entire vault, with cited sources.
class AskPage extends ConsumerStatefulWidget {
  const AskPage({super.key});

  @override
  ConsumerState<AskPage> createState() => _AskPageState();
}

class _AskPageState extends ConsumerState<AskPage> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  static List<String> _suggestions(AppLocalizations l10n) => [
        l10n.askSuggestion1,
        l10n.askSuggestion2,
        l10n.askSuggestion3,
      ];

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send(String question) {
    _inputController.clear();
    ref.read(askControllerProvider.notifier).send(question);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;
    final suggestions = _suggestions(l10n);
    final messages = ref.watch(askMessagesProvider).value ?? const [];
    final sendState = ref.watch(askControllerProvider);
    final documentCount =
        ref.watch(allDocumentsProvider).value?.length ?? 0;

    ref.listen(askControllerProvider, (previous, next) {
      final failure = next.failure;
      if (failure != null && failure != previous?.failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
        ref.read(askControllerProvider.notifier).dismissFailure();
      }
      // Keep the thinking indicator in view once it appears.
      if (next.sending && previous?.sending != true) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController
                .jumpTo(_scrollController.position.maxScrollExtent);
          }
        });
      }
    });

    ref.listen(askMessagesProvider, (_, _) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController
              .jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    });

    return Scaffold(
      backgroundColor: colors.bgSection,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: Text(
                      l10n.ask,
                      style: typo.pageTitle.copyWith(fontSize: 25),
                    ),
                  ),
                  Text(
                    l10n.searchesAllDocuments(documentCount),
                    style: typo.bodySmall.copyWith(color: colors.muted),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(18, 6, 18, 10),
                children: [
                  if (messages.isEmpty)
                    _IntroCard(onAsk: _send, suggestions: suggestions),
                  for (final message in messages) ...[
                    if (message.isUser)
                      UserBubble(text: message.content)
                    else
                      AssistantBubble(
                        message: message,
                        onOpenSource: (citation) => context.pushNamed(
                          'documentViewer',
                          pathParameters: {'id': citation.documentId},
                        ),
                      ),
                    const SizedBox(height: 12),
                  ],
                  if (sendState.sending) ...[
                    const ThinkingBubble(),
                    const SizedBox(height: 12),
                  ],
                  if (messages.isNotEmpty && !sendState.sending)
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: [
                        for (final suggestion in suggestions.take(2))
                          _SuggestionChip(
                            label: suggestion,
                            onTap: () => _send(suggestion),
                          ),
                      ],
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 104),
              child: AskInputBar(
                controller: _inputController,
                sending: sendState.sending,
                onSend: _send,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard({required this.onAsk, required this.suggestions});

  final ValueChanged<String> onAsk;
  final List<String> suggestions;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.cardTranslucent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.cardBorder),
          ),
          child: Text(
            l10n.askIntro,
            style: typo.body.copyWith(
              fontSize: 13.5,
              height: 1.55,
              color: colors.muted,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [
            for (final suggestion in suggestions)
              _SuggestionChip(
                label: suggestion,
                onTap: () => onAsk(suggestion),
              ),
          ],
        ),
      ],
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;

    return Material(
      color: colors.cardTranslucent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(99),
        side: BorderSide(color: colors.cardBorder),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(99),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          child: Text(
            label,
            style: typo.bodySmall.copyWith(
              color: colors.ink.withValues(alpha: 0.85),
            ),
          ),
        ),
      ),
    );
  }
}
