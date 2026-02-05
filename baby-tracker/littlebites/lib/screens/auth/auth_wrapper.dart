import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/providers/auth_providers.dart';
import '../../services/providers/service_providers.dart';
import '../../services/service_factory.dart';
import '../../routes/app_routes.dart';
import '../create_profile_screen.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

enum AuthFlowState { checkingAuth, authLoading, loggedIn, needProfile, loggedOut, error }

class AuthWrapper extends ConsumerStatefulWidget {
  final Widget child;

  const AuthWrapper({super.key, required this.child});

  @override
  ConsumerState<AuthWrapper> createState() => AuthWrapperState();
}

class AuthWrapperState extends ConsumerState<AuthWrapper> {
  AuthFlowState _flowState = AuthFlowState.checkingAuth;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Refresh Firebase availability check
    ServiceFactory.refreshFirebaseAvailability();

    // Small delay to allow auth state to load
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    final user = ref.read(authServiceProvider).currentUser;

    if (user == null) {
      setState(() {
        _flowState = AuthFlowState.loggedOut;
      });
    } else {
      // User is logged in, check if they have profiles
      setState(() {
        _flowState = AuthFlowState.authLoading;
      });

      try {
        final profileService = await ref.read(profileServiceProvider.future);
        final profiles = await profileService.getProfiles();

        if (profiles.isEmpty) {
          setState(() {
            _flowState = AuthFlowState.needProfile;
          });
        } else {
          setState(() {
            _flowState = AuthFlowState.loggedIn;
          });
        }
      } catch (e) {
        setState(() {
          _flowState = AuthFlowState.error;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _retry() {
    setState(() {
      _flowState = AuthFlowState.checkingAuth;
      _errorMessage = null;
    });
    _checkAuth();
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while checking auth
    if (_flowState == AuthFlowState.checkingAuth) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    // User needs to create a profile
    if (_flowState == AuthFlowState.needProfile) {
      return MaterialApp(
        title: 'LittleBites - Create Profile',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4A90E2),
            primary: const Color(0xFF4A90E2),
          ),
          useMaterial3: true,
        ),
        home: const CreateProfileScreen(),
      );
    }

    // Error state
    if (_flowState == AuthFlowState.error) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text('Something went wrong'),
                const SizedBox(height: 8),
                Text(_errorMessage ?? 'Unknown error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _retry,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Watch auth state for changes
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        // If user is authenticated and has profiles, show the app
        if (user != null && _flowState == AuthFlowState.loggedIn) {
          return widget.child;
        }

        // Otherwise, show login screen
        return MaterialApp(
          title: 'LittleBites - Login',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF4A90E2),
              primary: const Color(0xFF4A90E2),
            ),
            useMaterial3: true,
          ),
          initialRoute: '/login',
          routes: {
            '/login': (context) => const LoginScreen(),
            '/signup': (context) => const SignupScreen(),
            AppRoutes.createProfile: (context) => const CreateProfileScreen(),
          },
        );
      },
      loading: () => const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error: (error, stack) => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text('Something went wrong'),
                const SizedBox(height: 8),
                Text(error.toString()),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _retry,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
