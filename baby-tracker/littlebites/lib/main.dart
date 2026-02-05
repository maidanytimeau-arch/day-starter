import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'routes/app_routes.dart';
import 'screens/home_screen.dart';
import 'screens/add_meal_screen.dart';
import 'screens/food_history_screen.dart';
import 'screens/log_reaction_screen.dart';
import 'screens/poop_log_screen.dart';
import 'screens/profiles_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/auth/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Try to initialize Firebase, but don't fail if not configured
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Enable Firestore offline persistence
    await FirebaseFirestore.instance.enablePersistence(
      const PersistenceSettings(
        synchronizeTabs: true,
      ),
    );

    print('✅ Firebase initialized successfully');
    print('✅ Firestore offline persistence enabled');
  } catch (e) {
    // Persistence already enabled or other non-fatal error
    print('⚠️ Firebase not configured yet (using mock data): $e');
  }

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthWrapper(
      child: MaterialApp(
        title: 'LittleBites',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4A90E2),
            primary: const Color(0xFF4A90E2),
          ),
          scaffoldBackgroundColor: Colors.white,
          fontFamily: 'Poppins',
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFF2C3E50),
            elevation: 0,
            centerTitle: true,
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        initialRoute: AppRoutes.home,
        routes: {
          AppRoutes.home: (context) => const HomeScreen(),
          AppRoutes.addMeal: (context) => const AddMealScreen(),
          AppRoutes.foodHistory: (context) => const FoodHistoryScreen(),
          AppRoutes.logReaction: (context) => const LogReactionScreen(),
          AppRoutes.poopLog: (context) => const PoopLogScreen(),
          AppRoutes.profiles: (context) => const ProfilesScreen(),
          AppRoutes.settings: (context) => const SettingsScreen(),
        },
      ),
    );
  }
}
