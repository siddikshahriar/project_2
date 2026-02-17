import 'package:flutter/material.dart';
import 'login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  Future<void> _signup() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    try {
      final res = await Supabase.instance.client.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        data: {
          'first_name': firstNameController.text,
          'last_name': lastNameController.text,
        },
      );

      if (res.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            const Text("NeuroGym",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, color: Colors.white)),
            const SizedBox(height: 20),
            _field(firstNameController, "First Name"),
            _field(lastNameController, "Last Name"),
            _field(emailController, "Email"),
            _field(passwordController, "Password", hide: true),
            _field(confirmPasswordController, "Confirm Password", hide: true),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
              onPressed: _signup,
              child: const Text("Create Account"),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
              child:
              const Text("Sign in", style: TextStyle(color: Colors.green)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String h, {bool hide = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        obscureText: hide,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: h,
          filled: true,
          fillColor: Colors.grey,
        ),
      ),
    );
  }
}
