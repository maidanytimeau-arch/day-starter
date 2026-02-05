import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/providers/auth_providers.dart';
import '../../services/service_factory.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class AuthWrapper extends ConsumerStatefulWidget {
  final Widget child;

  const AuthWrapper({super.key, required this.child});

  @override
  ConsumerState<AuthWrapper> createState() => AuthWrapperState();
}

class AuthWrapperState extends ConsumerState<AuthWrapper> {
  bool _isLoading = true;

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

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    // Show loading while checking auth
    if (_isLoading) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return authState.when(
      data: (user) {
        // If user is authenticated, show the app
        if (user != null) {
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
