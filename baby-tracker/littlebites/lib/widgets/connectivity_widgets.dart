import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/connectivity_service.dart';

/// Widget that shows connectivity status
class ConnectivityBanner extends ConsumerWidget {
  final Widget child;

  const ConnectivityBanner({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity = ref.watch(connectivityServiceProvider);

    return Column(
      children: [
        // Show offline banner
        if (connectivity.isOffline)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.orange.shade100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi_off, size: 16, color: Colors.orange.shade800),
                const SizedBox(width: 8),
                Text(
                  'You\'re offline. Changes will sync when connection is restored.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade800,
                  ),
                ),
              ],
            ),
          ),
        // Show checking banner
        if (!connectivity.isOffline && connectivity.isChecking)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.blue.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue.shade800),
                ),
                const SizedBox(width: 8),
                Text(
                  'Checking connection...',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade800,
                  ),
                ),
              ],
            ),
          ),
        // Main content
        Expanded(child: child),
      ],
    );
  }
}

/// Wrapper widget that shows a snack bar when connection changes
class ConnectivityAware extends ConsumerStatefulWidget {
  final Widget child;

  const ConnectivityAware({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<ConnectivityAware> createState() => _ConnectivityAwareState();
}

class _ConnectivityAwareState extends ConsumerState<ConnectivityAware> {
  bool _wasOffline = false;

  @override
  void initState() {
    super.initState();
    _wasOffline = ref.read(connectivityServiceProvider).isOffline;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ConnectivityService>(connectivityServiceProvider, (previous, next) {
      // Show snack bar when connection changes
      if (previous != null && previous.isOffline != next.isOffline) {
        if (!next.isOffline && _wasOffline) {
          // Back online
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You\'re back online!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else if (next.isOffline) {
          // Went offline
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You\'re offline. Some features may be limited.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
      _wasOffline = next.isOffline;
    });

    return widget.child;
  }
}

/// Widget that shows loading state when offline and trying to sync
class OfflineAwareBuilder<T> extends ConsumerWidget {
  final AsyncValue<T> asyncValue;
  final Widget Function(T data) builder;
  final Widget Function()? loadingBuilder;
  final Widget Function(Object error, StackTrace)? errorBuilder;
  final Widget Function()? offlineBuilder;

  const OfflineAwareBuilder({
    super.key,
    required this.asyncValue,
    required this.builder,
    this.loadingBuilder,
    this.errorBuilder,
    this.offlineBuilder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity = ref.watch(connectivityServiceProvider);

    return asyncValue.when(
      data: (data) => builder(data),
      loading: () => loadingBuilder?.call() ??
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading...'),
              ],
            ),
          ),
      error: (error, stack) {
        // If offline, show offline message instead of error
        if (connectivity.isOffline) {
          return offlineBuilder?.call() ??
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_off, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'You\'re offline',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 8),
                    Text('Changes will sync when connection is restored'),
                  ],
                ),
              );
        }
        return errorBuilder?.call(error, stack) ??
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: $error'),
                  if (connectivity.isOffline) ...[
                    const SizedBox(height: 8),
                    const Text('You\'re offline. Some features may be limited.'),
                  ],
                ],
              ),
            );
      },
    );
  }
}
