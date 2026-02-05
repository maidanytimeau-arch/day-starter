import '../models/profile.dart';
import '../models/food.dart';
import '../models/meal_log.dart';
import '../models/reaction.dart';
import '../models/poop_log.dart';
import 'interfaces/meal_service_interface.dart';
import 'interfaces/reaction_service_interface.dart';
import 'interfaces/poop_service_interface.dart';
import 'interfaces/profile_service_interface.dart';

// Mock profiles
final List<Profile> _mockProfiles = [
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
final List<Food> _mockFoods = [
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
final List<MealLog> _mockMealLogs = [
  MealLog(
    id: 'meal_1',
    profileId: 'profile_1',
    foods: [
      _mockFoods[0], // Banana
      _mockFoods[1], // Oatmeal
    ],
    timestamp: DateTime(2026, 2, 4, 8, 30),
    preparation: 'Pureed',
    notes: 'Loved it!',
  ),
  MealLog(
    id: 'meal_2',
    profileId: 'profile_1',
    foods: [
      _mockFoods[3], // Broccoli
      _mockFoods[4], // Chicken puree
    ],
    timestamp: DateTime(2026, 2, 4, 12, 0),
    preparation: 'Mashed',
  ),
  MealLog(
    id: 'meal_3',
    profileId: 'profile_1',
    foods: [
      _mockFoods[2], // Strawberries
      _mockFoods[0], // Banana
    ],
    timestamp: DateTime(2026, 2, 3, 15, 0),
    preparation: 'Finger food',
  ),
  MealLog(
    id: 'meal_4',
    profileId: 'profile_1',
    foods: [
      _mockFoods[9], // Sweet potato
    ],
    timestamp: DateTime(2026, 2, 3, 8, 0),
    preparation: 'Roasted',
  ),
];

// Mock reactions
final List<Reaction> _mockReactions = [
  Reaction(
    id: 'reaction_1',
    profileId: 'profile_1',
    foodId: 'food_6', // Peanut
    foodName: 'Peanut',
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
    foodName: 'Dairy (milk)',
    severity: 2,
    symptoms: ['Runny nose', 'Slight swelling'],
    startTime: DateTime(2026, 1, 20, 10, 0),
    endTime: DateTime(2026, 1, 20, 14, 0),
    notes: 'Very mild reaction',
  ),
];

// Mock poop logs
final List<PoopLog> _mockPoopLogs = [
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

class MockMealService implements MealServiceInterface {
  @override
  Future<List<MealLog>> getMeals(String profileId) async {
    return _mockMealLogs
        .where((meal) => meal.profileId == profileId)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  @override
  Stream<List<MealLog>> streamMeals(String profileId) {
    // For mock, just return a stream that emits once
    return Stream.value(
      _mockMealLogs
          .where((meal) => meal.profileId == profileId)
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp)),
    );
  }

  @override
  Future<List<MealLog>> getTodayMeals(String profileId) async {
    final today = DateTime.now();
    return _mockMealLogs
        .where((meal) {
          return meal.profileId == profileId &&
              meal.timestamp.year == today.year &&
              meal.timestamp.month == today.month &&
              meal.timestamp.day == today.day;
        })
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  @override
  Future<MealLog> addMeal(MealLog meal) async {
    final newMeal = MealLog(
      id: meal.id.isEmpty
          ? DateTime.now().millisecondsSinceEpoch.toString()
          : meal.id,
      profileId: meal.profileId,
      foods: meal.foods,
      timestamp: meal.timestamp,
      preparation: meal.preparation,
      notes: meal.notes,
      photoUrls: meal.photoUrls,
    );
    _mockMealLogs.add(newMeal);
    return newMeal;
  }

  @override
  Future<void> updateMeal(MealLog meal) async {
    final index = _mockMealLogs.indexWhere((m) => m.id == meal.id);
    if (index != -1) {
      _mockMealLogs[index] = meal;
    }
  }

  @override
  Future<void> deleteMeal(String mealId) async {
    _mockMealLogs.removeWhere((m) => m.id == mealId);
  }

  @override
  Future<MealLog?> getMealById(String mealId) async {
    try {
      return _mockMealLogs.firstWhere((m) => m.id == mealId);
    } catch (e) {
      return null;
    }
  }
}

class MockReactionService implements ReactionServiceInterface {
  @override
  Future<List<Reaction>> getReactions(String profileId) async {
    return _mockReactions
        .where((reaction) => reaction.profileId == profileId)
        .toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  @override
  Stream<List<Reaction>> streamReactions(String profileId) {
    return Stream.value(
      _mockReactions
          .where((reaction) => reaction.profileId == profileId)
          .toList()
        ..sort((a, b) => b.startTime.compareTo(a.startTime)),
    );
  }

  @override
  Future<List<Reaction>> getRecentReactions(String profileId, {int limit = 10}) async {
    return _mockReactions
        .where((reaction) => reaction.profileId == profileId)
        .toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  @override
  Future<Reaction> addReaction(Reaction reaction) async {
    final newReaction = Reaction(
      id: reaction.id.isEmpty
          ? DateTime.now().millisecondsSinceEpoch.toString()
          : reaction.id,
      profileId: reaction.profileId,
      foodId: reaction.foodId,
      foodName: reaction.foodName,
      severity: reaction.severity,
      symptoms: reaction.symptoms,
      startTime: reaction.startTime,
      endTime: reaction.endTime,
      notes: reaction.notes,
      photoUrls: reaction.photoUrls,
    );
    _mockReactions.add(newReaction);
    return newReaction;
  }

  @override
  Future<void> updateReaction(Reaction reaction) async {
    final index = _mockReactions.indexWhere((r) => r.id == reaction.id);
    if (index != -1) {
      _mockReactions[index] = reaction;
    }
  }

  @override
  Future<void> deleteReaction(String reactionId) async {
    _mockReactions.removeWhere((r) => r.id == reactionId);
  }

  @override
  Future<Reaction?> getReactionById(String reactionId) async {
    try {
      return _mockReactions.firstWhere((r) => r.id == reactionId);
    } catch (e) {
      return null;
    }
  }
}

class MockPoopService implements PoopServiceInterface {
  @override
  Future<List<PoopLog>> getPoopLogs(String profileId) async {
    return _mockPoopLogs
        .where((log) => log.profileId == profileId)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  @override
  Stream<List<PoopLog>> streamPoopLogs(String profileId) {
    return Stream.value(
      _mockPoopLogs
          .where((log) => log.profileId == profileId)
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp)),
    );
  }

  @override
  Future<List<PoopLog>> getRecentPoopLogs(String profileId, {int limit = 10}) async {
    return _mockPoopLogs
        .where((log) => log.profileId == profileId)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  @override
  Future<PoopLog> addPoopLog(PoopLog poopLog) async {
    final newPoopLog = PoopLog(
      id: poopLog.id.isEmpty
          ? DateTime.now().millisecondsSinceEpoch.toString()
          : poopLog.id,
      profileId: poopLog.profileId,
      timestamp: poopLog.timestamp,
      color: poopLog.color,
      consistency: poopLog.consistency,
      notes: poopLog.notes,
      photoUrls: poopLog.photoUrls,
    );
    _mockPoopLogs.add(newPoopLog);
    return newPoopLog;
  }

  @override
  Future<void> updatePoopLog(PoopLog poopLog) async {
    final index = _mockPoopLogs.indexWhere((p) => p.id == poopLog.id);
    if (index != -1) {
      _mockPoopLogs[index] = poopLog;
    }
  }

  @override
  Future<void> deletePoopLog(String poopLogId) async {
    _mockPoopLogs.removeWhere((p) => p.id == poopLogId);
  }

  @override
  Future<PoopLog?> getPoopLogById(String poopLogId) async {
    try {
      return _mockPoopLogs.firstWhere((p) => p.id == poopLogId);
    } catch (e) {
      return null;
    }
  }
}

class MockProfileService implements ProfileServiceInterface {
  String? _activeProfileId = 'profile_1';

  @override
  Future<List<Profile>> getProfiles() async {
    return List.from(_mockProfiles)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Stream<List<Profile>> streamProfiles() {
    return Stream.value(
      List.from(_mockProfiles)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
    );
  }

  @override
  Future<Profile?> getActiveProfile() async {
    if (_activeProfileId == null) return null;
    try {
      return _mockProfiles.firstWhere((p) => p.id == _activeProfileId);
    } catch (e) {
      return null;
    }
  }

  @override
  Stream<Profile?> streamActiveProfile() {
    // For mock, just return a stream that emits once
    return Stream.fromFuture(getActiveProfile());
  }

  @override
  Future<void> setActiveProfile(String profileId) async {
    _activeProfileId = profileId;
  }

  @override
  Future<Profile> addProfile(Profile profile) async {
    final newProfile = Profile(
      id: profile.id.isEmpty
          ? DateTime.now().millisecondsSinceEpoch.toString()
          : profile.id,
      name: profile.name,
      birthDate: profile.birthDate,
      familyId: profile.familyId,
      parentId: profile.parentId,
      createdAt: profile.createdAt,
    );
    _mockProfiles.add(newProfile);

    // Set as active if first profile
    if (_mockProfiles.length == 1) {
      _activeProfileId = newProfile.id;
    }

    return newProfile;
  }

  @override
  Future<void> updateProfile(Profile profile) async {
    final index = _mockProfiles.indexWhere((p) => p.id == profile.id);
    if (index != -1) {
      _mockProfiles[index] = profile;
    }
  }

  @override
  Future<void> deleteProfile(String profileId) async {
    _mockProfiles.removeWhere((p) => p.id == profileId);
  }

  @override
  Future<Profile?> getProfileById(String profileId) async {
    try {
      return _mockProfiles.firstWhere((p) => p.id == profileId);
    } catch (e) {
      return null;
    }
  }
}

// Static access for backward compatibility (will be phased out)
class MockDataService {
  static List<Food> get foods => _mockFoods;

  static List<Profile> get profiles => _mockProfiles;

  static List<MealLog> get mealLogs => _mockMealLogs;

  static Profile getActiveProfile() {
    return _mockProfiles[0];
  }

  static List<MealLog> getTodayMeals() {
    final today = DateTime.now();
    return _mockMealLogs.where((meal) {
      return meal.timestamp.year == today.year &&
          meal.timestamp.month == today.month &&
          meal.timestamp.day == today.day;
    }).toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  static List<Reaction> getRecentReactions() {
    return List.from(_mockReactions)..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  static List<PoopLog> getRecentPoopLogs() {
    return List.from(_mockPoopLogs)..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  static void addMealLog(MealLog meal) {
    final newMeal = MealLog(
      id: meal.id.isEmpty ? DateTime.now().millisecondsSinceEpoch.toString() : meal.id,
      profileId: meal.profileId,
      foods: meal.foods,
      timestamp: meal.timestamp,
      preparation: meal.preparation,
      notes: meal.notes,
      photoUrls: meal.photoUrls,
    );
    _mockMealLogs.add(newMeal);
  }

  static void addReaction(Reaction reaction) {
    final newReaction = Reaction(
      id: reaction.id.isEmpty ? DateTime.now().millisecondsSinceEpoch.toString() : reaction.id,
      profileId: reaction.profileId,
      foodId: reaction.foodId,
      foodName: reaction.foodName,
      severity: reaction.severity,
      symptoms: reaction.symptoms,
      startTime: reaction.startTime,
      endTime: reaction.endTime,
      notes: reaction.notes,
      photoUrls: reaction.photoUrls,
    );
    _mockReactions.add(newReaction);
  }

  static void addPoopLog(PoopLog poopLog) {
    final newPoopLog = PoopLog(
      id: poopLog.id.isEmpty ? DateTime.now().millisecondsSinceEpoch.toString() : poopLog.id,
      profileId: poopLog.profileId,
      timestamp: poopLog.timestamp,
      color: poopLog.color,
      consistency: poopLog.consistency,
      notes: poopLog.notes,
      photoUrls: poopLog.photoUrls,
    );
    _mockPoopLogs.add(newPoopLog);
  }
}
