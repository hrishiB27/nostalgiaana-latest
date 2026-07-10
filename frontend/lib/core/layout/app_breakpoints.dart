import 'package:flutter/material.dart';

/// Single source of truth for the desktop/mobile layout split. "Desktop"
/// here means *wide window*, not platform — a desktop build in a narrow
/// window still gets the mobile layout, and a wide mobile-web viewport
/// gets the desktop layout.
class AppBreakpoints {
  const AppBreakpoints._();

  /// Above this logical-pixel width, screens switch to their desktop
  /// layout (NavigationRail, grids, centered max-width content, etc).
  static const double desktop = 600.0;

  /// M3 "expanded" window size class threshold — spacing graduation only.
  static const double expanded = 840.0;

  /// M3 "large" window size class threshold — spacing graduation only.
  static const double large = 1200.0;

  /// M3 "extra-large" window size class threshold — spacing graduation only.
  static const double extraLarge = 1600.0;

  static bool isDesktopWidth(double width) => width > desktop;

  static bool isDesktop(BuildContext context) =>
      isDesktopWidth(MediaQuery.sizeOf(context).width);
}
