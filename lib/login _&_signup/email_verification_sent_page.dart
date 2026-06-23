import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';
import 'package:go_router/go_router.dart';

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

    // setState updates UI when state variable changes (state management concept)
    setState(() => _loading = true);

    // Calling Supabase authentication method (using singleton instance object)
    final res = await Supabase.instance.client.auth.verifyOTP(
      email: widget.email, // Accessing parent widget's property (object communication)
      token: otpController.text.trim(), // Getting value from controller object
      type: OtpType.signup, // Enum type (OOP constant grouping concept)
    );

    // Updating state after async operation completes
    setState(() => _loading = false);

    // Checking if session object exists (conditional logic)
    if (res.session != null) {

      // Signing out user (calling method from auth object)
      await Supabase.instance.client.auth.signOut();

      // Navigating to LoginPage via GoRouter (clears the stack safely)
      context.go('/login');

    } else {

      // Showing SnackBar using ScaffoldMessenger object
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid OTP"),
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
              onPressed: _loading ? null : verifyOtp, // Function reference (method binding)
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
