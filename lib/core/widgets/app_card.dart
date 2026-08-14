import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';

/// White surface card — the base container of the design language.
///
/// Radius 14 by default, hairline border (visible only in dark), soft
/// shadow in light. Wraps [InkWell] when [onTap] is given so every card
/// stays a proper touch target.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
    this.radius = AppRadius.card,
    this.color,
    this.borderColor,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? color;
  final Color? borderColor;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: BorderSide(color: borderColor ?? colors.cardBorder),
    );

    Widget card = Container(
      decoration: ShapeDecoration(
        color: color ?? colors.card,
        shape: shape,
        shadows: colors.cardShadow,
      ),
      child: onTap == null
          ? Padding(padding: padding, child: child)
          : Material(
              color: Colors.transparent,
              shape: shape,
              child: InkWell(
                onTap: onTap,
                customBorder: shape,
                child: Padding(padding: padding, child: child),
              ),
            ),
    );

    if (semanticLabel != null) {
      card = Semantics(
        label: semanticLabel,
        button: onTap != null,
        child: card,
      );
    }
    return card;
  }
}
