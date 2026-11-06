import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AnimatedAnswerFeedback extends StatefulWidget {
  final bool isCorrect;
  final String title;
  final String subtitle;
  final int pointsEarned;
  final VoidCallback? onAnimationComplete;

  const AnimatedAnswerFeedback({
    super.key,
    required this.isCorrect,
    required this.title,
    required this.subtitle,
    this.pointsEarned = 0,
    this.onAnimationComplete,
  });

  @override
  State<AnimatedAnswerFeedback> createState() => _AnimatedAnswerFeedbackState();
}

class _AnimatedAnswerFeedbackState extends State<AnimatedAnswerFeedback> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _shakeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: Curves.elasticOut,
      ),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: Curves.easeOutQuad,
      ),
    );

    _mainController.forward();
    if (!widget.isCorrect) {
      _shakeController.forward();
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bool isTablet = MediaQuery.sizeOf(context).shortestSide >= 600;

    final Color primaryColor = widget.isCorrect ? AppTheme.trueGreen : AppTheme.falseRed;

    return AnimatedBuilder(
      animation: Listenable.merge([_mainController, _shakeController]),
      builder: (context, child) {
        // Compute shake offset if wrong
        double shakeOffsetX = 0.0;
        if (!widget.isCorrect && _shakeController.isAnimating) {
          final progress = _shakeController.value;
          shakeOffsetX = sin(progress * pi * 6) * 16 * (1.0 - progress);
        }

        return Transform.translate(
          offset: Offset(shakeOffsetX, 0),
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 32 : 20,
                vertical: isTablet ? 24 : 16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: widget.isCorrect
                      ? [
                          AppTheme.trueGreen.withAlpha(isDark ? 60 : 35),
                          AppTheme.trueGreenDark.withAlpha(isDark ? 40 : 20),
                        ]
                      : [
                          AppTheme.falseRed.withAlpha(isDark ? 60 : 35),
                          AppTheme.falseRedDark.withAlpha(isDark ? 40 : 20),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(isTablet ? 32 : 24),
                border: Border.all(
                  color: primaryColor.withAlpha((180 * _glowAnimation.value).toInt()),
                  width: isTablet ? 3.5 : 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withAlpha((80 * _glowAnimation.value).toInt()),
                    blurRadius: isTablet ? 28 : 18,
                    spreadRadius: isTablet ? 4 : 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated Icon Badge
                  Container(
                    padding: EdgeInsets.all(isTablet ? 16 : 10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryColor,
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withAlpha(120),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.isCorrect ? Icons.check_rounded : Icons.close_rounded,
                      size: isTablet ? 38 : 28,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: isTablet ? 20 : 14),

                  // Texts
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: isTablet ? 26 : 20,
                            fontWeight: FontWeight.w900,
                            color: primaryColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.subtitle,
                          style: TextStyle(
                            fontSize: isTablet ? 16 : 13,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white70 : const Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Points badge if correct
                  if (widget.isCorrect && widget.pointsEarned > 0) ...[
                    SizedBox(width: isTablet ? 18 : 12),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 16 : 10,
                        vertical: isTablet ? 8 : 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.amberStreak,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.amberStreak.withAlpha(90),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        '+${widget.pointsEarned}',
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 14,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
