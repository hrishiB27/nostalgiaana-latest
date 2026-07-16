import 'package:flutter/material.dart';

import '../../../core/config/theme_config.dart';

/// The fixed set of official show categories, mirroring the backend's
/// `CategoryName` enum (`audio/src/main/java/.../category/CategoryName.java`).
/// The backend's `categories` table is still free-text/admin-managed (kept
/// for backward compatibility with the existing categoryId-based upload and
/// filtering plumbing), but is now constrained server-side to only ever
/// contain these five names — this enum exists purely to attach UI
/// presentation metadata (color/icon) to whichever of the five a given
/// [CategoryModel] happens to be.
enum ContentCategory {
  weeknightShows,
  weekendCharchaShows,
  khojSeries,
  specialGuestPresentations,
  memberPresentations,
}

extension ContentCategoryMetadata on ContentCategory {
  String get displayName => switch (this) {
        ContentCategory.weeknightShows => 'Weeknight Shows',
        ContentCategory.weekendCharchaShows => 'Weekend Charcha Shows',
        ContentCategory.khojSeries => 'Khoj Series',
        ContentCategory.specialGuestPresentations => 'Special Guest Presentations',
        ContentCategory.memberPresentations => 'Member Presentations',
      };

  /// Reuses the app's existing brand tokens where they're already a close
  /// match (crimson, gold) rather than introducing near-duplicate hexes;
  /// the other three get new colors local to this file since no existing
  /// `AppColors` token fits them.
  Color get color => switch (this) {
        ContentCategory.weeknightShows => AppColors.crimson,
        ContentCategory.khojSeries => AppColors.gold,
        ContentCategory.weekendCharchaShows => const Color(0xFF00A8A0),
        ContentCategory.specialGuestPresentations => const Color(0xFF9A7F7C),
        ContentCategory.memberPresentations => const Color(0xFF20BF6B),
      };

  IconData get icon => switch (this) {
        ContentCategory.weeknightShows => Icons.calendar_today_rounded,
        ContentCategory.weekendCharchaShows => Icons.forum_rounded,
        ContentCategory.khojSeries => Icons.travel_explore_rounded,
        ContentCategory.specialGuestPresentations => Icons.mic_rounded,
        ContentCategory.memberPresentations => Icons.co_present_rounded,
      };
}

/// Matches a backend category name (`CategoryModel.name`) to its
/// [ContentCategory], case/whitespace-insensitively. Returns `null` for
/// anything that doesn't match one of the five official names — callers
/// should fall back to a generic presentation rather than crash, since
/// stale/unexpected data shouldn't be able to break the UI.
ContentCategory? contentCategoryFromName(String name) {
  final normalized = name.trim().toLowerCase();
  for (final category in ContentCategory.values) {
    if (category.displayName.toLowerCase() == normalized) return category;
  }
  return null;
}
