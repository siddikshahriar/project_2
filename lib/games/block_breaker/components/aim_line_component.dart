import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:project_2/games/block_breaker/world.dart';

/// Draws the dashed "where will it go" line + arrowhead while a ball is
/// resting on the paddle. This used to be drawn straight from
/// BlockBreakerWorld.render(), but a Component's own render() call always
/// runs *before* its children render - so the line was being painted, then
/// immediately covered up by the opaque background rectangle (also a
/// child) every single frame, making it invisible. Living in its own child
/// component with a priority above everything else fixes that: it now
/// renders last, on top of the background/bricks/paddle/ball.
class AimLineComponent extends PositionComponent {
  final BlockBreakerWorld world;
  AimLineComponent({required this.world}) : super(priority: 45);

  @override
  void render(Canvas canvas) {
    if (world.gameOver || world.ballsLaunched || world.activeBalls.isEmpty) {
      return;
    }

    final ball = world.activeBalls.first;
    final dir = Vector2(world.aimDirX, -1).normalized();
    const lineLength = 140.0;
    final start = ball.position + dir * (ball.radius + 4);
    final end = ball.position + dir * lineLength;

    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // Dashed line effect
    const dashLength = 10.0;
    const gapLength = 6.0;
    final totalLength = (end - start).length;
    final step = dir * (dashLength + gapLength);
    var cursor = start.clone();
    var drawn = 0.0;
    while (drawn < totalLength) {
      final dashEnd = cursor + dir * dashLength;
      canvas.drawLine(
        Offset(cursor.x, cursor.y),
        Offset(dashEnd.x, dashEnd.y),
        linePaint,
      );
      cursor = cursor + step;
      drawn += dashLength + gapLength;
    }

    // Arrow head pointing in the launch direction
    final arrowPaint = Paint()..color = Colors.white.withValues(alpha: 0.85);
    final arrowPath = Path()
      ..moveTo(end.x, end.y)
      ..lineTo(end.x - dir.x * 10 - dir.y * 6, end.y - dir.y * 10 + dir.x * 6)
      ..lineTo(end.x - dir.x * 10 + dir.y * 6, end.y - dir.y * 10 - dir.x * 6)
      ..close();
    canvas.drawPath(arrowPath, arrowPaint);
  }
}
