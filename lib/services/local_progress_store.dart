import 'package:hive/hive.dart';

/// Stores each game's progress on this device so the player can
/// continue even with no internet connection.
class LocalProgressStore {
  static const String _boxName = 'game_progress_box';

  static Box get _box => Hive.box(_boxName);

  /// Saves progress for one game. Stamps "now" and marks it unsynced
  /// so ProgressSyncService knows to push it up later.
  /// [gameKey] example: 'number_matching' or 'path_finder'
  static Future<void> saveProgress(String gameKey, Map<String, dynamic> data) async {
    final entry = {
      ...data,
      'updated_at': DateTime.now().toIso8601String(),
      'synced': false,
    };
    await _box.put(gameKey, entry);
  }

  /// Used only by ProgressSyncService when pulling newer data down
  /// from Supabase — keeps the cloud's own timestamp.
  static Future<void> saveRaw(String gameKey, Map<String, dynamic> fullEntry) async {
    await _box.put(gameKey, fullEntry);
  }

  /// Reads the saved progress for one game. Returns null if nothing saved yet.
  static Map<String, dynamic>? loadProgress(String gameKey) {
    final raw = _box.get(gameKey);
    if (raw == null) return null;
    return Map<String, dynamic>.from(raw as Map);
  }

  /// All game keys that have local progress.
  static List<String> allGameKeys() => _box.keys.cast<String>().toList();

  /// Marks a game's local entry as already synced to Supabase.
  static Future<void> markSynced(String gameKey) async {
    final raw = _box.get(gameKey);
    if (raw == null) return;
    final entry = Map<String, dynamic>.from(raw as Map);
    entry['synced'] = true;
    await _box.put(gameKey, entry);
  }
}
