import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import 'world.dart';

/// Game Over / Level Complete overlay with a tap-to-restart prompt.
class RestartOverlay extends PositionComponent with TapCallbacks {
  final BlockBreakerWorld world;
  final String title;
  final String subtitle;

  RestartOverlay({
    required this.world,
    required this.title,
    required this.subtitle,
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size, anchor: Anchor.topLeft) {
    priority = 100;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      size.toRect(),
      Paint()..color = Colors.black.withOpacity(0.7),
    );

    TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 36,
        fontWeight: FontWeight.bold,
      ),
    ).render(
      canvas,
      title,
      Vector2(size.x / 2, size.y / 2 - 40),
      anchor: Anchor.center,
    );

    TextPaint(
      style: const TextStyle(color: Colors.white70, fontSize: 18),
    ).render(
      canvas,
      subtitle,
      Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
    );

    TextPaint(
      style: const TextStyle(
        color: Color(0xFF54A0FF),
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ).render(
      canvas,
      'TAP TO RESTART',
      Vector2(size.x / 2, size.y / 2 + 50),
      anchor: Anchor.center,
    );
  }

  @override
  void onTapUp(TapUpEvent event) {
    world.restartGame();
  }
}
