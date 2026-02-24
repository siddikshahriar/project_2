import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:project_2/games/number_matching/number_matching.dart';
import 'package:project_2/games/path_finder/pathfinder_world.dart';
import 'package:project_2/games/path_finder/pathfinder_levels.dart';
import 'package:project_2/home_page.dart'; // Assuming GameType is defined here

class NeuroGym extends FlameGame {
  final GameType gameType;

  // Use nullable for the game components to safely check status
  NumberMatching? currentGameNumberMatching;

  NeuroGym({required this.gameType});

  @override
  Future<void> onLoad() async {
    super.onLoad();

    switch (gameType) {
      case GameType.numberMatching:
        _initNumberMatching();
        break;

      case GameType.pathFinder:
        // Open the Flutter Dashboard Overlay
        overlays.add('PathFinderDashboard');
        break;

      case GameType.blackShelby:
        add(
          TextComponent(
            text: 'Black Shelby - Coming Soon!',
            position: Vector2(100, 100),
          ),
        );
        break;
    }
  }

  // Internal helper to launch NumberMatching
  void _initNumberMatching() {
    currentGameNumberMatching = NumberMatching(position: Vector2.zero(), n: 2);
    add(currentGameNumberMatching!);
  }

  /// RESTARTS NumberMatching
  /// Clears specific cameras and viewports to ensure HUDs are deleted.
  void restartNumberMatching() {
    if (currentGameNumberMatching != null) {
      // 1. Clear the viewport children (HUDs) of the current game's camera
      currentGameNumberMatching!.camera.viewport.removeAll(
        currentGameNumberMatching!.camera.viewport.children,
      );

      // 2. Remove the camera and the game component
      currentGameNumberMatching!.camera.removeFromParent();
      currentGameNumberMatching!.removeFromParent();
    }

    // 3. Re-initialize
    _initNumberMatching();
  }

  Future<void> startPathFinder(dynamic levelData) async {
    overlays.remove('PathFinderDashboard');
    world.removeAll(world.children);
    children.whereType<CameraComponent>().forEach((c) => c.removeFromParent());

    final pfWorld = PathFinderWorld(levelData);
    this.world = pfWorld;
    await add(pfWorld);

    // Calculate how much we need to zoom to see the whole maze
    // We want the maze tiles (tileSize * cols) to fit inside our 1000px width
    double mazeWidth = pfWorld.cols * pfWorld.tileSize;
    double mazeHeight = pfWorld.rows * pfWorld.tileSize;

    // FIX: Use a constant virtual size (e.g., 1000x1000) so HUD text stays consistent
    // The "FixedResolution" acts as the internal canvas size.
    final pfCamera = CameraComponent.withFixedResolution(
      world: pfWorld,
      width: mazeWidth,
      height: mazeHeight,
    );

    // Set zoom so the maze fills roughly 80% of the screen
    //double zoom = 800 / (mazeWidth > mazeHeight ? mazeWidth : mazeHeight);
    //pfCamera.viewfinder.zoom = zoom;

    pfCamera.viewfinder.anchor = Anchor.center;
    // Center the camera on the middle of the maze
    pfCamera.viewfinder.position = Vector2(mazeWidth / 2, mazeHeight / 2);

    add(pfCamera);
  }
}
