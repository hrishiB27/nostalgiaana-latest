import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/config/theme_config.dart';
import '../../../sampleui/screens/auth_landing_screen.dart';

class _NoteSpec {
  const _NoteSpec({
    required this.icon,
    required this.color,
    required this.start,
    required this.delay,
  });

  final IconData icon;
  final Color color;
  final Alignment start;

  /// Where in the notes controller's 0..1 timeline this note starts moving,
  /// so they converge in a staggered, organic wave rather than in lockstep.
  final double delay;
}

const _notes = [
  _NoteSpec(icon: Icons.music_note, color: AppColors.teal, start: Alignment(-1.3, -0.9), delay: 0.0),
  _NoteSpec(icon: Icons.audiotrack, color: AppColors.gold, start: Alignment(1.2, -1.0), delay: 0.08),
  _NoteSpec(icon: Icons.music_note, color: AppColors.gold, start: Alignment(-1.2, 1.0), delay: 0.16),
  _NoteSpec(icon: Icons.queue_music, color: AppColors.teal, start: Alignment(1.3, 0.95), delay: 0.05),
  _NoteSpec(icon: Icons.music_note, color: AppColors.teal, start: Alignment(0, -1.3), delay: 0.22),
  _NoteSpec(icon: Icons.audiotrack, color: AppColors.gold, start: Alignment(0, 1.3), delay: 0.12),
];

/// Glowing notes converge toward the center and dissolve as the logo fades
/// and scales in over them, holds for 1.5s, then cross-fades into the role
/// gate. Two explicit controllers drive this: [_notesController] for the
/// convergence and [_logoController] for the reveal, started with a partial
/// overlap so the handoff feels continuous rather than two separate beats.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _notesController;
  late final AnimationController _logoController;

  static const _notesSpan = 0.75;

  @override
  void initState() {
    super.initState();
    _notesController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _playSequence();
  }

  Timer? _preLogoTimer;
  Timer? _holdTimer;

  void _playSequence() {
    unawaited(_notesController.forward());
    _preLogoTimer = Timer(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      _logoController.forward().whenComplete(() {
        if (!mounted) return;
        _holdTimer = Timer(const Duration(milliseconds: 1500), () {
          if (mounted) _goToAuthLanding();
        });
      });
    });
  }

  void _goToAuthLanding() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (_, _, _) => const AuthLandingScreen(),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  double _noteProgress(double delay) {
    final raw = ((_notesController.value - delay) / _notesSpan).clamp(0.0, 1.0);
    return Curves.easeOutCubic.transform(raw);
  }

  @override
  void dispose() {
    _preLogoTimer?.cancel();
    _holdTimer?.cancel();
    _notesController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Stack(
        alignment: Alignment.center,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                radius: 1.1,
                colors: [Color(0x1AC62828), Colors.transparent],
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _notesController,
            builder: (context, _) {
              return Stack(
                alignment: Alignment.center,
                children: _notes.map((note) {
                  final t = _noteProgress(note.delay);
                  final alignment = Alignment.lerp(note.start, Alignment.center, t)!;
                  final fadeEnvelope =
                      (t < 0.5 ? t * 2 : (1 - (t - 0.5) * 2)).clamp(0.0, 1.0);
                  final scale = 0.5 + t * 0.9;
                  return Align(
                    alignment: alignment,
                    child: Opacity(
                      opacity: fadeEnvelope,
                      child: Transform.scale(
                        scale: scale,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: note.color.withValues(alpha: 0.35),
                                blurRadius: 18,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Icon(note.icon, color: note.color, size: 26),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          FadeTransition(
            opacity: CurvedAnimation(parent: _logoController, curve: Curves.easeOut),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.85, end: 1.0).animate(
                CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
              ),
              child: FractionallySizedBox(
                widthFactor: 0.62,
                child: Image.asset('assets/images/nostalgiaana_logo_transparent.png'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
