import 'package:flutter/material.dart';

class PawnKingGameRules extends StatelessWidget {
  const PawnKingGameRules({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        title: const Text(
          'Game Rules',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: 500),
          decoration: BoxDecoration(
            color: const Color(0xFF161B22),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.cyan.withOpacity(0.2), width: 1.5),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildRuleRow(
                  Icons.people,
                  'The game is played by two players.',
                ),
                _buildRuleRow(
                  Icons.grid_4x4,
                  'There are 16 pawns in total (8 for each player).',
                ),
                _buildRuleRow(
                  Icons.flag,
                  'The objective is to guide a pawn safely to the opponent\'s back row.',
                ),
                _buildRuleRow(
                  Icons.emoji_events,
                  'The first player to advance at least one pawn into the opposite last row wins the game.',
                ),
                _buildRuleRow(
                  Icons.navigation,
                  'Pawns move forward exactly 1 cell. They capture enemy pawns diagonally 1 cell forward.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRuleRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.cyanAccent, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
