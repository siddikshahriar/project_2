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

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // local, on-device storage for offline game progress and the
  // last-known list of games (used when there is no internet)
  await Hive.initFlutter();
  await Hive.openBox('game_progress_box');
  await Hive.openBox('games_catalog_box');

  // await Supabase.initialize(
  //   url: 'https://uvycbfdnjvzleikvcgzn.supabase.co',
  //   anonKey: 'sb_publishable_g7zFmsN835t9qAzbdqAhLw_vHT0yeJn',
  // );
  await Supabase.initialize(
    url: 'https://uvycbfdnjvzleikvcgzn.supabase.co',
    anonKey: 'sb_publishable_g7zFmsN835t9qAzbdqAhLw_vHT0yeJn',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
