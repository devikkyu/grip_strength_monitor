import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grip_strength_monitor/core/theme/app_theme.dart';
import 'package:grip_strength_monitor/main_navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _bgController;
  late AnimationController _blurController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(vsync: this, duration: Duration(milliseconds: 3000))..repeat(reverse: true);
    _logoController = AnimationController(vsync: this, duration: Duration(milliseconds: 1200));
    _textController = AnimationController(vsync: this, duration: Duration(milliseconds: 1000));
    _blurController = AnimationController(vsync: this, duration: Duration(milliseconds: 800));

    _logoController.forward().then((_) {
      _textController.forward().then((_) {
        _blurController.forward();
      });
    });

    Timer(Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: Duration(milliseconds: 800),
            pageBuilder: (_, __, ___) => MainNavigation(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(
                opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                child: child,
              );
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _bgController.dispose();
    _blurController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgController,
        builder: (context, _) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.lerp(AppTheme.primaryPink, AppTheme.primaryLightPink, _bgController.value)!,
                  Color.lerp(AppTheme.primaryLightPink, AppTheme.primaryPink, _bgController.value)!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -100 + (_bgController.value * 50),
                  right: -100 + (_bgController.value * 30),
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -80 + (_bgController.value * 40),
                  left: -80 + (_bgController.value * 20),
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.3,
                  left: MediaQuery.of(context).size.width * 0.15,
                  child: AnimatedBuilder(
                    animation: _blurController,
                    builder: (context, _) {
                      return BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 10 * _blurController.value,
                          sigmaY: 10 * _blurController.value,
                        ),
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.1 * _blurController.value),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _logoController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _logoController.value,
                            child: Opacity(
                              opacity: _logoController.value,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      blurRadius: 40,
                                      offset: Offset(0, 20),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.fitness_center_rounded,
                                  size: 60,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 40),
                      AnimatedBuilder(
                        animation: _textController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, 30 * (1 - _textController.value)),
                            child: Opacity(
                              opacity: _textController.value,
                              child: Column(
                                children: [
                                  Text(
                                    'Grip',
                                    style: GoogleFonts.sarabun(
                                      fontSize: 48,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: -2,
                                    ),
                                  ),
                                  Text(
                                    'Strength Monitor',
                                    style: GoogleFonts.sarabun(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white70,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'ฝึกบีบมือ สร้างสุขภาพที่ดี',
                                    style: GoogleFonts.sarabun(
                                      fontSize: 14,
                                      color: Colors.white60,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 60),
                      AnimatedBuilder(
                        animation: _blurController,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _blurController.value,
                            child: SizedBox(
                              width: 120,
                              height: 4,
                              child: LinearProgressIndicator(
                                backgroundColor: Colors.white24,
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
