import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'settings_page.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:project_2/services/local_progress_store.dart';

class GameProgress {
  final String gameName;
  final int passedLevels;
  final int xp;

  GameProgress({
    required this.gameName,
    required this.passedLevels,
    required this.xp,
  });
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final supabase = Supabase.instance.client;
  final nameController = TextEditingController();

  String? avatarUrl;

  bool loading = true;
  bool uploadingAvatar = false;

  List<GameProgress> gameStats = [];

  int get totalXP => gameStats.fold(0, (sum, item) => sum + item.xp);

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      nameController.text = "Guest User";
      _loadLocalHiveData();
      if (mounted) {
        setState(() => loading = false);
      }
      return;
    }

    // Set initial fallback name from metadata
    final first = user.userMetadata?['first_name'] ?? '';
    final last = user.userMetadata?['last_name'] ?? '';
    nameController.text = "$first $last".trim();

    // 1. Isolated network call so offline errors won't block local state
    try {
      final profileData = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (profileData != null) {
        avatarUrl = profileData['avatar_url'];
      }
    } catch (e) {
      print("Network error loading profile details: $e");
    }

    // 2. Always execute Hive data loading independently of network status
    _loadLocalHiveData();

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  // Helper method dedicated to loading local progress data safely
  void _loadLocalHiveData() {
    try {
      final box = Hive.box('game_progress_box');
      List<GameProgress> temporaryStats = [];

      for (final key in box.keys) {
        final data = box.get(key);

        if (data is Map) {
          temporaryStats.add(
            GameProgress(
              gameName: key.toString(),
              passedLevels: (data['lastLevel'] ?? 0) as int,
              xp: (data['gameXP'] ?? 0) as int,
            ),
          );
        }
      }
      gameStats = temporaryStats;
    } catch (e) {
      print("Error loading local Hive data: $e");
    }
  }

  Future<void> _pickImage() async {
    if (uploadingAvatar) return;

    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);

    if (file == null) return;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    setState(() {
      uploadingAvatar = true;
    });

    try {
      final fileName = '${user.id}.png';

      await supabase.storage
          .from('profile_pictures')
          .upload(
            fileName,
            File(file.path),
            fileOptions: const FileOptions(upsert: true),
          );

      final url = supabase.storage
          .from('profile_pictures')
          .getPublicUrl(fileName);

      await supabase
          .from('profiles')
          .update({'avatar_url': url})
          .eq('id', user.id);

      if (mounted) {
        setState(() {
          avatarUrl = url;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to upload avatar. Check your connection."),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          uploadingAvatar = false;
        });
      }
    }
  }

  Widget _gameCard(GameProgress game) {
    return Card(
      color: Colors.grey.shade900,
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.cyan,
          child: Icon(Icons.sports_esports, color: Colors.black),
        ),
        title: Text(
          game.gameName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          "Passed ${game.passedLevels} Levels",
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("XP", style: TextStyle(color: Colors.cyan)),
            Text(
              "${game.xp}",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final email = supabase.auth.currentUser?.email ?? "guest@example.com";

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey,
                  backgroundImage: avatarUrl != null
                      ? NetworkImage(avatarUrl!)
                      : null,
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
                      child: uploadingAvatar
                          ? const SizedBox(
                              height: 15,
                              width: 15,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.edit, color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Center(
            child: Text(
              nameController.text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Center(
            child: Text(email, style: const TextStyle(color: Colors.white70)),
          ),
          const SizedBox(height: 25),
          Card(
            color: Colors.cyan,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text("TOTAL XP", style: TextStyle(fontSize: 18)),
                  Text(
                    "$totalXP",
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Game Progress",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          gameStats.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      "No game data available.",
                      style: TextStyle(color: Colors.white60),
                    ),
                  ),
                )
              : Column(children: gameStats.map((e) => _gameCard(e)).toList()),
        ],
      ),
    );
  }
}
