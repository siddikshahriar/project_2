import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/src/text/renderers/text_renderer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_2/games/path_finder/maze_tile.dart';
import 'pathfinder_level.dart';
import 'package:project_2/games/path_finder/pathfinder_player.dart';

class PathFinderWorld extends World
    with HasGameReference<FlameGame>, TapCallbacks, KeyboardCallbacks {
  late final PathFinderLevel level;
  final double tileSize = 50;

  late List<List<String>> grid;
  late Point player;
  late PlayerComponent playerComp;
  int moveCount = 0;
  bool gameWon = false;
  TextComponent? moveCounterText;
  TextComponent? instructionsText;
  TextComponent? winText;
  List<Point> pathHistory = [];
  late int rows;
  late int cols;

  PathFinderWorld(this.level);

  @override
  Future<void> onLoad() async {
    grid = level.maze.map((r) => r.split("")).toList();
    rows = grid.length;
    cols = grid[0].length;
    player = level.start;
    pathHistory = [player];
    _buildMaze();
    _buildPlayer();
    _addOverlays(initial: true);
  }

  void _addOverlays({required bool initial}) {
    // Remove overlays if already present, but keep winText if it exists
    final overlaysToRemove = children
        .whereType<TextComponent>()
        .where((c) => c != winText)
        .toList();
    for (final overlay in overlaysToRemove) {
      remove(overlay);
    }
    if (moveCounterText == null) {
      moveCounterText = TextComponent(
        text: 'Moves: 0',
        position: Vector2(10, 10),
        anchor: Anchor.topLeft,
        priority: 999,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.yellow,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      add(moveCounterText!);
    }
    if (instructionsText == null) {
      instructionsText = TextComponent(
        text:
            'Tap near the player to move.\nReach the red tile!\nPress R to restart.',
        position: Vector2(10, 40),
        anchor: Anchor.topLeft,
        priority: 999,
        textRenderer: TextPaint(
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      );
      add(instructionsText!);
    }
    if (winText == null) {
      winText = TextComponent(
        text: 'You Win!',
        position: Vector2(cols * tileSize / 2, rows * tileSize / 2),
        anchor: Anchor.center,
        priority: 1000,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.green,
            fontSize: 36,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(blurRadius: 8, color: Colors.black, offset: Offset(2, 2)),
            ],
          ),
        ),
      );
      winText!.opacity = 0.0;
      add(winText!);
    } else {
      winText!.opacity = 0.0;
      winText!.position = Vector2(cols * tileSize / 2, rows * tileSize / 2);
    }
  }

  void _buildPlayer() {
    playerComp = PlayerComponent(
      row: player.r,
      col: player.c,
      tileSize: tileSize,
    );
    add(playerComp);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (gameWon) return;
    final pos = event.localPosition;
    final center = playerComp.position + Vector2.all(tileSize / 2);
    final dx = pos.x - center.x;
    final dy = pos.y - center.y;
    if (dx.abs() > dy.abs()) {
      move(0, dx > 0 ? 1 : -1);
    } else {
      move(dy > 0 ? 1 : -1, 0);
    }
  }

  @override
  void onKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent &&
        event.logicalKey.keyLabel.toLowerCase() == 'r') {
      _restart();
    }
  }

  void _buildMaze() {
    final tilesToAdd = <MazeTile>[];
    for (int i = 0; i < grid.length; i++) {
      for (int j = 0; j < grid[i].length; j++) {
        tilesToAdd.add(
          MazeTile(
            type: grid[i][j],
            row: i,
            col: j,
            tilesize: tileSize,
            highlight: pathHistory.any((p) => p.r == i && p.c == j),
          ),
        );
      }
    }
    for (final tile in tilesToAdd) {
      add(tile);
    }
  }

  void move(int dr, int dc) {
    int r = player.r;
    int c = player.c;
    bool moved = false;
    List<Point> path = [];
    while (true) {
      int nr = r + dr;
      int nc = c + dc;
      if (grid[nr][nc] == "#") break;
      r = nr;
      c = nc;
      moved = true;
      path.add(Point(r, c));
      if (_isJunction(r, c)) break;
    }
    if (moved) {
      moveCount++;
      moveCounterText?.text = 'Moves: $moveCount';
      pathHistory.addAll(path);
      // Rebuild maze to update highlights
      final tilesToRemove = children.whereType<MazeTile>().toList();
      for (final tile in tilesToRemove) {
        remove(tile);
      }
      _buildMaze();
      // Always keep overlays on top
      _addOverlays(initial: false);
    }
    player = Point(r, c);
    playerComp.moveTo(r, c);
    if (r == level.end.r && c == level.end.c) {
      gameWon = true;
      if (winText != null) {
        winText!.position = Vector2(cols * tileSize / 2, rows * tileSize / 2);
        winText!.opacity = 1.0;
      }
    }
  }

  void _restart() {
    moveCount = 0;
    moveCounterText?.text = 'Moves: 0';
    gameWon = false;
    if (winText != null) winText!.opacity = 0.0;
    player = level.start;
    playerComp.moveTo(player.r, player.c);
    pathHistory = [player];
    // Rebuild maze to clear highlights
    final tilesToRemove = children.whereType<MazeTile>().toList();
    for (final tile in tilesToRemove) {
      remove(tile);
    }
    _buildMaze();
    // Always keep overlays on top
    _addOverlays(initial: false);
  }

  bool _isJunction(int r, int c) {
    int paths = 0;
    List<List<int>> dirs = [
      [1, 0],
      [-1, 0],
      [0, 1],
      [0, -1],
    ];
    for (var d in dirs) {
      if (grid[r + d[0]][c + d[1]] != "#") {
        paths++;
      }
    }
    return paths > 2;
  }
}

mixin KeyboardCallbacks on Component {
  void onKeyEvent(RawKeyEvent event) {}
}

extension on TextComponent<TextRenderer> {
  set opacity(double opacity) {}
}
