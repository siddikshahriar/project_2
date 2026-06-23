import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project_2/login%20_&_signup/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:project_2/home_page.dart';
import 'package:project_2/profile_page.dart';
import 'package:project_2/splash_screen.dart';
import 'router_constants.dart';
import 'package:project_2/games/block_breaker/game_screen.dart';

// 1. UTILITY CLASS: Implements Listenable to convert streams safely for GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
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

    // refreshListenable: GoRouterRefreshStream(
    //   Supabase.instance.client.auth.onAuthStateChange,
    // ),
    // redirect: (context, state) {
    //   final loggedIn = Supabase.instance.client.auth.currentSession != null;
    //   final goingToLogin = state.matchedLocation == '/login';

    //   if (!loggedIn && !goingToLogin) return '/login';
    //   if (loggedIn && goingToLogin) return '/';
    //   return null;
    // },
    routes: [
      GoRoute(
        name: RouteConstants.homeRouteName,
        path: '/home_page',
        pageBuilder: (context, start) {
          return MaterialPage(child: HomePage());
        },
      ),
      GoRoute(
        name: RouteConstants.profileRouteName,
        path: '/profile_page',
        pageBuilder: (context, start) {
          return MaterialPage(child: ProfilePage());
        },
      ),
      GoRoute(
        name: 'splash_screen',
        path: '/',
        pageBuilder: (context, start) {
          return MaterialPage(child: SplashScreen());
        },
      ),
      GoRoute(
        name: 'login',
        path: '/login',
        pageBuilder: (context, start) {
          return MaterialPage(child: LoginPage());
        },
      ),

      GoRoute(
        name: 'block_breaker_gamescreen',
        path: '/block_breaker/:level',
        pageBuilder: (context, state) {
          // Extract the level string from path parameters and parse to integer
          final levelString = state.pathParameters['level'] ?? '1';
          final level = int.parse(levelString);
          return MaterialPage(child: GameScreen(level: level));
        },
      ),
    ],
  );
}
