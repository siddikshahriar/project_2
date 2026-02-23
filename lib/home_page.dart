import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:project_2/games/number_matching/number_matching.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login _&_sighup/login_page.dart';
import 'games/path_finder/pathfinder_levels.dart';
import 'games/path_finder/pathfinder_world.dart';

enum GameType { blackShelby, numberMatching, pathFinder }

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("NeuroGym Games"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        children: [
          _gameCard("Black Shelby", "assets/black_shelby.png", () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => _centeredGameScreen(
                  GameWidget(game: NeuroGym(gameType: GameType.blackShelby)),
                ),
              ),
            );
          }),
          _gameCard("Number Matching", "assets/number_matching.png", () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => _centeredGameScreen(
                  GameWidget(game: NeuroGym(gameType: GameType.numberMatching)),
                ),
              ),
            );
          }),
          _gameCard("Path Finder", "assets/path_finder.png", () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => _centeredGameScreen(
                  GameWidget(game: NeuroGym(gameType: GameType.pathFinder)),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _centeredGameScreen(Widget gameWidget) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: AspectRatio(
            aspectRatio: 1,
            child: SizedBox(width: 400, height: 400, child: gameWidget),
          ),
        ),
      ),
    );
  }

  Widget _gameCard(String title, String image, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.grey[900],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(image, height: 100),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

class NeuroGym extends FlameGame {
  final GameType gameType;

  NeuroGym({required this.gameType});

  @override
  Future<void> onLoad() async {
    switch (gameType) {
      case GameType.numberMatching:
        add(NumberMatching(position: Vector2.zero(), n: 3));
        break;
      case GameType.blackShelby:
        add(
          TextComponent(text: 'Black Shelby - Coming Soon!')
            ..position = Vector2(100, 100),
        );
        break;
      case GameType.pathFinder:
        final world = PathFinderWorld(PathFinderLevels.levels[0]);
        this.world = world;
        await world.onLoad(); // Ensure grid and player are initialized
        const double padding = 32.0;
        final camera = CameraComponent.withFixedResolution(
          world: world,
          width: world.cols * world.tileSize + padding * 2,
          height: world.rows * world.tileSize + padding * 2,
        );
        camera.viewfinder.anchor = Anchor.topLeft;
        camera.viewfinder.position = Vector2(-padding, -padding);
        add(camera);
        break;
    }
  }
}
