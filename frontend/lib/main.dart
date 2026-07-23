import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';

import 'core/config/theme_config.dart';
import 'features/auth/presentation/splash_screen.dart';

void main() {
  MediaKit.ensureInitialized();
  // Defensive reset: a debug hot-restart doesn't call dispose(), so a
  // landscape/immersive lock left by VideoPlayerScreen could otherwise
  // persist into the freshly restarted app.
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const ProviderScope(child: NostalgiaanaApp()));
}

class NostalgiaanaApp extends StatelessWidget {
  const NostalgiaanaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nostalgiaana',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const SplashScreen(),
    );
  }
}
