import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';

class EmailVerificationSentPage extends StatefulWidget {
  final String email;
  const EmailVerificationSentPage({super.key, required this.email});

  @override
  State<EmailVerificationSentPage> createState() =>
      _EmailVerificationSentPageState();
}

class _EmailVerificationSentPageState extends State<EmailVerificationSentPage> {
  final otpController = TextEditingController();
  bool _loading = false;

  Future<void> verifyOtp() async {
    setState(() => _loading = true);

    final res = await Supabase.instance.client.auth.verifyOTP(
      email: widget.email,
      token: otpController.text.trim(),
      type: OtpType.signup,
    );

    setState(() => _loading = false);

    if (res.session != null) {
      await Supabase.instance.client.auth.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
            (_) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid OTP"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> resendOtp() async {
    await Supabase.instance.client.auth.resend(
      type: OtpType.signup,
      email: widget.email,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Enter Email OTP",
                style: TextStyle(color: Colors.white, fontSize: 22)),
            const SizedBox(height: 20),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "6 digit OTP",
                filled: true,
                fillColor: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : verifyOtp,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text("Verify"),
            ),
            TextButton(
              onPressed: resendOtp,
              child: const Text("Resend OTP",
                  style: TextStyle(color: Colors.cyan)),
            ),
          ],
        ),
      ),
    );
  }
}
