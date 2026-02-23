import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ordered_set/read_only_ordered_set.dart';

class NumberMatching extends Component with HasGameReference<FlameGame> {
  final Vector2 position;
  late final World world;
  late final CameraComponent camera;
  final int n;

  NumberMatching({required this.position, required this.n});

  @override
  Future<void> onLoad() async {
    world = NumberMatchingWorld(n: n);

    camera = CameraComponent.withFixedResolution(
      world: world,
      width: 600,
      height: 800,
    );

    // place this mini-game on landing page
    camera.viewport.position = position;
    camera.viewfinder.position = Vector2(n * 100 / 2, n * 100 / 2);

    await game.add(world);
    await game.add(camera);
  }
}

class NumberMatchingWorld extends World with HasGameReference<FlameGame> {
  final int n;
  final double tileSize = 100;

  late List<List<int?>> grid;

  NumberMatchingWorld({required this.n});

  @override
  Future<void> onLoad() async {
    _initBoard();
    _shuffle();
    _buildTiles();
  }

  void _initBoard() {
    grid = List.generate(n, (i) {
      return List.generate(n, (j) {
        int val = i * n + j + 1;
        return val == n * n ? null : val;
      });
    });
  }

  (int, int) _emptyPos() {
    for (int i = 0; i < n; i++) {
      for (int j = 0; j < n; j++) {
        if (grid[i][j] == null) return (i, j);
      }
    }
    throw Exception("No empty tile");
  }

  bool _canMove(int r, int c) {
    var (er, ec) = _emptyPos();
    return (r - er).abs() + (c - ec).abs() == 1;
  }

  bool _move(int r, int c) {
    if (!_canMove(r, c)) return false;

    var (er, ec) = _emptyPos();

    grid[er][ec] = grid[r][c];
    grid[r][c] = null;
    return true;
  }

  void _shuffle() {
    final rand = Random();

    for (int i = 0; i < 200; i++) {
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
        if (i == n - 1 && j == n - 1) {
          return grid[i][j] == null;
        }

        if (grid[i][j] != expected++) return false;
      }
    }
    return true;
  }

  void _buildTiles() {
    removeAll(children);

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
    if (_move(r, c)) {
      _buildTiles();

      if (_isSolved()) {
        add(
          TextComponent(text: 'You solved it!')
            ..position = Vector2(n * tileSize / 2, n * tileSize + 20)
            ..anchor = Anchor.center,
        );
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
    this.size = Vector2.all(tilesize);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (number != null) {
      onTapTile(row, col);
    }
  }

  @override
  void render(Canvas canvas) {
    if (number == null) return;

    final rect = size.toRect();

    // Dark tile background
    final tilePaint = Paint()..color = const Color(0xFF23272F);
    canvas.drawRect(rect, tilePaint);

    // Border
    final borderPaint = Paint()
      ..color = const Color(0xFF444B5A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRect(rect.deflate(1.5), borderPaint);

    // Number text
    final textPainter = TextPainter(
      text: TextSpan(
        text: number.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(blurRadius: 4, color: Colors.black54, offset: Offset(1, 2)),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        size.x / 2 - textPainter.width / 2,
        size.y / 2 - textPainter.height / 2,
      ),
    );
  }
}
