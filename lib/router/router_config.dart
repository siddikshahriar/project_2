import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:project_2/home_page.dart';
import 'package:project_2/profile_page.dart';
import 'package:project_2/splash_screen.dart';
import 'package:project_2/login _&_sighup/login_page.dart';

/// Lets GoRouter "listen" to Supabase login/logout events, so routing
/// re-checks itself automatically whenever auth state changes.
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription _subscription;
  GoRouterRefreshStream(Stream stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class MyAppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(
      Supabase.instance.client.auth.onAuthStateChange,
    ),
    redirect: (context, state) {
      final loggedIn = Supabase.instance.client.auth.currentSession != null;
      final goingToLogin = state.matchedLocation == '/login';

      if (!loggedIn && !goingToLogin) return '/login';
      if (loggedIn && goingToLogin) return '/';
      return null;
    },
    routes: [
      GoRoute(
        name: 'home',
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        name: 'profile',
        path: '/profile_page',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        name: 'splash_screen',
        path: '/splash_screen',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        name: 'login',
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
    ],
  );
}
