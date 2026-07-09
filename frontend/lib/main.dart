import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';

import 'core/config/theme_config.dart';
import 'features/auth/presentation/splash_screen.dart';

void main() {
  MediaKit.ensureInitialized();
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
