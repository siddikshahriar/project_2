import 'package:flutter/material.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_links/app_links.dart';
import 'splash_screen.dart';
import 'login _&_sighup/reset_password_page.dart';
import 'login _&_sighup/login_page.dart';
import 'home_page.dart';
import 'login _&_sighup/forgot_password_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://uglqgzxgltwtaiwmgmsj.supabase.co',
    anonKey: 'sb_publishable_fJZ4dL13vCRdosLmGVmALQ_7AOkGNtJ',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NeuroGym',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const SplashScreen(),
      routes: {
        '/forgot-password': (_) =>
            const ForgotPasswordPage(), // <-- route for forgot password
      },
    );
  }
}
