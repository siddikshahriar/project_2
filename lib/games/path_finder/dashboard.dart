import 'package:flutter/material.dart';
import 'package:project_2/games/neurogym.dart';
import 'package:project_2/games/path_finder/levels.dart';
import 'package:project_2/services/local_progress_store.dart';

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
            final levelData = PathFinderLevels.levels[index];
            final levelXP = levelData.levelXP;
            final levelID = levelData.id;
            return _buildLevelCard(levelID, levelXP, levelData);
          },
        ),
      ),
    );
  }

  Widget _buildLevelCard(int levelID, int levelXP, dynamic levelData) {
    // Read completed levels from local Hive storage
    final progress = LocalProgressStore.loadProgress('path_finder');
    int lastLevel = progress?['lastLevel'] as int? ?? 0;
    int gameXP = progress?['gameXP'] as int? ?? 0;
    bool isDone = levelID <= lastLevel;

    return InkWell(
      onTap: () => levelID > lastLevel + 1
          ? ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '!complete previous levels!',
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
            )
          : widget.game.startPathFinder(levelData, levelID, levelXP),

      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2D323E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDone
                ? Colors.greenAccent.withOpacity(0.7)
                : Colors.blueAccent.withOpacity(0.4),
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
            Stack(
              alignment: Alignment.topRight,
              clipBehavior: Clip.none, // Prevents checkmark clipping
              children: [
                Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    isDone
                        ? Icons.check_circle
                        : levelID == lastLevel + 1
                        ? Icons.lock_open
                        : Icons.lock,
                    color: isDone
                        ? Colors.green
                        : levelID == lastLevel + 1
                        ? Colors.green
                        : Colors.red,
                    size: 40,
                  ),
                ),
              ],
            ),
            Text(
              '$levelXP XP',
              style: const TextStyle(
                color: Color(0xFFFFDF00),
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
            Text(
              'Level $levelID',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
