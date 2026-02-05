import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/providers/service_providers.dart';
import '../services/providers/auth_providers.dart';
import '../routes/app_routes.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileServiceProvider);
    final mealAsync = ref.watch(mealServiceProvider);
    final reactionAsync = ref.watch(reactionServiceProvider);
    final poopAsync = ref.watch(poopServiceProvider);

    return profileAsync.when(
      data: (profileService) {
        return FutureBuilder(
          future: _loadData(profileService, mealAsync, reactionAsync, poopAsync),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final data = snapshot.data;
            if (data == null) {
              return const Scaffold(
                body: Center(child: Text('Error loading data')),
              );
            }

            final profile = data['profile'];
            final todayMeals = data['todayMeals'] as List;
            final recentReactions = data['recentReactions'] as List;
            final recentPoopLogs = data['recentPoopLogs'] as List;

            return Scaffold(
              appBar: AppBar(
                title: const Text('LittleBites'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {
                      // TODO: Navigate to notifications
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.person_outline),
                    onPressed: () {
                      AppNavigator.navigateTo(context, AppRoutes.profiles);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () {
                      ref.read(authServiceProvider).signOut();
                    },
                  ),
                ],
              ),
              drawer: _buildDrawer(context),
              body: RefreshIndicator(
                onRefresh: () async {
                  // Refresh providers
                  ref.invalidate(profileServiceProvider);
                  ref.invalidate(mealServiceProvider);
                  ref.invalidate(reactionServiceProvider);
                  ref.invalidate(poopServiceProvider);
                },
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Date and weather
                    _buildDateHeader(),
                    const SizedBox(height: 20),

                    // Today's Meals
                    _buildSectionHeader('🍽️ Today\'s Meals', onTap: () => AppNavigator.navigateTo(context, AppRoutes.foodHistory)),
                    const SizedBox(height: 8),
                    if (todayMeals.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: Text(
                              'No meals logged today',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      )
                    else
                      ...todayMeals.map((meal) => _buildMealCard(context, meal)).toList(),
                    const SizedBox(height: 20),

                    // Recent Reactions
                    if (recentReactions.isNotEmpty) ...[
                      _buildSectionHeader('⚠️ Recent Reactions', onTap: () => AppNavigator.navigateTo(context, AppRoutes.logReaction)),
                      const SizedBox(height: 8),
                      ...recentReactions.take(2).map((reaction) => _buildReactionCard(context, reaction)),
                      const SizedBox(height: 20),
                    ],

                    // Recent Poop Logs
                    if (recentPoopLogs.isNotEmpty) ...[
                      _buildSectionHeader('💩 Poop Log', onTap: () => AppNavigator.navigateTo(context, AppRoutes.poopLog)),
                      const SizedBox(height: 8),
                      ...recentPoopLogs.take(1).map((poop) => _buildPoopCard(context, poop)),
                      const SizedBox(height: 20),
                    ],

                    // Stats summary
                    _buildStatsCard(profile),
                  ],
                ),
              ),
              floatingActionButton: FloatingActionButton.extended(
                onPressed: () {
                  AppNavigator.navigateTo(context, AppRoutes.addMeal);
                },
                backgroundColor: const Color(0xFF4A90E2),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Log Meal', style: TextStyle(color: Colors.white)),
              ),
            );
          },
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
            ],
          ),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _loadData(
    dynamic profileService,
    AsyncValue mealAsync,
    AsyncValue reactionAsync,
    AsyncValue poopAsync,
  ) async {
    // Get active profile
    final profile = await profileService.getActiveProfile();

    // Get meals, reactions, and poop logs (use sync providers or handle async)
    List todayMeals = [];
    List recentReactions = [];
    List recentPoopLogs = [];

    // Check if providers are ready
    if (mealAsync.value != null && profile != null) {
      todayMeals = await mealAsync.value!.getTodayMeals(profile.id);
    }
    if (reactionAsync.value != null && profile != null) {
      recentReactions = await reactionAsync.value!.getRecentReactions(profile.id, limit: 5);
    }
    if (poopAsync.value != null && profile != null) {
      recentPoopLogs = await poopAsync.value!.getRecentPoopLogs(profile.id, limit: 5);
    }

    return {
      'profile': profile,
      'todayMeals': todayMeals,
      'recentReactions': recentReactions,
      'recentPoopLogs': recentPoopLogs,
    };
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF4A90E2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  child: Icon(Icons.child_care, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 12),
                const Text(
                  'LittleBites',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Baby Food Tracker',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('Add Meal'),
            onTap: () {
              Navigator.pop(context);
              AppNavigator.navigateTo(context, AppRoutes.addMeal);
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Food History'),
            onTap: () {
              Navigator.pop(context);
              AppNavigator.navigateTo(context, AppRoutes.foodHistory);
            },
          ),
          ListTile(
            leading: const Icon(Icons.warning_amber_outlined),
            title: const Text('Log Reaction'),
            onTap: () {
              Navigator.pop(context);
              AppNavigator.navigateTo(context, AppRoutes.logReaction);
            },
          ),
          ListTile(
            leading: const Icon(Icons.eco_outlined),
            title: const Text('Poop Log'),
            onTap: () {
              Navigator.pop(context);
              AppNavigator.navigateTo(context, AppRoutes.poopLog);
            },
          ),
          ListTile(
            leading: const Icon(Icons.people_outline),
            title: const Text('Profiles & Family'),
            onTap: () {
              Navigator.pop(context);
              AppNavigator.navigateTo(context, AppRoutes.profiles);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              AppNavigator.navigateTo(context, AppRoutes.settings);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader() {
    final now = DateTime.now();
    final month = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'][now.month - 1];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Today, $month ${now.day}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        const Row(
          children: [
            Icon(Icons.wb_sunny, color: Color(0xFFF5A623)),
            SizedBox(width: 4),
            Text(
              '26°C',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF7F8C8D),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
            if (onTap != null)
              const Icon(Icons.chevron_right, color: Color(0xFF4A90E2)),
          ],
        ),
      ),
    );
  }

  Widget _buildMealCard(BuildContext context, dynamic meal) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              meal.timeDisplay,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF7F8C8D),
              ),
            ),
            const SizedBox(height: 8),
            ...meal.foods.map((food) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      food.name,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ),
                ],
              ),
            )),
            if (meal.hasAllergens) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: List<Widget>.from(meal.allAllergens.map((allergen) => Chip(
                  label: Text(
                    allergen,
                    style: const TextStyle(fontSize: 10),
                  ),
                  backgroundColor: const Color(0xFFF5A623).withOpacity(0.2),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ))),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReactionCard(BuildContext context, dynamic reaction) {
    Color severityColor;
    String severityLabel;
    switch (reaction.severityColor) {
      case 'green':
        severityColor = const Color(0xFF50E3C2);
        severityLabel = 'Safe';
        break;
      case 'yellow':
        severityColor = const Color(0xFFF5A623);
        severityLabel = 'Mild';
        break;
      case 'red':
        severityColor = const Color(0xFFE74C3C);
        severityLabel = 'Severe';
        break;
      default:
        severityColor = const Color(0xFF50E3C2);
        severityLabel = 'Safe';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: severityColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber_outlined,
                  color: severityColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '$severityLabel - ${reaction.foodName ?? reaction.foodId}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: severityColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _getRelativeTime(reaction.startTime),
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF7F8C8D),
              ),
            ),
            if (reaction.symptoms.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: List<Widget>.from(reaction.symptoms.map((symptom) => Chip(
                  label: Text(
                    symptom,
                    style: const TextStyle(fontSize: 10),
                  ),
                  backgroundColor: severityColor.withOpacity(0.2),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ))),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPoopCard(BuildContext context, dynamic poop) {
    Color poopColor;
    switch (poop.color.toLowerCase()) {
      case 'green':
        poopColor = Colors.green;
        break;
      case 'brown':
        poopColor = Colors.brown;
        break;
      case 'yellow':
        poopColor = Colors.yellow;
        break;
      case 'red':
        poopColor = Colors.red;
        break;
      case 'black':
        poopColor = Colors.black;
        break;
      default:
        poopColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: poopColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    poop.timeDisplay,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  Text(
                    '${poop.color}, ${poop.consistency}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7F8C8D),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(dynamic profile) {
    // Calculate stats based on actual data
    // For now, use placeholder values
    final foodsTried = 10; // This should be calculated from actual data
    final mealsLogged = 20; // This should be calculated from actual data

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: const Color(0xFF4A90E2).withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text(
                  '$foodsTried',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A90E2),
                  ),
                ),
                const Text(
                  'Foods tried',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7F8C8D),
                  ),
                ),
              ],
            ),
            Container(
              width: 1,
              height: 40,
              color: const Color(0xFFECF0F1),
            ),
            Column(
              children: [
                Text(
                  '$mealsLogged',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A90E2),
                  ),
                ),
                const Text(
                  'Meals logged',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7F8C8D),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    return '${difference.inDays ~/ 7} weeks ago';
  }
}
