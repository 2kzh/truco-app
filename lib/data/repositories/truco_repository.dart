import 'package:hive_flutter/hive_flutter.dart';

import '../models/truco_match.dart';

/// Persistência local simples da partida atual (sem geração de código).
class TrucoRepository {
  static const _boxName = 'truco_match_box';
  static const _matchKey = 'match';

  Future<Box> _openBox() => Hive.openBox(_boxName);

  Future<void> save(TrucoMatch match) async {
    final box = await _openBox();
    await box.put(_matchKey, match.toJson());
  }

  Future<TrucoMatch?> load() async {
    final box = await _openBox();
    final raw = box.get(_matchKey);
    if (raw == null) return null;
    return TrucoMatch.fromJson(Map<String, dynamic>.from(raw as Map));
  }
}
