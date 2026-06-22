import 'team_side.dart';

/// Registro de uma mão já jogada, para exibir no histórico.
class HandRecord {
  final DateTime time;
  final TeamSide winner;
  final int points;
  final int scoreNosAfter;
  final int scoreElesAfter;

  const HandRecord({
    required this.time,
    required this.winner,
    required this.points,
    required this.scoreNosAfter,
    required this.scoreElesAfter,
  });

  Map<String, dynamic> toJson() => {
        'time': time.toIso8601String(),
        'winner': winner.name,
        'points': points,
        'scoreNosAfter': scoreNosAfter,
        'scoreElesAfter': scoreElesAfter,
      };

  factory HandRecord.fromJson(Map<String, dynamic> json) => HandRecord(
        time: DateTime.parse(json['time'] as String),
        winner: TeamSide.values.firstWhere((t) => t.name == json['winner']),
        points: json['points'] as int,
        scoreNosAfter: json['scoreNosAfter'] as int,
        scoreElesAfter: json['scoreElesAfter'] as int,
      );
}
