import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'local_progress_store.dart';

/// Keeps the on-device game progress and the Supabase 'game_progress'
/// table in sync. Local storage is always the source of truth while
/// offline; this only talks to the network when a connection exists.
class ProgressSyncService {
  static StreamSubscription<List<ConnectivityResult>>? _sub;

  /// Call this once, when HomePage opens (covers both "just logged in"
  /// and "already had a session from last time" cases).
  static void start() {
    syncNow(); // try immediately in case we're already online

    _sub?.cancel();
    _sub = Connectivity().onConnectivityChanged.listen((results) {
      final hasNetwork = results.any((r) => r != ConnectivityResult.none);
      if (hasNetwork) syncNow();
    });
  }

  static void stop() {
    _sub?.cancel();
    _sub = null;
  }

  /// Pushes any unsynced local progress up, then pulls down anything
  /// newer from the cloud. Safe to call any time — quietly does
  /// nothing if there's no internet or no logged-in user.
  static Future<void> syncNow() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      await _pushLocalChanges(user.id);
      await _pullCloudChanges(user.id);
    } catch (_) {
      // no internet, or Supabase unreachable - stay on local data
    }
  }

  static Future<void> _pushLocalChanges(String userId) async {
    for (final gameKey in LocalProgressStore.allGameKeys()) {
      final local = LocalProgressStore.loadProgress(gameKey);
      if (local == null || local['synced'] == true) continue;

      final updatedAt = local['updated_at'] as String;
      final progressData = Map<String, dynamic>.from(local)
        ..remove('synced')
        ..remove('updated_at');

      await Supabase.instance.client.from('game_progress').upsert({
        'user_id': userId,
        'game_key': gameKey,
        'progress': progressData,
        'updated_at': updatedAt,
      }, onConflict: 'user_id,game_key');

      await LocalProgressStore.markSynced(gameKey);
    }
  }

  static Future<void> _pullCloudChanges(String userId) async {
    final rows = await Supabase.instance.client
        .from('game_progress')
        .select()
        .eq('user_id', userId);

    for (final row in rows as List) {
      final gameKey = row['game_key'] as String;
      final cloudUpdatedAt = DateTime.parse(row['updated_at'] as String);
      final local = LocalProgressStore.loadProgress(gameKey);
      final localUpdatedAt = local != null
          ? DateTime.parse(local['updated_at'] as String)
          : DateTime.fromMillisecondsSinceEpoch(0);

      // only overwrite the phone's copy if the cloud copy is newer
      if (cloudUpdatedAt.isAfter(localUpdatedAt)) {
        final progress = Map<String, dynamic>.from(row['progress'] as Map);
        await LocalProgressStore.saveRaw(gameKey, {
          ...progress,
          'updated_at': row['updated_at'],
          'synced': true,
        });
      }
    }
  }
}
