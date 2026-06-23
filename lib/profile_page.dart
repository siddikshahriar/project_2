import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final supabase = Supabase.instance.client;

  final nameController = TextEditingController();
  final locationController = TextEditingController();
  final bioController = TextEditingController();
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();

  String? avatarUrl;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    nameController.dispose();
    locationController.dispose();
    bioController.dispose();
    oldPasswordController.dispose();
    newPasswordController.dispose();
    super.dispose();
  }

  // Load profile (show dummy data if not logged in)
  Future<void> _loadProfile() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      nameController.text = "Guest User";
      locationController.text = "Dhaka, Bangladesh";
      bioController.text = "Welcome to NeuroGym! Edit this profile.";
      setState(() => loading = false);
      return;
    }

    final first = user.userMetadata?['first_name'] ?? '';
    final last = user.userMetadata?['last_name'] ?? '';
    nameController.text = "$first $last".trim();

    try {
      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (data != null) {
        locationController.text = data['location'] ?? '';
        bioController.text = data['bio'] ?? '';
        avatarUrl = data['avatar_url'];
      } else {
        await supabase.from('profiles').insert({
          'id': user.id,
          'email': user.email,
        });
      }
    } catch (e) {
      print("Profile load error: $e");
      locationController.text = "Error loading location";
      bioController.text = "Error loading bio";
    } finally {
      setState(() => loading = false);
    }
  }

  // Pick image from gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    final user = supabase.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please login to change avatar")),
      );
      return;
    }

    final fileName = '${user.id}.png';

    try {
      await supabase.storage.from('profile_pictures').upload(
            fileName,
            File(file.path),
            fileOptions: const FileOptions(upsert: true),
          );

      final url = supabase.storage.from('profile_pictures').getPublicUrl(fileName);

      await supabase
          .from('profiles')
          .update({'avatar_url': url})
          .eq('id', user.id);

      setState(() => avatarUrl = url);
    } catch (e) {
      print("Upload failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image upload failed: $e")),
      );
    }
  }

  // Save profile and password changes
  Future<void> _saveProfile() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please login to save profile")),
      );
      return;
    }

    final email = user.email!;

    try {
      // Update profile table
      await supabase.from('profiles').update({
        'full_name': nameController.text.trim(),
        'location': locationController.text.trim(),
        'bio': bioController.text.trim(),
      }).eq('id', user.id);

      // Update auth metadata
      final names = nameController.text.trim().split(" ");
      await supabase.auth.updateUser(
        UserAttributes(data: {
          'first_name': names.first,
          'last_name': names.length > 1 ? names.sublist(1).join(" ") : '',
        }),
      );

      // Handle password change
      if (oldPasswordController.text.isNotEmpty &&
          newPasswordController.text.isNotEmpty) {
        try {
          await supabase.auth.signInWithPassword(
            email: email,
            password: oldPasswordController.text.trim(),
          );

          await supabase.auth.updateUser(
            UserAttributes(password: newPasswordController.text.trim()),
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Password updated successfully")),
          );
          oldPasswordController.clear();
          newPasswordController.clear();
        } catch (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Old password is incorrect")),
          );
          return;
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProfile,
            tooltip: 'Save',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            // Profile image and edit button
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage:
                        avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                    backgroundColor: Colors.grey,
                    child: avatarUrl == null
                        ? const Icon(Icons.person, size: 60, color: Colors.white)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.cyan,
                        child: const Icon(Icons.edit, size: 18, color: Colors.black),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                bioController.text,
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            _label("Full Name"),
            _field(nameController),
            _label("Email"),
            _readonlyField(supabase.auth.currentUser?.email ?? "guest@example.com"),
            _label("Old Password"),
            _field(oldPasswordController, hide: true),
            _label("New Password"),
            _field(newPasswordController, hide: true),
            _label("Location"),
            _field(locationController),
            _label("Bio (max 60 chars)"),
            _bioField(),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
              onPressed: _saveProfile,
              child: const Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widgets
  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white54, fontSize: 12),
      ),
    );
  }

  Widget _field(TextEditingController c, {bool hide = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        obscureText: hide,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[900],
        ),
      ),
    );
  }

  Widget _readonlyField(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        enabled: false,
        controller: TextEditingController(text: text),
        style: const TextStyle(color: Colors.white54),
        decoration: const InputDecoration(
          filled: true,
          fillColor: Colors.grey,
        ),
      ),
    );
  }

  Widget _bioField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: bioController,
        maxLength: 60,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[900],
        ),
      ),
    );
  }
}