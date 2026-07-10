import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/theme_config.dart';
import '../../../core/layout/adaptive_content_wrapper.dart';
import '../../../core/network/api_error.dart';
import '../../../core/widgets/nostalgiaana_brand_text.dart';
import '../../../core/widgets/tier_badge.dart';
import '../../../sampleui/screens/auth_landing_screen.dart';
import '../../auth/application/auth_notifier.dart';
import '../../auth/data/models/user_role.dart';
import '../../category/application/category_providers.dart';
import '../../content/application/listener_content_providers.dart';
import '../../content/data/models/content_response_model.dart';
import '../../content/data/models/content_type.dart';
import '../../content/presentation/content_detail_screen.dart';
import '../../content/presentation/widgets/now_playing_bar.dart';
import '../../payment/presentation/premium_upgrade_sheet.dart';

/// Home shell a regular (LISTENER/PREMIUM) user lands on after OTP
/// verification — a category filter row plus two horizontally scrolling
/// shelves (Shows, Audios), both refetched whenever the selected category
/// changes (`null` = "All").
class UserHomeScreenShell extends ConsumerStatefulWidget {
  const UserHomeScreenShell({super.key});

  @override
  ConsumerState<UserHomeScreenShell> createState() => _UserHomeScreenShellState();
}

class _UserHomeScreenShellState extends ConsumerState<UserHomeScreenShell> {
  String? _selectedCategoryId;

  Future<bool> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.crimson),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _logout() async {
    if (!await _confirmLogout()) return;
    if (!mounted) return;
    await ref.read(authNotifierProvider.notifier).logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthLandingScreen()),
      (route) => false,
    );
  }

  Widget _buildCategoryChips() {
    final categories = ref.watch(categoriesProvider);
    return SizedBox(
      height: 134,
      child: categories.when(
        data: (items) => ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            _CategoryCard(
              label: 'All',
              icon: Icons.apps_rounded,
              gradient: const [AppColors.charcoal, Color(0xFF56636A)],
              selected: _selectedCategoryId == null,
              onTap: () => setState(() => _selectedCategoryId = null),
            ),
            for (final (index, category) in items.indexed) ...[
              const SizedBox(width: 12),
              _CategoryCard(
                label: category.name,
                icon: _iconForCategory(category.name),
                gradient: _gradientForIndex(index),
                selected: _selectedCategoryId == category.id,
                onTap: () => setState(() => _selectedCategoryId = category.id),
              ),
            ],
          ],
        ),
        loading: () => const Center(
          child: SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.teal),
          ),
        ),
        error: (error, stackTrace) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildShelf(String title, AsyncValue<List<ContentResponseModel>> asyncItems) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 190,
            child: asyncItems.when(
              data: (items) => items.isEmpty
                  ? Center(
                      child: Text(
                        'Nothing here yet.',
                        style: TextStyle(color: AppColors.charcoal.withValues(alpha: 0.5)),
                      ),
                    )
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 14),
                      itemBuilder: (context, index) => _ContentCard(item: items[index]),
                    ),
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.teal)),
              error: (error, stackTrace) => Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    messageFor(error),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.gold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showsAsync = ref.watch(listenerShowsProvider(_selectedCategoryId));
    final audiosAsync = ref.watch(listenerAudiosProvider(_selectedCategoryId));
    final isListener = ref.watch(authNotifierProvider).user?.role == UserRole.listener;

    return Scaffold(
      appBar: AppBar(
        title: const NostalgiaanaBrandText(
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        actions: [
          if (isListener)
            IconButton(
              onPressed: () => PremiumUpgradeSheet.show(context),
              icon: const Icon(Icons.workspace_premium, color: AppColors.gold),
              tooltip: 'Go Premium',
            ),
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: AppColors.charcoal),
          ),
        ],
      ),
      bottomNavigationBar: const NowPlayingBar(),
      body: SingleChildScrollView(
        child: AdaptiveContentWrapper(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              _buildCategoryChips(),
              _buildShelf('Shows', showsAsync),
              _buildShelf('Audios', audiosAsync),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/// Cycling set of theme-derived gradients for the category cards — each
/// pairs a core `AppColors` tone with a lighter tint of itself so cards
/// stay within the app's "Modern Retro" palette rather than introducing
/// unrelated colors.
const _categoryGradients = [
  [AppColors.crimson, Color(0xFFE57373)],
  [AppColors.teal, Color(0xFF4DB6AC)],
  [AppColors.gold, Color(0xFFFFD54F)],
  [Color(0xFF8D6E63), Color(0xFFBCAAA4)],
];

List<Color> _gradientForIndex(int index) => _categoryGradients[index % _categoryGradients.length];

/// Picks an icon relevant to the category's name; falls back to a generic
/// tag icon for anything that doesn't match a known theme.
IconData _iconForCategory(String name) {
  final normalized = name.toLowerCase();
  if (normalized.contains('trivia') || normalized.contains('quiz')) return Icons.quiz_rounded;
  if (normalized.contains('interview')) return Icons.mic_rounded;
  if (normalized.contains('podcast')) return Icons.podcasts_rounded;
  if (normalized.contains('song') ||
      normalized.contains('film') ||
      normalized.contains('music')) {
    return Icons.music_note_rounded;
  }
  return Icons.local_offer_rounded;
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final List<Color> gradient;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = gradient.first == AppColors.gold ? AppColors.charcoal : Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 132,
        height: 128,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          borderRadius: BorderRadius.circular(20),
          border: selected ? Border.all(color: AppColors.charcoal, width: 2.5) : null,
          boxShadow: [
            BoxShadow(
              color: gradient.first.withValues(alpha: selected ? 0.45 : 0.2),
              blurRadius: selected ? 14 : 6,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: foreground, size: 30),
            Text(
              label,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: foreground,
                fontWeight: FontWeight.w700,
                fontSize: 14,
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContentCard extends StatelessWidget {
  const _ContentCard({required this.item});

  final ContentResponseModel item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ContentDetailScreen(content: item)),
      ),
      child: SizedBox(
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    item.coverUrl != null
                        ? Image.network(item.coverUrl!, fit: BoxFit.cover)
                        : DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.teal.withValues(alpha: 0.35),
                                  AppColors.crimson.withValues(alpha: 0.25),
                                ],
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                item.contentType == ContentType.audio
                                    ? Icons.graphic_eq
                                    : Icons.movie_outlined,
                                color: AppColors.charcoal,
                                size: 32,
                              ),
                            ),
                          ),
                    if (item.isPremium)
                      const Positioned(
                        top: 8,
                        right: 8,
                        child: TierBadge(label: 'PREMIUM', color: AppColors.gold),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.charcoal, fontWeight: FontWeight.w600),
            ),
            if (item.speaker != null)
              Text(
                item.speaker!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: AppColors.charcoal.withValues(alpha: 0.55), fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }
}
