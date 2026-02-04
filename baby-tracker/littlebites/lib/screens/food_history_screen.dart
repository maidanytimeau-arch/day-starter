import 'package:flutter/material.dart';
import '../models/food.dart';
import '../models/reaction.dart';
import '../services/mock_data_service.dart';

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
}

class FoodHistoryScreen extends StatefulWidget {
  const FoodHistoryScreen({super.key});

  @override
  State<FoodHistoryScreen> createState() => _FoodHistoryScreenState();
}

class _FoodHistoryScreenState extends State<FoodHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  String _selectedSort = 'A-Z';

  final List<String> _filterOptions = ['All', 'fruit', 'vegetable', 'protein', 'grain', 'dairy'];
  final List<String> _sortOptions = ['A-Z', 'Most Recent', 'Most Tried', 'Lowest Acceptance'];

  List<FoodStats> _computeFoodStats() {
    final profileId = MockDataService.getActiveProfile().id;
    final mealLogs = MockDataService.mealLogs
        .where((meal) => meal.profileId == profileId)
        .toList();
    final reactions = MockDataService.reactions
        .where((r) => r.profileId == profileId)
        .toList();

    final Map<String, FoodStats> statsMap = {};

    // Initialize stats for all foods
    for (final food in MockDataService.foods) {
      statsMap[food.id] = FoodStats(
        food: food,
        firstTried: null,
        lastTried: null,
        timesTried: 0,
        acceptanceRate: 0.0,
        worstReaction: null,
      );
    }

    // Process meal logs
    for (final meal in mealLogs) {
      for (final food in meal.foods) {
        final current = statsMap[food.id]!;
        statsMap[food.id] = FoodStats(
          food: current.food,
          firstTried: current.firstTried == null
              ? meal.timestamp
              : (meal.timestamp.isBefore(current.firstTried!) ? meal.timestamp : current.firstTried),
          lastTried: current.lastTried == null
              ? meal.timestamp
              : (meal.timestamp.isAfter(current.lastTried!) ? meal.timestamp : current.lastTried),
          timesTried: current.timesTried + 1,
          acceptanceRate: 1.0, // TODO: Introduce meal-level acceptance to compute real rate
          worstReaction: current.worstReaction,
        );
      }
    }

    // Find worst reaction for each food
    for (final reaction in reactions) {
      final foodId = reaction.foodId;
      if (foodId != null) {
        final current = statsMap[foodId];
        if (current != null) {
          statsMap[foodId] = FoodStats(
            food: current.food,
            firstTried: current.firstTried,
            lastTried: current.lastTried,
            timesTried: current.timesTried,
            acceptanceRate: current.acceptanceRate,
            worstReaction: current.worstReaction == null ||
                reaction.severity > current.worstReaction!.severity
                ? reaction
                : current.worstReaction,
          );
        }
      }
    }

    return statsMap.values.toList();
  }

  List<FoodStats> _filterAndSort(List<FoodStats> stats) {
    // Apply search filter
    List<FoodStats> filtered = stats;
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((stat) =>
          stat.food.name.toLowerCase().contains(query)
      ).toList();
    }

    // Apply category filter
    if (_selectedFilter != 'All') {
      filtered = filtered.where((stat) =>
          stat.food.category == _selectedFilter
      ).toList();
    }

    // Apply sort
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
  Widget build(BuildContext context) {
    final allStats = _computeFoodStats();
    final filteredStats = _filterAndSort(allStats);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Food History'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search foods...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF8F9FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),

          // Filter and Sort dropdowns
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    label: 'Filter',
                    value: _selectedFilter,
                    options: _filterOptions,
                    onChanged: (value) {
                      setState(() {
                        _selectedFilter = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDropdown(
                    label: 'Sort',
                    value: _selectedSort,
                    options: _sortOptions,
                    onChanged: (value) {
                      setState(() {
                        _selectedSort = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Food cards list
          Expanded(
            child: filteredStats.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No foods found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF7F8C8D),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredStats.length,
                    itemBuilder: (context, index) {
                      final stat = filteredStats[index];
                      return FoodStatsCard(stats: stat);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF7F8C8D),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFECF0F1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              items: options.map((option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(
                    option,
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
              icon: const Icon(Icons.arrow_drop_down, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class FoodStatsCard extends StatefulWidget {
  final FoodStats stats;

  const FoodStatsCard({
    super.key,
    required this.stats,
  });

  @override
  State<FoodStatsCard> createState() => _FoodStatsCardState();
}

class _FoodStatsCardState extends State<FoodStatsCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final stats = widget.stats;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Food name and expand icon
              Row(
                children: [
                  Expanded(
                    child: Text(
                      stats.food.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: const Color(0xFF7F8C8D),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Key stats (always visible)
              _buildStatRow('First tried', stats.firstTried != null
                  ? _getRelativeTime(stats.firstTried!)
                  : 'Never'),
              const SizedBox(height: 8),
              _buildStatRow('Times tried', '${stats.timesTried}'),
              const SizedBox(height: 8),
              _buildStatRow('Acceptance', '${_buildStarRating(stats.starRating)} (${stats.acceptancePercentage})'),
              const SizedBox(height: 8),
              _buildStatRow('Last tried', stats.lastTried != null
                  ? _getRelativeTime(stats.lastTried!)
                  : 'Never'),

              const SizedBox(height: 8),

              // Reaction status badge
              _buildReactionBadge(stats),

              // Expanded details
              if (_isExpanded) ...[
                const SizedBox(height: 16),
                const Divider(color: Color(0xFFE8E8E8)),
                const SizedBox(height: 12),
                _buildExpandedDetails(stats),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF7F8C8D),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF2C3E50),
          ),
        ),
      ],
    );
  }

  Widget _buildReactionBadge(FoodStats stats) {
    Color badgeColor;
    Color textColor;
    String icon;

    switch (stats.reactionColorLabel) {
      case 'green':
        badgeColor = const Color(0xFF50E3C2);
        textColor = const Color(0xFF50E3C2);
        icon = '✅';
        break;
      case 'yellow':
        badgeColor = const Color(0xFFF5A623);
        textColor = const Color(0xFFF5A623);
        icon = '⚠️';
        break;
      case 'red':
        badgeColor = const Color(0xFFE74C3C);
        textColor = const Color(0xFFE74C3C);
        icon = '⚠️';
        break;
      default:
        badgeColor = const Color(0xFF50E3C2);
        textColor = const Color(0xFF50E3C2);
        icon = '✅';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(width: 6),
          Text(
            stats.reactionStatus,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedDetails(FoodStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Food category
        _buildDetailRow(
          'Category',
          _capitalizeFirst(stats.food.category),
        ),
        const SizedBox(height: 8),

        // Allergens
        _buildDetailRow(
          'Allergens',
          stats.food.allergens.isNotEmpty
              ? stats.food.allergens.join(', ')
              : 'None',
        ),
        const SizedBox(height: 8),

        // Worst reaction details
        if (stats.worstReaction != null) ...[
          _buildDetailRow(
            'Worst reaction',
            stats.worstReaction!.severityText,
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            'Symptoms',
            stats.worstReaction!.symptoms.isNotEmpty
                ? stats.worstReaction!.symptoms.join(', ')
                : 'None recorded',
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            'Reaction date',
            _formatDate(stats.worstReaction!.startTime),
          ),
          if (stats.worstReaction!.notes != null) ...[
            const SizedBox(height: 8),
            _buildDetailRow(
              'Notes',
              stats.worstReaction!.notes!,
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF7F8C8D),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF2C3E50),
            ),
          ),
        ),
      ],
    );
  }

  String _buildStarRating(int rating) {
    return '⭐' * rating + '☆' * (5 - rating);
  }

  String _getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    if (difference.inDays < 30) return '${difference.inDays ~/ 7} weeks ago';
    if (difference.inDays < 365) return '${difference.inDays ~/ 30} months ago';
    return '${difference.inDays ~/ 365} years ago';
  }

  String _formatDate(DateTime dateTime) {
    final month = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][dateTime.month - 1];
    return '$month ${dateTime.day}, ${dateTime.year}';
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
