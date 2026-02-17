import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("NeuroGym Games"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
              );
            },
          )
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        children: [
          _gameCard("Black Shelby", "assets/black_shelby.png"),
          _gameCard("Number Matching", "assets/number_matching.png"),
          _gameCard("Path Finder", "assets/path_finder.png"),
        ],
      ),
    );
  }

  Widget _gameCard(String title, String image) {
    return Card(
      color: Colors.grey[900],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(image, height: 100),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
