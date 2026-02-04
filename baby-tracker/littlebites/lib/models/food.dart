class Food {
  final String id;
  final String name;
  final List<String> allergens;
  final String category;
  final String? preparation;

  Food({
    required this.id,
    required this.name,
    required this.allergens,
    required this.category,
    this.preparation,
  });

  // Check if food contains any allergens
  bool get hasAllergens => allergens.isNotEmpty;

  // Get allergen display text
  String get allergenDisplay {
    if (allergens.isEmpty) return 'No allergens';
    return allergens.join(', ');
  }

  Food copyWith({
    String? id,
    String? name,
    List<String>? allergens,
    String? category,
    String? preparation,
  }) {
    return Food(
      id: id ?? this.id,
      name: name ?? this.name,
      allergens: allergens ?? this.allergens,
      category: category ?? this.category,
      preparation: preparation ?? this.preparation,
    );
  }
}
