import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grip_strength_monitor/core/theme/app_theme.dart';
import 'package:grip_strength_monitor/core/constants/app_localizations.dart';
import 'package:grip_strength_monitor/core/utils/animations.dart';
import 'package:grip_strength_monitor/services/todo_provider.dart';
import 'package:grip_strength_monitor/services/sound_service.dart';
import 'package:grip_strength_monitor/shared/models/todo.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> with TickerProviderStateMixin {
  late final AnimationController _animController;
  late final AnimationController _petBounceController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(duration: Duration(milliseconds: 1000), vsync: this)..forward();
    _petBounceController = AnimationController(duration: Duration(milliseconds: 800), vsync: this)..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    _petBounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: Consumer<TodoProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppAnimations.fadeSlideUp(controller: _animController, delay: 0.0, child: _buildPetCard(context, provider)),
                SizedBox(height: 20),
                AppAnimations.fadeSlideUp(controller: _animController, delay: 0.1, child: _buildExpCard(context, provider)),
                SizedBox(height: 20),
                AppAnimations.fadeSlideUp(controller: _animController, delay: 0.2, child: _buildDailyTasksCard(context, provider)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPetCard(BuildContext context, TodoProvider provider) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.3), blurRadius: 20, offset: Offset(0, 10))],
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _petBounceController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, -8 * _petBounceController.value),
                child: child,
              );
            },
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Center(child: Text('🐱', style: TextStyle(fontSize: 52))),
            ),
          ),
          SizedBox(height: 16),
          Text(
            AppLocalizations.get('turtlePet'),
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.3),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${AppLocalizations.get('level')} ${provider.level}',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
          SizedBox(height: 12),
          Text(
            AppLocalizations.get('keepTraining'),
            style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildExpCard(BuildContext context, TodoProvider provider) {
    final progress = provider.expProgress / provider.expRequired;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppTheme.primaryBlue.withValues(alpha: 0.08), blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.get('experience'),
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary, letterSpacing: -0.2),
              ),
              Text(
                '${provider.expProgress}/${provider.expRequired}',
                style: TextStyle(fontSize: 13, color: AppTheme.primaryBlue, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 500),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: AppTheme.systemGray6,
                valueColor: AlwaysStoppedAnimation(AppTheme.primaryBlue),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          SizedBox(height: 10),
          Text(
            '${(progress * 100).toInt()}% ${AppLocalizations.get('toNextLevel')}',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyTasksCard(BuildContext context, TodoProvider provider) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppTheme.accentGreen.withValues(alpha: 0.08), blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(color: AppTheme.primaryBlue.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                child: Icon(Icons.checklist_rounded, color: AppTheme.primaryBlue, size: 16),
              ),
              SizedBox(width: 10),
              Text(
                AppLocalizations.get('dailyTasks'),
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary, letterSpacing: -0.2),
              ),
            ],
          ),
          SizedBox(height: 16),
          ...provider.todos.asMap().entries.map((entry) {
            final todo = entry.value;
            final isLast = entry.key == provider.todos.length - 1;
            return Column(
              children: [
                _buildTaskItem(todo, provider),
                if (!isLast) Divider(height: 1, indent: 48),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTaskItem(Todo todo, TodoProvider provider) {
    return GestureDetector(
      onTap: () {
        SoundService().playTap();
        provider.toggleTodo(todo.id);
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: todo.isCompleted ? AppTheme.accentGreen : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: todo.isCompleted ? AppTheme.accentGreen : AppTheme.separator,
                  width: 1.5,
                ),
              ),
              child: todo.isCompleted ? Icon(Icons.check_rounded, color: Colors.white, size: 16) : null,
            ),
            SizedBox(width: 14),
            Expanded(
              child: Text(
                _getTaskTitle(todo.id),
                style: TextStyle(
                  fontSize: 15,
                  color: todo.isCompleted ? AppTheme.textTertiary : AppTheme.textPrimary,
                  decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            if (todo.isCompleted)
              Icon(Icons.check_circle_rounded, color: AppTheme.accentGreen, size: 20),
          ],
        ),
      ),
    );
  }

  String _getTaskTitle(String id) {
    switch (id) {
      case '1':
        return AppLocalizations.get('gripExercise');
      case '2':
        return AppLocalizations.get('audioRhythm');
      case '3':
        return AppLocalizations.get('consecutiveTraining');
      default:
        return '';
    }
  }
}
