import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TimerGauge extends StatelessWidget {
  final int secondsRemaining;
  final int totalSeconds;

  const TimerGauge({
    super.key,
    required this.secondsRemaining,
    required this.totalSeconds,
  });

  @override
  Widget build(BuildContext context) {
    if (totalSeconds <= 0) {
      return const SizedBox.shrink();
    }

    final double progress = (secondsRemaining / totalSeconds).clamp(0.0, 1.0);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bool isTablet = MediaQuery.sizeOf(context).shortestSide >= 600;

    Color timerColor;
    if (progress > 0.45) {
      timerColor = AppTheme.trueGreen;
    } else if (progress > 0.20) {
      timerColor = AppTheme.amberStreak;
    } else {
      timerColor = AppTheme.falseRed;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 18 : 14,
        vertical: isTablet ? 10 : 8,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: timerColor.withAlpha(120),
          width: isTablet ? 2.0 : 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_rounded,
            size: isTablet ? 24 : 18,
            color: timerColor,
          ),
          SizedBox(width: isTablet ? 10 : 8),
          SizedBox(
            width: isTablet ? 85 : 60,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: isTablet ? 12 : 8,
                backgroundColor: isDark ? Colors.white12 : Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(timerColor),
              ),
            ),
          ),
          SizedBox(width: isTablet ? 10 : 8),
          Text(
            '${secondsRemaining}s',
            style: TextStyle(
              fontSize: isTablet ? 18 : 14,
              fontWeight: FontWeight.w900,
              color: timerColor,
            ),
          ),
        ],
      ),
    );
  }
}
