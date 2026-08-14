import 'package:flutter/material.dart';

/// Design tokens for Recora's Gemini-inspired design language.
///
/// The language is built on circles and pills, borderless tonal surfaces,
/// and the signature brand gradient (blue → purple → coral) used for the
/// hero card, capture button and wordmark. Light sits on white with
/// `#F0F4F9` tonal cards; dark sits on `#131314` with `#1E1F20` cards.
///
/// Semantics are unchanged: amber marks abnormal values, red is reserved
/// for critical alerts only.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.bgHome,
    required this.bgSection,
    required this.card,
    required this.cardTranslucent,
    required this.cardBorder,
    required this.ink,
    required this.muted,
    required this.accent,
    required this.onAccent,
    required this.accentSoft,
    required this.onAccentSoft,
    required this.accentSoftBorder,
    required this.amber,
    required this.amberBg,
    required this.amberBorder,
    required this.amberChip,
    required this.amberDot,
    required this.green,
    required this.greenBg,
    required this.blue,
    required this.blueBg,
    required this.purple,
    required this.purpleBg,
    required this.orange,
    required this.orangeBg,
    required this.critical,
    required this.criticalBg,
    required this.divider,
    required this.navBg,
    required this.band,
    required this.chartLine,
    required this.chipActive,
    required this.onChipActive,
    required this.brandGradient,
    required this.heroBg,
    required this.heroBorder,
    required this.heroInk,
    required this.heroMuted,
    required this.heroRingBg,
    required this.heroRing,
    required this.heroLabel,
    required this.fieldBg,
    required this.fieldBorder,
    required this.fieldWarnBg,
    required this.cardShadow,
    required this.fabGlow,
    required this.heroShadow,
    required this.navShadow,
  });

  final Color bgHome;
  final Color bgSection;
  final Color card;
  final Color cardTranslucent;
  final Color cardBorder;
  final Color ink;
  final Color muted;
  final Color accent;
  final Color onAccent;
  final Color accentSoft;
  final Color onAccentSoft;
  final Color accentSoftBorder;
  final Color amber;
  final Color amberBg;
  final Color amberBorder;
  final Color amberChip;
  final Color amberDot;
  final Color green;
  final Color greenBg;
  final Color blue;
  final Color blueBg;
  final Color purple;
  final Color purpleBg;
  final Color orange;
  final Color orangeBg;
  final Color critical;
  final Color criticalBg;
  final Color divider;
  final Color navBg;
  final Color band;
  final Color chartLine;
  final Color chipActive;
  final Color onChipActive;

  /// The Gemini-style signature gradient: sharp blue leading edge
  /// diffusing through purple into coral.
  final Gradient brandGradient;

  final Gradient heroBg;
  final Color heroBorder;
  final Color heroInk;
  final Color heroMuted;
  final Color heroRingBg;
  final Color heroRing;
  final Color heroLabel;
  final Color fieldBg;
  final Color fieldBorder;
  final Color fieldWarnBg;
  final List<BoxShadow> cardShadow;
  final List<BoxShadow> fabGlow;
  final List<BoxShadow> heroShadow;
  final List<BoxShadow> navShadow;

  static const _gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4285F4), Color(0xFF9B72CB), Color(0xFFD96570)],
  );

  static const light = AppColors(
    bgHome: Color(0xFFFFFFFF),
    bgSection: Color(0xFFFFFFFF),
    card: Color(0xFFF0F4F9),
    cardTranslucent: Color(0xFFF0F4F9),
    cardBorder: Color(0x00000000),
    ink: Color(0xFF1F1F1F),
    muted: Color(0xFF747775),
    accent: Color(0xFF0B57D0),
    onAccent: Color(0xFFFFFFFF),
    accentSoft: Color(0xFFD3E3FD),
    onAccentSoft: Color(0xFF0B57D0),
    accentSoftBorder: Color(0x00000000),
    amber: Color(0xFFA56300),
    amberBg: Color(0xFFFEF7E0),
    amberBorder: Color(0x00000000),
    amberChip: Color(0xFFFDE293),
    amberDot: Color(0xFFF9AB00),
    green: Color(0xFF146C2E),
    greenBg: Color(0xFFE6F4EA),
    blue: Color(0xFF0B57D0),
    blueBg: Color(0xFFD3E3FD),
    purple: Color(0xFF681DA8),
    purpleBg: Color(0xFFF3E8FD),
    orange: Color(0xFFE8710A),
    orangeBg: Color(0xFFFEEFE3),
    critical: Color(0xFFC5221F),
    criticalBg: Color(0xFFFCE8E6),
    divider: Color(0xFFE4E9F0),
    navBg: Color(0xFFFFFFFF),
    band: Color(0xFFE8F0FE),
    chartLine: Color(0xFF0B57D0),
    chipActive: Color(0xFF0B57D0),
    onChipActive: Color(0xFFFFFFFF),
    brandGradient: _gradient,
    heroBg: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF0B57D0), Color(0xFF3B72E0)],
    ),
    heroBorder: Color(0x00000000),
    heroInk: Color(0xFFFFFFFF),
    heroMuted: Color(0xD9FFFFFF),
    heroRingBg: Color(0x4DFFFFFF),
    heroRing: Color(0xFFFFFFFF),
    heroLabel: Color(0xD9FFFFFF),
    fieldBg: Color(0xFFF0F4F9),
    fieldBorder: Color(0xFFE3E8F0),
    fieldWarnBg: Color(0xFFFEF7E0),
    cardShadow: [],
    fabGlow: [
      BoxShadow(
        color: Color(0x664285F4),
        offset: Offset(0, 4),
        blurRadius: 18,
      ),
    ],
    heroShadow: [
      BoxShadow(
        color: Color(0x330B57D0),
        offset: Offset(0, 6),
        blurRadius: 18,
      ),
    ],
    navShadow: [
      BoxShadow(
        color: Color(0x1A1F1F1F),
        offset: Offset(0, 6),
        blurRadius: 24,
      ),
    ],
  );

  static const dark = AppColors(
    bgHome: Color(0xFF131314),
    bgSection: Color(0xFF131314),
    card: Color(0xFF1E1F20),
    cardTranslucent: Color(0xFF1E1F20),
    cardBorder: Color(0x00000000),
    ink: Color(0xFFE3E3E3),
    muted: Color(0xFF9AA0A6),
    accent: Color(0xFFA8C7FA),
    onAccent: Color(0xFF062E6F),
    accentSoft: Color(0xFF0842A0),
    onAccentSoft: Color(0xFFD3E3FD),
    accentSoftBorder: Color(0x00000000),
    amber: Color(0xFFFDD663),
    amberBg: Color(0xFF2A2005),
    amberBorder: Color(0x00000000),
    amberChip: Color(0xFF3D2E00),
    amberDot: Color(0xFFF9AB00),
    green: Color(0xFF6DD58C),
    greenBg: Color(0xFF14311F),
    blue: Color(0xFFA8C7FA),
    blueBg: Color(0xFF17304F),
    purple: Color(0xFFD0BCFF),
    purpleBg: Color(0xFF2B2140),
    orange: Color(0xFFFDA982),
    orangeBg: Color(0xFF3A2415),
    critical: Color(0xFFF2B8B5),
    criticalBg: Color(0xFF3A1210),
    divider: Color(0xFF2D2F33),
    navBg: Color(0xFF1E1F20),
    band: Color(0xFF17304F),
    chartLine: Color(0xFFA8C7FA),
    chipActive: Color(0xFFA8C7FA),
    onChipActive: Color(0xFF062E6F),
    brandGradient: _gradient,
    heroBg: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF213655), Color(0xFF16233A)],
    ),
    heroBorder: Color(0x00000000),
    heroInk: Color(0xFFE3E3E3),
    heroMuted: Color(0xFF9FB0C8),
    heroRingBg: Color(0x338AB4F8),
    heroRing: Color(0xFFA8C7FA),
    heroLabel: Color(0xFFA8C7FA),
    fieldBg: Color(0xFF282A2C),
    fieldBorder: Color(0xFF3C4043),
    fieldWarnBg: Color(0xFF2A2005),
    cardShadow: [],
    fabGlow: [
      BoxShadow(color: Color(0x734285F4), blurRadius: 22),
    ],
    heroShadow: [
      BoxShadow(color: Color(0x2E4285F4), blurRadius: 20),
    ],
    navShadow: [
      BoxShadow(
        color: Color(0x80000000),
        offset: Offset(0, 6),
        blurRadius: 20,
      ),
    ],
  );

  @override
  AppColors copyWith() => this;

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return t < 0.5 ? this : other;
  }
}

extension AppColorsX on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
