import 'dart:async';
import 'package:flutter/material.dart';
import '../models/game_mode.dart';
import '../models/player.dart';
import '../models/question.dart';
import '../theme/app_theme.dart';
import '../widgets/placa_button.dart';
import '../widgets/question_display.dart';
import '../widgets/timer_gauge.dart';
import '../widgets/explanation_sheet.dart';
import 'result_screen.dart';

class SoloQuizScreen extends StatefulWidget {
  final Player player;
  final List<Question> questions;
  final int secondsPerQuestion;

  const SoloQuizScreen({
    super.key,
    required this.player,
    required this.questions,
    required this.secondsPerQuestion,
  });

  @override
  State<SoloQuizScreen> createState() => _SoloQuizScreenState();
}

class _SoloQuizScreenState extends State<SoloQuizScreen> {
  int _currentIndex = 0;
  Timer? _timer;
  int _secondsRemaining = 0;
  int _timeSpentMs = 0;
  DateTime? _questionStartTime;

  bool _isAnswered = false;
  bool? _selectedAnswer;
  int _pointsEarnedThisRound = 0;

  @override
  void initState() {
    super.initState();
    widget.player.resetGame();
    _startQuestion();
  }

  void _startQuestion() {
    setState(() {
      _isAnswered = false;
      _selectedAnswer = null;
      _pointsEarnedThisRound = 0;
      _secondsRemaining = widget.secondsPerQuestion;
      _questionStartTime = DateTime.now();
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
          _handleTimeOut();
        }
      });
    }
  }

  void _handleTimeOut() {
    if (_isAnswered) return;
    _registerAnswer(null);
  }

  void _onAnswerSelected(bool answer) {
    if (_isAnswered) return;
    _timer?.cancel();
    _registerAnswer(answer);
  }

  void _registerAnswer(bool? answer) {
    final now = DateTime.now();
    _timeSpentMs = _questionStartTime != null ? now.difference(_questionStartTime!).inMilliseconds : 0;

    final currentQuestion = widget.questions[_currentIndex];
    final bool isCorrect = answer != null && answer == currentQuestion.answer;

    int points = 0;
    if (answer != null) {
      points = widget.player.registerAnswer(
        answer: answer,
        isCorrect: isCorrect,
        responseTimeMs: _timeSpentMs,
        maxTimeMs: widget.secondsPerQuestion * 1000,
        speedBonus: true,
      );
    } else {
      widget.player.registerAnswer(
        answer: false,
        isCorrect: false,
        responseTimeMs: widget.secondsPerQuestion * 1000,
        maxTimeMs: widget.secondsPerQuestion * 1000,
        speedBonus: false,
      );
    }

    setState(() {
      _isAnswered = true;
      _selectedAnswer = answer;
      _pointsEarnedThisRound = points;
    });

    // Allow user to see the animated feedback on the button (shake or bounce) before opening explanation
    Future.delayed(const Duration(milliseconds: 650), () {
      if (mounted) {
        _showExplanationModal();
      }
    });
  }

  void _showExplanationModal() {
    final currentQuestion = widget.questions[_currentIndex];
    final isLast = _currentIndex >= widget.questions.length - 1;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => ExplanationSheet(
        question: currentQuestion,
        playerAnswer: _selectedAnswer,
        pointsEarned: _pointsEarnedThisRound,
        isLastQuestion: isLast,
        onNext: () {
          Navigator.pop(context); // Close bottom sheet
          _goToNext();
        },
      ),
    );
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
          gameMode: GameMode.solo,
          players: [widget.player],
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

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: isTablet ? 18 : 14,
              backgroundColor: widget.player.color,
              child: Icon(widget.player.icon, size: isTablet ? 20 : 16, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Text(
              widget.player.name,
              style: TextStyle(
                fontSize: isTablet ? 20 : 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 18 : 12,
              vertical: isTablet ? 8 : 6,
            ),
            decoration: BoxDecoration(
              color: AppTheme.amberStreak.withAlpha(isDark ? 50 : 25),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.amberStreak.withAlpha(100)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bolt_rounded, size: isTablet ? 22 : 16, color: AppTheme.amberStreak),
                const SizedBox(width: 4),
                Text(
                  '${widget.player.score} pts',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppTheme.amberStreak,
                    fontSize: isTablet ? 18 : 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 36 : 20,
            vertical: isTablet ? 20 : 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress Bar & Timer
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: (_currentIndex + 1) / widget.questions.length,
                        minHeight: isTablet ? 14 : 10,
                        backgroundColor: isDark ? Colors.white12 : Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryIndigo),
                      ),
                    ),
                  ),
                  if (widget.secondsPerQuestion > 0) ...[
                    const SizedBox(width: 16),
                    TimerGauge(
                      secondsRemaining: _secondsRemaining,
                      totalSeconds: widget.secondsPerQuestion,
                    ),
                  ],
                ],
              ),
              SizedBox(height: isTablet ? 28 : 20),

              // Question Statement Display
              Expanded(
                flex: 3,
                child: Center(
                  child: QuestionDisplay(
                    question: currentQuestion,
                    currentIndex: _currentIndex,
                    totalQuestions: widget.questions.length,
                  ),
                ),
              ),
              SizedBox(height: isTablet ? 28 : 20),

              // Interactive Placas: VERDADEIRO (V) e FALSO (F)
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Expanded(
                      child: PlacaButton(
                        isTrue: true,
                        isSelected: _selectedAnswer == true,
                        isCorrect: _isAnswered ? currentQuestion.answer == true : null,
                        showResult: _isAnswered,
                        disabled: _isAnswered,
                        onTap: () => _onAnswerSelected(true),
                      ),
                    ),
                    SizedBox(width: isTablet ? 24 : 16),
                    Expanded(
                      child: PlacaButton(
                        isTrue: false,
                        isSelected: _selectedAnswer == false,
                        isCorrect: _isAnswered ? currentQuestion.answer == false : null,
                        showResult: _isAnswered,
                        disabled: _isAnswered,
                        onTap: () => _onAnswerSelected(false),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isTablet ? 18 : 12),
            ],
          ),
        ),
      ),
    );
  }
}
