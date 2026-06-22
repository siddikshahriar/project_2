import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Decides which games show up on the home page.
/// Online: reads the live list from Supabase (new games/levels show
/// up automatically on next launch, no app update needed).
/// Offline: shows whatever was last remembered, so the player is
/// never stuck on a blank screen.
class GamesCatalogService {
  static const String _boxName = 'games_catalog_box';
  static const String _cacheKey = 'last_known_games';

  /// Shown only the very first time the app is opened with no
  /// internet connection and nothing cached yet.
  static const List<Map<String, dynamic>> _bundledDefault = [
    {'game_key': 'black_shelby', 'title': 'Black Shelby'},
    {'game_key': 'number_matching', 'title': 'Number Matching'},
    {'game_key': 'path_finder', 'title': 'Path Finder'},
  ];

  static Future<List<Map<String, dynamic>>> fetchGames() async {
    final box = Hive.box(_boxName);

    try {
      final rows = await Supabase.instance.client
          .from('games_catalog')
          .select()
          .eq('is_active', true)
          .order('sort_order');

      final games = (rows as List)
          .map((r) => {
        'game_key': r['game_key'] as String,
        'title': r['title'] as String,
      })
          .toList();

      await box.put(_cacheKey, games);
      return games;
    } catch (_) {
      final cached = box.get(_cacheKey);
      if (cached != null) {
        return (cached as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }
      return _bundledDefault;
    }
  }
}
