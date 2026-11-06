import 'dart:async';
import 'package:flutter/material.dart';
import '../models/game_mode.dart';
import '../models/player.dart';
import '../models/question.dart';
import '../theme/app_theme.dart';
import '../widgets/question_display.dart';
import '../widgets/timer_gauge.dart';
import '../widgets/simultaneous_player_tile.dart';
import 'result_screen.dart';

class SimultaneousQuizScreen extends StatefulWidget {
  final GameMode mode;
  final List<Player> players;
  final List<Question> questions;
  final int secondsPerQuestion;

  const SimultaneousQuizScreen({
    super.key,
    required this.mode,
    required this.players,
    required this.questions,
    required this.secondsPerQuestion,
  });

  @override
  State<SimultaneousQuizScreen> createState() => _SimultaneousQuizScreenState();
}

class _SimultaneousQuizScreenState extends State<SimultaneousQuizScreen> {
  int _currentIndex = 0;
  Timer? _timer;
  int _secondsRemaining = 0;
  DateTime? _questionStartTime;
  bool _isRevealed = false;

  @override
  void initState() {
    super.initState();
    for (var p in widget.players) {
      p.resetGame();
    }
    _startQuestion();
  }

  void _startQuestion() {
    setState(() {
      _isRevealed = false;
      _secondsRemaining = widget.secondsPerQuestion;
      _questionStartTime = DateTime.now();
      for (var p in widget.players) {
        p.resetRound();
      }
    });

    _timer?.cancel();
    if (widget.secondsPerQuestion > 0) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) return;
        if (_secondsRemaining > 1) {
          setState(() {
            _secondsRemaining--;
          });
        } else {
          _timer?.cancel();
          _triggerReveal();
        }
      });
    }
  }

  void _onPlayerAnswer(Player player, bool answer) {
    if (_isRevealed || player.hasAnswered) return;

    final now = DateTime.now();
    final timeSpent = _questionStartTime != null ? now.difference(_questionStartTime!).inMilliseconds : 0;
    final currentQ = widget.questions[_currentIndex];
    final bool isCorrect = answer == currentQ.answer;

    setState(() {
      player.registerAnswer(
        answer: answer,
        isCorrect: isCorrect,
        responseTimeMs: timeSpent,
        maxTimeMs: widget.secondsPerQuestion > 0 ? widget.secondsPerQuestion * 1000 : 15000,
        speedBonus: true,
      );
    });

    // Check if all players answered
    final bool allAnswered = widget.players.every((p) => p.hasAnswered);
    if (allAnswered) {
      _timer?.cancel();
      _triggerReveal();
    }
  }

  void _triggerReveal() {
    setState(() {
      _isRevealed = true;
    });
  }

  void _goToNext() {
    if (_currentIndex < widget.questions.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _startQuestion();
    } else {
      _finishQuiz();
    }
  }

  void _finishQuiz() {
    _timer?.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          gameMode: widget.mode,
          players: widget.players,
          questions: widget.questions,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bool isTablet = MediaQuery.sizeOf(context).shortestSide >= 600;
    final currentQuestion = widget.questions[_currentIndex];
    final int answeredCount = widget.players.where((p) => p.hasAnswered).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.mode.title,
          style: TextStyle(
            fontSize: isTablet ? 20 : 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          if (widget.secondsPerQuestion > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: TimerGauge(
                secondsRemaining: _secondsRemaining,
                totalSeconds: widget.secondsPerQuestion,
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Linear Progress Bar & Status Pill
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 24 : 16,
                vertical: isTablet ? 8 : 4,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: (_currentIndex + 1) / widget.questions.length,
                        minHeight: isTablet ? 10 : 6,
                        backgroundColor: isDark ? Colors.white12 : Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryIndigo),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 14 : 10,
                      vertical: isTablet ? 6 : 4,
                    ),
                    decoration: BoxDecoration(
                      color: _isRevealed
                          ? AppTheme.trueGreen.withAlpha(isDark ? 55 : 25)
                          : AppTheme.primaryIndigo.withAlpha(isDark ? 55 : 25),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      _isRevealed
                          ? 'Gabarito Revelado!'
                          : '$answeredCount/${widget.players.length} responderam',
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 11,
                        fontWeight: FontWeight.w800,
                        color: _isRevealed ? AppTheme.trueGreen : AppTheme.primaryIndigo,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Question Display (Optimized for Tablet view)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 24 : 16,
                vertical: isTablet ? 10 : 8,
              ),
              child: QuestionDisplay(
                question: currentQuestion,
                currentIndex: _currentIndex,
                totalQuestions: widget.questions.length,
                compact: true,
              ),
            ),

            // Explanation Banner when Revealed (Large for Gincana)
            if (_isRevealed) ...[
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: isTablet ? 24 : 16,
                  vertical: isTablet ? 8 : 4,
                ),
                padding: EdgeInsets.all(isTablet ? 18 : 12),
                decoration: BoxDecoration(
                  color: (currentQuestion.answer ? AppTheme.trueGreen : AppTheme.falseRed).withAlpha(isDark ? 50 : 25),
                  borderRadius: BorderRadius.circular(isTablet ? 22 : 18),
                  border: Border.all(
                    color: (currentQuestion.answer ? AppTheme.trueGreen : AppTheme.falseRed).withAlpha(160),
                    width: isTablet ? 2.5 : 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 12 : 8,
                        vertical: isTablet ? 6 : 4,
                      ),
                      decoration: BoxDecoration(
                        color: currentQuestion.answer ? AppTheme.trueGreen : AppTheme.falseRed,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        currentQuestion.answer ? 'V' : 'F',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: isTablet ? 20 : 14,
                        ),
                      ),
                    ),
                    SizedBox(width: isTablet ? 14 : 10),
                    Expanded(
                      child: Text(
                        currentQuestion.explanation,
                        style: TextStyle(
                          fontSize: isTablet ? 17 : 12,
                          height: 1.35,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Player Simultaneous Zones (Responsive Grid or Column)
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 24 : 16,
                  vertical: isTablet ? 8 : 4,
                ),
                child: widget.players.length == 2
                    ? Column(
                        children: [
                          Expanded(
                            child: SimultaneousPlayerTile(
                              player: widget.players[0],
                              currentQuestion: currentQuestion,
                              isRevealed: _isRevealed,
                              onAnswerSelected: (ans) => _onPlayerAnswer(widget.players[0], ans),
                            ),
                          ),
                          SizedBox(height: isTablet ? 18 : 12),
                          Expanded(
                            child: SimultaneousPlayerTile(
                              player: widget.players[1],
                              currentQuestion: currentQuestion,
                              isRevealed: _isRevealed,
                              onAnswerSelected: (ans) => _onPlayerAnswer(widget.players[1], ans),
                            ),
                          ),
                        ],
                      )
                    : GridView.count(
                        crossAxisCount: 2,
                        childAspectRatio: isTablet ? 1.45 : 1.15,
                        mainAxisSpacing: isTablet ? 14 : 10,
                        crossAxisSpacing: isTablet ? 14 : 10,
                        physics: const NeverScrollableScrollPhysics(),
                        children: widget.players.map((p) {
                          return SimultaneousPlayerTile(
                            player: p,
                            currentQuestion: currentQuestion,
                            isRevealed: _isRevealed,
                            isCompact: true,
                            onAnswerSelected: (ans) => _onPlayerAnswer(p, ans),
                          );
                        }).toList(),
                      ),
              ),
            ),

            // Bottom Action when revealed
            if (_isRevealed) ...[
              Padding(
                padding: EdgeInsets.fromLTRB(
                  isTablet ? 24 : 16,
                  4,
                  isTablet ? 24 : 16,
                  isTablet ? 18 : 12,
                ),
                child: ElevatedButton(
                  onPressed: _goToNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryIndigo,
                    foregroundColor: Colors.white,
                    minimumSize: Size.fromHeight(isTablet ? 62 : 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(isTablet ? 24 : 18),
                    ),
                    elevation: 4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentIndex >= widget.questions.length - 1
                            ? 'VER RESULTADO FINAL'
                            : 'PRÓXIMA PERGUNTA',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: isTablet ? 18 : 15,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _currentIndex >= widget.questions.length - 1
                            ? Icons.emoji_events_rounded
                            : Icons.arrow_forward_rounded,
                        size: isTablet ? 24 : 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
