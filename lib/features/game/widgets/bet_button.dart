import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/bet_level.dart';

/// Botão único que mostra o nível de aposta atual e avança para o próximo
/// a cada toque (voltando para normal depois de doze).
class BetButton extends StatelessWidget {
  final BetLevel level;
  final VoidCallback onTap;

  const BetButton({super.key, required this.level, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.light,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: SizedBox(
        width: double.infinity,
        child: Text(
          '${level.label} · vale ${level.value}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
