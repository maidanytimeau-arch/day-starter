import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'interfaces/meal_service_interface.dart';
import 'interfaces/reaction_service_interface.dart';
import 'interfaces/poop_service_interface.dart';
import 'interfaces/profile_service_interface.dart';
import 'mock_data_service.dart';
import 'firebase/firebase_meal_service.dart';
import 'firebase/firebase_reaction_service.dart';
import 'firebase/firebase_poop_service.dart';
import 'firebase/firebase_profile_service.dart';
import 'firebase/auth_service.dart';

class ServiceFactory {
  static bool _isFirebaseAvailable = false;
  static bool _isFirebaseChecked = false;

  // Check if Firebase is properly configured and user is authenticated
  static Future<bool> isFirebaseAvailable() async {
    if (_isFirebaseChecked) return _isFirebaseAvailable;

    try {
      // Check if Firebase is initialized
      if (Firebase.apps.isEmpty) {
        _isFirebaseAvailable = false;
        _isFirebaseChecked = true;
        return false;
      }

      // Check if user is authenticated
      final user = FirebaseAuth.instance.currentUser;
      _isFirebaseAvailable = user != null;
      _isFirebaseChecked = true;
      return _isFirebaseAvailable;
    } catch (e) {
      print('Firebase availability check failed: $e');
      _isFirebaseAvailable = false;
      _isFirebaseChecked = true;
      return false;
    }
  }

  // Force re-check Firebase availability (call after auth state changes)
  static void refreshFirebaseAvailability() {
    _isFirebaseChecked = false;
  }

  // Get appropriate meal service
  static Future<MealServiceInterface> getMealService() async {
    if (await isFirebaseAvailable()) {
      return FirebaseMealService();
    }
    return MockMealService();
  }

  // Get appropriate reaction service
  static Future<ReactionServiceInterface> getReactionService() async {
    if (await isFirebaseAvailable()) {
      return FirebaseReactionService();
    }
    return MockReactionService();
  }

  // Get appropriate poop service
  static Future<PoopServiceInterface> getPoopService() async {
    if (await isFirebaseAvailable()) {
      return FirebasePoopService();
    }
    return MockPoopService();
  }

  // Get appropriate profile service
  static Future<ProfileServiceInterface> getProfileService() async {
    if (await isFirebaseAvailable()) {
      return FirebaseProfileService();
    }
    return MockProfileService();
  }

  // Get auth service (always Firebase, but handles unauthenticated state)
  static AuthService getAuthService() {
    return AuthService();
  }
}
