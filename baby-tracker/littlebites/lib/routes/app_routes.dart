import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/placeholder_screens.dart';
import '../screens/log_reaction_screen.dart' as log_reaction;
import '../screens/create_profile_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String addMeal = '/add-meal';
  static const String foodHistory = '/food-history';
  static const String logReaction = '/log-reaction';
  static const String poopLog = '/poop-log';
  static const String profiles = '/profiles';
  static const String settings = '/settings';
  static const String createProfile = '/create-profile';
}

class AppNavigator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case AppRoutes.addMeal:
        return MaterialPageRoute(builder: (_) => const AddMealScreen());
      case AppRoutes.foodHistory:
        return MaterialPageRoute(builder: (_) => const FoodHistoryScreen());
      case AppRoutes.logReaction:
        return MaterialPageRoute(builder: (_) => const log_reaction.LogReactionScreen());
      case AppRoutes.poopLog:
        return MaterialPageRoute(builder: (_) => const PoopLogScreen());
      case AppRoutes.profiles:
        return MaterialPageRoute(builder: (_) => const ProfilesScreen());
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case AppRoutes.createProfile:
        return MaterialPageRoute(builder: (_) => const CreateProfileScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Page not found'),
            ),
          ),
        );
    }
  }

  static void navigateTo(BuildContext context, String route) {
    Navigator.pushNamed(context, route);
  }

  static void navigateBack(BuildContext context) {
    Navigator.pop(context);
  }
}
