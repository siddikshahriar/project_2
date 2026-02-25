import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_2/games/path_finder/maze_tile.dart';
import 'package:project_2/games/path_finder/pathfinder_levels.dart';
import 'package:project_2/games/path_finder/pathfinder_player.dart';
import 'package:flame/input.dart';

/// creates a pathfinder world
class PathFinderWorld extends World
    with HasGameReference<FlameGame>, TapCallbacks {
  late final PathFinderLevel level;
  final double tileSize = 50;
  late List<List<String>> grid;
  late Point player;
  late PlayerComponent playerComp;

  int moveCount = 0;
  bool gameWon = false;

  late TextComponent moveCounterText;
  late TextComponent winText;
  List<Point> pathHistory = [];

  /// stores the current path of player
  late int rows;
  late int cols;

  PathFinderWorld(this.level);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    grid = level.maze.map((r) => r.split("")).toList();
    rows = grid.length;
    cols = grid[0].length;

    // Initial state
    player = level.start;
    pathHistory = [player];

    _buildMaze();
    _buildPlayer();
    _initHUD();
  }

  /// move counter and win text HUD
  void _initHUD() {
    moveCounterText = TextComponent(
      text: 'Moves: 0',
      position: Vector2(10, 10),
      priority: 999,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.yellow,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    winText = TextComponent(
      text: '',
      position: Vector2(cols * tileSize / 2, rows * tileSize / 2),
      anchor: Anchor.center,
      priority: 1000,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.greenAccent,
          fontSize: 42,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(blurRadius: 10, color: Colors.black)],
        ),
      ),
    );
    add(moveCounterText);
    add(winText);
  }

  /// building the innitial maze
  void _buildMaze() {
    for (int i = 0; i < grid.length; i++) {
      for (int j = 0; j < grid[i].length; j++) {
        add(
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
  }

  /// build the player component
  void _buildPlayer() {
    playerComp = PlayerComponent(
      row: player.r,
      col: player.c,
      tileSize: tileSize,
    );
    add(playerComp);
  }

  /// compares the tapped cell location with the players current position
  /// to determine the intended direction
  @override
  void onTapDown(TapDownEvent event) {
    if (gameWon) return;
    final pos = event.localPosition;
    final center = playerComp.position + Vector2(tileSize / 2, tileSize / 2);
    final dx = pos.x - center.x;
    final dy = pos.y - center.y;

    if (dx.abs() > dy.abs()) {
      move(0, dx > 0 ? 1 : -1);
    } else {
      move(dy > 0 ? 1 : -1, 0);
    }
  }

  /// executes player move to the (dr,dc) direction
  /// until it hits any wall or lands on a junction
  void move(int dr, int dc) {
    if (gameWon) return;
    int r = player.r;
    int c = player.c;
    bool moved = false;

    while (true) {
      int nr = r + dr;
      int nc = c + dc;
      if (nr < 0 || nr >= rows || nc < 0 || nc >= cols || grid[nr][nc] == "#")
        break;

      r = nr;
      c = nc;
      moved = true;

      Point currentPoint = Point(r, c);

      /// delets path history in case of backword traversal
      /// or adds the cell to the path history
      if (pathHistory.length > 1 &&
          pathHistory[pathHistory.length - 2] == currentPoint) {
        pathHistory.removeLast();
      } else {
        if (!pathHistory.contains(currentPoint)) {
          pathHistory.add(currentPoint);
        }
      }

      /// multiple path to go
      if (_isJunction(r, c)) break;

      /// player reached at the end cell
      if (r == level.end.r && c == level.end.c) break;
    }

    /// succesfull move
    if (moved) {
      moveCount++;
      moveCounterText.text = 'Moves: $moveCount';
      player = Point(r, c);
      playerComp.moveTo(r, c);
      _updateTileHighlights();
      _checkWin();
    }
  }

  /// update the state of each tile
  void _updateTileHighlights() {
    children.whereType<MazeTile>().forEach((tile) {
      tile.highlight = pathHistory.any(
        (p) => p.r == tile.row && p.c == tile.col,
      );
    });
  }

  void _checkWin() {
    if (player.r == level.end.r && player.c == level.end.c) {
      gameWon = true;
      winText.text = 'LEVEL COMPLETE!';
    }
  }

  /// restarting the game
  void _restart() {
    moveCount = 0;
    moveCounterText.text = 'Moves: 0';
    gameWon = false;
    winText.text = '';
    player = level.start;
    playerComp.moveTo(player.r, player.c);
    pathHistory = [player];
    _updateTileHighlights();
  }

  /// a cell from where player can move in multiple direction
  bool _isJunction(int r, int c) {
    int paths = 0;
    List<List<int>> dirs = [
      [1, 0],
      [-1, 0],
      [0, 1],
      [0, -1],
    ];
    for (var d in dirs) {
      int nr = r + d[0];
      int nc = c + d[1];
      if (nr >= 0 && nr < rows && nc >= 0 && nc < cols && grid[nr][nc] != "#") {
        paths++;
      }
    }
    return paths > 2;
  }
}
