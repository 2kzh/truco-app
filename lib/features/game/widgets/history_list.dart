import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/hand_record.dart';
import '../../../data/models/team_side.dart';

class HistoryList extends StatelessWidget {
  final List<HandRecord> hands;

  const HistoryList({super.key, required this.hands});

  @override
  Widget build(BuildContext context) {
    if (hands.isEmpty) {
      return Center(
        child: Text(
          'Nenhuma mão registrada ainda.',
          style: TextStyle(color: AppColors.muted, fontSize: 13),
        ),
      );
    }

    return ListView.separated(
      itemCount: hands.length,
      separatorBuilder: (context, index) => Divider(height: 1, color: AppColors.surfaceElevated),
      itemBuilder: (context, index) {
        final hand = hands[index];
        final teamColor = hand.winner == TeamSide.nos ? AppColors.accent : AppColors.light;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Text(
                _formatTime(hand.time),
                style: TextStyle(color: AppColors.muted, fontSize: 13),
              ),
              const SizedBox(width: 12),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: teamColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${hand.winner.label} +${hand.points}',
                  style: TextStyle(color: teamColor, fontSize: 14),
                ),
              ),
              Text(
                '${hand.scoreNosAfter} x ${hand.scoreElesAfter}',
                style: const TextStyle(
                  color: AppColors.light,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(DateTime time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}
