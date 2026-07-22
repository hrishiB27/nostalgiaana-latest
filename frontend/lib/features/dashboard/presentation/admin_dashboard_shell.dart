import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/theme_config.dart';
import '../../../core/layout/app_breakpoints.dart';
import '../../../core/widgets/command_header_bar.dart';
import '../../../sampleui/screens/auth_landing_screen.dart';
import '../../admin/presentation/manage_audios_screen.dart';
import '../../admin/presentation/manage_shows_screen.dart';
import '../../admin/presentation/manage_users_screen.dart';
import '../../auth/application/auth_notifier.dart';

/// Management shell an ADMIN lands on after login. "Manage
/// Shows"/"Manage Audios" still route to placeholder screens — wiring them
/// to `/api/admin/shows`/`/api/admin/audios` is a follow-up once the admin
/// content upload flow is built. "Manage Users" is fully wired to
/// `/api/admin/users`.
class AdminDashboardShell extends ConsumerStatefulWidget {
  const AdminDashboardShell({super.key});

  @override
  ConsumerState<AdminDashboardShell> createState() =>
      _AdminDashboardShellState();
}

class _AdminDashboardShellState extends ConsumerState<AdminDashboardShell> {
  int _selectedIndex = 0;

  static const _panels = [
    (
      title: 'Manage Shows',
      subtitle: 'Coming soon',
      icon: Icons.podcasts,
      accent: AppColors.crimson,
    ),
    (
      title: 'Manage Audios',
      subtitle: 'Coming soon',
      icon: Icons.audiotrack,
      accent: AppColors.teal,
    ),
    (
      title: 'Manage Users',
      subtitle: 'View accounts, suspend access',
      icon: Icons.people_alt,
      accent: AppColors.gold,
    ),
  ];

  /// Pushed full-screen on mobile/narrow width via [_openPanel] — each
  /// screen keeps its own AppBar since it's the only content on screen.
  static const _pushDestinations = [
    ManageShowsScreen(),
    ManageAudiosScreen(),
    ManageUsersScreen(),
  ];

  /// Embedded next to the [NavigationRail] on desktop width — AppBar
  /// omitted since `_buildDesktopBody` shows its own `CommandHeaderBar`
  /// above the embedded content instead.
  static const _railDestinations = [
    ManageShowsScreen(showAppBar: false),
    ManageAudiosScreen(showAppBar: false),
    ManageUsersScreen(showAppBar: false),
  ];

  void _openPanel(BuildContext context, int index) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => _pushDestinations[index]));
  }

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

  Widget _buildMobileBody(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _panels.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final panel = _panels[index];
        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _openPanel(context, index),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppColors.panelCream,
              border: Border.all(color: panel.accent.withValues(alpha: 0.35)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: panel.accent.withValues(alpha: 0.18),
                  child: Icon(panel.icon, color: panel.accent),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        panel.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        panel.subtitle,
                        style: TextStyle(
                          color: AppColors.charcoal.withValues(alpha: 0.55),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.charcoal.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> get _headerActions => [
    IconButton(
      onPressed: _logout,
      icon: const Icon(Icons.logout, color: AppColors.charcoal),
    ),
  ];

  Widget _buildDesktopBody() {
    return Row(
      // Row defaults to CrossAxisAlignment.center, which left a gap above
      // the rail/divider if either ended up shorter than the row's full
      // height — stretch guarantees the rail, divider, and content pane all
      // span the complete height with no gap at the top. There is no
      // Scaffold.appBar above this Row anymore (see build() below), so the
      // rail and its divider now start at the window's absolute top edge —
      // the "Admin Console" heading/logout button live in a
      // CommandHeaderBar inside the content pane instead, not spanning the
      // full width above the rail.
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NavigationRail(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) =>
              setState(() => _selectedIndex = index),
          labelType: NavigationRailLabelType.all,
          destinations: const [
            NavigationRailDestination(
              icon: Icon(Icons.podcasts),
              label: Text('Manage Shows'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.audiotrack),
              label: Text('Manage Audios'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.people_alt),
              label: Text('Manage Users'),
            ),
          ],
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: Column(
            children: [
              CommandHeaderBar(
                leading: SizedBox(
                  height: 34,
                  child: Image.asset(
                    'assets/images/nostalgiaana_logo_transparent.png',
                    fit: BoxFit.contain,
                  ),
                ),
                title: 'Admin Console',
                actions: _headerActions,
              ),
              Expanded(
                child: IndexedStack(
                  index: _selectedIndex,
                  children: _railDestinations,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = AppBreakpoints.isDesktopWidth(constraints.maxWidth);
        return Scaffold(
          body: desktop
              ? _buildDesktopBody()
              : Column(
                  children: [
                    CommandHeaderBar(
                      leading: SizedBox(
                        height: 34,
                        child: Image.asset(
                          'assets/images/nostalgiaana_logo_transparent.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      title: 'Admin Console',
                      actions: _headerActions,
                    ),
                    Expanded(child: _buildMobileBody(context)),
                  ],
                ),
        );
      },
    );
  }
}
