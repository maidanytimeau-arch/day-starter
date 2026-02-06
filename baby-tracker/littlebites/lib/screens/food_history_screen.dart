import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/food.dart';
import '../models/reaction.dart';
import '../services/providers/service_providers.dart';

// Model to hold computed statistics for each food
class FoodStats {
  final Food food;
  final DateTime? firstTried;
  final DateTime? lastTried;
  final int timesTried;
  final double acceptanceRate; // 0.0 to 1.0
  final Reaction? worstReaction;

  FoodStats({
    required this.food,
    required this.firstTried,
    required this.lastTried,
    required this.timesTried,
    required this.acceptanceRate,
    this.worstReaction,
  });

  int get starRating => (acceptanceRate * 5).round();

  String get acceptancePercentage => '${(acceptanceRate * 100).toInt()}%';

  String get reactionStatus {
    if (worstReaction == null) return 'No reactions';
    if (worstReaction!.severity <= 2) return 'Mild';
    return 'Severe';
  }

  String get reactionColorLabel {
    if (worstReaction == null) return 'green';
    if (worstReaction!.severity <= 2) return 'yellow';
    return 'red';
  }

  FoodStats copyWith({
    Food? food,
    DateTime? firstTried,
    DateTime? lastTried,
    int? timesTried,
    double? acceptanceRate,
    Reaction? worstReaction,
  }) {
    return FoodStats(
      food: food ?? this.food,
      firstTried: firstTried ?? this.firstTried,
      lastTried: lastTried ?? this.lastTried,
      timesTried: timesTried ?? this.timesTried,
      acceptanceRate: acceptanceRate ?? this.acceptanceRate,
      worstReaction: worstReaction ?? this.worstReaction,
    );
  }
}

class FoodHistoryScreen extends ConsumerStatefulWidget {
  const FoodHistoryScreen({super.key});

  @override
  ConsumerState<FoodHistoryScreen> createState() => _FoodHistoryScreenState();
}

class _FoodHistoryScreenState extends ConsumerState<FoodHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  String _selectedSort = 'A-Z';

  final List<String> _filterOptions = ['All', 'fruit', 'vegetable', 'protein', 'grain', 'dairy'];
  final List<String> _sortOptions = ['A-Z', 'Most Recent', 'Most Tried', 'Lowest Acceptance'];

  List<FoodStats> _computeFoodStats(List mealLogs, List reactions) {
    final Map<String, FoodStats> statsMap = {};

    // Process meal logs to extract foods and build stats
    for (final meal in mealLogs) {
      for (final food in meal.foods) {
        if (!statsMap.containsKey(food.id)) {
          statsMap[food.id] = FoodStats(
            food: food,
            firstTried: null,
            lastTried: null,
            timesTried: 0,
            acceptanceRate: 0.0,
            worstReaction: null,
          );
        }

        final stats = statsMap[food.id]!;
        if (stats.firstTried == null || meal.timestamp.isBefore(stats.firstTried!)) {
          statsMap[food.id] = stats.copyWith(firstTried: meal.timestamp);
        }
        if (stats.lastTried == null || meal.timestamp.isAfter(stats.lastTried!)) {
          statsMap[food.id] = stats.copyWith(lastTried: meal.timestamp);
        }
        statsMap[food.id] = stats.copyWith(timesTried: stats.timesTried + 1);
      }
    }

    // Process reactions
    for (final reaction in reactions) {
      if (reaction.foodId != null && statsMap.containsKey(reaction.foodId)) {
        final stats = statsMap[reaction.foodId]!;
        if (stats.worstReaction == null || reaction.severity > stats.worstReaction!.severity) {
          statsMap[reaction.foodId] = stats.copyWith(worstReaction: reaction);
        }
      }
    }

    return statsMap.values.toList();
  }

  List<FoodStats> _filterAndSortStats(List<FoodStats> stats) {
    var filtered = stats;

    // Filter by category
    if (_selectedFilter != 'All') {
      filtered = filtered.where((stat) => stat.food.category == _selectedFilter).toList();
    }

    // Filter by search
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((stat) => stat.food.name.toLowerCase().contains(query)).toList();
    }

    // Sort
    switch (_selectedSort) {
      case 'A-Z':
        filtered.sort((a, b) => a.food.name.compareTo(b.food.name));
        break;
      case 'Most Recent':
        filtered.sort((a, b) {
          if (a.lastTried == null && b.lastTried == null) return 0;
          if (a.lastTried == null) return 1;
          if (b.lastTried == null) return -1;
          return b.lastTried!.compareTo(a.lastTried!);
        });
        break;
      case 'Most Tried':
        filtered.sort((a, b) => b.timesTried.compareTo(a.timesTried));
        break;
      case 'Lowest Acceptance':
        filtered.sort((a, b) => a.acceptanceRate.compareTo(b.acceptanceRate));
        break;
    }

    return filtered;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mealService = ref.watch(mealServiceProvider);
    final reactionService = ref.watch(reactionServiceProvider);
    final profileService = ref.watch(profileServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Food History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('About Food History'),
                  content: const Text(
                    'Track which foods your baby has tried, how many times, and their reactions.\n\n'
                    '• Star rating: How much your baby likes the food\n'
                    '• Reaction status: Any allergic reactions detected\n',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Got it'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: mealService.when(
        data: (mealSvc) {
          return reactionService.when(
            data: (reactionSvc) {
              return profileService.when(
                data: (profileSvc) {
                  return StreamBuilder(
                    stream: _combineDataStreams(profileSvc, mealSvc, reactionSvc),
                    builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData) {
                        return const Center(child: Text('No data available'));
                      }

                      final mealLogs = snapshot.data!['mealLogs'] as List;
                      final reactions = snapshot.data!['reactions'] as List;

                      final allStats = _computeFoodStats(mealLogs, reactions);
                      final filteredStats = _filterAndSortStats(allStats);

                      if (filteredStats.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.restaurant_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No foods match your filters',
                                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        );
                      }

                      return Column(
                        children: [
                          // Search and filters
                          Container(
                            padding: const EdgeInsets.all(16),
                            color: Colors.grey[50],
                            child: Column(
                              children: [
                                // Search
                                TextField(
                                  controller: _searchController,
                                  decoration: InputDecoration(
                                    hintText: 'Search foods...',
                                    prefixIcon: const Icon(Icons.search),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onChanged: (value) => setState(() {}),
                                ),
                                const SizedBox(height: 16),
                                // Filters
                                Row(
                                  children: [
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        value: _selectedFilter,
                                        decoration: InputDecoration(
                                          labelText: 'Category',
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        items: _filterOptions
                                            .map((filter) => DropdownMenuItem(
                                                  value: filter,
                                                  child: Text(filter[0].toUpperCase() + filter.substring(1)),
                                                ))
                                            .toList(),
                                        onChanged: (value) => setState(() => _selectedFilter = value!),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        value: _selectedSort,
                                        decoration: InputDecoration(
                                          labelText: 'Sort by',
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        items: _sortOptions
                                            .map((sort) => DropdownMenuItem(
                                                  value: sort,
                                                  child: Text(sort),
                                                ))
                                            .toList(),
                                        onChanged: (value) => setState(() => _selectedSort = value!),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Food list
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredStats.length,
                              itemBuilder: (context, index) {
                                final stat = filteredStats[index];
                                return _buildFoodCard(context, stat);
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: $error'),
                    ],
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: $error'),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
            ],
          ),
        ),
      ),
    );
  }

  Stream<Map<String, dynamic>> _combineDataStreams(
    dynamic profileSvc,
    dynamic mealSvc,
    dynamic reactionSvc,
  ) async* {
    // Get active profile
    final profile = await profileSvc.getActiveProfile();

    if (profile == null) {
      yield {
        'profile': null,
        'mealLogs': <dynamic>[],
        'reactions': <dynamic>[],
      };
      return;
    }

    // Create streams
    final mealStream = mealSvc.streamMeals(profile.id);
    final reactionStream = reactionSvc.streamReactions(profile.id);

    // Combine streams - use asyncMap on meal stream and fetch reactions
    yield* mealStream.asyncMap((meals) async {
      final reactions = await reactionStream.first;

      return {
        'profile': profile,
        'mealLogs': meals,
        'reactions': reactions,
      };
    });
  }

  Widget _buildFoodCard(BuildContext context, FoodStats stat) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Food icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(stat.food.category),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getCategoryIcon(stat.food.category),
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                // Food name and category
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stat.food.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stat.food.category.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Times tried
                Column(
                  children: [
                    Text(
                      '${stat.timesTried}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A90E2),
                      ),
                    ),
                    Text(
                      'time${stat.timesTried == 1 ? '' : 's'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Star rating
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < stat.starRating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 20,
                );
              }),
            ),
            const SizedBox(height: 8),
            // First and last tried
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  stat.firstTried != null
                      ? 'First: ${_formatDate(stat.firstTried!)}'
                      : 'Not tried yet',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                if (stat.lastTried != null) ...[
                  const SizedBox(width: 16),
                  Icon(Icons.update, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Last: ${_formatDate(stat.lastTried!)}',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
            // Reaction status
            if (stat.worstReaction != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getReactionColor(stat.reactionColorLabel),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getReactionIcon(stat.reactionColorLabel),
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      stat.reactionStatus,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'fruit':
        return Colors.red;
      case 'vegetable':
        return Colors.green;
      case 'protein':
        return Colors.orange;
      case 'grain':
        return Colors.brown;
      case 'dairy':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'fruit':
        return Icons.apple;
      case 'vegetable':
        return Icons.eco;
      case 'protein':
        return Icons.set_meal;
      case 'grain':
        return Icons.grain;
      case 'dairy':
        return Icons.water_drop;
      default:
        return Icons.fastfood;
    }
  }

  Color _getReactionColor(String label) {
    switch (label) {
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.orange;
      case 'red':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getReactionIcon(String label) {
    switch (label) {
      case 'green':
        return Icons.check_circle;
      case 'yellow':
        return Icons.warning;
      case 'red':
        return Icons.error;
      default:
        return Icons.info;
    }
  }
}
