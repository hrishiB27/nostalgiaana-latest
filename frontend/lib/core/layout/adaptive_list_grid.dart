import 'package:flutter/material.dart';

import 'app_breakpoints.dart';

/// Renders [itemCount] items via [itemBuilder] as a single-column
/// `ListView.separated` on narrow widths (identical to a plain list), or
/// a `GridView.builder` with a fixed row height on wide widths. Column
/// count is derived from available width via
/// `SliverGridDelegateWithMaxCrossAxisExtent` rather than manual
/// breakpoint math.
class AdaptiveListGrid extends StatelessWidget {
  const AdaptiveListGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.padding = EdgeInsets.zero,
    this.spacing = 12,
    this.tileMaxExtent = 420,
    this.tileHeight = 108,
  });

  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final EdgeInsets padding;
  final double spacing;
  final double tileMaxExtent;
  final double tileHeight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!AppBreakpoints.isDesktopWidth(constraints.maxWidth)) {
          return ListView.separated(
            padding: padding,
            itemCount: itemCount,
            separatorBuilder: (_, _) => SizedBox(height: spacing),
            itemBuilder: itemBuilder,
          );
        }
        return GridView.builder(
          padding: padding,
          itemCount: itemCount,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: tileMaxExtent,
            mainAxisExtent: tileHeight,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
          ),
          itemBuilder: itemBuilder,
        );
      },
    );
  }
}
