import 'app_breakpoints.dart';

/// Layout spacing tokens for the desktop-adaptive overhaul. Deliberately
/// separate from `theme_config.dart` (colors/text only) since this is
/// structural, not visual, styling.
///
/// Gutter and max-content-width are graduated in discrete steps across
/// Material 3's window size class tiers rather than continuously
/// interpolated — deliberately simple, easily-scannable step functions.
class AppSpacing {
  const AppSpacing._();

  /// Extra horizontal gutter added outside a screen's own existing
  /// padding when running in desktop layout, sized to the given local
  /// available width (not the whole window).
  static double gutterFor(double width) {
    if (width >= AppBreakpoints.extraLarge) return 64;
    if (width >= AppBreakpoints.large) return 48;
    if (width >= AppBreakpoints.expanded) return 32;
    return 24; // 600–839 (medium)
  }

  /// Clamp for primary page content, sized to the given local available
  /// width. No cap below the `expanded` tier — content isn't wide enough
  /// yet for one to matter.
  static double maxContentWidthFor(double width) {
    if (width >= AppBreakpoints.extraLarge) return 1400;
    if (width >= AppBreakpoints.large) return 1200;
    if (width >= AppBreakpoints.expanded) return 900;
    return double.infinity;
  }
}
