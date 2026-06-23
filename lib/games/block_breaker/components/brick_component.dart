import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:project_2/games/block_breaker/world.dart';

class BrickComponent extends PositionComponent {
  final Color color;
  final bool isSpecial;

  BrickComponent({
    required super.position,
    required super.size,
    required this.color,
    this.isSpecial = false,
  });

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = color;
    canvas.drawRRect(
      RRect.fromRectAndRadius(size.toRect(), const Radius.circular(4)),
      paint,
    );

    if (isSpecial) {
      // Gold outline + star marker flag this as a power-up brick.
      final borderPaint = Paint()
        ..color = const Color(0xFFFFD32A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          size.toRect().deflate(1),
          const Radius.circular(4),
        ),
        borderPaint,
      );
      canvas.drawPath(
        buildStarPath(size.x / 2, size.y / 2, 6, 2.6),
        Paint()..color = Colors.white,
      );
    }
  }
}
