import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:project_2/games/path_finder/pathfinder_level.dart';

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
    canvas.drawRect(size.toRect(), Paint()..color = Colors.blue);
  }
}
