import 'package:flutter/material.dart';
import 'package:grip_strength_monitor/core/theme/app_theme.dart';
import '../models/game_note.dart';

class GameArea extends StatelessWidget {
  final List<GameNote> notes;
  final int nextNoteIndex;
  final double currentGrip;

  const GameArea({
    super.key,
    required this.notes,
    required this.nextNoteIndex,
    required this.currentGrip,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = constraints.maxHeight;
        final screenWidth = constraints.maxWidth;

        return ClipRect(
          child: Container(
            width: double.infinity,
            color: AppTheme.backgroundWhite,
            child: Stack(
              children: [
                ...notes.where((n) => n.state == NoteState.active).map((note) {
                  final noteY = screenHeight * 0.3 + (note.currentX * 0.08);
                  if (note.currentX > screenWidth + 100 ||
                      noteY > screenHeight + 100) {
                    return const SizedBox.shrink();
                  }

                  return Positioned(
                    left: -note.width + note.currentX,
                    top: noteY.clamp(50.0, screenHeight * 0.7),
                    child: _buildNote(note),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNote(GameNote note) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 50),
      width: note.width,
      height: note.height,
      decoration: BoxDecoration(
        color: note.color,
        borderRadius: BorderRadius.circular(note.type == NoteType.short ? 28 : 16),
        boxShadow: [
          BoxShadow(
            color: note.color.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              note.icon,
              color: Colors.white,
              size: note.type == NoteType.short ? 24 : 28,
            ),
            if (note.type == NoteType.long) ...[
              SizedBox(height: 2),
              Text(
                note.label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
