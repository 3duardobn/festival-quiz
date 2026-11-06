import 'game_mode.dart';

class ScoreboardEntry {
  final String id;
  final DateTime dateTime;
  final GameMode gameMode;
  final int totalQuestions;
  final String winnerName;
  final int winnerScore;
  final List<Map<String, dynamic>> playersSummary;

  ScoreboardEntry({
    required this.id,
    required this.dateTime,
    required this.gameMode,
    required this.totalQuestions,
    required this.winnerName,
    required this.winnerScore,
    required this.playersSummary,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateTime': dateTime.toIso8601String(),
      'gameMode': gameMode.name,
      'totalQuestions': totalQuestions,
      'winnerName': winnerName,
      'winnerScore': winnerScore,
      'playersSummary': playersSummary,
    };
  }

  factory ScoreboardEntry.fromJson(Map<String, dynamic> json) {
    GameMode mode = GameMode.solo;
    try {
      mode = GameMode.values.byName(json['gameMode'] ?? 'solo');
    } catch (_) {
      mode = GameMode.solo;
    }

    final rawPlayers = json['playersSummary'] as List? ?? [];
    final List<Map<String, dynamic>> parsedPlayers = rawPlayers.map((p) => Map<String, dynamic>.from(p as Map)).toList();

    return ScoreboardEntry(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      dateTime: DateTime.tryParse(json['dateTime'] ?? '') ?? DateTime.now(),
      gameMode: mode,
      totalQuestions: json['totalQuestions'] ?? 0,
      winnerName: json['winnerName'] ?? 'Anônimo',
      winnerScore: json['winnerScore'] ?? 0,
      playersSummary: parsedPlayers,
    );
  }
}
