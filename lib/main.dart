import 'package:flutter/material.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_links/app_links.dart';

import 'login_page.dart';
import 'home_page.dart';
import 'reset_password_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://uglqgzxgltwtaiwmgmsj.supabase.co',
    anonKey: 'sb_publishable_fJZ4dL13vCRdosLmGVmALQ_7AOkGNtJ',
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    _linkSubscription = _appLinks.uriLinkStream.listen((Uri uri) {
      _handleDeepLink(uri);
    });

    try {
      final Uri? initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        _handleDeepLink(initialLink);
      }
    } catch (e) {
      debugPrint('Error getting initial link: $e');
    }
  }

  void _handleDeepLink(Uri uri) {
    String? type;
    String? accessToken;

    // Supabase returns tokens in the URL fragment (#)
    if (uri.fragment.isNotEmpty) {
      final fragmentParams = Uri.splitQueryString(uri.fragment);
      type = fragmentParams['type'];
      accessToken = fragmentParams['access_token'];
    } else {
      type = uri.queryParameters['type'];
      accessToken = uri.queryParameters['access_token'];
    }

    if (accessToken != null) {
      if (type == 'recovery') {
        _setSessionAndNavigate(accessToken, isRecovery: true);
      } else {
        _setSessionAndNavigate(accessToken, isRecovery: false);
      }
    }
  }

  Future<void> _setSessionAndNavigate(String accessToken, {required bool isRecovery}) async {
    try {
      await Supabase.instance.client.auth.setSession(accessToken);

      if (isRecovery) {
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const ResetPasswordPage()),
              (route) => false,
        );
      } else {
        // Sign out after verification so they can log in manually
        await Supabase.instance.client.auth.signOut();

        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
              (route) => false,
        );

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (navigatorKey.currentContext != null) {
            ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
              const SnackBar(
                content: Text('Email verified successfully! Please login.'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 5),
              ),
            );
          }
        });
      }
    } catch (e) {
      debugPrint('Error setting session: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'NeuroGym',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text("NeuroGym", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}