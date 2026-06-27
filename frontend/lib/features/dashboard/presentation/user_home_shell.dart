import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/theme_config.dart';
import '../../auth/application/auth_notifier.dart';
import '../../auth/presentation/role_selection_screen.dart';

/// Placeholder home shell a regular (LISTENER/PREMIUM) user lands on after
/// OTP verification. The "Shows"/"Audios" tabs are static placeholder grids
/// — wiring them to `/api/content` is a follow-up once real data is needed.
class UserHomeScreenShell extends ConsumerStatefulWidget {
  const UserHomeScreenShell({super.key});

  @override
  ConsumerState<UserHomeScreenShell> createState() => _UserHomeScreenShellState();
}

class _UserHomeScreenShellState extends ConsumerState<UserHomeScreenShell> {
  int _tabIndex = 0;

  static const _tabs = ['Shows', 'Audios'];

  Future<void> _logout() async {
    await ref.read(authNotifierProvider.notifier).logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nostalgiaana'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: AppColors.offWhite),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: List.generate(_tabs.length, (index) {
                final selected = index == _tabIndex;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ChoiceChip(
                    label: Text(_tabs[index]),
                    selected: selected,
                    onSelected: (_) => setState(() => _tabIndex = index),
                    selectedColor: AppColors.crimson,
                    backgroundColor: Colors.white.withValues(alpha: 0.06),
                    labelStyle: TextStyle(
                      color: selected ? AppColors.offWhite : AppColors.offWhite.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                );
              }),
            ),
          ),
          Expanded(child: _PlaceholderGrid(label: _tabs[_tabIndex])),
        ],
      ),
    );
  }
}

class _PlaceholderGrid extends StatelessWidget {
  const _PlaceholderGrid({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.78,
      ),
      itemCount: 8,
      itemBuilder: (context, index) {
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Colors.white.withValues(alpha: 0.05),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.teal.withValues(alpha: 0.35),
                          AppColors.crimson.withValues(alpha: 0.25),
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.graphic_eq, color: AppColors.offWhite, size: 28),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '$label ${index + 1}',
                  style: const TextStyle(color: AppColors.offWhite, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  'Coming soon',
                  style: TextStyle(color: AppColors.offWhite.withValues(alpha: 0.55), fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
