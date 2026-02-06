import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Service to track network connectivity status
class ConnectivityService extends ChangeNotifier {
  bool _isOnline = true;
  bool _isChecking = false;

  bool get isOnline => _isOnline;
  bool get isChecking => _isChecking;
  bool get isOffline => !_isOnline;

  ConnectivityService() {
    _checkConnectivity();
  }

  /// Check current connectivity status
  Future<void> _checkConnectivity() async {
    _isChecking = true;
    notifyListeners();

    try {
      // Try to connect to a reliable server
      // In a real app, you'd use a dedicated connectivity plugin
      // For now, we'll simulate connectivity check
      await Future.delayed(const Duration(milliseconds: 500));

      // For web, assume online (no native connectivity plugin)
      // For mobile, you'd use connectivity_plus
      _isOnline = true;
    } catch (e) {
      _isOnline = false;
    }

    _isChecking = false;
    notifyListeners();
  }

  /// Manually refresh connectivity status
  Future<void> refresh() async {
    await _checkConnectivity();
  }

  /// Toggle connectivity (for testing purposes)
  void toggleConnectivity() {
    _isOnline = !_isOnline;
    notifyListeners();
  }
}

/// Provider for connectivity service
final connectivityServiceProvider = ChangeNotifierProvider<ConnectivityService>((ref) {
  return ConnectivityService();
});
