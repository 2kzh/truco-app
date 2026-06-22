import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/bet_level.dart';
import '../../data/models/hand_record.dart';
import '../../data/models/team_side.dart';
import '../../data/models/truco_match.dart';
import '../../data/repositories/truco_repository.dart';

final trucoRepositoryProvider = Provider<TrucoRepository>((ref) => TrucoRepository());

class GameController extends Notifier<TrucoMatch> {
  @override
  TrucoMatch build() => TrucoMatch.initial();

  /// Restaura uma partida salva ao abrir o app, sem disparar persistência.
  void hydrate(TrucoMatch? match) {
    if (match != null) state = match;
  }

  /// Avança o nível de aposta (normal -> truco -> seis -> nove -> doze) e,
  /// se já estiver no máximo, volta para normal.
  void cycleBet() {
    if (state.isFinished) return;
    state = state.copyWith(betLevel: state.betLevel.next ?? BetLevel.normal);
    _persist();
  }

  /// Registra que [team] venceu a mão: soma o valor da aposta atual ao
  /// placar (sem passar de 12), passa a mão para o outro time e volta a
  /// aposta para o nível normal.
  void awardHand(TeamSide team) {
    if (state.isFinished) return;

    final currentScore = state.scoreOf(team);
    final points = state.betLevel.value;
    final newScore = (currentScore + points).clamp(0, targetScore);
    final newScoreNos = team == TeamSide.nos ? newScore : state.scoreNos;
    final newScoreEles = team == TeamSide.eles ? newScore : state.scoreEles;

    final record = HandRecord(
      time: DateTime.now(),
      winner: team,
      points: points,
      scoreNosAfter: newScoreNos,
      scoreElesAfter: newScoreEles,
    );

    state = state.copyWith(
      scoreNos: newScoreNos,
      scoreEles: newScoreEles,
      maoTeam: state.maoTeam.other,
      betLevel: BetLevel.normal,
      hands: [record, ...state.hands],
    );
    _persist();
  }

  /// Troca manualmente quem está com a mão, sem alterar placar ou aposta.
  void swapMao() {
    if (state.isFinished) return;
    state = state.copyWith(maoTeam: state.maoTeam.other);
    _persist();
  }

  /// Desfaz a última mão marcada: tira os pontos do time que tinha vencido,
  /// devolve a mão para quem jogava antes e remove a marcação do histórico.
  /// Funciona mesmo se a partida já tiver terminado, para corrigir um
  /// engano na última marcação.
  void undoLastHand() {
    if (state.hands.isEmpty) return;

    final last = state.hands.first;
    final newScoreNos =
        last.winner == TeamSide.nos ? state.scoreNos - last.points : state.scoreNos;
    final newScoreEles =
        last.winner == TeamSide.eles ? state.scoreEles - last.points : state.scoreEles;

    state = state.copyWith(
      scoreNos: newScoreNos.clamp(0, targetScore),
      scoreEles: newScoreEles.clamp(0, targetScore),
      maoTeam: state.maoTeam.other,
      betLevel: BetLevel.normal,
      hands: state.hands.skip(1).toList(),
    );
    _persist();
  }

  /// Começa uma nova partida. Se a partida atual já tinha um vencedor,
  /// soma 1 à contagem de partidas ganhas desse time antes de zerar o resto.
  void newMatch() {
    final winner = state.winner;
    state = TrucoMatch.initial().copyWith(
      matchesWonNos: state.matchesWonNos + (winner == TeamSide.nos ? 1 : 0),
      matchesWonEles: state.matchesWonEles + (winner == TeamSide.eles ? 1 : 0),
    );
    _persist();
  }

  /// Zera tudo: placar, mãos e a contagem de partidas ganhas de cada time.
  void resetAll() {
    state = TrucoMatch.initial();
    _persist();
  }

  void _persist() {
    ref.read(trucoRepositoryProvider).save(state);
  }
}

final gameControllerProvider = NotifierProvider<GameController, TrucoMatch>(GameController.new);
