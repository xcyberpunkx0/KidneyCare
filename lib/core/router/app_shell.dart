import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../widgets/app_bottom_nav.dart';

/// Scaffold around the five tab branches: keeps each branch's state
/// alive, hosts the floating pill navigation, and owns the capture
/// button in the corner above it.
///
/// The body extends behind the nav so content scrolls under the floating
/// pill; a gradient scrim fades it out underneath so nothing collides
/// visually. Scrollables must pad their bottom by [AppShell.navClearance].
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  /// Bottom padding scrollable pages need so their last item can scroll
  /// fully above the floating nav and its scrim.
  static const double navClearance = 130;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final scrimColor = navigationShell.currentIndex == 0
        ? colors.bgHome
        : colors.bgSection;

    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: Stack(
        children: [
          // The scrim is painted but must never intercept taps: a painted
          // BoxDecoration hit-tests across its whole rectangle, and its
          // transparent upper band would silently swallow touches meant
          // for content behind it (like the capture button).
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      scrimColor.withValues(alpha: 0),
                      scrimColor.withValues(alpha: 0.85),
                      scrimColor,
                    ],
                    stops: const [0, 0.4, 0.75],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 28),
            child: SafeArea(
              top: false,
              child: AppBottomNav(
                current: AppTab.values[navigationShell.currentIndex],
                onSelect: (tab) => navigationShell.goBranch(
                  tab.index,
                  initialLocation:
                      tab.index == navigationShell.currentIndex,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
