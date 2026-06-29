import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PawnKingDashboard extends StatelessWidget {
  const PawnKingDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 280,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                    elevation: 4,
                  ),
                  onPressed: () {
                    GoRouter.of(context).pushNamed('pawn_king_playing_board');
                  },
                  child: const Row(
                    //mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 25),
                      Icon(Icons.play_arrow, size: 24),
                      SizedBox(width: 8),
                      Text('PLAY GAME'),
                      SizedBox(width: 20),
                      Text('100+ XP', style: TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Game Rules Button
              SizedBox(
                width: 280,
                height: 56,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    //side: Border.all(color: Colors.white30, width: 1.5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  onPressed: () {
                    GoRouter.of(context).pushNamed('pawn_king_game_rules');
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.menu_book, size: 20, color: Colors.white70),
                      SizedBox(width: 8),
                      Text('Game Rules'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
