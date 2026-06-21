import 'package:flutter/material.dart';
import 'package:project_2/router/router_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://uglqgzxgltwtaiwmgmsj.supabase.co',
    anonKey: 'sb_publishable_fJZ4dL13vCRdosLmGVmALQ_7AOkGNtJ',
  );

  runApp(const MyApp());
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'NeuroGym',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData.dark(),
//       home: const SplashScreen(),
//       routes: {
//         '/forgot-password': (_) =>
//             const ForgotPasswordPage(), // <-- route for forgot password
//       },
//     );
//   }
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'NeuroGym',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      routeInformationParser: MyAppRouter().router.routeInformationParser,
      routerDelegate: MyAppRouter().router.routerDelegate,
    );
  }
}
