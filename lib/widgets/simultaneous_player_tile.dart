import 'dart:math';
import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/question.dart';
import '../theme/app_theme.dart';
import 'placa_button.dart';

class SimultaneousPlayerTile extends StatefulWidget {
  final Player player;
  final Question currentQuestion;
  final bool isRevealed;
  final Function(bool answer) onAnswerSelected;
  final bool isCompact;

  const SimultaneousPlayerTile({
    super.key,
    required this.player,
    required this.currentQuestion,
    required this.isRevealed,
    required this.onAnswerSelected,
    this.isCompact = false,
  });

  @override
  State<SimultaneousPlayerTile> createState() => _SimultaneousPlayerTileState();
}

class _SimultaneousPlayerTileState extends State<SimultaneousPlayerTile> with TickerProviderStateMixin {
  late AnimationController _shakeController;
  late AnimationController _bounceController;
  late Animation<double> _bounceScale;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _bounceScale = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );
  }

  @override
  void didUpdateWidget(covariant SimultaneousPlayerTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isRevealed && widget.isRevealed) {
      final isCorrect = widget.player.currentAnswer == widget.currentQuestion.answer;
      if (isCorrect) {
        _bounceController.forward(from: 0.0);
      } else {
        _shakeController.forward(from: 0.0);
      }
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bool isTablet = MediaQuery.sizeOf(context).shortestSide >= 600;

    final bool hasAnswered = widget.player.hasAnswered;
    final bool isCorrect = widget.player.currentAnswer == widget.currentQuestion.answer;

    return AnimatedBuilder(
      animation: Listenable.merge([_shakeController, _bounceController]),
      builder: (context, child) {
        double shakeOffsetX = 0.0;
        if (widget.isRevealed && !isCorrect && _shakeController.isAnimating) {
          final progress = _shakeController.value;
          shakeOffsetX = sin(progress * pi * 6) * 14 * (1.0 - progress);
        }

        double scale = 1.0;
        if (widget.isRevealed && isCorrect && _bounceController.isAnimating) {
          scale = _bounceScale.value;
        }

        return Transform.translate(
          offset: Offset(shakeOffsetX, 0),
          child: Transform.scale(
            scale: scale,
            child: Container(
              padding: EdgeInsets.all(isTablet ? 18 : (widget.isCompact ? 10 : 16)),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(isTablet ? 28 : 24),
                border: Border.all(
                  color: widget.player.color.withAlpha(widget.isRevealed ? 240 : 130),
                  width: widget.isRevealed ? (isTablet ? 3.5 : 2.5) : (isTablet ? 2.5 : 1.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.player.color.withAlpha(isDark ? 50 : 25),
                    blurRadius: isTablet ? 16 : 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Player Header: Color bar, Avatar, Name, Live Score
                  Row(
                    children: [
                      CircleAvatar(
                        radius: isTablet ? 22 : (widget.isCompact ? 14 : 18),
                        backgroundColor: widget.player.color,
                        child: Icon(
                          widget.player.icon,
                          size: isTablet ? 24 : (widget.isCompact ? 16 : 20),
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.player.name,
                              style: TextStyle(
                                fontSize: isTablet ? 18 : (widget.isCompact ? 13 : 15),
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (widget.player.streak > 1)
                              Text(
                                '🔥 Combo x${widget.player.streak}',
                                style: TextStyle(
                                  fontSize: isTablet ? 13 : 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.amberStreak,
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Score Pill
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 14 : 10,
                          vertical: isTablet ? 6 : 4,
                        ),
                        decoration: BoxDecoration(
                          color: widget.player.color.withAlpha(isDark ? 55 : 25),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${widget.player.score} pts',
                          style: TextStyle(
                            fontSize: isTablet ? 16 : (widget.isCompact ? 12 : 14),
                            fontWeight: FontWeight.w900,
                            color: widget.player.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isTablet ? 14 : (widget.isCompact ? 8 : 12)),

                  // Action Area:
                  // Case 1: Revealed mode -> Show what the player picked and points
                  if (widget.isRevealed) ...[
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: isTablet ? 16 : (widget.isCompact ? 8 : 12),
                        horizontal: 14,
                      ),
                      decoration: BoxDecoration(
                        color: (hasAnswered && isCorrect)
                            ? AppTheme.trueGreen.withAlpha(isDark ? 60 : 35)
                            : AppTheme.falseRed.withAlpha(isDark ? 60 : 35),
                        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                        border: Border.all(
                          color: (hasAnswered && isCorrect) ? AppTheme.trueGreen : AppTheme.falseRed,
                          width: isTablet ? 2.5 : 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            hasAnswered
                                ? (isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded)
                                : Icons.timer_off_rounded,
                            color: (hasAnswered && isCorrect) ? AppTheme.trueGreen : AppTheme.falseRed,
                            size: isTablet ? 30 : (widget.isCompact ? 20 : 24),
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              hasAnswered
                                  ? (isCorrect
                                      ? 'ACERTOU! (+${widget.player.lastPointsEarned} pts)'
                                      : 'ERROU! (Marcou ${widget.player.currentAnswer! ? "V" : "F"})')
                                  : 'Tempo Esgotado!',
                              style: TextStyle(
                                fontSize: isTablet ? 16 : (widget.isCompact ? 12 : 14),
                                fontWeight: FontWeight.w900,
                                color: (hasAnswered && isCorrect) ? AppTheme.trueGreen : AppTheme.falseRed,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]
                  // Case 2: Player has answered, but reveal is not yet triggered
                  else if (hasAnswered) ...[
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: isTablet ? 24 : (widget.isCompact ? 14 : 20),
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white12 : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                        border: Border.all(
                          color: widget.player.color.withAlpha(140),
                          width: 2.0,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lock_rounded,
                            color: widget.player.color,
                            size: isTablet ? 26 : (widget.isCompact ? 18 : 22),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Resposta Bloqueada! 🔒',
                            style: TextStyle(
                              fontSize: isTablet ? 18 : (widget.isCompact ? 13 : 15),
                              fontWeight: FontWeight.w900,
                              color: widget.player.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]
                  // Case 3: Player needs to answer! Two interactive paddles
                  else ...[
                    Row(
                      children: [
                        Expanded(
                          child: PlacaButton(
                            isTrue: true,
                            compact: true,
                            onTap: () => widget.onAnswerSelected(true),
                          ),
                        ),
                        SizedBox(width: isTablet ? 14 : 10),
                        Expanded(
                          child: PlacaButton(
                            isTrue: false,
                            compact: true,
                            onTap: () => widget.onAnswerSelected(false),
                          ),
                        ),
                      ],
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
