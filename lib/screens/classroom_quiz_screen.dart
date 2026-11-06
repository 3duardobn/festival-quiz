import 'dart:async';
import 'package:flutter/material.dart';
import '../models/game_mode.dart';
import '../models/player.dart';
import '../models/question.dart';
import '../theme/app_theme.dart';
import '../widgets/timer_gauge.dart';
import '../widgets/animated_answer_feedback.dart';
import 'result_screen.dart';

class ClassroomQuizScreen extends StatefulWidget {
  final List<Player> teams;
  final List<Question> questions;
  final int secondsPerQuestion;

  const ClassroomQuizScreen({
    super.key,
    required this.teams,
    required this.questions,
    required this.secondsPerQuestion,
  });

  @override
  State<ClassroomQuizScreen> createState() => _ClassroomQuizScreenState();
}

class _ClassroomQuizScreenState extends State<ClassroomQuizScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isRevealed = false;
  Timer? _timer;
  int _secondsRemaining = 0;

  late AnimationController _revealAnimController;
  late Animation<double> _revealScaleAnimation;

  @override
  void initState() {
    super.initState();
    _revealAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _revealScaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _revealAnimController, curve: Curves.elasticOut),
    );

    for (var t in widget.teams) {
      t.resetGame();
    }
    _startQuestion();
  }

  void _startQuestion() {
    setState(() {
      _isRevealed = false;
      _secondsRemaining = widget.secondsPerQuestion;
      for (var t in widget.teams) {
        t.resetRound();
      }
    });

    _revealAnimController.reset();

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

  void _triggerReveal() {
    setState(() {
      _isRevealed = true;
    });
    _revealAnimController.forward(from: 0.0);
  }

  void _revealAnswer() {
    _timer?.cancel();
    _triggerReveal();
  }

  void _addPointToTeam(Player team) {
    setState(() {
      team.score += 100;
      team.correctCount += 1;
    });
  }

  void _goToNext() {
    if (_currentIndex < widget.questions.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _startQuestion();
    } else {
      _timer?.cancel();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            gameMode: GameMode.classroom,
            players: widget.teams,
            questions: widget.questions,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _revealAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bool isTablet = MediaQuery.sizeOf(context).shortestSide >= 600;
    final currentQ = widget.questions[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Modo Apresentador • Gincana',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: isTablet ? 22 : 16,
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
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 36 : 20,
            vertical: isTablet ? 20 : 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header progress & instruction
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 18 : 12,
                      vertical: isTablet ? 8 : 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryIndigo.withAlpha(isDark ? 50 : 25),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppTheme.primaryIndigo.withAlpha(90),
                        width: isTablet ? 2.0 : 1.0,
                      ),
                    ),
                    child: Text(
                      'Pergunta ${_currentIndex + 1} de ${widget.questions.length}',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: isTablet ? 16 : 13,
                        color: AppTheme.primaryIndigo,
                      ),
                    ),
                  ),
                  Text(
                    'Levantem as placas V ou F!',
                    style: TextStyle(
                      fontSize: isTablet ? 17 : 13,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isTablet ? 24 : 16),

              // Giant Big Question Display Card for Projection / Classroom Gincana
              Container(
                padding: EdgeInsets.all(isTablet ? 36 : 24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(isTablet ? 36 : 28),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    width: isTablet ? 2.5 : 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(isDark ? 60 : 18),
                      blurRadius: isTablet ? 24 : 16,
                      offset: Offset(0, isTablet ? 10 : 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 16 : 12,
                        vertical: isTablet ? 8 : 6,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        currentQ.category,
                        style: TextStyle(
                          fontSize: isTablet ? 15 : 12,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                        ),
                      ),
                    ),
                    SizedBox(height: isTablet ? 28 : 18),
                    Text(
                      currentQ.question,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isTablet ? 34 : 24,
                        fontWeight: FontWeight.w900,
                        height: 1.35,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: isTablet ? 18 : 12),
                    if (currentQ.source.isNotEmpty)
                      Text(
                        currentQ.source,
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 12,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: isTablet ? 26 : 18),

              // Answer Reveal Section
              if (!_isRevealed) ...[
                ElevatedButton(
                  onPressed: _revealAnswer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryCyan,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: isTablet ? 24 : 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(isTablet ? 26 : 20),
                    ),
                    elevation: 6,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.visibility_rounded, size: isTablet ? 30 : 24),
                      const SizedBox(width: 10),
                      Text(
                        'REVELAR GABARITO PARA A TURMA',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: isTablet ? 20 : 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Animated Banner & Placas Reveal
                ScaleTransition(
                  scale: _revealScaleAnimation,
                  child: Column(
                    children: [
                      AnimatedAnswerFeedback(
                        isCorrect: true, // Show celebration banner with the correct answer
                        title: currentQ.answer ? 'GABARITO: VERDADEIRO (V) 🎉' : 'GABARITO: FALSO (F) ❌',
                        subtitle: 'Confirmem os pontos das equipes que acertaram!',
                      ),
                      SizedBox(height: isTablet ? 24 : 16),

                      Row(
                        children: [
                          Expanded(
                            child: _buildClassroomPlaca(
                              letter: 'V',
                              text: 'VERDADEIRO',
                              color: AppTheme.trueGreen,
                              isWinner: currentQ.answer == true,
                              isTablet: isTablet,
                            ),
                          ),
                          SizedBox(width: isTablet ? 22 : 14),
                          Expanded(
                            child: _buildClassroomPlaca(
                              letter: 'F',
                              text: 'FALSO',
                              color: AppTheme.falseRed,
                              isWinner: currentQ.answer == false,
                              isTablet: isTablet,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isTablet ? 24 : 16),

                // Official Explanation (Large for Gincana)
                Container(
                  padding: EdgeInsets.all(isTablet ? 26 : 18),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(isTablet ? 26 : 20),
                    border: Border.all(
                      color: isDark ? Colors.white12 : const Color(0xFFCBD5E1),
                      width: isTablet ? 2.0 : 1.2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.auto_stories_rounded,
                            size: isTablet ? 24 : 18,
                            color: AppTheme.primaryIndigo,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'EXPLICAÇÃO PEDAGÓGICA (PDF OFICIAL)',
                            style: TextStyle(
                              fontSize: isTablet ? 15 : 12,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.primaryIndigo,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isTablet ? 14 : 8),
                      Text(
                        currentQ.explanation,
                        style: TextStyle(
                          fontSize: isTablet ? 22 : 16,
                          height: 1.45,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: isTablet ? 32 : 22),

              // Team Scoring Controls
              Text(
                'PONTUAÇÃO DAS EQUIPES',
                style: TextStyle(
                  fontSize: isTablet ? 15 : 12,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  letterSpacing: 1.0,
                ),
              ),
              SizedBox(height: isTablet ? 14 : 10),
              Wrap(
                spacing: 14,
                runSpacing: 14,
                children: widget.teams.map((team) {
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 22 : 16,
                      vertical: isTablet ? 14 : 10,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(isTablet ? 22 : 18),
                      border: Border.all(
                        color: team.color.withAlpha(140),
                        width: isTablet ? 2.5 : 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: team.color.withAlpha(isDark ? 40 : 20),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: isTablet ? 18 : 12,
                          backgroundColor: team.color,
                          child: Icon(team.icon, size: isTablet ? 20 : 14, color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          team.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: isTablet ? 18 : 14,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 12 : 8,
                            vertical: isTablet ? 5 : 2,
                          ),
                          decoration: BoxDecoration(
                            color: team.color.withAlpha(35),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${team.score} pts',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: team.color,
                              fontSize: isTablet ? 17 : 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: Icon(
                            Icons.add_circle_rounded,
                            color: AppTheme.trueGreen,
                            size: isTablet ? 32 : 24,
                          ),
                          tooltip: '+100 pts',
                          onPressed: () => _addPointToTeam(team),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: isTablet ? 36 : 26),

              // Next question button
              if (_isRevealed)
                ElevatedButton(
                  onPressed: _goToNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryIndigo,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: isTablet ? 22 : 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
                    ),
                    elevation: 4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentIndex >= widget.questions.length - 1
                            ? 'FINALIZAR E VER PLACAR'
                            : 'PRÓXIMA PERGUNTA',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: isTablet ? 19 : 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(Icons.arrow_forward_rounded, size: isTablet ? 24 : 20),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClassroomPlaca({
    required String letter,
    required String text,
    required Color color,
    required bool isWinner,
    required bool isTablet,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: isTablet ? 26 : 16),
      decoration: BoxDecoration(
        color: isWinner ? color : Colors.grey.shade800.withAlpha(30),
        borderRadius: BorderRadius.circular(isTablet ? 30 : 22),
        border: Border.all(
          color: isWinner ? color : Colors.transparent,
          width: isTablet ? 4.5 : 3.0,
        ),
        boxShadow: isWinner
            ? [
                BoxShadow(
                  color: color.withAlpha(120),
                  blurRadius: isTablet ? 24 : 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          Text(
            letter,
            style: TextStyle(
              fontSize: isTablet ? 68 : 36,
              fontWeight: FontWeight.w900,
              color: isWinner ? Colors.white : Colors.grey.shade500,
            ),
          ),
          Text(
            text,
            style: TextStyle(
              fontSize: isTablet ? 20 : 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              color: isWinner ? Colors.white : Colors.grey.shade500,
            ),
          ),
          if (isWinner) ...[
            SizedBox(height: isTablet ? 8 : 4),
            Icon(Icons.check_circle_rounded, color: Colors.white, size: isTablet ? 30 : 20),
          ],
        ],
      ),
    );
  }
}
