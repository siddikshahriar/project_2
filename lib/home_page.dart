import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:project_2/games/number_matching/number_matching_dashboard.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login _&_sighup/login_page.dart';
import 'games/neurogym.dart';
import 'games/path_finder/path_finder_dashboard.dart';

enum GameType { blackShelby, numberMatching, pathFinder }

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "NeuroGym Games",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _gameCard("Black Shelby", "assets/black_shelby.png", () {
            _navigateToGame(
              context,
              GameWidget(game: NeuroGym(gameType: GameType.blackShelby)),
            );
          }),

          _gameCard("Number Matching", "assets/number_matching.png", () {
            _navigateToGame(
              context,
              GameWidget<NeuroGym>(
                game: NeuroGym(gameType: GameType.numberMatching),
                overlayBuilderMap: {
                  'NumberMatchingDashboard': (context, game) =>
                      NumberMatchingDashboard(game: game),
                },
              ),
            );
          }),

          _gameCard("Path Finder", "assets/path_finder.png", () {
            _navigateToGame(
              context,
              GameWidget<NeuroGym>(
                game: NeuroGym(gameType: GameType.pathFinder),
                overlayBuilderMap: {
                  'PathFinderDashboard': (context, game) =>
                      PathFinderDashboard(game: game),
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  void _navigateToGame(BuildContext context, Widget gameWidget) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _centeredGameScreen(gameWidget)),
    );
  }

  Widget _centeredGameScreen(Widget gameWidget) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117), // Deeper dark theme
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
      ),
      body: Center(
        child: Container(
          // Allow the container to take up more space on the screen
          margin: const EdgeInsets.all(16),
          // Use ConstrainedBox to prevent the game from becoming infinitely large on tablets
          constraints: const BoxConstraints(
            maxWidth: 500, // Maximum width for the game area
            maxHeight: 1000, // Maximum height for the game area
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF161B22), // GitHub-style dark grey
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.6),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          // Padding inside the "frame"
          padding: const EdgeInsets.all(12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16), // Match container's vibe
            child: AspectRatio(
              // CHANGE THIS: 0.8 to 1.0 is ideal for grid games
              aspectRatio: 0.5,
              child: gameWidget,
            ),
          ),
        ),
      ),
    );
  }

  Widget _gameCard(String title, String image, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        color: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Added error handling for images
            Image.asset(
              image,
              height: 80,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.gamepad, size: 80, color: Colors.white24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
