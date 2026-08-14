import 'package:flutter/widgets.dart';

/// Spacing scale. All layout spacing derives from these steps.
abstract final class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  /// Horizontal screen gutter used by every page.
  static const double gutter = 20;

  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: gutter);
}

/// Corner radius scale — generous, rounded, Gemini-style.
abstract final class AppRadius {
  static const double chip = 12;
  static const double doseChip = 18;
  static const double card = 20;
  static const double attention = 24;
  static const double hero = 28;
  static const double sheet = 28;
  static const double pill = 99;
}

/// Icon sizing scale.
abstract final class AppIconSize {
  static const double xs = 13;
  static const double sm = 15;
  static const double md = 17;
  static const double lg = 21;
  static const double xl = 23;
}

/// Minimum touch target for interactive elements (accessibility).
abstract final class AppTouch {
  static const double minTarget = 48;
}
