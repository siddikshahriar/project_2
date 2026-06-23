import 'dart:math';
import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:project_2/games/number_matching/number_tile.dart';
import 'world.dart';

class GameScreen extends StatelessWidget {
  final int level;
  const GameScreen({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Scaffold gives you an automatic back button over the game canvas
      appBar: AppBar(
        title: Text('NeuroGym - Level $level'),
        backgroundColor: const Color(0xFF1A1D24),
      ),
      body: GameWidget(
        // Pass the level dynamically to your Flame Game instance
        game: BlockBreaker(level: level),
      ),
    );
  }
}

class BlockBreaker extends FlameGame {
  int level;
  BlockBreaker({required this.level});

  @override
  Future<void> onLoad() async {
    /// global viewport resolution
    camera.viewport = FixedResolutionViewport(resolution: Vector2(600, 1200));
    await loadLevel(level);
  }

  Future<void> loadLevel(int level) async {
    /// new world
    final newWorld = BlockBreakerWorld(level: level);

    /// assigning new world to the in built world
    world = newWorld;

    ///new viewfinder for new world
    camera.viewfinder.position = Vector2(0, 0);
    camera.viewfinder.anchor = Anchor.center;
  }
}
