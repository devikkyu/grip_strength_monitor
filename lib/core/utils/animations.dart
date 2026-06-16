import 'package:flutter/material.dart';

class AppAnimations {
  // Smooth fade + slide up
  static Widget fadeSlideUp({
    required AnimationController controller,
    required Widget child,
    double delay = 0.0,
    double slideDistance = 30.0,
  }) {
    final delayedAnimation = CurvedAnimation(
      parent: controller,
      curve: Interval(delay, (delay + 0.5).clamp(0.0, 1.0), curve: Curves.easeOut),
    );

    return AnimatedBuilder(
      animation: delayedAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: delayedAnimation.value,
          child: Transform.translate(
            offset: Offset(0, slideDistance * (1 - delayedAnimation.value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  // Smooth scale animation
  static Widget scaleIn({
    required AnimationController controller,
    required Widget child,
    double delay = 0.0,
  }) {
    final delayedAnimation = CurvedAnimation(
      parent: controller,
      curve: Interval(delay, (delay + 0.5).clamp(0.0, 1.0), curve: Curves.elasticOut),
    );

    return AnimatedBuilder(
      animation: delayedAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: delayedAnimation.value,
          child: child,
        );
      },
      child: child,
    );
  }

  // Smooth shimmer effect
  static Widget shimmer({
    required AnimationController controller,
    required Widget child,
  }) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Opacity(
          opacity: 0.8 + 0.2 * controller.value,
          child: child,
        );
      },
      child: child,
    );
  }

  // Pulse animation for status
  static Widget pulse({
    required AnimationController controller,
    required Widget child,
  }) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + 0.05 * controller.value,
          child: child,
        );
      },
      child: child,
    );
  }

  // Count up animation
  static String countUp({
    required AnimationController controller,
    required double endValue,
    int decimals = 0,
  }) {
    final value = controller.value * endValue;
    return value.toStringAsFixed(decimals);
  }

  // Staggered animation delays
  static List<double> staggeredDelays(int count) {
    return List.generate(count, (index) => index * 0.1);
  }

  // Luxury gradient animation
  static Shader luxuryGradient(Rect bounds) {
    return LinearGradient(
      colors: const [
        Color(0xFF667eea),
        Color(0xFF764ba2),
        Color(0xFF6B8DD6),
        Color(0xFF8E37D7),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(bounds);
  }
}
