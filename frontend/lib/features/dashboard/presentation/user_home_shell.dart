import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/theme_config.dart';
import '../../../core/network/api_error.dart';
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

  Future<void> _logout() async {
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
      height: 44,
      child: categories.when(
        data: (items) => ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            _CategoryChip(
              label: 'All',
              selected: _selectedCategoryId == null,
              onTap: () => setState(() => _selectedCategoryId = null),
            ),
            for (final category in items) ...[
              const SizedBox(width: 10),
              _CategoryChip(
                label: category.name,
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
        title: const Text('Nostalgiaana'),
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
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.crimson,
      backgroundColor: AppColors.panelCream,
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.charcoal.withValues(alpha: 0.7),
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
