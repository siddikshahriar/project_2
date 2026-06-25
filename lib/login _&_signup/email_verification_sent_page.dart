import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';
import 'package:go_router/go_router.dart';
import 'package:project_2/router/router_config.dart';

// Defining a StatefulWidget class (Blueprint for a screen with mutable state)
class EmailVerificationSentPage extends StatefulWidget {
  // Instance variable (encapsulation: holds email passed from previous screen)
  final String email;

  // Constructor of the class (used to create object of this widget)
  const EmailVerificationSentPage({super.key, required this.email});

  // Overriding method from StatefulWidget to create associated State object
  @override
  State<EmailVerificationSentPage> createState() =>
      _EmailVerificationSentPageState();
}

// State class (handles mutable state and logic of the widget)
// "_" makes it private to this file (data hiding concept in OOP)
class _EmailVerificationSentPageState extends State<EmailVerificationSentPage> {
  // Creating an object of TextEditingController (object manages OTP input)
  final otpController = TextEditingController();

  // Boolean state variable (controls loading state of UI)
  bool _loading = false;

  // Asynchronous method (object behavior / class function)
  Future<void> verifyOtp() async {
    setState(() => _loading = true);

    try {
      final res = await Supabase.instance.client.auth.verifyOTP(
        email: widget.email,
        token: otpController.text.trim(),
        type: OtpType.signup,
      );

      setState(() => _loading = false);

      if (res.session != null) {
        await Supabase.instance.client.auth.signOut();

        // --- THE FIX: Guard the async gap ---
        //if (!mounted) return;

        // Now it is safe to use context
        MyAppRouter.router.goNamed('login');
      } else {
        // --- THE FIX: Guard this async gap too ---
        //if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Invalid OTP"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Catching network/server errors during verification
      //if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Another asynchronous method (class behavior)
  Future<void> resendOtp() async {
    // Calling resend method from Supabase auth object
    await Supabase.instance.client.auth.resend(
      type: OtpType.signup,
      email: widget.email,
    );
  }

  // Overriding build method from State class (polymorphism)
  @override
  Widget build(BuildContext context) {
    // Returning Scaffold object (UI structure class)
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(24),

        // Column is a widget object that arranges child widgets vertically
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Text widget object
            const Text(
              "Enter Email OTP",
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),

            const SizedBox(height: 20),

            // TextField object for OTP input
            TextField(
              controller: otpController, // Attaching controller object
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "6 digit OTP",
                filled: true,
                fillColor: Colors.grey,
              ),
            ),

            const SizedBox(height: 20),

            // ElevatedButton object
            ElevatedButton(
              onPressed: _loading
                  ? null
                  : verifyOtp, // Function reference (method binding)
              child: _loading
                  ? const CircularProgressIndicator() // Object shown during loading
                  : const Text("Verify"),
            ),

            // TextButton object
            TextButton(
              onPressed: resendOtp, // Calling resendOtp method
              child: const Text(
                "Resend OTP",
                style: TextStyle(color: Colors.cyan),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
