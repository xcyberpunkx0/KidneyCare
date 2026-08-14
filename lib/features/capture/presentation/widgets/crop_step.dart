import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import 'camera_step.dart';

/// Crop step: "Adjust the corners" with accent corner handles, then
/// retake or continue to extraction.
class CropStep extends StatefulWidget {
  const CropStep({
    super.key,
    required this.imageBytes,
    required this.onRetake,
    required this.onCropped,
  });

  final Uint8List imageBytes;
  final VoidCallback onRetake;
  final ValueChanged<Uint8List> onCropped;

  @override
  State<CropStep> createState() => _CropStepState();
}

class _CropStepState extends State<CropStep> {
  final _controller = CropController();
  bool _cropping = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;
    final l10n = context.l10n;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Text(
            l10n.adjustCorners,
            style: typo.cardTitle.copyWith(
              fontSize: 14,
              color: CaptureChrome.ink,
            ),
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 28, vertical: 6),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Crop(
                image: widget.imageBytes,
                controller: _controller,
                baseColor: CaptureChrome.background,
                maskColor: CaptureChrome.background.withValues(alpha: 0.6),
                cornerDotBuilder: (size, alignment) =>
                    _CornerHandle(color: colors.accent),
                onCropped: (result) {
                  setState(() => _cropping = false);
                  switch (result) {
                    case CropSuccess(:final croppedImage):
                      widget.onCropped(croppedImage);
                    case CropFailure():
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.cropFailed)),
                      );
                  }
                },
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
          child: Row(
            children: [
              Expanded(
                child: _FlowButton(
                  label: l10n.retake,
                  outlined: true,
                  onTap: widget.onRetake,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FlowButton(
                  label: _cropping ? l10n.preparingPhoto : l10n.usePhoto,
                  onTap: _cropping
                      ? null
                      : () {
                          setState(() => _cropping = true);
                          _controller.crop();
                        },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CornerHandle extends StatelessWidget {
  const _CornerHandle({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
    );
  }
}

class _FlowButton extends StatelessWidget {
  const _FlowButton({
    required this.label,
    required this.onTap,
    this.outlined = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typo;

    return Material(
      color: outlined ? Colors.transparent : colors.accent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(99),
        side: outlined
            ? const BorderSide(color: CaptureChrome.outline, width: 1.5)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(99),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 13),
          child: Center(
            child: Text(
              label,
              style: typo.cardTitle.copyWith(
                color: outlined ? CaptureChrome.ink : colors.onAccent,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
