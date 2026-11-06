import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PlacaButton extends StatefulWidget {
  final bool isTrue;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool? isCorrect;
  final bool showResult;
  final bool compact;
  final bool disabled;

  const PlacaButton({
    super.key,
    required this.isTrue,
    this.onTap,
    this.isSelected = false,
    this.isCorrect,
    this.showResult = false,
    this.compact = false,
    this.disabled = false,
  });

  @override
  State<PlacaButton> createState() => _PlacaButtonState();
}

class _PlacaButtonState extends State<PlacaButton> with TickerProviderStateMixin {
  late AnimationController _pressAnimController;
  late Animation<double> _scaleAnimation;

  late AnimationController _shakeAnimController;
  late AnimationController _bounceAnimController;
  late Animation<double> _bounceScaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _pressAnimController, curve: Curves.easeInOut),
    );

    _shakeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _bounceAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _bounceScaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _bounceAnimController, curve: Curves.elasticOut),
    );
  }

  @override
  void didUpdateWidget(covariant PlacaButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.showResult && widget.showResult && widget.isSelected) {
      if (widget.isCorrect == true) {
        _bounceAnimController.forward(from: 0.0);
      } else if (widget.isCorrect == false) {
        _shakeAnimController.forward(from: 0.0);
      }
    }
  }

  @override
  void dispose() {
    _pressAnimController.dispose();
    _shakeAnimController.dispose();
    _bounceAnimController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.disabled && widget.onTap != null) {
      _pressAnimController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.disabled && widget.onTap != null) {
      _pressAnimController.reverse();
    }
  }

  void _handleTapCancel() {
    if (!widget.disabled && widget.onTap != null) {
      _pressAnimController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bool isTablet = MediaQuery.sizeOf(context).shortestSide >= 600;

    final Color baseColor = widget.isTrue ? AppTheme.trueGreen : AppTheme.falseRed;
    final Color baseColorDark = widget.isTrue ? AppTheme.trueGreenDark : AppTheme.falseRedDark;

    Color backgroundColor;
    Color borderColor;
    Color textColor;
    double elevation = 4;

    if (widget.showResult) {
      if (widget.isSelected) {
        final bool correct = widget.isCorrect ?? false;
        backgroundColor = correct ? AppTheme.trueGreen : AppTheme.falseRed;
        borderColor = correct ? AppTheme.trueGreenDark : AppTheme.falseRedDark;
        textColor = Colors.white;
        elevation = 10;
      } else {
        backgroundColor = isDark ? Colors.grey.shade900 : Colors.grey.shade200;
        borderColor = Colors.transparent;
        textColor = isDark ? Colors.grey.shade600 : Colors.grey.shade500;
        elevation = 0;
      }
    } else if (widget.isSelected) {
      backgroundColor = baseColor;
      borderColor = Colors.white;
      textColor = Colors.white;
      elevation = 8;
    } else {
      backgroundColor = isDark ? baseColor.withAlpha(45) : baseColor.withAlpha(25);
      borderColor = baseColor.withAlpha(140);
      textColor = isDark ? Colors.white : baseColorDark;
    }

    if (widget.disabled && !widget.isSelected) {
      backgroundColor = isDark ? Colors.white10 : Colors.black.withAlpha(15);
      borderColor = Colors.transparent;
      textColor = isDark ? Colors.white38 : Colors.black38;
      elevation = 0;
    }

    // Scale sizes for Tablet and Gincana
    final double verticalPadding = isTablet
        ? (widget.compact ? 16 : 28)
        : (widget.compact ? 12 : 20);
    final double horizontalPadding = isTablet
        ? (widget.compact ? 16 : 28)
        : (widget.compact ? 12 : 20);
    final double letterFontSize = isTablet
        ? (widget.compact ? 44 : 76)
        : (widget.compact ? 32 : 54);
    final double labelFontSize = isTablet
        ? (widget.compact ? 16 : 22)
        : (widget.compact ? 13 : 16);
    final double iconSize = isTablet
        ? (widget.compact ? 28 : 42)
        : (widget.compact ? 22 : 32);

    return AnimatedBuilder(
      animation: Listenable.merge([_shakeAnimController, _bounceAnimController]),
      builder: (context, child) {
        double shakeOffsetX = 0.0;
        if (widget.showResult && widget.isSelected && widget.isCorrect == false && _shakeAnimController.isAnimating) {
          final progress = _shakeAnimController.value;
          shakeOffsetX = sin(progress * pi * 6) * 16 * (1.0 - progress);
        }

        double bounceScale = 1.0;
        if (widget.showResult && widget.isSelected && widget.isCorrect == true && _bounceAnimController.isAnimating) {
          bounceScale = _bounceScaleAnimation.value;
        }

        return Transform.translate(
          offset: Offset(shakeOffsetX, 0),
          child: Transform.scale(
            scale: bounceScale,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: GestureDetector(
                onTapDown: _handleTapDown,
                onTapUp: _handleTapUp,
                onTapCancel: _handleTapCancel,
                onTap: widget.disabled ? null : widget.onTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(isTablet ? (widget.compact ? 22 : 32) : (widget.compact ? 18 : 26)),
                    border: Border.all(
                      color: borderColor,
                      width: widget.isSelected ? (isTablet ? 4.5 : 3.5) : (isTablet ? 3.0 : 2.0),
                    ),
                    boxShadow: elevation > 0
                        ? [
                            BoxShadow(
                              color: baseColor.withAlpha(widget.isSelected ? 110 : 40),
                              blurRadius: widget.isSelected ? (isTablet ? 24 : 16) : 10,
                              offset: Offset(0, widget.isSelected ? (isTablet ? 8 : 5) : 3),
                            ),
                          ]
                        : null,
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: verticalPadding,
                    horizontal: horizontalPadding,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon badge
                      Container(
                        padding: EdgeInsets.all(isTablet ? (widget.compact ? 8 : 14) : (widget.compact ? 6 : 10)),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.isSelected
                              ? Colors.white.withAlpha(50)
                              : baseColor.withAlpha(widget.showResult ? 50 : 30),
                        ),
                        child: Icon(
                          widget.isTrue ? Icons.check_rounded : Icons.close_rounded,
                          size: iconSize,
                          color: widget.isSelected ? Colors.white : baseColor,
                        ),
                      ),
                      SizedBox(height: isTablet ? 12 : 8),

                      // Placa Letter "V" or "F"
                      Text(
                        widget.isTrue ? 'V' : 'F',
                        style: TextStyle(
                          fontSize: letterFontSize,
                          fontWeight: FontWeight.w900,
                          height: 1.0,
                          color: textColor,
                          letterSpacing: -1,
                        ),
                      ),
                      SizedBox(height: isTablet ? 8 : 4),

                      // Subtitle: VERDADEIRO / FALSO
                      Text(
                        widget.isTrue ? 'VERDADEIRO' : 'FALSO',
                        style: TextStyle(
                          fontSize: labelFontSize,
                          fontWeight: FontWeight.w900,
                          color: textColor.withAlpha(widget.isSelected ? 255 : 210),
                          letterSpacing: isTablet ? 1.8 : 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
