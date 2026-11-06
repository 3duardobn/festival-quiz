import 'package:flutter/material.dart';
import '../models/game_mode.dart';
import '../models/player.dart';
import '../models/question.dart';
import '../models/scoreboard_entry.dart';
import '../services/scoreboard_service.dart';
import '../theme/app_theme.dart';
import '../widgets/confetti_overlay.dart';
import 'player_setup_screen.dart';
import 'scoreboard_screen.dart';

class ResultScreen extends StatefulWidget {
  final GameMode gameMode;
  final List<Player> players;
  final List<Question> questions;

  const ResultScreen({
    super.key,
    required this.gameMode,
    required this.players,
    required this.questions,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final ScoreboardService _scoreboardService = ScoreboardService();
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _saveGameResult();
  }

  Future<void> _saveGameResult() async {
    if (_saved) return;
    _saved = true;

    // Sort players descending by score
    final sorted = List<Player>.from(widget.players)
      ..sort((a, b) => b.score.compareTo(a.score));

    final winner = sorted.isNotEmpty ? sorted.first : null;

    final entry = ScoreboardEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      dateTime: DateTime.now(),
      gameMode: widget.gameMode,
      totalQuestions: widget.questions.length,
      winnerName: winner != null ? winner.name : 'Jogador',
      winnerScore: winner != null ? winner.score : 0,
      playersSummary: sorted.map((p) => p.toJson()).toList(),
    );

    await _scoreboardService.saveEntry(entry);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bool isTablet = MediaQuery.sizeOf(context).shortestSide >= 600;

    final sortedPlayers = List<Player>.from(widget.players)
      ..sort((a, b) => b.score.compareTo(a.score));
    final winner = sortedPlayers.first;

    return ConfettiOverlay(
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 48 : 24,
              vertical: isTablet ? 24 : 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),

                // Winner Trophy Card
                Center(
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(isTablet ? 36 : 24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF1E1B4B), const Color(0xFF312E81)]
                            : [const Color(0xFF6366F1), const Color(0xFF4F46E5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(isTablet ? 40 : 32),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryIndigo.withAlpha(isDark ? 50 : 60),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(isTablet ? 24 : 16),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white24,
                          ),
                          child: Icon(
                            Icons.emoji_events_rounded,
                            size: isTablet ? 90 : 64,
                            color: Colors.amber,
                          ),
                        ),
                        SizedBox(height: isTablet ? 20 : 16),
                        Text(
                          widget.players.length > 1 ? 'GRANDE VENCEDOR!' : 'QUIZ CONCLUÍDO!',
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w800,
                            fontSize: isTablet ? 17 : 14,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          winner.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: isTablet ? 36 : 26,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${winner.score} PONTOS',
                          style: TextStyle(
                            color: Colors.amberAccent,
                            fontWeight: FontWeight.w900,
                            fontSize: isTablet ? 26 : 20,
                          ),
                        ),
                        SizedBox(height: isTablet ? 16 : 12),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 18 : 14,
                            vertical: isTablet ? 8 : 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white12,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${winner.correctCount} acertos de ${widget.questions.length} perguntas (${winner.accuracy.toStringAsFixed(0)}%)',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isTablet ? 16 : 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: isTablet ? 36 : 32),

                // Leaderboard breakdown
                Text(
                  'CLASSIFICAÇÃO GERAL',
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 13,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    letterSpacing: 1.0,
                  ),
                ),
                SizedBox(height: isTablet ? 16 : 12),

                ...List.generate(sortedPlayers.length, (index) {
                  final p = sortedPlayers[index];
                  final medal = index == 0
                      ? '🥇'
                      : index == 1
                          ? '🥈'
                          : index == 2
                              ? '🥉'
                              : '${index + 1}º';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.all(isTablet ? 22 : 16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
                      border: Border.all(
                        color: index == 0 ? Colors.amber.withAlpha(160) : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        width: index == 0 ? (isTablet ? 3.0 : 2.0) : 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(medal, style: TextStyle(fontSize: isTablet ? 28 : 22, fontWeight: FontWeight.bold)),
                        SizedBox(width: isTablet ? 18 : 14),
                        CircleAvatar(
                          radius: isTablet ? 22 : 16,
                          backgroundColor: p.color,
                          child: Icon(p.icon, size: isTablet ? 24 : 18, color: Colors.white),
                        ),
                        SizedBox(width: isTablet ? 16 : 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: isTablet ? 20 : 16,
                                ),
                              ),
                              Text(
                                '${p.correctCount} acertos • ${p.accuracy.toStringAsFixed(0)}% precisão',
                                style: TextStyle(
                                  fontSize: isTablet ? 14 : 12,
                                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 16 : 12,
                            vertical: isTablet ? 8 : 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.amberStreak.withAlpha(isDark ? 55 : 25),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '${p.score} pts',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: AppTheme.amberStreak,
                              fontSize: isTablet ? 18 : 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                SizedBox(height: isTablet ? 36 : 32),

                // Action Buttons
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PlayerSetupScreen(initialMode: widget.gameMode),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryIndigo,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: isTablet ? 22 : 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.replay_rounded, size: isTablet ? 26 : 22),
                      const SizedBox(width: 8),
                      Text(
                        'JOGAR NOVAMENTE',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: isTablet ? 18 : 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ScoreboardScreen()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: isTablet ? 20 : 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.leaderboard_rounded, size: isTablet ? 24 : 20),
                      const SizedBox(width: 8),
                      Text(
                        'VER SCOREBOARD COMPLETO',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: isTablet ? 16 : 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                TextButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: Text(
                    'Voltar ao Menu Principal',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: isTablet ? 16 : 14,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
