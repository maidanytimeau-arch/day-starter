class Reaction {
  final String id;
  final String profileId;
  final String? foodId;
  final String? foodName; // Name of the food for display
  final int severity; // 1-5
  final List<String> symptoms;
  final DateTime startTime;
  final DateTime? endTime;
  final String? notes;
  final String? loggedBy;
  final List<String>? photoUrls;

  Reaction({
    required this.id,
    required this.profileId,
    this.foodId,
    this.foodName,
    required this.severity,
    required this.symptoms,
    required this.startTime,
    this.endTime,
    this.notes,
    this.loggedBy,
    this.photoUrls,
  });

  // Check if reaction is severe (should alert family)
  bool get isSevere => severity >= 3;

  // Get severity text
  String get severityText {
    switch (severity) {
      case 1:
        return 'Very mild';
      case 2:
        return 'Mild';
      case 3:
        return 'Moderate';
      case 4:
        return 'Severe';
      case 5:
        return 'Very severe';
      default:
        return 'Unknown';
    }
  }

  // Get severity color (for UI)
  String get severityColor {
    if (severity <= 2) return 'green'; // Safe
    if (severity == 3) return 'yellow'; // Warning
    return 'red'; // Danger
  }

  // Format time range for display
  String get timeDisplay {
    final start = '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    if (endTime == null) return '$start - ongoing';
    final end = '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}';
    return '$start - $end';
  }

  // Calculate duration in minutes
  int? get durationMinutes {
    if (endTime == null) return null;
    return endTime!.difference(startTime).inMinutes;
  }

  Reaction copyWith({
    String? id,
    String? profileId,
    String? foodId,
    String? foodName,
    int? severity,
    List<String>? symptoms,
    DateTime? startTime,
    DateTime? endTime,
    String? notes,
    String? loggedBy,
    List<String>? photoUrls,
  }) {
    return Reaction(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      foodId: foodId ?? this.foodId,
      foodName: foodName ?? this.foodName,
      severity: severity ?? this.severity,
      symptoms: symptoms ?? this.symptoms,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      notes: notes ?? this.notes,
      loggedBy: loggedBy ?? this.loggedBy,
      photoUrls: photoUrls ?? this.photoUrls,
    );
  }
}
