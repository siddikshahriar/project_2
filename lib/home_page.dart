import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:project_2/games/number_matching/dashboard.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'games/neurogym.dart';
import 'games/path_finder/dashboard.dart';
import 'profile_page.dart';
import 'games/block_breaker/dashboard.dart';
import 'games/pawn_king/dashboard.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

enum GameType { blockBreaker, numberMatching, pathFinder }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = "Guest";
  int totalXP = 0;
  bool isLoading = true;
  final user = Supabase.instance.client.auth.currentUser;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  String _safeAreaText() {
    return user != null ? "Select a Mission" : "log in to save progress";
  }

  Future<void> _fetchUserData() async {
    // A. Fetch username from Supabase Metadata
    final user = Supabase.instance.client.auth.currentUser;
    String firstName = 'Guest';
    if (user != null) {
      firstName = user.userMetadata?['first_name'] ?? 'Guest';
    }

    // B. Calculate dynamic XP from Hive 'game_progress_box'
    int calculatedXP = 0;
    try {
      if (Hive.isBoxOpen('game_progress_box')) {
        final box = Hive.box('game_progress_box');

        for (var item in box.values) {
          if (item is Map) {
            calculatedXP += (item['gameXP'] as num? ?? 0).toInt();
          } else if (item is num) {
            calculatedXP += item.toInt();
          }
        }
      } else {
        // Fallback open if it's not open yet
        final box = await Hive.openBox('game_progress_box');
        for (var item in box.values) {
          if (item is Map) {
            calculatedXP += (item['gameXP'] as num? ?? 0).toInt();
          } else if (item is num) {
            calculatedXP += item.toInt();
          }
        }
      }
    } catch (e) {
      print("Error fetching dynamic XP from Hive: $e");
    }

    if (mounted) {
      setState(() {
        userName = firstName;
        totalXP =
            calculatedXP; // 3. Update the UI state with local storage values
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D0D0D), Color(0xFF1A2A40), Color(0xFF00FFFF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCustomHeader(context),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Text(
                  _safeAreaText(),
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 16,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.cyan),
                      )
                    : GridView.count(
                        crossAxisCount: 2,
                        padding: const EdgeInsets.all(20),
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        children: [
                          _gameCard(
                            "Block Breaker",
                            "assets/icons/block_breaker.png",
                            () {
                              _navigateToGame(context, BlockBreakerDashboard());
                            },
                          ),
                          _gameCard(
                            "Number Matching",
                            "assets/icons/number_matching.png",
                            () {
                              _navigateToGame(
                                context,
                                GameWidget<NeuroGym>(
                                  game: NeuroGym(
                                    gameType: GameType.numberMatching,
                                  ),
                                  overlayBuilderMap: {
                                    'NumberMatchingDashboard':
                                        (context, game) =>
                                            NumberMatchingDashboard(game: game),
                                  },
                                ),
                              );
                            },
                          ),
                          _gameCard(
                            "Path Finder",
                            "assets/icons/path_finder.png",
                            () {
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
                            },
                          ),
                          _gameCard(
                            "Pawn King",
                            "assets/icons/pawn_king.png",
                            () {
                              _navigateToGame(context, PawnKingDashboard());
                            },
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "NeuroGym",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    userName,
                    style: const TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.cyan.withOpacity(0.2),
                      border: Border.all(color: Colors.cyan, width: 1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.flash_on,
                          color: Colors.cyanAccent,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "$totalXP XP",
                          style: const TextStyle(
                            color: Colors.cyanAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfilePage()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.cyan, width: 2),
                  ),
                  child: const CircleAvatar(
                    backgroundColor: Colors.black45,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white70),
                onPressed: () async {
                  await Supabase.instance.client.auth.signOut();
                  if (context.mounted) {
                    GoRouter.of(context).goNamed('login');
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToGame(BuildContext context, Widget gameWidget) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _centeredGameScreen(gameWidget)),
    );
    _fetchUserData();
  }

  Widget _centeredGameScreen(Widget gameWidget) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        title: const Text('Dashboard'),
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

  Widget _gameCard(String title, String image, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.grey.shade900, Colors.black],
          ),
          border: Border.all(color: Colors.cyan.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.cyan.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              image,
              height: 75,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.sports_esports,
                size: 75,
                color: Colors.white24,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
