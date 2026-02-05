import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../firebase/auth_service.dart';
import '../service_factory.dart';

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return ServiceFactory.getAuthService();
});

// Auth state provider
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authServiceProvider).currentUser;
});

// Is logged in provider
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authServiceProvider).isLoggedIn;
});
