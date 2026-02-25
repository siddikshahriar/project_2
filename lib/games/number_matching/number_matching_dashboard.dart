import 'package:flutter/material.dart';
import '../neurogym.dart';

class NumberMatchingDashboard extends StatelessWidget {
  final NeuroGym game;
  const NumberMatchingDashboard({super.key, required this.game});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.yellow.withOpacity(0.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Select Difficulty",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _difficultyButton(context, "Easy (3x3)", 3),
            _difficultyButton(context, "Medium (4x4)", 4),
            _difficultyButton(context, "Hard (5x5)", 5),
          ],
        ),
      ),
    );
  }

  Widget _difficultyButton(BuildContext context, String label, int size) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.yellow,
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 50),
        ),
        onPressed: () => game.startNumberMatchingGame(size),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
