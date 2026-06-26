import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() =>
      _SettingsPageState();
}

class _SettingsPageState
    extends State<SettingsPage> {
  final supabase = Supabase.instance.client;

  final locationController =
  TextEditingController();

  final oldPasswordController =
  TextEditingController();

  final newPasswordController =
  TextEditingController();

  bool saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() async {
    final user =
        supabase.auth.currentUser;

    if (user == null) return;

    final data = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (data != null) {
      locationController.text =
          data['location'] ?? '';
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _save() async {
    if (saving) return;

    final user =
        supabase.auth.currentUser;

    if (user == null) return;

    setState(() {
      saving = true;
    });

    try {
      await supabase
          .from('profiles')
          .update({
        'location':
        locationController.text,
      })
          .eq('id', user.id);

      if (oldPasswordController
          .text.isNotEmpty &&
          newPasswordController
              .text.isNotEmpty) {
        await supabase.auth
            .signInWithPassword(
          email: user.email!,
          password:
          oldPasswordController
              .text,
        );

        await supabase.auth
            .updateUser(
          UserAttributes(
            password:
            newPasswordController
                .text,
          ),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(
            content:
            Text("Saved"),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content:
            Text("$e"),
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        saving = false;
      });
    }
  }

  @override
  void dispose() {
    locationController.dispose();
    oldPasswordController.dispose();
    newPasswordController.dispose();
    super.dispose();
  }

  Widget label(String text) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 5,
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
        ),
      ),
    );
  }

  Widget field(
      TextEditingController c, {
        bool hide = false,
      }) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 20,
      ),
      child: TextField(
        controller: c,
        obscureText: hide,
        style: const TextStyle(
          color: Colors.white,
        ),
        decoration:
        InputDecoration(
          filled: true,
          fillColor:
          Colors.grey.shade900,
          border:
          OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(
              10,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(
      BuildContext context) {
    return Scaffold(
      backgroundColor:
      Colors.black,
      appBar: AppBar(
        backgroundColor:
        Colors.black,
        title:
        const Text("Settings"),
      ),
      body: Padding(
        padding:
        const EdgeInsets.all(
            20),
        child: ListView(
          children: [
            label("Location"),
            field(locationController),

            label(
                "Current Password"),
            field(
              oldPasswordController,
              hide: true,
            ),

            label(
                "New Password"),
            field(
              newPasswordController,
              hide: true,
            ),

            const SizedBox(
                height: 20),

            ElevatedButton(
              onPressed: saving
                  ? null
                  : _save,
              child: saving
                  ? const SizedBox(
                height: 20,
                width: 20,
                child:
                CircularProgressIndicator(),
              )
                  : const Text(
                "Save Changes",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
