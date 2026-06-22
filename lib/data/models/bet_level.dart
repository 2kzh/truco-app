/// Níveis de aposta do truco paulista: normal -> truco -> seis -> nove -> doze.
enum BetLevel {
  normal(1, 'Mão normal'),
  truco(3, 'Truco'),
  seis(6, 'Seis'),
  nove(9, 'Nove'),
  doze(12, 'Doze');

  final int value;
  final String label;

  const BetLevel(this.value, this.label);

  /// Próximo nível de aposta, ou null se já está no máximo (doze).
  BetLevel? get next {
    final nextIndex = index + 1;
    return nextIndex < BetLevel.values.length ? BetLevel.values[nextIndex] : null;
  }

  static BetLevel fromName(String name) =>
      BetLevel.values.firstWhere((b) => b.name == name);
}
