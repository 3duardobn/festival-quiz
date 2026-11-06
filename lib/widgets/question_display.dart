import 'package:flutter/material.dart';
import '../models/question.dart';
import '../theme/app_theme.dart';

class QuestionDisplay extends StatelessWidget {
  final Question question;
  final int currentIndex;
  final int totalQuestions;
  final bool compact;

  const QuestionDisplay({
    super.key,
    required this.question,
    required this.currentIndex,
    required this.totalQuestions,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bool isTablet = MediaQuery.sizeOf(context).shortestSide >= 600;

    // Tablet-optimized typography
    final double statementFontSize = isTablet
        ? (compact ? 24 : 32)
        : (compact ? 19 : 23);

    final double badgeFontSize = isTablet ? 15 : 12;
    final double paddingVal = isTablet ? (compact ? 20 : 32) : (compact ? 14 : 22);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(paddingVal),
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
            blurRadius: isTablet ? 26 : 18,
            offset: Offset(0, isTablet ? 10 : 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Badges row: Question number & Category
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 16 : 12,
                  vertical: isTablet ? 8 : 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryIndigo.withAlpha(isDark ? 55 : 25),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: AppTheme.primaryIndigo.withAlpha(90),
                    width: isTablet ? 1.8 : 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.quiz_rounded,
                      size: isTablet ? 20 : 16,
                      color: AppTheme.primaryIndigo,
                    ),
                    SizedBox(width: isTablet ? 8 : 6),
                    Text(
                      'Pergunta ${currentIndex + 1} de $totalQuestions',
                      style: TextStyle(
                        fontSize: badgeFontSize,
                        fontWeight: FontWeight.w800,
                        color: isDark ? const Color(0xFFA5B4FC) : AppTheme.primaryIndigo,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 14 : 10,
                    vertical: isTablet ? 8 : 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white12 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Text(
                    question.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: badgeFontSize,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? (compact ? 16 : 28) : (compact ? 12 : 20)),

          // Question statement (large, prominent for gincanas)
          Text(
            question.question,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: statementFontSize,
              fontWeight: FontWeight.w900,
              height: 1.35,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              letterSpacing: -0.4,
            ),
          ),
          SizedBox(height: isTablet ? 16 : 10),

          // Source / Material reference
          if (question.source.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withAlpha(8) : Colors.black.withAlpha(6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                question.source,
                style: TextStyle(
                  fontSize: isTablet ? 13 : 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
