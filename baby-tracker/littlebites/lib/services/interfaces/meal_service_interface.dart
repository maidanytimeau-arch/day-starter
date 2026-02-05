import '../../models/meal_log.dart';

abstract class MealServiceInterface {
  // Get all meals for a profile
  Future<List<MealLog>> getMeals(String profileId);

  // Stream of meals for a profile (real-time updates)
  Stream<List<MealLog>> streamMeals(String profileId);

  // Get today's meals for a profile
  Future<List<MealLog>> getTodayMeals(String profileId);

  // Add a new meal
  Future<MealLog> addMeal(MealLog meal);

  // Update an existing meal
  Future<void> updateMeal(MealLog meal);

  // Delete a meal
  Future<void> deleteMeal(String mealId);

  // Get meal by ID
  Future<MealLog?> getMealById(String mealId);
}
