import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/game/game_screen.dart';

class TrucoApp extends StatelessWidget {
  const TrucoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tru.co',
      theme: AppTheme.dark,
      debugShowCheckedModeBanner: false,
      home: const GameScreen(),
    );
  }
}
