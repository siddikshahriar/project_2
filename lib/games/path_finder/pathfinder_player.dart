import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class PlayerComponent extends PositionComponent {
  final double tileSize;
  PlayerComponent({
    required int row,
    required int col,
    required this.tileSize,
  }) {
    position = Vector2(col * tileSize, row * tileSize);
    size = Vector2.all(tileSize);
  }

  void moveTo(int r, int c) {
    position = Vector2(c * tileSize, r * tileSize);
  }

  @override
  void render(Canvas canvas) {
    // 1. Optional: Draw a slight shadow or glow under the emoji
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x / 3,
      Paint()
        ..color = Colors.black26
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    final textPainter = TextPainter(
      text: TextSpan(
        text: '🐱',
        style: TextStyle(fontSize: tileSize * 2),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        size.x / 2 - textPainter.width / 2,
        size.y / 2 - textPainter.height / 2,
      ),
    );
  }
}
