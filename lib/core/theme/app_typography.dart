import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography for Recora's Gemini-inspired design language.
///
/// Outfit — a geometric grotesk close to Google Sans — carries all
/// interface text in both themes. Numeric medical values always use
/// Spline Sans Mono so readings line up and misreads are impossible.
@immutable
class AppTypography extends ThemeExtension<AppTypography> {
  const AppTypography({
    required this.pageTitle,
    required this.sectionTitle,
    required this.cardTitle,
    required this.body,
    required this.bodySmall,
    required this.caption,
    required this.overline,
    required this.metricValue,
    required this.metricValueLarge,
    required this.metricLabel,
    required this.numberFamily,
  });

  /// Screen headers, e.g. "Labs", "Medicines" — 26px semibold.
  final TextStyle pageTitle;

  /// In-page section headers, e.g. "Today's doses" — 14px semibold.
  final TextStyle sectionTitle;

  /// Card headline text — 13.5px medium.
  final TextStyle cardTitle;

  /// Default reading text.
  final TextStyle body;

  /// Secondary reading text.
  final TextStyle bodySmall;

  /// Muted metadata (dates, counts).
  final TextStyle caption;

  /// Uppercase spaced labels, e.g. "NEEDS ATTENTION".
  final TextStyle overline;

  /// Numeric values on metric tiles — 16px bold mono.
  final TextStyle metricValue;

  /// Big lab reading — 34px bold mono.
  final TextStyle metricValueLarge;

  /// Tiny label above a metric value.
  final TextStyle metricLabel;

  /// Font family used for numbers (always the mono face).
  final String numberFamily;

  factory AppTypography.forBrightness(Brightness brightness) {
    final sans = GoogleFonts.outfit().fontFamily!;
    final mono = GoogleFonts.splineSansMono().fontFamily!;

    TextStyle sansStyle(double size, FontWeight weight,
        {double? spacing, double? height}) {
      return TextStyle(
        fontFamily: sans,
        fontSize: size,
        fontWeight: weight,
        letterSpacing: spacing,
        height: height,
      );
    }

    TextStyle numStyle(double size, FontWeight weight, {double? spacing}) {
      return TextStyle(
        fontFamily: mono,
        fontSize: size,
        fontWeight: weight,
        letterSpacing: spacing,
      );
    }

    return AppTypography(
      pageTitle: sansStyle(26, FontWeight.w600, spacing: -0.3),
      sectionTitle: sansStyle(14, FontWeight.w600, spacing: -0.1),
      cardTitle: sansStyle(13.5, FontWeight.w500),
      body: sansStyle(13, FontWeight.w400, height: 1.45),
      bodySmall: sansStyle(12, FontWeight.w400, height: 1.4),
      caption: sansStyle(11, FontWeight.w400),
      overline: sansStyle(10.5, FontWeight.w600, spacing: 0.8),
      metricValue: numStyle(16, FontWeight.w700, spacing: -0.3),
      metricValueLarge: numStyle(34, FontWeight.w700, spacing: -0.7),
      metricLabel: sansStyle(10, FontWeight.w400),
      numberFamily: mono,
    );
  }

  /// A numeric style at an arbitrary size in the mono number family.
  TextStyle number(double size,
      {FontWeight weight = FontWeight.w700, Color? color}) {
    return TextStyle(
      fontFamily: numberFamily,
      fontSize: size,
      fontWeight: weight,
      letterSpacing: -0.2,
      color: color,
    );
  }

  @override
  AppTypography copyWith() => this;

  @override
  AppTypography lerp(ThemeExtension<AppTypography>? other, double t) {
    if (other is! AppTypography) return this;
    return t < 0.5 ? this : other;
  }
}

extension AppTypographyX on BuildContext {
  AppTypography get typo => Theme.of(this).extension<AppTypography>()!;
}
