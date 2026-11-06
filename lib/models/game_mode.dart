enum GameMode {
  solo,
  duel2P,
  multiplayer4P,
  classroom;

  String get title {
    switch (this) {
      case GameMode.solo:
        return '1 Jogador (Solo)';
      case GameMode.duel2P:
        return 'Duelo 2P (Mesma Tela)';
      case GameMode.multiplayer4P:
        return 'Multijogador (2 a 4 Jogadores)';
      case GameMode.classroom:
        return 'Apresentador / Turma';
    }
  }

  String get shortName {
    switch (this) {
      case GameMode.solo:
        return 'Solo';
      case GameMode.duel2P:
        return 'Duelo 2P';
      case GameMode.multiplayer4P:
        return '4P Simultâneo';
      case GameMode.classroom:
        return 'Apresentador';
    }
  }

  String get description {
    switch (this) {
      case GameMode.solo:
        return 'Teste seu conhecimento e bata seu recorde no placar geral.';
      case GameMode.duel2P:
        return 'Dois jogadores frente a frente respondendo simultaneamente na mesma tela.';
      case GameMode.multiplayer4P:
        return 'Até 4 jogadores na mesma tela com botões V/F simultâneos e disputa de reflexos.';
      case GameMode.classroom:
        return 'Apresente as perguntas em tela grande para a turma levantar as placas V ou F.';
    }
  }
}
