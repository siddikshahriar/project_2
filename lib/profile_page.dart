import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Profile"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: ${user?.userMetadata?['first_name']} ${user?.userMetadata?['last_name']}",
                style: const TextStyle(color: Colors.white)),
            Text("Email: ${user?.email}", style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan,
              ),
              onPressed: () async {
                await Supabase.instance.client.auth.updateUser(
                  UserAttributes(password: "newPasswordHere"),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Password changed")),
                );
              },
              child: const Text("Change Password"),
            ),
          ],
        ),
      ),
    );
  }
}
