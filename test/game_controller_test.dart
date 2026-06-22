import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:truco/data/models/bet_level.dart';
import 'package:truco/data/models/team_side.dart';
import 'package:truco/data/models/truco_match.dart';
import 'package:truco/data/repositories/truco_repository.dart';
import 'package:truco/features/game/game_controller.dart';

/// Repositório fake — evita tocar o Hive real nos testes unitários.
class FakeTrucoRepository extends TrucoRepository {
  @override
  Future<void> save(TrucoMatch match) async {}

  @override
  Future<TrucoMatch?> load() async => null;
}

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [trucoRepositoryProvider.overrideWithValue(FakeTrucoRepository())],
    );
  });

  tearDown(() => container.dispose());

  GameController controller() => container.read(gameControllerProvider.notifier);
  TrucoMatch match() => container.read(gameControllerProvider);

  test('estado inicial: 0 a 0, Nós é mão, aposta normal', () {
    expect(match().scoreNos, 0);
    expect(match().scoreEles, 0);
    expect(match().maoTeam, TeamSide.nos);
    expect(match().peTeam, TeamSide.eles);
    expect(match().betLevel, BetLevel.normal);
  });

  test('cycleBet avança normal -> truco -> seis -> nove -> doze -> normal', () {
    controller().cycleBet();
    expect(match().betLevel, BetLevel.truco);
    controller().cycleBet();
    expect(match().betLevel, BetLevel.seis);
    controller().cycleBet();
    expect(match().betLevel, BetLevel.nove);
    controller().cycleBet();
    expect(match().betLevel, BetLevel.doze);

    controller().cycleBet();
    expect(match().betLevel, BetLevel.normal, reason: 'depois de doze volta para normal');
  });

  test('vencer a mão soma os pontos da aposta e passa a mão', () {
    controller().cycleBet();
    controller().awardHand(TeamSide.nos);

    expect(match().scoreNos, 3);
    expect(match().maoTeam, TeamSide.eles, reason: 'mão passa para o outro time');
    expect(match().betLevel, BetLevel.normal, reason: 'aposta reseta após a mão');
  });

  test('cada mão registrada entra no topo do histórico', () {
    controller().awardHand(TeamSide.nos);
    controller().cycleBet();
    controller().awardHand(TeamSide.eles);

    expect(match().hands, hasLength(2));
    expect(match().hands.first.winner, TeamSide.eles, reason: 'mão mais recente fica no topo');
    expect(match().hands.first.points, 3);
    expect(match().hands.last.winner, TeamSide.nos);
  });

  test('placar nunca passa de 12', () {
    controller().cycleBet();
    controller().cycleBet();
    controller().cycleBet();
    controller().cycleBet();
    expect(match().betLevel, BetLevel.doze);

    controller().awardHand(TeamSide.nos);
    expect(match().scoreNos, 12);

    expect(match().isFinished, isTrue);
    expect(match().winner, TeamSide.nos);
  });

  test('partida finalizada não aceita mais mãos nem mudança de aposta', () {
    controller().cycleBet();
    controller().cycleBet();
    controller().cycleBet();
    controller().cycleBet();
    controller().awardHand(TeamSide.nos);
    expect(match().isFinished, isTrue);

    final before = match();
    controller().cycleBet();
    controller().awardHand(TeamSide.eles);
    expect(match(), before, reason: 'estado não muda após o fim da partida');
  });

  group('voltar partida (undo)', () {
    test('desfaz a última mão: tira os pontos e devolve a mão', () {
      controller().cycleBet();
      controller().awardHand(TeamSide.nos);
      expect(match().scoreNos, 3);
      expect(match().maoTeam, TeamSide.eles);

      controller().undoLastHand();

      expect(match().scoreNos, 0);
      expect(match().maoTeam, TeamSide.nos);
      expect(match().hands, isEmpty);
    });

    test('funciona mesmo depois da partida terminar, para corrigir a última marcação', () {
      controller().cycleBet();
      controller().cycleBet();
      controller().cycleBet();
      controller().cycleBet();
      controller().awardHand(TeamSide.nos);
      expect(match().isFinished, isTrue);

      controller().undoLastHand();

      expect(match().isFinished, isFalse);
      expect(match().scoreNos, 0);
    });

    test('sem mãos registradas, não faz nada', () {
      final before = match();
      controller().undoLastHand();
      expect(match(), before);
    });

    test('desfaz só a última, mantendo as anteriores', () {
      controller().awardHand(TeamSide.nos);
      controller().awardHand(TeamSide.eles);

      controller().undoLastHand();

      expect(match().scoreEles, 0);
      expect(match().scoreNos, 1);
      expect(match().hands, hasLength(1));
      expect(match().hands.first.winner, TeamSide.nos);
    });
  });

  test('nova partida zera o placar e volta Nós como mão', () {
    controller().awardHand(TeamSide.nos);
    controller().newMatch();

    expect(match().scoreNos, 0);
    expect(match().scoreEles, 0);
    expect(match().maoTeam, TeamSide.nos);
  });

  test('zerar manualmente (sem vencedor) não soma partida ganha', () {
    controller().awardHand(TeamSide.nos);
    controller().newMatch();

    expect(match().matchesWonNos, 0);
    expect(match().matchesWonEles, 0);
  });

  test('vencer a partida soma 1 às partidas ganhas ao começar a próxima', () {
    controller().cycleBet();
    controller().cycleBet();
    controller().cycleBet();
    controller().cycleBet();
    controller().awardHand(TeamSide.eles);
    expect(match().winner, TeamSide.eles);

    controller().newMatch();

    expect(match().matchesWonEles, 1);
    expect(match().matchesWonNos, 0);
    expect(match().scoreEles, 0, reason: 'placar da partida zera, só a contagem de partidas persiste');
  });

  test('resetAll zera placar, mãos e partidas ganhas', () {
    controller().cycleBet();
    controller().cycleBet();
    controller().cycleBet();
    controller().cycleBet();
    controller().awardHand(TeamSide.nos);
    controller().newMatch();
    expect(match().matchesWonNos, 1);

    controller().resetAll();

    expect(match().matchesWonNos, 0);
    expect(match().matchesWonEles, 0);
    expect(match().scoreNos, 0);
    expect(match().hands, isEmpty);
  });
}
