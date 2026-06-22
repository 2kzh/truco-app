enum TeamSide {
  nos('Nós'),
  eles('Eles');

  final String label;

  const TeamSide(this.label);

  TeamSide get other => this == TeamSide.nos ? TeamSide.eles : TeamSide.nos;
}
