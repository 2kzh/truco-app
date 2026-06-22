import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'features/game/game_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  final container = ProviderContainer();
  final savedMatch = await container.read(trucoRepositoryProvider).load();
  container.read(gameControllerProvider.notifier).hydrate(savedMatch);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const TrucoApp(),
    ),
  );
}
