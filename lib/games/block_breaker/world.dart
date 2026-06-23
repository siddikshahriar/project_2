import 'dart:async';
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'block_breaker.dart';
import 'components/ball_component.dart';
import 'components/brick_component.dart';
import 'components/paddle_component.dart';
import 'components/star_component.dart';
import 'components/aim_line_component.dart';
import 'restart_overlay.dart';
import 'levels.dart';

class BlockBreakerWorld extends World with HasGameReference<BlockBreaker> {
  int level;

  BlockBreakerWorld({required this.level});

  // Game Arena Dimensions matching the viewport
  final double arenaWidth = 600;
  final double arenaHeight = 1200;

  /// game constants
  static const int startingLives = 3;
  static const double ballSpeed = 350;
  static const double starFallSpeed = 140;

  /// tilt-control constants
  static const double tiltDeadZone = 0.4; // ignore tiny jitter when held flat
  static const double tiltSensitivity =
      120.0; // px/s of paddle speed per m/s^2 of tilt

  /// game states
  int lives = startingLives;
  int score = 0;
  bool ballsLaunched = false;
  bool gameOver = false;
  double aimDirX = 0; // -1 (full left) .. 0 (straight up) .. 1 (full right)

  late PaddleComponent paddle;
  late TextComponent scoreText;
  late TextComponent livesText;

  final List<BallComponent> activeBalls = [];
  final List<BrickComponent> bricks = [];
  final List<StarComponent> stars = [];

  StreamSubscription<AccelerometerEvent>? _accelSubscription;
  double _tiltX = 0;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _setupLevel();
    _listenToTilt();
  }

  @override
  void onRemove() {
    _accelSubscription?.cancel();
    super.onRemove();
  }

  void _listenToTilt() {
    _accelSubscription?.cancel();
    _accelSubscription = accelerometerEventStream().listen((event) {
      _tiltX = event.x;
    });
  }

  // Builds (or rebuilds, on restart) everything the level needs.
  void _setupLevel() {
    for (final child in children.toList()) {
      child.removeFromParent();
    }
    bricks.clear();
    activeBalls.clear();
    stars.clear();

    lives = startingLives;
    score = 0;
    ballsLaunched = false;
    gameOver = false;
    aimDirX = 0;
    _tiltX = 0;

    // 1. Add a dark slate background canvas
    add(
      RectangleComponent(
        position: Vector2(-arenaWidth / 2, -arenaHeight / 2),
        size: Vector2(arenaWidth, arenaHeight),
        paint: Paint()
          ..color = const Color(0xFF15161B), // Set background color here
      ),
    );

    // 2. Build the Level Brick Layout Grid
    _buildBrickLayout();

    // 3. Spawn the Game Elements (Paddle & Ball)
    _spawnGameElements();

    // 4. HUD (score + lives)
    _buildHud();

    // 5. Aim line: a dedicated, high-priority child so it draws ON TOP of
    //    the background/bricks/paddle instead of being drawn straight from
    //    World.render() (which runs *before* children and was getting
    //    painted over by the opaque background rectangle every frame).
    add(AimLineComponent(world: this));

    // 6. Full-arena input layer: drags move the paddle and, before launch,
    //    tilt the aim line. Releasing fires the ball(s).
    add(
      InputLayer(
        world: this,
        position: Vector2(-arenaWidth / 2, -arenaHeight / 2),
        size: Vector2(arenaWidth, arenaHeight),
      )..priority = 40,
    );
  }

  void _buildBrickLayout() {
    // Configuration metrics for uniform bricks
    const double brickWidth = 60.0;
    const double brickHeight = 25.0;
    const double spacing = 8.0;

    // Define coordinate offsets to center the block grids horizontally
    final double startX = (-arenaWidth / 2) + 28;
    final double startY = (-arenaHeight / 2) + 100; // Leave space at the top

    // Multi-dimensional matrices representing distinct layout designs per level
    // 1 = Block exists, 0 = Empty air space
    final BlockBreakerLevels allLevels = BlockBreakerLevels();

    // Assign different accent colors based on grid tier rows
    final List<Color> rowColors = [
      const Color(0xFFFF4B4B), // Top Tier Red
      const Color(0xFFFF9F43), // Mid Tier Orange
      const Color(0xFF10AC84), // Low Tier Green
      const Color(0xFF2E86DE), // Bottom Tier Blue
    ];

    // Iterative matrix translation loop converting numbers into physical game components
    for (
      int row = 0;
      row < allLevels.levelList[level - 1].layout.length;
      row++
    ) {
      for (
        int col = 0;
        col < allLevels.levelList[level - 1].layout[row].length;
        col++
      ) {
        if (allLevels.levelList[level - 1].layout[row][col] == 1) {
          final double posX = startX + (col * (brickWidth + spacing));
          final double posY = startY + (row * (brickHeight + spacing));

          final brickColor = rowColors[row % rowColors.length];

          // Roughly 1 in 4 bricks is a special "star" brick.
          final bool isSpecial = (row + col) % 10 == 0;

          final brick = BrickComponent(
            position: Vector2(posX, posY),
            size: Vector2(brickWidth, brickHeight),
            color: brickColor,
            isSpecial: isSpecial,
          );
          bricks.add(brick);
          add(brick);
        }
      }
    }
  }

  void _spawnGameElements() {
    // Spawn Interactive Paddle centered near the bottom of the arena
    paddle = PaddleComponent(
      position: Vector2(0, (arenaHeight / 2) - 80),
      size: Vector2(100, 20),
    );
    add(paddle);

    // Spawn the first ball, resting on the paddle, waiting to be launched
    _spawnRestingBall(offsetX: 0);
  }

  void _spawnRestingBall({required double offsetX}) {
    final ball = BallComponent(
      position: Vector2(
        paddle.position.x + offsetX,
        paddle.position.y - paddle.size.y / 2 - 10,
      ),
      radius: 10,
      restOffsetX: offsetX,
    );
    activeBalls.add(ball);
    add(ball);
  }

  /// score and live count HUD
  void _buildHud() {
    scoreText = TextComponent(
      text: 'Score: $score',
      position: Vector2(-arenaWidth / 2 + 20, -arenaHeight / 2 + 24),
      anchor: Anchor.topLeft,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    )..priority = 50;

    livesText = TextComponent(
      text: 'Lives: $lives',
      position: Vector2(arenaWidth / 2 - 20, -arenaHeight / 2 + 24),
      anchor: Anchor.topRight,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    )..priority = 50;

    add(scoreText);
    add(livesText);
  }

  /// game loop
  @override
  void update(double dt) {
    super.update(dt);
    if (gameOver) return;

    // Phone-tilt steering, layered on top of drag input.
    _applyTiltControl(dt);

    // Resting balls ride along with the paddle, fanned out a little if
    // there's more than one waiting to launch.
    for (final ball in activeBalls) {
      if (!ball.isLaunched) {
        ball.position.x = paddle.position.x + ball.restOffsetX;
        ball.position.y = paddle.position.y - paddle.size.y / 2 - ball.radius;
      }
    }

    // Physics for balls already in flight (iterate a copy since balls can
    // remove themselves from activeBalls mid-loop).
    for (final ball in List<BallComponent>.from(activeBalls)) {
      if (ball.isLaunched) {
        _updateBallPhysics(ball, dt);
      }
    }

    // If every launched ball has fallen off the bottom, the round is lost.
    if (ballsLaunched && activeBalls.isEmpty) {
      _loseLife();
    }

    // Falling stars from broken special bricks.
    for (final star in List<StarComponent>.from(stars)) {
      star.position.y += starFallSpeed * dt;
      final starRect = _componentRect(star);
      if (starRect.overlaps(_paddleRect())) {
        star.removeFromParent();
        stars.remove(star);
        _collectStar();
      } else if (star.position.y - star.size.y / 2 > arenaHeight / 2) {
        star.removeFromParent();
        stars.remove(star);
      }
    }
  }

  /// Tilting the phone side to side nudges the paddle, exactly like a
  /// continuous drag. Works at the same time as touch dragging - whichever
  /// input moved last each frame wins, so they don't fight each other.
  void _applyTiltControl(double dt) {
    if (_tiltX.abs() < tiltDeadZone) return;

    final halfPaddle = paddle.size.x / 2;
    // Tilting the top of the phone to the right produces a negative
    // accelerometer x reading on most devices held in portrait, so this is
    // inverted to feel natural. Flip the sign below if it feels backwards
    // on your device.
    paddle.position.x = (paddle.position.x - _tiltX * tiltSensitivity * dt)
        .clamp(-arenaWidth / 2 + halfPaddle, arenaWidth / 2 - halfPaddle);
  }

  void handleDrag(Vector2 delta) {
    if (gameOver) return;

    final halfPaddle = paddle.size.x / 2;
    paddle.position.x = (paddle.position.x + delta.x).clamp(
      -arenaWidth / 2 + halfPaddle,
      arenaWidth / 2 - halfPaddle,
    );

    if (!ballsLaunched) {
      aimDirX = (aimDirX + delta.x * 0.01).clamp(-0.85, 0.85);
    }
  }

  void handleDragEnd() {
    if (gameOver || ballsLaunched) return;
    launchBalls();
  }

  void launchBalls() {
    final dir = Vector2(aimDirX, -1).normalized();
    for (final ball in activeBalls) {
      ball.velocity = dir * ballSpeed;
      ball.isLaunched = true;
    }
    ballsLaunched = true;
  }

  /// Collisions
  void _updateBallPhysics(BallComponent ball, double dt) {
    ball.position += ball.velocity * dt;

    // Bounce off the side walls
    if (ball.position.x - ball.radius <= -arenaWidth / 2) {
      ball.position.x = -arenaWidth / 2 + ball.radius;
      ball.velocity.x = ball.velocity.x.abs();
    } else if (ball.position.x + ball.radius >= arenaWidth / 2) {
      ball.position.x = arenaWidth / 2 - ball.radius;
      ball.velocity.x = -ball.velocity.x.abs();
    }

    // Bounce off the ceiling
    if (ball.position.y - ball.radius <= -arenaHeight / 2) {
      ball.position.y = -arenaHeight / 2 + ball.radius;
      ball.velocity.y = ball.velocity.y.abs();
    }

    // Fell past the bottom -> this ball is lost
    if (ball.position.y - ball.radius > arenaHeight / 2) {
      ball.removeFromParent();
      activeBalls.remove(ball);
      return;
    }

    // Bounce off the paddle, steering the rebound by where it was hit
    if (ball.velocity.y > 0 &&
        _circleRectOverlap(ball.position, ball.radius, _paddleRect())) {
      ball.position.y = paddle.position.y - paddle.size.y / 2 - ball.radius;
      final hitOffset =
          ((ball.position.x - paddle.position.x) / (paddle.size.x / 2)).clamp(
            -1.0,
            1.0,
          );
      ball.velocity = Vector2(
        hitOffset * ballSpeed * 0.6,
        -ball.velocity.y.abs(),
      );
    }

    // Bounce off (and break) bricks - resolve a single hit per frame
    for (final brick in List<BrickComponent>.from(bricks)) {
      final rect = _componentRect(brick);
      if (_circleRectOverlap(ball.position, ball.radius, rect)) {
        final center = Vector2(rect.center.dx, rect.center.dy);
        final diff = ball.position - center;
        final overlapX = (rect.width / 2 + ball.radius) - diff.x.abs();
        final overlapY = (rect.height / 2 + ball.radius) - diff.y.abs();
        if (overlapX < overlapY) {
          ball.velocity.x = -ball.velocity.x;
        } else {
          ball.velocity.y = -ball.velocity.y;
        }
        _destroyBrick(brick);
        break;
      }
    }
  }

  bool _circleRectOverlap(Vector2 center, double radius, Rect rect) {
    final closestX = center.x.clamp(rect.left, rect.right);
    final closestY = center.y.clamp(rect.top, rect.bottom);
    final dx = center.x - closestX;
    final dy = center.y - closestY;
    return (dx * dx + dy * dy) <= radius * radius;
  }

  Rect _componentRect(PositionComponent c) {
    final topLeft = c.anchor == Anchor.center
        ? c.position - c.size / 2
        : c.position;
    return Rect.fromLTWH(topLeft.x, topLeft.y, c.size.x, c.size.y);
  }

  Rect _paddleRect() => _componentRect(paddle);

  void _destroyBrick(BrickComponent brick) {
    score += brick.isSpecial ? 25 : 10;
    scoreText.text = 'Score: $score';

    if (brick.isSpecial) {
      final star = StarComponent(
        position: Vector2(
          brick.position.x + brick.size.x / 2,
          brick.position.y + brick.size.y / 2,
        ),
      )..priority = 3;
      stars.add(star);
      add(star);
    }

    brick.removeFromParent();
    bricks.remove(brick);

    if (bricks.isEmpty) {
      _showLevelComplete();
    }
  }

  void _collectStar() {
    score += 5;
    scoreText.text = 'Score: $score';

    if (!ballsLaunched) {
      // Still aiming: queue another ball alongside the resting one(s).
      final offset = (activeBalls.length * 18.0) - 9.0;
      _spawnRestingBall(offsetX: offset);
    } else if (activeBalls.isNotEmpty) {
      // In play: split off a new ball from an existing one.
      final source = activeBalls.first;
      final extra = BallComponent(position: source.position.clone(), radius: 10)
        ..isLaunched = true
        ..velocity = Vector2(-source.velocity.x, source.velocity.y);
      activeBalls.add(extra);
      add(extra);
    }
  }

  void _loseLife() {
    lives--;
    livesText.text = 'Lives: $lives';

    if (lives <= 0) {
      _showGameOver();
      return;
    }

    ballsLaunched = false;
    aimDirX = 0;
    _spawnRestingBall(offsetX: 0);
  }

  void _showGameOver() {
    gameOver = true;
    add(
      RestartOverlay(
        world: this,
        title: 'GAME OVER',
        subtitle: 'Score: $score',
        position: Vector2(-arenaWidth / 2, -arenaHeight / 2),
        size: Vector2(arenaWidth, arenaHeight),
      ),
    );
  }

  void _showLevelComplete() {
    gameOver = true;
    add(
      RestartOverlay(
        world: this,
        title: 'LEVEL CLEAR!',
        subtitle: 'Score: $score',
        position: Vector2(-arenaWidth / 2, -arenaHeight / 2),
        size: Vector2(arenaWidth, arenaHeight),
      ),
    );
  }

  void restartGame() {
    _setupLevel();
  }
}

/// Builds a simple 5-point star path centered at (cx, cy).
Path buildStarPath(
  double cx,
  double cy,
  double outerRadius,
  double innerRadius,
) {
  final path = Path();
  for (int i = 0; i < 10; i++) {
    final r = i.isEven ? outerRadius : innerRadius;
    final angle = i * pi / 5 - pi / 2;
    final x = cx + r * cos(angle);
    final y = cy + r * sin(angle);
    if (i == 0) {
      path.moveTo(x, y);
    } else {
      path.lineTo(x, y);
    }
  }
  path.close();
  return path;
}

/// Invisible full-arena layer that captures all drag input: it moves the
/// paddle and, while a ball is waiting to launch, adjusts the aim angle.
class InputLayer extends PositionComponent with DragCallbacks {
  final BlockBreakerWorld world;

  InputLayer({
    required this.world,
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size, anchor: Anchor.topLeft);

  @override
  void onDragUpdate(DragUpdateEvent event) {
    world.handleDrag(event.localDelta);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    world.handleDragEnd();
  }
}
