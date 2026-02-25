import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:project_2/games/number_matching/number_matching.dart';
import 'package:project_2/games/path_finder/pathfinder_world.dart';
import 'package:project_2/home_page.dart';

class NeuroGym extends FlameGame {
  final GameType gameType;
  NumberMatching? currentGameNumberMatching;

  /// gametype is passed from home page through constructor
  NeuroGym({required this.gameType});
  @override
  Future<void> onLoad() async {
    super.onLoad();
    switch (gameType) {
      case GameType.numberMatching:
        currentGameNumberMatching = NumberMatching();
        add(currentGameNumberMatching!);
        break;
      case GameType.pathFinder:
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

  void startNumberMatchingGame(int difficulty) {
    if (currentGameNumberMatching != null) {
      currentGameNumberMatching!.startLevel(difficulty);
    }
  }

  /// creates pathfinder world and camera
  Future<void> startPathFinder(dynamic levelData) async {
    overlays.remove('PathFinderDashboard');
    world.removeAll(world.children);
    children.whereType<CameraComponent>().forEach((c) => c.removeFromParent());

    final pfWorld = PathFinderWorld(levelData);
    this.world = pfWorld;
    await add(pfWorld);
    double mazeWidth = pfWorld.cols * pfWorld.tileSize;
    double mazeHeight = pfWorld.rows * pfWorld.tileSize;
    final pfCamera = CameraComponent.withFixedResolution(
      world: pfWorld,
      width: mazeWidth,
      height: mazeHeight,
    );
    pfCamera.viewfinder.anchor = Anchor.center;
    pfCamera.viewfinder.position = Vector2(mazeWidth / 2, mazeHeight / 2);
    add(pfCamera);
  }

  // void restartNumberMatching() {
  //   if (currentGameNumberMatching != null) {
  //     if (currentGameNumberMatching!.camera != null) {
  //       currentGameNumberMatching!.camera!.viewport.removeAll(
  //         currentGameNumberMatching!.camera!.viewport.children,
  //       );
  //       currentGameNumberMatching!.camera!.removeFromParent();
  //     }
  //     currentGameNumberMatching!.removeFromParent();
  //   }
  //   currentGameNumberMatching = NumberMatching();
  //   add(currentGameNumberMatching!);
  // }
}
