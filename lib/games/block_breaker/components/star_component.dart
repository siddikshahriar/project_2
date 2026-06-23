import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:project_2/games/block_breaker/world.dart';

class StarComponent extends PositionComponent {
  StarComponent({required Vector2 position})
    : super(position: position, size: Vector2(18, 18), anchor: Anchor.center);

  @override
  void render(Canvas canvas) {
    canvas.drawPath(
      buildStarPath(size.x / 2, size.y / 2, size.x / 2, size.x / 4),
      Paint()..color = const Color(0xFFFFD32A),
    );
  }
}
