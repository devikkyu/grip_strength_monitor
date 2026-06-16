import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grip_strength_monitor/core/theme/app_theme.dart';

class SqueezeButton extends StatefulWidget {
  final bool isSqueezing;
  final double currentGrip;
  final double gripThreshold;
  final VoidCallback? onSqueezeStart;
  final VoidCallback? onSqueezeEnd;

  const SqueezeButton({
    super.key,
    required this.isSqueezing,
    required this.currentGrip,
    this.gripThreshold = 10.0,
    this.onSqueezeStart,
    this.onSqueezeEnd,
  });

  @override
  State<SqueezeButton> createState() => _SqueezeButtonState();
}

class _SqueezeButtonState extends State<SqueezeButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.currentGrip >= widget.gripThreshold;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = isActive ? 1.0 + 0.05 * _pulseController.value : 1.0;
        return Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTapDown: (_) {
              HapticFeedback.mediumImpact();
              widget.onSqueezeStart?.call();
            },
            onTapUp: (_) {
              HapticFeedback.lightImpact();
              widget.onSqueezeEnd?.call();
            },
            onTapCancel: () {
              widget.onSqueezeEnd?.call();
            },
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: isActive
                      ? [AppTheme.accentGreen, AppTheme.primaryBlue]
                      : [AppTheme.systemGray6, AppTheme.systemGray6],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isActive ? AppTheme.accentGreen : AppTheme.systemGray6)
                        .withValues(alpha: 0.4),
                    blurRadius: 24,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.fitness_center_rounded,
                    color: isActive ? Colors.white : AppTheme.textTertiary,
                    size: 32,
                  ),
                  SizedBox(height: 4),
                  Text(
                    isActive
                        ? widget.currentGrip.toStringAsFixed(0)
                        : '...',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.white : AppTheme.textTertiary,
                    ),
                  ),
                  Text(
                    'kg',
                    style: TextStyle(
                      fontSize: 10,
                      color: isActive
                          ? Colors.white.withValues(alpha: 0.8)
                          : AppTheme.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
