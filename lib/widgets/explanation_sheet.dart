import 'package:flutter/material.dart';
import '../models/question.dart';
import '../theme/app_theme.dart';
import 'animated_answer_feedback.dart';

class ExplanationSheet extends StatelessWidget {
  final Question question;
  final bool? playerAnswer;
  final int pointsEarned;
  final VoidCallback onNext;
  final bool isLastQuestion;

  const ExplanationSheet({
    super.key,
    required this.question,
    required this.playerAnswer,
    required this.pointsEarned,
    required this.onNext,
    this.isLastQuestion = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bool isTablet = MediaQuery.sizeOf(context).shortestSide >= 600;

    final bool isCorrect = playerAnswer == question.answer;

    final String feedbackTitle = isCorrect ? 'RESPOSTA CORRETA!' : 'RESPOSTA INCORRETA!';
    final String feedbackSubtitle = 'Gabarito Oficial: ${question.answer ? "VERDADEIRO (V)" : "FALSO (F)"}';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 90 : 35),
            blurRadius: 32,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        isTablet ? 36 : 20,
        16,
        isTablet ? 36 : 20,
        isTablet ? 36 : 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 56,
              height: 6,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          SizedBox(height: isTablet ? 20 : 14),

          // Animated Answer Feedback (Pop / Shake)
          AnimatedAnswerFeedback(
            isCorrect: isCorrect,
            title: feedbackTitle,
            subtitle: feedbackSubtitle,
            pointsEarned: pointsEarned,
          ),
          SizedBox(height: isTablet ? 24 : 16),

          // Official PDF Gabarito Box (Large & readable for gincana)
          Container(
            padding: EdgeInsets.all(isTablet ? 24 : 16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
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
                      Icons.menu_book_rounded,
                      size: isTablet ? 22 : 18,
                      color: isDark ? const Color(0xFFA5B4FC) : AppTheme.primaryIndigo,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'EXPLICAÇÃO PEDAGÓGICA (GABARITO OFICIAL)',
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        fontWeight: FontWeight.w900,
                        color: isDark ? const Color(0xFFA5B4FC) : AppTheme.primaryIndigo,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isTablet ? 14 : 10),
                Text(
                  question.explanation.isNotEmpty
                      ? question.explanation
                      : 'Sem explicação detalhada cadastrada.',
                  style: TextStyle(
                    fontSize: isTablet ? 20 : 16,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isTablet ? 28 : 20),

          // Action Button
          ElevatedButton(
            onPressed: onNext,
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
                  isLastQuestion ? 'VER RESULTADOS FINAIS' : 'PRÓXIMA PERGUNTA',
                  style: TextStyle(
                    fontSize: isTablet ? 19 : 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  isLastQuestion ? Icons.emoji_events_rounded : Icons.arrow_forward_rounded,
                  size: isTablet ? 24 : 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
