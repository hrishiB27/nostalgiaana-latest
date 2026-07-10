import 'package:flutter/material.dart';

import '../config/theme_config.dart';

/// Anchored page-heading bar for dashboard/content screens — everywhere
/// except the user home screen, which keeps its own plain `AppBar`. A
/// rounded, slightly-darker-beige panel standing in for a system `AppBar`,
/// so it reads as part of the page content rather than OS chrome; drop it
/// at the top of a screen's `Column` (above the scrollable/expanded body)
/// rather than passing it as `Scaffold.appBar`.
///
/// [title] and [actions] mirror `AppBar`'s shape closely on purpose, so
/// converting an existing `AppBar(title: Text(x), actions: [...])` into
/// this component is close to a drop-in swap:
/// ```dart
/// Column(
///   children: [
///     CommandHeaderBar(title: 'Manage Users', actions: [logoutButton]),
///     Expanded(child: bodyContent),
///   ],
/// )
/// ```
class CommandHeaderBar extends StatelessWidget {
  const CommandHeaderBar({
    super.key,
    required this.title,
    this.leading,
    this.actions = const [],
  });

  final String title;
  final Widget? leading;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.headerBeige,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (leading != null) ...[leading!, const SizedBox(width: 12)],
                  Flexible(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
              if (actions.isNotEmpty)
                Row(mainAxisSize: MainAxisSize.min, children: actions),
            ],
          ),
        ),
      ),
    );
  }
}
