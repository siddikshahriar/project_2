import 'package:flame/components.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:project_2/router/router_config.dart';
import 'levels.dart';
import 'package:project_2/games/block_breaker/world.dart';

class BlockBreakerDashboard extends StatelessWidget {
  final BlockBreakerLevels allLevel = BlockBreakerLevels();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 1,
          ),
          itemCount: allLevel.levelList.length,
          itemBuilder: (context, index) {
            return _buildLevelCard(context, index + 1);
          },
        ),
      ),
    );
  }

  Widget _buildLevelCard(BuildContext context, levelNumber) {
    return InkWell(
      onTap: () {
        GoRouter.of(context).pushNamed(
          'block_breaker_gamescreen',
          pathParameters: {'level': levelNumber.toString()},
        );
      },

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
}
