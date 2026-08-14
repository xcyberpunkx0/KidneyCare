import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/ask_message.dart';

/// Caregiver question bubble, right-aligned in the active chip color.
class UserBubble extends StatelessWidget {
  const UserBubble({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colors.chipActive,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(6),
          ),
        ),
        child: Text(
          text,
          style: typo.body.copyWith(
            fontSize: 13.5,
            color: colors.onChipActive,
          ),
        ),
      ),
    );
  }
}

/// Assistant answer bubble with cited source documents and the standing
/// medical disclaimer.
class AssistantBubble extends StatelessWidget {
  const AssistantBubble({
    super.key,
    required this.message,
    required this.onOpenSource,
  });

  final AskMessage message;
  final void Function(AskCitation citation) onOpenSource;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 340),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colors.cardTranslucent,
          border: Border.all(color: colors.cardBorder),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(6),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: typo.body.copyWith(
                fontSize: 13.5,
                height: 1.55,
                color: colors.ink,
              ),
            ),
            if (message.citations.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                l10n.sources,
                style: typo.overline.copyWith(
                  fontSize: 10,
                  color: colors.muted,
                ),
              ),
              const SizedBox(height: 6),
              for (final citation in message.citations) ...[
                _SourceRow(
                  citation: citation,
                  onOpen: () => onOpenSource(citation),
                ),
                const SizedBox(height: 5),
              ],
            ],
            const SizedBox(height: 6),
            Text(
              l10n.confirmWithDoctor,
              style: typo.caption.copyWith(
                fontSize: 10,
                height: 1.4,
                color: colors.muted.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Gemini-style loading state: the brand-gradient spark breathing on
/// the left of the chat next to a placeholder bubble whose skeleton
/// lines shimmer while the model composes its answer.
class ThinkingBubble extends StatefulWidget {
  const ThinkingBubble({super.key});

  @override
  State<ThinkingBubble> createState() => _ThinkingBubbleState();
}

class _ThinkingBubbleState extends State<ThinkingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final barColor = colors.muted.withValues(alpha: 0.16);
    final barHighlight = colors.muted.withValues(alpha: 0.38);

    return Semantics(
      label: l10n.askThinking,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final t = _controller.value;
                  final breathe = 0.5 - 0.5 * math.cos(2 * math.pi * t);
                  return Transform.scale(
                    scale: 0.85 + 0.25 * breathe,
                    child: Opacity(
                      opacity: 0.7 + 0.3 * breathe,
                      child: child,
                    ),
                  );
                },
                child: ShaderMask(
                  shaderCallback: (bounds) =>
                      colors.brandGradient.createShader(bounds),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 22,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              constraints: const BoxConstraints(maxWidth: 260),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: colors.cardTranslucent,
                border: Border.all(color: colors.cardBorder),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(6),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return ShaderMask(
                    blendMode: BlendMode.srcATop,
                    shaderCallback: (bounds) => LinearGradient(
                      begin: const Alignment(-1, -0.2),
                      end: const Alignment(1, 0.2),
                      colors: [barColor, barHighlight, barColor],
                      stops: const [0.35, 0.5, 0.65],
                      transform:
                          _SlidingGradient(_controller.value * 3 - 1.5),
                    ).createShader(bounds),
                    child: child,
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SkeletonLine(width: 200, color: barColor),
                    const SizedBox(height: 9),
                    _SkeletonLine(width: 168, color: barColor),
                    const SizedBox(height: 9),
                    _SkeletonLine(width: 116, color: barColor),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Translates the shimmer gradient horizontally across the skeleton so
/// the highlight sweeps left-to-right once per animation cycle.
class _SlidingGradient extends GradientTransform {
  const _SlidingGradient(this.offset);

  final double offset;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * offset, 0, 0);
  }
}

class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine({required this.width, required this.color});

  final double width;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 11,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

class _SourceRow extends StatelessWidget {
  const _SourceRow({required this.citation, required this.onOpen});

  final AskCitation citation;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;

    return Semantics(
      button: true,
      label: l10n.openSource(citation.title),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: colors.fieldBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colors.fieldBorder),
          ),
          child: Row(
            children: [
              Icon(Icons.description_outlined,
                  size: 18, color: colors.muted),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      citation.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typo.caption.copyWith(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: colors.ink,
                      ),
                    ),
                    Text(
                      citation.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typo.caption.copyWith(
                        fontSize: 10,
                        color: colors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                l10n.open,
                style: typo.caption.copyWith(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: colors.accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
