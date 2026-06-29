import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project_2/games/block_breaker/dashboard.dart';
import 'package:project_2/login%20_&_signup/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:project_2/home_page.dart';
import 'package:project_2/profile_page.dart';
import 'package:project_2/splash_screen.dart';
import 'route_name.dart';
import 'package:project_2/games/block_breaker/block_breaker.dart';
import 'package:project_2/games/pawn_king/game_rules.dart';
import 'package:project_2/games/pawn_king/playing_board.dart';

class MyAppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        name: RouteName.home,
        path: '/home_page',
        pageBuilder: (context, start) {
          return MaterialPage(child: HomePage());
        },
      ),

      GoRoute(
        name: RouteName.profile,
        path: '/profile_page',
        pageBuilder: (context, start) {
          return MaterialPage(child: ProfilePage());
        },
      ),

      GoRoute(
        name: RouteName.splashScreen,
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

      /////////////////////////// Block Breaker routes
      GoRoute(
        name: RouteName.blockBreakerGamescreen,
        path: '/block_breaker/:level',
        pageBuilder: (context, state) {
          // Extract the level string from path parameters and parse to integer
          final levelString = state.pathParameters['level'] ?? '1';
          final level = int.parse(levelString);
          final levelXP = (state.extra as int) ?? 0;
          return MaterialPage(
            child: GameScreen(level: level, levelXP: levelXP),
          );
        },
      ),
      GoRoute(
        name: RouteName.blockBreakerDashboard,
        path: '/games/block_breaker/dashboard',
        pageBuilder: (context, start) {
          return MaterialPage(child: BlockBreakerDashboard());
        },
      ),

      ////////////////////////// Pawn King routes
      GoRoute(
        name: RouteName.pawnKingGameRules,
        path: '/pawn_king/game_rules',
        pageBuilder: (context, start) {
          return MaterialPage(child: PawnKingGameRules());
        },
      ),
      GoRoute(
        name: RouteName.pawnKingPlayingBoard,
        path: '/pawn_king/playing_board',
        pageBuilder: (context, start) {
          return MaterialPage(child: PawnKingPlayingBoard());
        },
      ),
    ],
  );
}
