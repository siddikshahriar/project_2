import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class NumberMatching extends Component with HasGameReference<FlameGame> {
  final Vector2 position;
  final int n; // Default n if needed, but usually set via dashboard

  World? world;
  CameraComponent? camera;

  NumberMatching({required this.position, this.n = 3});

  @override
  Future<void> onLoad() async {
    // Instead of loading the grid immediately, we show the dashboard overlay
    game.overlays.add('NumberMatchingDashboard');
  }

  /// Called from the NumberMatchingDashboard when a difficulty is selected
  Future<void> startLevel(int difficulty) async {
    // 1. Remove the dashboard
    game.overlays.remove('NumberMatchingDashboard');

    // 2. Clean up any existing game components (for restarts/level changes)
    if (world != null) world!.removeFromParent();
    if (camera != null) camera!.removeFromParent();

    // 3. Initialize the new World and Camera
    world = NumberMatchingWorld(n: difficulty);

    // We use a constant 1000x1000 resolution for consistent HUD sizing
    camera = CameraComponent.withFixedResolution(
      world: world!,
      width: n * 100,
      height: n * 100,
    );

    // Center the grid and zoom to fit nicely
    final gridDimension = difficulty * 100.0;
    camera!.viewfinder.position = Vector2(gridDimension / 2, gridDimension / 2);
    camera!.viewfinder.anchor = Anchor.center;
    //camera!.viewfinder.zoom = 0.8;

    await game.add(world!);
    await game.add(camera!);

    // Attach the camera to the world logic for HUD placement
    (world as NumberMatchingWorld).attachedCamera = camera!;
    (world as NumberMatchingWorld)._buildCountHUD();
  }
}

// --- World and Tile classes remain largely the same, but ensure they use 'attachedCamera' ---

class NumberMatchingWorld extends World with HasGameReference<FlameGame> {
  final int n;
  final double tileSize = 100;
  late TextComponent countText;
  TextComponent? finalText;
  late CameraComponent attachedCamera;
  int moves = 0;
  bool gameOver = false;
  late List<List<int?>> grid;

  NumberMatchingWorld({required this.n});

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _initBoard();
    _shuffle();
    _renderGrid();
  }

  void _buildCountHUD() {
    countText = TextComponent(
      text: 'Moves: $moves',
      position: Vector2(500, 50),
      anchor: Anchor.topCenter,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.yellow,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    attachedCamera.viewport.add(countText);
  }

  void _buildFinalHUD() {
    finalText = TextComponent(
      text: 'PUZZLE SOLVED!!',
      position: Vector2(500, 920),
      anchor: Anchor.bottomCenter,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.greenAccent,
          fontSize: 48,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    attachedCamera.viewport.add(finalText!);
  }

  void _initBoard() {
    grid = List.generate(
      n,
      (i) => List.generate(n, (j) {
        int val = i * n + j + 1;
        return val == n * n ? null : val;
      }),
    );
  }

  (int, int) _emptyPos() {
    for (int i = 0; i < n; i++) {
      for (int j = 0; j < n; j++) {
        if (grid[i][j] == null) return (i, j);
      }
    }
    return (0, 0);
  }

  bool _move(int r, int c) {
    var (er, ec) = _emptyPos();
    if ((r - er).abs() + (c - ec).abs() == 1) {
      grid[er][ec] = grid[r][c];
      grid[r][c] = null;
      return true;
    }
    return false;
  }

  void _shuffle() {
    final rand = Random();
    for (int i = 0; i < 100; i++) {
      var (er, ec) = _emptyPos();
      List<(int, int)> neighbors = [
        (er + 1, ec),
        (er - 1, ec),
        (er, ec + 1),
        (er, ec - 1),
      ];
      neighbors.shuffle(rand);
      for (var (r, c) in neighbors) {
        if (r >= 0 && r < n && c >= 0 && c < n) {
          _move(r, c);
          break;
        }
      }
    }
  }

  bool _isSolved() {
    int expected = 1;
    for (int i = 0; i < n; i++) {
      for (int j = 0; j < n; j++) {
        if (i == n - 1 && j == n - 1) return grid[i][j] == null;
        if (grid[i][j] != expected++) return false;
      }
    }
    return true;
  }

  void _renderGrid() {
    children.whereType<NumberTile>().forEach((t) => t.removeFromParent());
    for (int i = 0; i < n; i++) {
      for (int j = 0; j < n; j++) {
        add(
          NumberTile(
            number: grid[i][j],
            row: i,
            col: j,
            tilesize: tileSize,
            onTapTile: _onTileTap,
          ),
        );
      }
    }
  }

  void _onTileTap(int r, int c) {
    if (!gameOver && _move(r, c)) {
      moves++;
      countText.text = 'Moves: $moves';
      _renderGrid();
      if (_isSolved()) {
        gameOver = true;
        _buildFinalHUD();
      }
    }
  }
}

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
