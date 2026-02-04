import '../models/profile.dart';
import '../models/food.dart';
import '../models/meal_log.dart';
import '../models/reaction.dart';
import '../models/poop_log.dart';

class MockDataService {
  // Mock profiles
  static final List<Profile> profiles = [
    Profile(
      id: 'profile_1',
      name: 'Baby Emma',
      birthDate: DateTime(2025, 8, 15),
      familyId: 'family_1',
      parentId: 'user_1',
      createdAt: DateTime(2025, 8, 15),
    ),
    Profile(
      id: 'profile_2',
      name: 'Baby Liam',
      birthDate: DateTime(2025, 11, 20),
      familyId: 'family_1',
      parentId: 'user_1',
      createdAt: DateTime(2025, 11, 20),
    ),
  ];

  // Mock foods
  static final List<Food> foods = [
    Food(
      id: 'food_1',
      name: 'Banana',
      allergens: [],
      category: 'fruit',
    ),
    Food(
      id: 'food_2',
      name: 'Oatmeal',
      allergens: [],
      category: 'grain',
    ),
    Food(
      id: 'food_3',
      name: 'Strawberries',
      allergens: [],
      category: 'fruit',
    ),
    Food(
      id: 'food_4',
      name: 'Broccoli',
      allergens: [],
      category: 'vegetable',
    ),
    Food(
      id: 'food_5',
      name: 'Chicken puree',
      allergens: [],
      category: 'protein',
    ),
    Food(
      id: 'food_6',
      name: 'Peanut',
      allergens: ['nuts', 'tree nut'],
      category: 'protein',
    ),
    Food(
      id: 'food_7',
      name: 'Dairy (milk)',
      allergens: ['dairy'],
      category: 'dairy',
    ),
    Food(
      id: 'food_8',
      name: 'Eggs',
      allergens: ['eggs'],
      category: 'protein',
    ),
    Food(
      id: 'food_9',
      name: 'Avocado',
      allergens: [],
      category: 'fruit',
    ),
    Food(
      id: 'food_10',
      name: 'Sweet potato',
      allergens: [],
      category: 'vegetable',
    ),
  ];

  // Mock meal logs
  static final List<MealLog> mealLogs = [
    MealLog(
      id: 'meal_1',
      profileId: 'profile_1',
      foods: [
        foods[0], // Banana
        foods[1], // Oatmeal
      ],
      timestamp: DateTime(2026, 2, 4, 8, 30),
      preparation: 'Pureed',
      notes: 'Loved it!',
    ),
    MealLog(
      id: 'meal_2',
      profileId: 'profile_1',
      foods: [
        foods[3], // Broccoli
        foods[4], // Chicken puree
      ],
      timestamp: DateTime(2026, 2, 4, 12, 0),
      preparation: 'Mashed',
    ),
    MealLog(
      id: 'meal_3',
      profileId: 'profile_1',
      foods: [
        foods[2], // Strawberries
        foods[0], // Banana
      ],
      timestamp: DateTime(2026, 2, 3, 15, 0),
      preparation: 'Finger food',
    ),
    MealLog(
      id: 'meal_4',
      profileId: 'profile_1',
      foods: [
        foods[9], // Sweet potato
      ],
      timestamp: DateTime(2026, 2, 3, 8, 0),
      preparation: 'Roasted',
    ),
  ];

  // Mock reactions
  static final List<Reaction> reactions = [
    Reaction(
      id: 'reaction_1',
      profileId: 'profile_1',
      foodId: 'food_6', // Peanut
      severity: 3,
      symptoms: ['Rash', 'Hives'],
      startTime: DateTime(2026, 2, 2, 14, 30),
      endTime: DateTime(2026, 2, 2, 18, 0),
      notes: 'Mild rash on cheeks, disappeared with antihistamine',
    ),
    Reaction(
      id: 'reaction_2',
      profileId: 'profile_1',
      foodId: 'food_7', // Dairy
      severity: 2,
      symptoms: ['Runny nose', 'Slight swelling'],
      startTime: DateTime(2026, 1, 20, 10, 0),
      endTime: DateTime(2026, 1, 20, 14, 0),
      notes: 'Very mild reaction',
    ),
  ];

  // Mock poop logs
  static final List<PoopLog> poopLogs = [
    PoopLog(
      id: 'poop_1',
      profileId: 'profile_1',
      timestamp: DateTime(2026, 2, 4, 15, 0),
      color: 'green',
      consistency: 'formed',
    ),
    PoopLog(
      id: 'poop_2',
      profileId: 'profile_1',
      timestamp: DateTime(2026, 2, 3, 10, 30),
      color: 'brown',
      consistency: 'soft',
    ),
    PoopLog(
      id: 'poop_3',
      profileId: 'profile_1',
      timestamp: DateTime(2026, 2, 2, 16, 0),
      color: 'yellow',
      consistency: 'soft',
    ),
  ];

  // Get active profile (first one for now)
  static Profile getActiveProfile() {
    return profiles[0];
  }

  // Get today's meals
  static List<MealLog> getTodayMeals() {
    final today = DateTime.now();
    return mealLogs.where((meal) {
      return meal.timestamp.year == today.year &&
             meal.timestamp.month == today.month &&
             meal.timestamp.day == today.day;
    }).toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  // Get recent reactions
  static List<Reaction> getRecentReactions() {
    return reactions..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  // Get recent poop logs
  static List<PoopLog> getRecentPoopLogs() {
    return poopLogs..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }
}
