import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:project_2/games/number_matching/number_tile.dart';

class NumberMatchingWorld extends World with HasGameReference<FlameGame> {
  final int n;
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

  /// shows the moves count as a HUD
  void buildCountHUD() {
    countText = TextComponent(
      text: 'Moves: $moves',
      position: Vector2(n * 100 / 2, 0),
      anchor: Anchor.topCenter,
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.yellow,
          fontSize: n * 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    attachedCamera.viewport.add(countText);
  }

  void buildFinalHUD() {
    finalText = TextComponent(
      text: 'PUZZLE SOLVED!!',
      position: Vector2(n * 100 / 2, 200),
      anchor: Anchor.bottomCenter,
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.greenAccent,
          fontSize: n * 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    attachedCamera.viewport.add(finalText!);
  }

  /// innitialize the board in sorted way
  void _initBoard() {
    grid = List.generate(
      n,
      (i) => List.generate(n, (j) {
        int val = i * n + j + 1;
        return val == n * n ? null : val;
      }),
    );
  }

  /// returns the location of the empty cell
  (int, int) _emptyPos() {
    for (int i = 0; i < n; i++) {
      for (int j = 0; j < n; j++) {
        if (grid[i][j] == null) return (i, j);
      }
    }
    return (0, 0);
  }

  /// swaps the tapped cell at r-th row and c-th column with the empty cell
  /// only if the empty cell is the neighbour of cell (r,c)
  bool _move(int r, int c) {
    var (er, ec) = _emptyPos();
    if ((r - er).abs() + (c - ec).abs() == 1) {
      grid[er][ec] = grid[r][c];
      grid[r][c] = null;
      return true;
    }
    return false;
  }

  /// Performs 100 random moves to shuffle the game move
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

  /// check if the grid is sorted
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

  /// renders the grid into the game world with NumberTile
  void _renderGrid() {
    /// all existing numberTile is removed first
    children.whereType<NumberTile>().forEach((t) => t.removeFromParent());
    for (int i = 0; i < n; i++) {
      for (int j = 0; j < n; j++) {
        add(
          NumberTile(number: grid[i][j], row: i, col: j, onTapTile: _onTileTap),
        );
      }
    }
  }

  /// action on each tile tap
  /// if the game is over or invalid move then nothing happens
  void _onTileTap(int r, int c) {
    if (!gameOver && _move(r, c)) {
      moves++;
      countText.text = 'Moves: $moves';
      _renderGrid();
      if (_isSolved()) {
        gameOver = true;
        buildFinalHUD();
      }
    }
  }
}
