import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/profile.dart';
import '../models/meal_log.dart';
import '../models/reaction.dart';
import '../models/poop_log.dart';
import '../services/providers/service_providers.dart';
import '../services/providers/auth_providers.dart';
import '../routes/app_routes.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use real-time streams for live data
    final profileAsync = ref.watch(profileServiceProvider);
    final currentUser = ref.watch(currentUserProvider);

    return profileAsync.when(
      data: (profileService) {
        // Watch profiles stream to get active profile
        final profilesStream = profileService.streamProfiles();
        final activeProfileStream = profileService.streamActiveProfile();

        return StreamBuilder<List<Profile>>(
          stream: profilesStream,
          builder: (context, profilesSnapshot) {
            if (!profilesSnapshot.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final profiles = profilesSnapshot.data ?? [];

            return StreamBuilder<Profile?>(
              stream: activeProfileStream,
              builder: (context, activeProfileSnapshot) {
                final activeProfile = activeProfileSnapshot.data;

                // If no active profile, show prompt to create one
                if (activeProfile == null || activeProfile.id.isEmpty) {
                  return _buildNoProfileScreen(context);
                }

                // Get real-time streams for active profile from respective services
                final mealServiceAsync = ref.watch(mealServiceProvider);
                final reactionServiceAsync = ref.watch(reactionServiceProvider);
                final poopServiceAsync = ref.watch(poopServiceProvider);

                return mealServiceAsync.when(
                  data: (mealService) {
                    final reactionAsync = reactionServiceAsync.value;
                    final poopAsync = poopServiceAsync.value;

                    return _buildHomeWithData(
                      context,
                      ref,
                      activeProfile,
                      profiles,
                      mealService.streamMeals(activeProfile.id),
                      reactionAsync?.streamReactions(activeProfile.id) ?? const Stream.empty(),
                      poopAsync?.streamPoopLogs(activeProfile.id) ?? const Stream.empty(),
                    );
                  },
                  loading: () => const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, __) => Scaffold(
                    body: Center(
                      child: Text('Error loading services: $error'),
                    ),
                  ),
                );
              },
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
              Text('Error loading profiles: $error'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoProfileScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LittleBites'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Sign out will be handled by AuthWrapper
              // Need to access ref here - simplified for now
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.child_care,
                size: 80,
                color: Color(0xFF4A90E2),
              ),
              const SizedBox(height: 24),
              const Text(
                'Welcome to LittleBites!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Let\'s start by adding a profile for your baby.',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF7F8C8D),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  AppNavigator.navigateTo(context, AppRoutes.profiles);
                },
                icon: const Icon(Icons.add),
                label: const Text('Create Profile'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeWithData(
    BuildContext context,
    WidgetRef ref,
    Profile activeProfile,
    List<Profile> profiles,
    Stream<List<MealLog>> mealStream,
    Stream<List<Reaction>> reactionStream,
    Stream<List<PoopLog>> poopStream,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(activeProfile.name),
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
      drawer: _buildDrawer(context, activeProfile, profiles),
      body: RefreshIndicator(
        onRefresh: () async {
          // Stream refresh happens automatically
          // Just invalidate providers to force reload
          ref.invalidate(profileServiceProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Date and weather
            _buildDateHeader(),
            const SizedBox(height: 20),

            // Today's Meals (real-time)
            _buildMealsSection(context, mealStream),
            const SizedBox(height: 20),

            // Recent Reactions (real-time)
            _buildReactionsSection(context, reactionStream),
            const SizedBox(height: 20),

            // Recent Poop Logs (real-time)
            _buildPoopLogsSection(context, poopStream),
            const SizedBox(height: 20),

            // Stats summary
            _buildStatsCard(context, ref, activeProfile),
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
  }

  Widget _buildMealsSection(BuildContext context, Stream<List<MealLog>> mealStream) {
    return StreamBuilder<List<MealLog>>(
      stream: mealStream,
      builder: (context, mealsSnapshot) {
        final todayMeals = _getTodayMeals(mealsSnapshot.data ?? []);

        if (todayMeals.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No meals logged today',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('🍽️ Today\'s Meals',
                onTap: () => AppNavigator.navigateTo(context, AppRoutes.foodHistory)),
            const SizedBox(height: 8),
            ...todayMeals.map((meal) => _buildMealCard(context, meal)),
          ],
        );
      },
    );
  }

  Widget _buildReactionsSection(BuildContext context, Stream<List<Reaction>> reactionStream) {
    return StreamBuilder<List<Reaction>>(
      stream: reactionStream,
      builder: (context, reactionsSnapshot) {
        final reactions = reactionsSnapshot.data ?? [];

        if (reactions.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('⚠️ Recent Reactions',
                onTap: () => AppNavigator.navigateTo(context, AppRoutes.logReaction)),
            const SizedBox(height: 8),
            ...reactions.take(2).map((reaction) => _buildReactionCard(context, reaction)),
          ],
        );
      },
    );
  }

  Widget _buildPoopLogsSection(BuildContext context, Stream<List<PoopLog>> poopStream) {
    return StreamBuilder<List<PoopLog>>(
      stream: poopStream,
      builder: (context, poopSnapshot) {
        final poopLogs = poopSnapshot.data ?? [];

        if (poopLogs.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('💩 Poop Log',
                onTap: () => AppNavigator.navigateTo(context, AppRoutes.poopLog)),
            const SizedBox(height: 8),
            ...poopLogs.take(1).map((poop) => _buildPoopCard(context, poop)),
          ],
        );
      },
    );
  }

  Widget _buildDrawer(BuildContext context, Profile activeProfile, List<Profile> profiles) {
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
                Text(
                  activeProfile.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${profiles.length} profile${profiles.length == 1 ? '' : 's'}',
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

  Widget _buildMealCard(BuildContext context, MealLog meal) {
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
                  backgroundColor: const Color(0xFFF5A623).withValues(alpha: 0.2),
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

  Widget _buildReactionCard(BuildContext context, Reaction reaction) {
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
      color: severityColor.withValues(alpha: 0.1),
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
                Expanded(
                  child: Text(
                    '$severityLabel - ${reaction.foodName ?? reaction.foodId ?? 'Unknown'}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: severityColor,
                    ),
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
                  backgroundColor: severityColor.withValues(alpha: 0.2),
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

  Widget _buildPoopCard(BuildContext context, PoopLog poop) {
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

  Widget _buildStatsCard(BuildContext context, WidgetRef ref, Profile activeProfile) {
    // Calculate stats based on real-time data
    final mealAsync = ref.watch(mealServiceProvider);
    final foodAsync = ref.watch(profileServiceProvider);

    return mealAsync.when(
      data: (mealService) {
        return FutureBuilder<List<MealLog>>(
          future: mealService.getMeals(activeProfile.id),
          builder: (context, mealsSnapshot) {
            if (!mealsSnapshot.hasData || mealsSnapshot.data == null) {
              return const SizedBox.shrink();
            }

            final meals = mealsSnapshot.data!;
            final foodsTried = meals.fold<Set<String>>(
              {},
              (acc, meal) => acc..addAll(meal.foods.map((f) => f.id)),
            ).length;
            final mealsLogged = meals.length;

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: const Color(0xFF4A90E2).withValues(alpha: 0.1),
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
          },
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  List<MealLog> _getTodayMeals(List<MealLog> meals) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    return meals.where((meal) {
      return meal.timestamp.isAfter(startOfDay) ||
          meal.timestamp.isAtSameMomentAs(startOfDay);
    }).toList();
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
