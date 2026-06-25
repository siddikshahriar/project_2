import 'dart:convert';
import 'package:hive/hive.dart';

class BlockBreakerLevels {
  static final BlockBreakerLevels instance = BlockBreakerLevels();

  /// Returns levels from Hive cache (filled by LevelSyncService when online).
  /// Falls back to the bundled list below when offline with no cache yet.
  List<Level> get levelList {
    try {
      final raw = Hive.box('block_breaker_levels_box').get('levels');
      if (raw != null) {
        final list = jsonDecode(raw as String) as List<dynamic>;
        //list.sort();
        if (list.isNotEmpty) {
          final parsedLevels = list.map<Level>((item) {
            final m = item as Map<String, dynamic>;
            final layout = (m['layout'] as List<dynamic>)
                .map<List<int>>(
                  (r) => (r as List<dynamic>)
                      .map((c) => (c as num).toInt())
                      .toList(),
                )
                .toList();
            return Level(
              levelId: (m['level_id'] as num).toInt(),
              layout: layout,
            );
          }).toList();
          parsedLevels.sort((a, b) => a.levelId.compareTo(b.levelId));
          return parsedLevels;
        }
      }
    } catch (_) {}
    return _bundled;
  }

  /// if the hive has no level yet then this level list will be shown
  static final List<Level> _bundled = [
    Level(
      levelId: 1,
      layout: [
        [1, 1, 1, 1, 1, 1, 1, 1],
        [2, 2, 2, 2, 2, 2, 2, 2],
        [3, 3, 3, 3, 3, 3, 3, 3],
        [4, 4, 4, 4, 4, 4, 4, 4],
        [3, 3, 3, 3, 3, 3, 3, 3],
        [2, 2, 2, 2, 2, 2, 2, 2],
        [1, 1, 1, 1, 1, 1, 1, 1],
      ],
    ),
  ];
}

class Level {
  final int levelId;
  final List<List<int>> layout;

  Level({required this.levelId, required this.layout});
}
