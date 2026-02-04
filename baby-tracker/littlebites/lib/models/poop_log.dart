class PoopLog {
  final String id;
  final String profileId;
  final DateTime timestamp;
  final String color;
  final String consistency;
  final String? notes;
  final List<String>? photoUrls;

  PoopLog({
    required this.id,
    required this.profileId,
    required this.timestamp,
    required this.color,
    required this.consistency,
    this.notes,
    this.photoUrls,
  });

  // Get color emoji for display
  String get colorEmoji {
    switch (color.toLowerCase()) {
      case 'black':
        return '⚫';
      case 'brown':
        return '🟤';
      case 'green':
        return '🟢';
      case 'yellow':
        return '🟡';
      case 'red':
        return '🔴';
      case 'grey':
        return '🩵';
      default:
        return '⚪';
    }
  }

  // Check if poop color is concerning (requires doctor attention)
  bool get isConcerningColor {
    return color.toLowerCase() == 'red' || color.toLowerCase() == 'black';
  }

  // Check if consistency is concerning
  bool get isConcerningConsistency {
    return consistency.toLowerCase() == 'hard' || consistency.toLowerCase() == 'watery';
  }

  // Format time for display
  String get timeDisplay {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  PoopLog copyWith({
    String? id,
    String? profileId,
    DateTime? timestamp,
    String? color,
    String? consistency,
    String? notes,
    List<String>? photoUrls,
  }) {
    return PoopLog(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      timestamp: timestamp ?? this.timestamp,
      color: color ?? this.color,
      consistency: consistency ?? this.consistency,
      notes: notes ?? this.notes,
      photoUrls: photoUrls ?? this.photoUrls,
    );
  }
}
