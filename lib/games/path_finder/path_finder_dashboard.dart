import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:project_2/games/neurogym.dart';
import 'package:project_2/games/path_finder/pathfinder_levels.dart';

class PathFinderDashboard extends StatefulWidget {
  final NeuroGym game;
  const PathFinderDashboard({super.key, required this.game});
  @override
  State<PathFinderDashboard> createState() => _PathFinderDashboardState();
}

class _PathFinderDashboardState extends State<PathFinderDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1D23),
      appBar: AppBar(
        title: const Text(
          'Pathfinder Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF23272F),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 1,
          ),
          itemCount: PathFinderLevels.levels.length,
          itemBuilder: (context, index) {
            final level = PathFinderLevels.levels[index];
            return _buildLevelCard(index + 1, level);
          },
        ),
      ),
    );
  }

  Widget _buildLevelCard(int levelNumber, dynamic levelData) {
    return InkWell(
      onTap: () => _startLevel(levelData),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2D323E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.blueAccent.withOpacity(0.4),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map_rounded, color: Colors.blueAccent, size: 40),
            const SizedBox(height: 12),
            Text(
              'Level $levelNumber',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startLevel(dynamic levelData) {
    widget.game.startPathFinder(levelData);
  }
}
