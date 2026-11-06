import 'package:flutter/material.dart';

class Player {
  final int id;
  String name;
  Color color;
  IconData icon;
  int score;
  int streak;
  bool? currentAnswer; // true (V) or false (F)
  int answerTimeMs;
  int lastPointsEarned;
  int correctCount;
  int wrongCount;

  Player({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
    this.score = 0,
    this.streak = 0,
    this.currentAnswer,
    this.answerTimeMs = 0,
    this.lastPointsEarned = 0,
    this.correctCount = 0,
    this.wrongCount = 0,
  });

  bool get hasAnswered => currentAnswer != null;

  void resetRound() {
    currentAnswer = null;
    answerTimeMs = 0;
    lastPointsEarned = 0;
  }

  void resetGame() {
    score = 0;
    streak = 0;
    correctCount = 0;
    wrongCount = 0;
    resetRound();
  }

  int registerAnswer({
    required bool answer,
    required bool isCorrect,
    required int responseTimeMs,
    required int maxTimeMs,
    bool speedBonus = true,
  }) {
    currentAnswer = answer;
    answerTimeMs = responseTimeMs;

    if (isCorrect) {
      streak += 1;
      correctCount += 1;

      // Base points
      int points = 100;

      // Speed bonus: up to +50 points if answered quickly
      if (speedBonus && maxTimeMs > 0) {
        final double speedRatio = (1.0 - (responseTimeMs / maxTimeMs)).clamp(0.0, 1.0);
        final int bonus = (speedRatio * 50).round();
        points += bonus;
      }

      // Streak multiplier bonus
      if (streak >= 3) {
        points = (points * 1.3).round();
      } else if (streak >= 2) {
        points = (points * 1.15).round();
      }

      lastPointsEarned = points;
      score += points;
      return points;
    } else {
      streak = 0;
      wrongCount += 1;
      lastPointsEarned = 0;
      return 0;
    }
  }

  double get accuracy {
    final total = correctCount + wrongCount;
    if (total == 0) return 0.0;
    return (correctCount / total) * 100.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'colorValue': color.toARGB32(),
      'score': score,
      'correctCount': correctCount,
      'wrongCount': wrongCount,
      'accuracy': accuracy,
    };
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] ?? 1,
      name: json['name'] ?? 'Jogador',
      color: Color(json['colorValue'] ?? 0xFF6366F1),
      icon: Icons.person,
      score: json['score'] ?? 0,
      correctCount: json['correctCount'] ?? 0,
      wrongCount: json['wrongCount'] ?? 0,
    );
  }
}
