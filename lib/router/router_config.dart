import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project_2/home_page.dart';

class MyAppRouter {
  GoRouter router = GoRouter(
    routes: [
      GoRoute(
        name: 'home',
        path: '/',
        pageBuilder: (context, start) {
          return MaterialPage(child: HomePage());
        },
      ),

      GoRoute(
        name: 'profile',
        path: '/profile_page',
        pageBuilder: (context, start) {
          return MaterialPage(child: HomePage());
        },
      ),

      GoRoute(
        name: 'splash_screen',
        path: '/splash_screen',
        pageBuilder: (context, start) {
          return MaterialPage(child: HomePage());
        },
      ),
    ],
  );
}
