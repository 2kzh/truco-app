import 'bet_level.dart';
import 'hand_record.dart';
import 'team_side.dart';

const targetScore = 12;

class TrucoMatch {
  final int scoreNos;
  final int scoreEles;
  final TeamSide maoTeam;
  final BetLevel betLevel;
  final List<HandRecord> hands;

  /// Quantas partidas (não mãos) cada time já venceu — acumulado entre
  /// partidas, só zera com um reset explícito.
  final int matchesWonNos;
  final int matchesWonEles;

  const TrucoMatch({
    required this.scoreNos,
    required this.scoreEles,
    required this.maoTeam,
    required this.betLevel,
    required this.hands,
    required this.matchesWonNos,
    required this.matchesWonEles,
  });

  factory TrucoMatch.initial() => const TrucoMatch(
        scoreNos: 0,
        scoreEles: 0,
        maoTeam: TeamSide.nos,
        betLevel: BetLevel.normal,
        hands: [],
        matchesWonNos: 0,
        matchesWonEles: 0,
      );

  TeamSide get peTeam => maoTeam.other;

  int scoreOf(TeamSide team) => team == TeamSide.nos ? scoreNos : scoreEles;

  int matchesWonBy(TeamSide team) => team == TeamSide.nos ? matchesWonNos : matchesWonEles;

  bool get isFinished => scoreNos >= targetScore || scoreEles >= targetScore;

  TeamSide? get winner {
    if (scoreNos >= targetScore) return TeamSide.nos;
    if (scoreEles >= targetScore) return TeamSide.eles;
    return null;
  }

  TrucoMatch copyWith({
    int? scoreNos,
    int? scoreEles,
    TeamSide? maoTeam,
    BetLevel? betLevel,
    List<HandRecord>? hands,
    int? matchesWonNos,
    int? matchesWonEles,
  }) {
    return TrucoMatch(
      scoreNos: scoreNos ?? this.scoreNos,
      scoreEles: scoreEles ?? this.scoreEles,
      maoTeam: maoTeam ?? this.maoTeam,
      betLevel: betLevel ?? this.betLevel,
      hands: hands ?? this.hands,
      matchesWonNos: matchesWonNos ?? this.matchesWonNos,
      matchesWonEles: matchesWonEles ?? this.matchesWonEles,
    );
  }

  Map<String, dynamic> toJson() => {
        'scoreNos': scoreNos,
        'scoreEles': scoreEles,
        'maoTeam': maoTeam.name,
        'betLevel': betLevel.name,
        'hands': hands.map((h) => h.toJson()).toList(),
        'matchesWonNos': matchesWonNos,
        'matchesWonEles': matchesWonEles,
      };

  factory TrucoMatch.fromJson(Map<String, dynamic> json) => TrucoMatch(
        scoreNos: json['scoreNos'] as int,
        scoreEles: json['scoreEles'] as int,
        maoTeam: TeamSide.values.firstWhere((t) => t.name == json['maoTeam']),
        betLevel: BetLevel.fromName(json['betLevel'] as String),
        hands: ((json['hands'] as List?) ?? [])
            .map((h) => HandRecord.fromJson(Map<String, dynamic>.from(h as Map)))
            .toList(),
        matchesWonNos: json['matchesWonNos'] as int? ?? 0,
        matchesWonEles: json['matchesWonEles'] as int? ?? 0,
      );
}
