import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/profile.dart';
import '../models/meal_log.dart';
import '../services/providers/service_providers.dart';

class ProfilesScreen extends ConsumerStatefulWidget {
  const ProfilesScreen({super.key});

  @override
  ConsumerState<ProfilesScreen> createState() => _ProfilesScreenState();
}

class _ProfilesScreenState extends ConsumerState<ProfilesScreen> {
  String? _activeProfileId;

  @override
  Widget build(BuildContext context) {
    final profileServiceAsync = ref.watch(profileServiceProvider);
    final mealServiceAsync = ref.watch(mealServiceProvider);

    return profileServiceAsync.when(
      data: (profileService) {
        return mealServiceAsync.when(
          data: (mealService) {
            return StreamBuilder<List<Profile>>(
              stream: profileService.streamProfiles(),
              builder: (context, profilesSnapshot) {
                if (!profilesSnapshot.hasData || profilesSnapshot.data == null) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                final profiles = profilesSnapshot.data ?? [];

                // Set initial active profile if not set
                if (_activeProfileId == null && profiles.isNotEmpty) {
                  _activeProfileId = profiles[0].id;
                }

                // Watch active profile stream
                return StreamBuilder<Profile?>(
                  stream: profileService.streamActiveProfile(),
                  builder: (context, activeProfileSnapshot) {
                    final activeProfile = activeProfileSnapshot.data ??
                        profiles.firstWhere(
                          (p) => p.id == _activeProfileId,
                          orElse: () => profiles.isNotEmpty ? profiles[0] : Profile(
                            id: '',
                            name: 'No Profile',
                            birthDate: DateTime.now(),
                            familyId: '',
                            parentId: '',
                            createdAt: DateTime.now(),
                          ),
                        );

                    if (activeProfile == null || activeProfile.id.isEmpty) {
                      return Scaffold(
                        appBar: AppBar(
                          title: const Text('Profiles'),
                        ),
                        body: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.child_care,
                                size: 64,
                                color: Color(0xFF4A90E2),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No profiles yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFF7F8C8D),
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/create-profile');
                                },
                                child: const Text('Create Profile'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // Stream meals for insights
                    return StreamBuilder<List<MealLog>>(
                      stream: mealService.streamMeals(activeProfile.id),
                      builder: (context, mealsSnapshot) {
                        final meals = mealsSnapshot.data ?? [];

                        // Calculate foods tried for active profile
                        final foodsTried = meals
                            .fold<Set<String>>(
                              <String>{},
                              (Set<String> acc, meal) => acc..addAll(meal.foods.map((f) => f.id)),
                            ).length;

                        // Calculate insights
                        final insights = _calculateInsights(meals);

                        return Scaffold(
                          appBar: AppBar(
                            title: const Text('Profiles'),
                            actions: [
                              IconButton(
                                icon: const Icon(Icons.settings_outlined),
                                onPressed: () {
                                  // TODO: Navigate to settings
                                },
                              ),
                            ],
                          ),
                          body: ListView(
                            padding: const EdgeInsets.all(16),
                            children: [
                              // Child Selector
                              _buildChildSelector(activeProfile, profileService),
                              const SizedBox(height: 24),

                              // Current Child Card
                              _buildCurrentChildCard(activeProfile, foodsTried),
                              const SizedBox(height: 24),

                              // Children Section
                              _buildChildrenSection(profiles, activeProfile, profileService),
                              const SizedBox(height: 24),

                              // Family/Caregivers Section
                              _buildFamilySection(),
                              const SizedBox(height: 24),

                              // Insights Section
                              _buildInsightsSection(insights),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
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
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, __) => Scaffold(
        body: Center(
          child: Text('Error loading profiles: $error'),
        ),
      ),
    );
  }

  Widget _buildChildSelector(Profile activeProfile, dynamic profileService) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: const Color(0xFF4A90E2).withOpacity(0.1),
      child: InkWell(
        onTap: () => _showChildSelectorDialog(profileService),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF4A90E2),
                child: const Icon(
                  Icons.child_care,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Active Child',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7F8C8D),
                      ),
                    ),
                    Text(
                      activeProfile.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A90E2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Active',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_drop_down,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentChildCard(Profile profile, int foodsTried) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: const Color(0xFF50E3C2),
                  child: const Icon(
                    Icons.child_care,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.cake_outlined,
                            size: 16,
                            color: Color(0xFF7F8C8D),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            profile.ageDisplay,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF7F8C8D),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF50E3C2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.restaurant_outlined,
                    color: Color(0xFF50E3C2),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Foods Tried',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF7F8C8D),
                          ),
                        ),
                        Text(
                          '$foodsTried',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                      ],
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

  Widget _buildChildrenSection(List<Profile> profiles, Profile activeProfile, dynamic profileService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '👶 Children',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              ...profiles.map((profile) => InkWell(
                onTap: () => _switchProfile(profile.id, profileService),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: profile.id == _activeProfileId
                            ? const Color(0xFF50E3C2)
                            : const Color(0xFFECF0F1),
                        child: Icon(
                          Icons.child_care,
                          color: profile.id == _activeProfileId
                              ? Colors.white
                              : const Color(0xFF7F8C8D),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          profile.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: profile.id == _activeProfileId
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: const Color(0xFF2C3E50),
                          ),
                        ),
                      ),
                      if (profile.id == _activeProfileId)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF50E3C2).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            '✓',
                            style: TextStyle(
                              color: Color(0xFF50E3C2),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              )),
              const Divider(height: 1),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/create-profile');
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add,
                        color: Color(0xFF4A90E2),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Add Child',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF4A90E2),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFamilySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '👨‍👩‍👧 Family / Caregivers',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              // You (current user)
              _buildCaregiverItem(
                name: 'Bob',
                role: 'You',
                icon: Icons.person,
                isYou: true,
              ),
              const Divider(height: 1),
              // Partner
              _buildCaregiverItem(
                name: 'Sarah',
                role: 'Partner',
                icon: Icons.person,
                status: 'Active',
              ),
              const Divider(height: 1),
              // Pending invite
              _buildCaregiverItem(
                name: 'Grandma',
                role: 'Grandparent',
                icon: Icons.person_outline,
                status: 'Pending',
                isPending: true,
              ),
              const Divider(height: 1),
              InkWell(
                onTap: () {
                  // TODO: Navigate to Invite Family screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invite family - Coming soon!')),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add,
                        color: Color(0xFF4A90E2),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Invite Family Member',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF4A90E2),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_hasPendingInvites()) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5A623).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFF5A623).withOpacity(0.3),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.pending_outlined,
                  color: Color(0xFFF5A623),
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '1 pending invite waiting for acceptance',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFFF5A623),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCaregiverItem({
    required String name,
    required String role,
    required IconData icon,
    String? status,
    bool isYou = false,
    bool isPending = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: isYou
                ? const Color(0xFF4A90E2)
                : const Color(0xFFECF0F1),
            child: Icon(
              icon,
              color: isYou ? Colors.white : const Color(0xFF7F8C8D),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
                Text(
                  role,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7F8C8D),
                  ),
                ),
              ],
            ),
          ),
          if (isYou)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF4A90E2).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'You',
                style: TextStyle(
                  color: Color(0xFF4A90E2),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          else if (isPending)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF5A623).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Pending',
                style: TextStyle(
                  color: Color(0xFFF5A623),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          else
            Text(
              status ?? 'Active',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF50E3C2),
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInsightsSection(Map<String, String> insights) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📊 Insights',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: const Color(0xFF9B59B6).withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInsightItem(
                  icon: Icons.favorite,
                  label: 'Most Loved',
                  value: insights['mostLoved'] ?? 'Not enough data',
                  color: const Color(0xFFE74C3C),
                ),
                const SizedBox(height: 16),
                _buildInsightItem(
                  icon: Icons.close,
                  label: 'Most Rejected',
                  value: insights['mostRejected'] ?? 'Not enough data',
                  color: const Color(0xFFF5A623),
                ),
                const SizedBox(height: 16),
                _buildInsightItem(
                  icon: Icons.calendar_today,
                  label: 'Best Day',
                  value: insights['bestDay'] ?? 'Not enough data',
                  color: const Color(0xFF4A90E2),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInsightItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF7F8C8D),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Map<String, String> _calculateInsights(List<MealLog> meals) {
    if (meals.isEmpty) {
      return {
        'mostLoved': 'Not enough data',
        'mostRejected': 'Not enough data',
        'bestDay': 'Not enough data',
      };
    }

    // Count food occurrences (simple approach - more frequent = more loved)
    final foodCounts = <String, int>{};
    for (var meal in meals) {
      for (var food in meal.foods) {
        foodCounts[food.name] = (foodCounts[food.name] ?? 0) + 1;
      }
    }

    if (foodCounts.isEmpty) {
      return {
        'mostLoved': 'Not enough data',
        'mostRejected': 'Not enough data',
        'bestDay': 'Not enough data',
      };
    }

    // Find most loved (most frequent)
    String mostLoved = foodCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    // Find least tried (most rejected for this simple mockup)
    String mostRejected = foodCounts.entries
        .reduce((a, b) => a.value < b.value ? a : b)
        .key;

    // Find best day of week
    final dayCounts = <int, int>{};
    for (var meal in meals) {
      dayCounts[meal.timestamp.weekday] = (dayCounts[meal.timestamp.weekday] ?? 0) + 1;
    }

    String bestDay = 'Not enough data';
    if (dayCounts.isNotEmpty) {
      final bestDayIndex = dayCounts.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
      final weekdays = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      bestDay = weekdays[bestDayIndex];
    }

    return {
      'mostLoved': mostLoved,
      'mostRejected': mostRejected,
      'bestDay': bestDay,
    };
  }

  bool _hasPendingInvites() {
    // In a real app, this would check actual invite status
    // For now, we hardcode to true to show the feature
    return true;
  }

  void _switchProfile(String profileId, dynamic profileService) async {
    setState(() {
      _activeProfileId = profileId;
    });

    // Set active profile in Firebase
    try {
      await profileService.setActiveProfile(profileId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Switched to profile'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error switching profile: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showChildSelectorDialog(dynamic profileService) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StreamBuilder<List<Profile>>(
          stream: profileService.streamProfiles(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data == null) {
              return const AlertDialog(
                content: Center(child: CircularProgressIndicator()),
              );
            }

            final profiles = snapshot.data!;

            return AlertDialog(
              title: const Text('Select Child'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: profiles.map((profile) {
                  final isActive = profile.id == _activeProfileId;
                  return InkWell(
                    onTap: () {
                      _switchProfile(profile.id, profileService);
                      Navigator.of(context).pop();
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF4A90E2).withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: isActive
                                ? const Color(0xFF4A90E2)
                                : const Color(0xFFECF0F1),
                            child: Icon(
                              Icons.child_care,
                              color: isActive ? Colors.white : const Color(0xFF7F8C8D),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              profile.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                                color: const Color(0xFF2C3E50),
                              ),
                            ),
                          ),
                          if (isActive)
                            const Icon(
                              Icons.check_circle,
                              color: Color(0xFF4A90E2),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
