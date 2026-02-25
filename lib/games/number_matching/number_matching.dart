import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:project_2/games/number_matching/number_tile.dart';
import 'number_matching_world.dart';

/// sets the game world,camera and HUDs
class NumberMatching extends Component with HasGameReference<FlameGame> {
  final Vector2 position = Vector2.zero();
  World? world;
  CameraComponent? camera;
  NumberMatching({super.key});
  @override
  Future<void> onLoad() async {
    game.overlays.add('NumberMatchingDashboard');
  }

  /// n is the difficulty of the level
  Future<void> startLevel(int n) async {
    /// remove the overlay before creating the game world
    game.overlays.remove('NumberMatchingDashboard');

    if (world != null) world!.removeFromParent();
    if (camera != null) camera!.removeFromParent();

    world = NumberMatchingWorld(n: n);
    camera = CameraComponent.withFixedResolution(
      world: world!,
      width: n * 100,
      height: n * 100 + 200,
    );

    /// 100 is the tile size, camera is adjusted with tihs
    final gridDimension = n * 100.0;

    /// viewfinder is located in the middle of the grid
    camera!.viewfinder.position = Vector2(gridDimension / 2, gridDimension / 2);
    camera!.viewfinder.anchor = Anchor.center;
    await game.add(world!);
    await game.add(camera!);
    (world as NumberMatchingWorld).attachedCamera = camera!;
    (world as NumberMatchingWorld).buildCountHUD();
  }
}
