import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class NumberTile extends PositionComponent with TapCallbacks {
  final int? number;
  final int row;
  final int col;
  final double tilesize;
  final Function(int, int) onTapTile;

  NumberTile({
    required this.number,
    required this.row,
    required this.col,
    required this.tilesize,
    required this.onTapTile,
  }) {
    position = Vector2(col * tilesize, row * tilesize);
    size = Vector2.all(tilesize);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (number != null) onTapTile(row, col);
  }

  @override
  void render(Canvas canvas) {
    if (number == null) return;
    final rect = size.toRect().deflate(2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      Paint()..color = const Color(0xFF2D323E),
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: '$number',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
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
