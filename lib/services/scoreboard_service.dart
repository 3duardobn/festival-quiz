import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/scoreboard_entry.dart';
import '../models/game_mode.dart';

class ScoreboardService {
  static const String _storageKey = 'festival_quiz_scoreboard_entries';
  static final ScoreboardService _instance = ScoreboardService._internal();

  factory ScoreboardService() => _instance;
  ScoreboardService._internal();

  List<ScoreboardEntry> _entries = [];
  bool _isLoaded = false;

  List<ScoreboardEntry> get entries => List.unmodifiable(_entries);

  Future<void> init() async {
    if (_isLoaded) return;
    await loadEntries();
  }

  Future<List<ScoreboardEntry>> loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final rawJson = prefs.getString(_storageKey);

    if (rawJson != null && rawJson.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(rawJson);
        _entries = decoded.map((e) => ScoreboardEntry.fromJson(Map<String, dynamic>.from(e))).toList();
        // Sort descending by date
        _entries.sort((a, b) => b.dateTime.compareTo(a.dateTime));
        _isLoaded = true;
        return _entries;
      } catch (e) {
        _entries = [];
      }
    }

    _entries = [];
    _isLoaded = true;
    return _entries;
  }

  Future<void> saveEntry(ScoreboardEntry entry) async {
    await init();
    _entries.insert(0, entry);
    // Keep max 100 entries
    if (_entries.length > 100) {
      _entries = _entries.sublist(0, 100);
    }
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_entries.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  List<Map<String, dynamic>> getSoloLeaderboard() {
    final soloEntries = _entries.where((e) => e.gameMode == GameMode.solo).toList();
    soloEntries.sort((a, b) => b.winnerScore.compareTo(a.winnerScore));

    return soloEntries.map((e) {
      final playerSummary = e.playersSummary.isNotEmpty ? e.playersSummary.first : null;
      return {
        'name': e.winnerName,
        'score': e.winnerScore,
        'date': e.dateTime,
        'totalQuestions': e.totalQuestions,
        'correctCount': playerSummary?['correctCount'] ?? 0,
        'accuracy': playerSummary?['accuracy'] ?? 0.0,
      };
    }).toList();
  }

  List<ScoreboardEntry> getMultiplayerHistory() {
    return _entries.where((e) => e.gameMode != GameMode.solo).toList();
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    _entries.clear();
  }
}
