import 'package:flutter/material.dart';

import 'app_breakpoints.dart';
import 'app_spacing.dart';

/// Centers page content and clamps it to a max width on wide windows,
/// with an extra gutter beyond the screen's own existing padding. Reads
/// *local* available width via its own `LayoutBuilder` (matching
/// `AdaptiveListGrid`'s pattern) rather than the whole window's
/// `MediaQuery` width — correct when nested next to a `NavigationRail`,
/// where the window can be wide while this widget's actual pane is
/// narrower, or vice versa.
///
/// On narrow/mobile widths this is a no-op passthrough — returns [child]
/// exactly as it renders today, so mobile layouts are unaffected.
class AdaptiveContentWrapper extends StatelessWidget {
  const AdaptiveContentWrapper({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (!AppBreakpoints.isDesktopWidth(width)) return child;

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: AppSpacing.maxContentWidthFor(width),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.gutterFor(width),
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
