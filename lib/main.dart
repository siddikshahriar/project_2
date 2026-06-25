import 'package:flutter/material.dart';
import 'package:project_2/router/router_config.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_links/app_links.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'splash_screen.dart';
import 'login _&_signup/reset_password_page.dart';
import 'login _&_signup/login_page.dart';
import 'home_page.dart';
import 'login _&_signup/forgot_password_page.dart';
import 'package:go_router/go_router.dart';
import 'package:project_2/services/level_sync_service.dart';
import 'package:project_2/services/progress_sync_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('game_progress_box');
  await Hive.openBox('games_catalog_box');
  await Hive.openBox('path_finder_levels_box');
  await Hive.openBox('block_breaker_levels_box');

  await Supabase.initialize(
    url: 'https://uvycbfdnjvzleikvcgzn.supabase.co',
    anonKey: 'sb_publishable_g7zFmsN835t9qAzbdqAhLw_vHT0yeJn',
  );

  /// download levels if online
  await LevelSyncService.syncLevels();

  /// start connectivity listener
  ProgressSyncService.start();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// When the user minimises or closes the app, push any unsaved
  /// local progress to Supabase immediately (if online).
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      ProgressSyncService.syncNow();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'NeuroGym',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      routerConfig: MyAppRouter.router,
    );
  }
}
