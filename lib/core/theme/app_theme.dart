import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// Builds the light (Recora) and dark (Nightingale) themes.
///
/// All colors come from [AppColors]; widgets must never hardcode color
/// values. Material widgets that leak defaults are overridden here.
abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light, AppColors.light);

  static ThemeData dark() => _build(Brightness.dark, AppColors.dark);

  static ThemeData _build(Brightness brightness, AppColors colors) {
    final typography = AppTypography.forBrightness(brightness);
    final textTheme = GoogleFonts.outfitTextTheme(
      brightness == Brightness.dark
          ? ThemeData.dark().textTheme
          : ThemeData.light().textTheme,
    ).apply(bodyColor: colors.ink, displayColor: colors.ink);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: colors.bgSection,
      canvasColor: colors.bgSection,
      cardColor: colors.card,
      dividerColor: colors.divider,
      splashFactory: InkSparkle.splashFactory,
      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.accent,
        brightness: brightness,
        primary: colors.accent,
        onPrimary: colors.onAccent,
        surface: colors.card,
        onSurface: colors.ink,
        error: colors.critical,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: colors.bgSection,
        foregroundColor: colors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.chipActive,
        contentTextStyle:
            typography.body.copyWith(color: colors.onChipActive),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      extensions: [colors, typography],
    );
  }
}
