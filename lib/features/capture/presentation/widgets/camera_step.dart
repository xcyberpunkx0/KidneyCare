import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/theme/app_typography.dart';

/// Capture chrome colors are fixed: the camera step is always dark,
/// regardless of theme, like a real camera surface.
abstract final class CaptureChrome {
  static const background = Color(0xFF14171C);
  static const viewfinder = Color(0xFF20242C);
  static const ink = Color(0xFFF4F5F8);
  static const pillBg = Color(0x1FFFFFFF);
  static const frame = Color(0x8CFFFFFF);
  static const outline = Color(0x4DFFFFFF);
}

/// Camera step: viewfinder with a document frame guide, gallery access
/// and a shutter. The system camera opens on shutter tap so focus, flash
/// and permissions stay native.
class CameraStep extends StatelessWidget {
  const CameraStep({
    super.key,
    required this.onCancel,
    required this.onShutter,
    required this.onGallery,
  });

  final VoidCallback onCancel;
  final VoidCallback onShutter;
  final VoidCallback onGallery;

  @override
  Widget build(BuildContext context) {
    final typo = context.typo;
    final l10n = context.l10n;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Pill(
                onTap: onCancel,
                child: Text(
                  l10n.cancel,
                  style: typo.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: CaptureChrome.ink,
                  ),
                ),
              ),
              _Pill(
                child: Text(
                  l10n.fillFrame,
                  style: typo.bodySmall.copyWith(color: CaptureChrome.ink),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            decoration: BoxDecoration(
              color: CaptureChrome.viewfinder,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: FractionallySizedBox(
                widthFactor: 0.76,
                child: AspectRatio(
                  aspectRatio: 3 / 4,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: CaptureChrome.frame,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        l10n.docInView,
                        textAlign: TextAlign.center,
                        style: typo.caption.copyWith(
                          fontSize: 11.5,
                          height: 1.6,
                          color: CaptureChrome.frame,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(36, 20, 36, 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Semantics(
                button: true,
                label: l10n.pickFromLibrary,
                child: InkWell(
                  onTap: onGallery,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: CaptureChrome.outline,
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.photo_library_outlined,
                      size: 18,
                      color: CaptureChrome.frame,
                    ),
                  ),
                ),
              ),
              Semantics(
                button: true,
                label: l10n.takePhoto,
                child: GestureDetector(
                  onTap: onShutter,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 44, height: 44),
            ],
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: CaptureChrome.pillBg,
      borderRadius: BorderRadius.circular(99),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(99),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: child,
        ),
      ),
    );
  }
}
