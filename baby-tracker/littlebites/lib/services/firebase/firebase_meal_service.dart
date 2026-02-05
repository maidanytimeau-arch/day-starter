import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/meal_log.dart';
import '../../models/food.dart';
import '../interfaces/meal_service_interface.dart';

class FirebaseMealService implements MealServiceInterface {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'meals';

  // Convert MealLog to Firestore document
  Map<String, dynamic> _mealToMap(MealLog meal) {
    return {
      'id': meal.id,
      'profileId': meal.profileId,
      'foods': meal.foods.map((food) => _foodToMap(food)).toList(),
      'timestamp': Timestamp.fromDate(meal.timestamp),
      'notes': meal.notes,
      'loggedBy': meal.loggedBy,
      'photoUrls': meal.photoUrls ?? [],
      'preparation': meal.preparation,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Convert Food to map
  Map<String, dynamic> _foodToMap(Food food) {
    return {
      'id': food.id,
      'name': food.name,
      'allergens': food.allergens,
      'category': food.category,
    };
  }

  // Convert Firestore document to MealLog
  MealLog _mapToMeal(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MealLog(
      id: data['id'] as String,
      profileId: data['profileId'] as String,
      foods: (data['foods'] as List<dynamic>).map((foodData) {
        return Food(
          id: foodData['id'] as String,
          name: foodData['name'] as String,
          allergens: List<String>.from(foodData['allergens'] ?? []),
          category: foodData['category'] as String? ?? 'other',
        );
      }).toList(),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      notes: data['notes'] as String?,
      loggedBy: data['loggedBy'] as String?,
      photoUrls: data['photoUrls'] != null
          ? List<String>.from(data['photoUrls'])
          : null,
      preparation: data['preparation'] as String?,
    );
  }

  @override
  Future<List<MealLog>> getMeals(String profileId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('profileId', isEqualTo: profileId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map(_mapToMeal).toList();
    } catch (e) {
      throw Exception('Failed to fetch meals: $e');
    }
  }

  @override
  Stream<List<MealLog>> streamMeals(String profileId) {
    return _firestore
        .collection(_collection)
        .where('profileId', isEqualTo: profileId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_mapToMeal).toList());
  }

  @override
  Future<List<MealLog>> getTodayMeals(String profileId) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await _firestore
          .collection(_collection)
          .where('profileId', isEqualTo: profileId)
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('timestamp', isLessThan: Timestamp.fromDate(endOfDay))
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map(_mapToMeal).toList();
    } catch (e) {
      throw Exception('Failed to fetch today\'s meals: $e');
    }
  }

  @override
  Future<MealLog> addMeal(MealLog meal) async {
    try {
      // Generate ID if not provided
      final id = meal.id.isEmpty
          ? _firestore.collection(_collection).doc().id
          : meal.id;

      final newMeal = meal.copyWith(id: id);

      await _firestore
          .collection(_collection)
          .doc(id)
          .set(_mealToMap(newMeal));

      return newMeal;
    } catch (e) {
      throw Exception('Failed to add meal: $e');
    }
  }

  @override
  Future<void> updateMeal(MealLog meal) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(meal.id)
          .update(_mealToMap(meal));
    } catch (e) {
      throw Exception('Failed to update meal: $e');
    }
  }

  @override
  Future<void> deleteMeal(String mealId) async {
    try {
      await _firestore.collection(_collection).doc(mealId).delete();
    } catch (e) {
      throw Exception('Failed to delete meal: $e');
    }
  }

  @override
  Future<MealLog?> getMealById(String mealId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(mealId).get();

      if (!doc.exists) return null;

      return _mapToMeal(doc);
    } catch (e) {
      throw Exception('Failed to fetch meal: $e');
    }
  }
}
