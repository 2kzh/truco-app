import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/team_side.dart';
import 'game_controller.dart';
import 'widgets/bet_button.dart';
import 'widgets/history_list.dart';
import 'widgets/team_score_card.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final match = ref.watch(gameControllerProvider);
    final controller = ref.read(gameControllerProvider.notifier);
    final hasProgress = match.scoreNos > 0 ||
        match.scoreEles > 0 ||
        match.matchesWonNos > 0 ||
        match.matchesWonEles > 0;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    'assets/logo_transparent.png',
                    height: 72,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.undo, color: AppColors.muted),
                        onPressed: match.hands.isEmpty ? null : controller.undoLastHand,
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.swap_horiz, color: AppColors.muted),
                            tooltip: 'Trocar mão',
                            onPressed: match.isFinished ? null : controller.swapMao,
                          ),
                          IconButton(
                            icon: Icon(Icons.refresh, color: AppColors.muted),
                            onPressed: () => _confirmReset(context, controller, hasProgress),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  TeamScoreCard(
                    team: TeamSide.nos,
                    score: match.scoreNos,
                    isMao: match.maoTeam == TeamSide.nos,
                    isWinner: match.winner == TeamSide.nos,
                    enabled: !match.isFinished,
                    matchesWon: match.matchesWonNos,
                    onTap: () => controller.awardHand(TeamSide.nos),
                  ),
                  TeamScoreCard(
                    team: TeamSide.eles,
                    score: match.scoreEles,
                    isMao: match.maoTeam == TeamSide.eles,
                    isWinner: match.winner == TeamSide.eles,
                    enabled: !match.isFinished,
                    matchesWon: match.matchesWonEles,
                    onTap: () => controller.awardHand(TeamSide.eles),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (match.isFinished)
                ElevatedButton(
                  onPressed: controller.newMatch,
                  child: const SizedBox(
                    width: double.infinity,
                    child: Text('Nova partida', textAlign: TextAlign.center),
                  ),
                )
              else
                BetButton(
                  level: match.betLevel,
                  onTap: controller.cycleBet,
                ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Histórico',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Expanded(child: HistoryList(hands: match.hands)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmReset(
    BuildContext context,
    GameController controller,
    bool hasProgress,
  ) async {
    if (!hasProgress) {
      controller.resetAll();
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Zerar tudo?'),
        content: const Text('O placar e as partidas ganhas de cada time serão zerados.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Zerar'),
          ),
        ],
      ),
    );

    if (confirmed == true) controller.resetAll();
  }
}
