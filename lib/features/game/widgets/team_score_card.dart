import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/team_side.dart';

class TeamScoreCard extends StatelessWidget {
  final TeamSide team;
  final int score;
  final bool isMao;
  final bool isWinner;
  final bool enabled;
  final int matchesWon;
  final VoidCallback onTap;

  const TeamScoreCard({
    super.key,
    required this.team,
    required this.score,
    required this.isMao,
    required this.isWinner,
    required this.enabled,
    required this.matchesWon,
    required this.onTap,
  });

  bool get _isAtEleven => score == 11 && !isWinner;

  @override
  Widget build(BuildContext context) {
    final alertColor = isWinner || _isAtEleven ? AppColors.accent : Colors.transparent;

    return Expanded(
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.symmetric(vertical: 28),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: alertColor, width: 3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                team.label,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.light,
                ),
              ),
              const SizedBox(height: 6),
              _SeatBadge(isMao: isMao),
              const SizedBox(height: 12),
              Text(
                '$score',
                style: TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  color: isWinner || _isAtEleven ? AppColors.accent : AppColors.light,
                ),
              ),
              if (isWinner) ...[
                const SizedBox(height: 8),
                const Icon(Icons.emoji_events, color: AppColors.accent, size: 28),
              ] else if (_isAtEleven) ...[
                const SizedBox(height: 8),
                const Text(
                  'MÃO DE 11',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: AppColors.accent,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Text(
                matchesWon == 1 ? '1 partida ganha' : '$matchesWon partidas ganhas',
                style: TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SeatBadge extends StatelessWidget {
  final bool isMao;

  const _SeatBadge({required this.isMao});

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isMao,
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: const Text(
          'MÃO',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: AppColors.light,
          ),
        ),
      ),
    );
  }
}
