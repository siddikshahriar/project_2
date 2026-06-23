import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:project_2/games/number_matching/dashboard.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'games/neurogym.dart';
import 'games/path_finder/dashboard.dart';
import 'profile_page.dart';
import 'games/block_breaker/dashboard.dart';
import 'package:go_router/go_router.dart';

enum GameType { blockBreaker, numberMatching, pathFinder }

/// homepage is where all the available games are listed
class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    //print("HomePage build called");
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "NeuroGym Games",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const CircleAvatar(
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, color: Colors.white),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            );
          },
        ),
        actions: [
          /// the signout button
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) {
                GoRouter.of(context).goNamed('login');
              }
            },
          ),
        ],
      ),

      /// all the games are listed in a grid view containing 2 columns for each row
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _gameCard("Block Breaker", "assets/icons/block_breaker.png", () {
            _navigateToGame(
              context,
              BlockBreakerDashboard(),
              //GameWidget(game: NeuroGym(gameType: GameType.blockBreaker)),
            );
          }),

          _gameCard("Number Matching", "assets/icons/number_matching.png", () {
            _navigateToGame(
              context,
              GameWidget<NeuroGym>(
                /// creates a game instance of type numbermatching which extends FlameGame
                game: NeuroGym(gameType: GameType.numberMatching),

                /// overlay for dashboard and additonal buttons to show over game world
                overlayBuilderMap: {
                  'NumberMatchingDashboard': (context, game) =>
                      NumberMatchingDashboard(game: game),
                },
              ),
            );
          }),

          _gameCard("Path Finder", "assets/icons/path_finder.png", () {
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

  /// and additional game screen where each game will show up
  Widget _centeredGameScreen(Widget gameWidget) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117), // Deeper dark theme
      appBar: AppBar(
        title: Text('Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(4),
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 1800),
          decoration: BoxDecoration(
            color: const Color(0xFF161B22),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.6),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(5),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(aspectRatio: 0.5, child: gameWidget),
          ),
        ),
      ),
    );
  }

  /// makes a rectangular card for each game
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
            Image.asset(
              image,
              height: 100,
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
