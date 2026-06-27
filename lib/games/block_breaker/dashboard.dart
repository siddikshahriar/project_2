import 'package:flame/components.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:project_2/router/router_config.dart';
import 'levels.dart';
import 'package:project_2/games/block_breaker/world.dart';
import 'package:project_2/services/local_progress_store.dart';

class BlockBreakerDashboard extends StatelessWidget {
  final List<Level> allLevel = BlockBreakerLevels.instance.levelList;

  BlockBreakerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Load progress ONCE here, instead of inside the loop
    final progress = LocalProgressStore.loadProgress('block_breaker');
    final completedLevels = progress != null
        ? List<int>.from(progress['completed_levels'] ?? [])
        : <int>[];

    return Scaffold(
      backgroundColor: const Color(
        0xFF1E222D,
      ), // Optional: sleek dark background match
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 1,
          ),
          itemCount: allLevel.length,
          itemBuilder: (context, index) {
            // 2. Grab the actual target level object
            final currentLevel = allLevel[index];
            final isDone = completedLevels.contains(currentLevel.levelId);
            final levelXP = currentLevel.levelXP;

            return _buildLevelCard(
              context,
              currentLevel.levelId,
              levelXP,
              isDone,
            );
          },
        ),
      ),
    );
  }

  // 3. Strongly typed parameters and separation of concerns
  Widget _buildLevelCard(
    BuildContext context,
    int levelId,
    int levelXP,
    bool isDone,
  ) {
    return InkWell(
      onTap: () {
        GoRouter.of(context).pushNamed(
          'block_breaker_gamescreen',
          pathParameters: {'level': levelId.toString()},
          extra: isDone ? 0 : levelXP,
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 8, 13, 23),
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
                const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.map_rounded,
                    color: Colors.blueAccent,
                    size: 40,
                  ),
                ),
                if (isDone)
                  const Positioned(
                    top: -2,
                    right: -2,
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.greenAccent,
                      size: 18,
                    ),
                  ),
              ],
            ),
            Text(
              'XP: $levelXP',
              style: const TextStyle(
                color: Color(0xFFFFDF00),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Level $levelId',
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
}
