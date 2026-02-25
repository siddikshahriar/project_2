import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class MazeTile extends PositionComponent {
  final String type;
  final int row;
  final int col;
  final double tilesize;
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

    if (type == "#") {
      paint.color = const Color(0xFF23272F);
    } else if (type == "S") {
      paint.color = Colors.green.shade700;
    } else if (type == "E") {
      paint.color = Colors.red.shade700;
    } else {
      paint.color = Colors.white;
    }
    canvas.drawRect(rect, paint);

    if (highlight && type != "#") {
      paint.color = Colors.yellow.withOpacity(0.5);
      canvas.drawRect(rect.deflate(2), paint);
    }
    paint.color = Colors.black.withOpacity(0.1);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1;
    canvas.drawRect(rect, paint);
  }
}
