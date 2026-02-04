import 'food.dart';

class MealLog {
  final String id;
  final String profileId;
  final List<Food> foods;
  final DateTime timestamp;
  final String? notes;
  final String? loggedBy;
  final List<String>? photoUrls;
  final String? preparation;

  MealLog({
    required this.id,
    required this.profileId,
    required this.foods,
    required this.timestamp,
    this.notes,
    this.loggedBy,
    this.photoUrls,
    this.preparation,
  });

  // Get combined allergens from all foods
  List<String> get allAllergens {
    final allergens = <String>{};
    for (var food in foods) {
      allergens.addAll(food.allergens);
    }
    return allergens.toList();
  }

  // Check if meal has allergens
  bool get hasAllergens => allAllergens.isNotEmpty;

  // Format time for display
  String get timeDisplay {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Get food names for display
  String get foodNamesDisplay {
    return foods.map((f) => f.name).join(', ');
  }

  MealLog copyWith({
    String? id,
    String? profileId,
    List<Food>? foods,
    DateTime? timestamp,
    String? notes,
    String? loggedBy,
    List<String>? photoUrls,
    String? preparation,
  }) {
    return MealLog(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      foods: foods ?? this.foods,
      timestamp: timestamp ?? this.timestamp,
      notes: notes ?? this.notes,
      loggedBy: loggedBy ?? this.loggedBy,
      photoUrls: photoUrls ?? this.photoUrls,
      preparation: preparation ?? this.preparation,
    );
  }
}
