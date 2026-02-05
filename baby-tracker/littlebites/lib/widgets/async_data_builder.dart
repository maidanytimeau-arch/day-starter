import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Helper widget to combine multiple AsyncValue providers and handle loading/error states
class AsyncDataBuilder<T> extends StatelessWidget {
  final List<AsyncValue> asyncValues;
  final Widget Function(List<T> data) builder;
  final Widget Function(Object error, StackTrace)? errorBuilder;
  final Widget? loadingWidget;

  const AsyncDataBuilder({
    super.key,
    required this.asyncValues,
    required this.builder,
    this.errorBuilder,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    // Check if any async value is loading
    for (final asyncValue in asyncValues) {
      if (asyncValue.isLoading) {
        return loadingWidget ?? const Center(child: CircularProgressIndicator());
      }

      if (asyncValue.hasError) {
        return errorBuilder?.call(
              asyncValue.error!,
              asyncValue.stackTrace ?? StackTrace.empty,
            ) ??
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${asyncValue.error}'),
                ],
              ),
            );
      }
    }

    // All data is available
    try {
      final data = asyncValues.map((av) => av.value as T).toList();
      return builder(data);
    } catch (e) {
      return errorBuilder?.call(e, StackTrace.current) ??
          Center(child: Text('Error: $e'));
    }
  }
}

/// Extension to make AsyncValue handling more concise
extension AsyncValueExtensions<T> on AsyncValue<T> {
  Widget whenOrNull({
    required Widget Function(T data) data,
    Widget Function(Object error, StackTrace)? error,
    Widget? loading,
  }) {
    return when(
      data: data,
      error: error ?? (e, s) => Center(child: Text('Error: $e')),
      loading: () => loading ?? const Center(child: CircularProgressIndicator()),
    );
  }
}
