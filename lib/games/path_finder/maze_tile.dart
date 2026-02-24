import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class MazeTile extends PositionComponent {
  final String type;
  final int row;
  final int col;
  final double tilesize;

  // Removed 'final' so the World can update this property dynamically
  bool highlight;

  MazeTile({
    required this.type,
    required this.row,
    required this.col,
    required this.tilesize,
    this.highlight = false,
  }) {
    position = Vector2(col * tilesize, row * tilesize);
    size = Vector2.all(tilesize);
  }

  @override
  void render(Canvas canvas) {
    final rect = size.toRect();
    final paint = Paint();

    // 1. Draw the Base Layer
    if (type == "#") {
      paint.color = const Color(0xFF23272F); // Darker Slate for walls
    } else if (type == "S") {
      paint.color = Colors.green.shade700;
    } else if (type == "E") {
      paint.color = Colors.red.shade700;
    } else {
      paint.color = Colors.white;
    }
    canvas.drawRect(rect, paint);

    // 2. Draw the Highlight Layer (Path History)
    // We draw this on top of the base color if highlighted
    if (highlight && type != "#") {
      paint.color = Colors.yellow.withOpacity(0.5);
      // We deflate the rect slightly to make the path look like a "trail"
      canvas.drawRect(rect.deflate(2), paint);
    }

    // 3. Draw Grid Borders (Optional, but helps clarity)
    paint.color = Colors.black.withOpacity(0.1);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1;
    canvas.drawRect(rect, paint);
  }
}
