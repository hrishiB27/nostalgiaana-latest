package com.nostalgiaana.audio.category;

/**
 * The fixed set of official show categories. {@link Category} rows are still
 * a free-text-named, admin-managed table (kept for backward compatibility
 * with the existing categoryId-based upload/response DTOs), but
 * {@link CategoryService} uses this enum to reject any name that isn't one
 * of these five, so the table can never drift from the official list.
 */
public enum CategoryName {
    WEEKNIGHT_SHOWS("Weeknight Shows"),
    WEEKEND_CHARCHA_SHOWS("Weekend Charcha Shows"),
    KHOJ_SERIES("Khoj Series"),
    SPECIAL_GUEST_PRESENTATIONS("Special Guest Presentations"),
    MEMBER_PRESENTATIONS("Member Presentations");

    public final String displayName;

    CategoryName(String displayName) {
        this.displayName = displayName;
    }

    public static boolean isOfficial(String name) {
        if (name == null) {
            return false;
        }
        String trimmed = name.trim();
        for (CategoryName category : values()) {
            if (category.displayName.equalsIgnoreCase(trimmed)) {
                return true;
            }
        }
        return false;
    }
}
