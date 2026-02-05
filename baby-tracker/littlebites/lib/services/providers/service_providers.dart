import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../interfaces/meal_service_interface.dart';
import '../interfaces/reaction_service_interface.dart';
import '../interfaces/poop_service_interface.dart';
import '../interfaces/profile_service_interface.dart';
import '../mock_data_service.dart';
import '../service_factory.dart';

// Meal service provider (async since it depends on Firebase availability)
final mealServiceProvider = FutureProvider<MealServiceInterface>((ref) async {
  try {
    return await ServiceFactory.getMealService();
  } catch (e) {
    // Fallback to mock service if Firebase fails
    return MockMealService();
  }
});

// Reaction service provider
final reactionServiceProvider = FutureProvider<ReactionServiceInterface>((ref) async {
  try {
    return await ServiceFactory.getReactionService();
  } catch (e) {
    // Fallback to mock service if Firebase fails
    return MockReactionService();
  }
});

// Poop service provider
final poopServiceProvider = FutureProvider<PoopServiceInterface>((ref) async {
  try {
    return await ServiceFactory.getPoopService();
  } catch (e) {
    // Fallback to mock service if Firebase fails
    return MockPoopService();
  }
});

// Profile service provider
final profileServiceProvider = FutureProvider<ProfileServiceInterface>((ref) async {
  try {
    return await ServiceFactory.getProfileService();
  } catch (e) {
    // Fallback to mock service if Firebase fails
    return MockProfileService();
  }
});

// Helper provider to get meal service synchronously for widgets
// This will provide mock service if async service isn't ready yet
final mealServiceSyncProvider = Provider<MealServiceInterface>((ref) {
  final asyncValue = ref.watch(mealServiceProvider);
  return asyncValue.value ?? MockMealService();
});

// Helper provider to get reaction service synchronously for widgets
final reactionServiceSyncProvider = Provider<ReactionServiceInterface>((ref) {
  final asyncValue = ref.watch(reactionServiceProvider);
  return asyncValue.value ?? MockReactionService();
});

// Helper provider to get poop service synchronously for widgets
final poopServiceSyncProvider = Provider<PoopServiceInterface>((ref) {
  final asyncValue = ref.watch(poopServiceProvider);
  return asyncValue.value ?? MockPoopService();
});

// Helper provider to get profile service synchronously for widgets
final profileServiceSyncProvider = Provider<ProfileServiceInterface>((ref) {
  final asyncValue = ref.watch(profileServiceProvider);
  return asyncValue.value ?? MockProfileService();
});
