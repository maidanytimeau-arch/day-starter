import 'package:flutter/material.dart';

class AddMealScreen extends StatelessWidget {
  const AddMealScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Meal'),
      ),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class FoodHistoryScreen extends StatelessWidget {
  const FoodHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food History'),
      ),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class LogReactionScreen extends StatelessWidget {
  const LogReactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Reaction'),
      ),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class PoopLogScreen extends StatelessWidget {
  const PoopLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Poop Log'),
      ),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class ProfilesScreen extends StatelessWidget {
  const ProfilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profiles & Family'),
      ),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
