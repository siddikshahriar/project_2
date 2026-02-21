import 'package:flutter/material.dart';
import 'login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'email_verification_sent_page.dart';

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
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Regex patterns
  final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  final RegExp passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
  );

  final RegExp nameRegex = RegExp(r'^[a-zA-Z]{2,}$');

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateFirstName(String? value) {
    if (value == null || value.isEmpty) {
      return 'First name is required';
    }
    if (!nameRegex.hasMatch(value.trim())) {
      return 'First name must be at least 2 letters (no numbers or special characters)';
    }
    return null;
  }

  String? _validateLastName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Last name is required';
    }
    if (!nameRegex.hasMatch(value.trim())) {
      return 'Last name must be at least 2 letters (no numbers or special characters)';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (!passwordRegex.hasMatch(value)) {
      return 'Min 8 chars with uppercase, lowercase, number & special char';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final res = await Supabase.instance.client.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        emailRedirectTo: 'com.neurogym.app://callback',
        data: {
          'first_name': firstNameController.text.trim(),
          'last_name': lastNameController.text.trim(),
        },
      );

      debugPrint('Signup response: ${res.user?.id}');
      debugPrint('Signup session: ${res.session}');

      if (res.user != null) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => EmailVerificationSentPage(
                email: emailController.text.trim(),
              ),
            ),
          );
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text("NeuroGym",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, color: Colors.white)),
              const SizedBox(height: 20),
              _field(firstNameController, "First Name", validator: _validateFirstName),
              _field(lastNameController, "Last Name", validator: _validateLastName),
              _field(emailController, "Email", validator: _validateEmail),
              _field(passwordController, "Password", hide: true, validator: _validatePassword),
              _field(confirmPasswordController, "Confirm Password", hide: true, validator: _validateConfirmPassword),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
                onPressed: _isLoading ? null : _signup,
                child: _isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Text("Create Account"),
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
      ),
    );
  }

  Widget _field(TextEditingController c, String h, {bool hide = false, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        obscureText: hide,
        validator: validator,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: h,
          filled: true,
          fillColor: Colors.grey,
          errorStyle: const TextStyle(color: Colors.redAccent),
        ),
      ),
    );
  }
}
