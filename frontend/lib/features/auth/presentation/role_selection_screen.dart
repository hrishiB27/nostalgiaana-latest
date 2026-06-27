import 'package:flutter/material.dart';

import '../../../core/config/theme_config.dart';
import '../../../core/widgets/glass_card.dart';
import 'admin_auth_screen.dart';
import 'user_auth_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.album, color: AppColors.teal.withValues(alpha: 0.85), size: 44),
              const SizedBox(height: 16),
              Text('Nostalgiaana', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text(
                'WHERE MEMORIES MATTER',
                style: TextStyle(
                  color: AppColors.gold,
                  letterSpacing: 2,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 56),
              _RolePanel(
                title: 'I AM A USER',
                subtitle: 'Listen to shows, trivia & podcasts',
                icon: Icons.album,
                accent: AppColors.crimson,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const UserAuthScreen()),
                ),
              ),
              const SizedBox(height: 20),
              _RolePanel(
                title: 'I AM AN ADMIN',
                subtitle: 'Manage shows, audios & users',
                icon: Icons.equalizer,
                accent: AppColors.teal,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AdminAuthScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RolePanel extends StatefulWidget {
  const _RolePanel({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  @override
  State<_RolePanel> createState() => _RolePanelState();
}

class _RolePanelState extends State<_RolePanel> {
  bool _pressed = false;
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final highlighted = _pressed || _hovering;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: widget.accent.withValues(alpha: highlighted ? 0.45 : 0.0),
                  blurRadius: 36,
                  spreadRadius: highlighted ? 2 : -8,
                ),
              ],
            ),
            child: GlassCard(
              borderColor: widget.accent,
              padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 22),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: widget.accent.withValues(alpha: 0.18),
                    child: Icon(widget.icon, color: widget.accent, size: 30),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 4),
                        Text(widget.subtitle, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: widget.accent),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
