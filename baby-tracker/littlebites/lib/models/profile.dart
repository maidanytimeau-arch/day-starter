class Profile {
  final String id;
  final String name;
  final DateTime birthDate;
  final String? avatarUrl;
  final String familyId;
  final String parentId;
  final DateTime createdAt;

  Profile({
    required this.id,
    required this.name,
    required this.birthDate,
    this.avatarUrl,
    required this.familyId,
    required this.parentId,
    required this.createdAt,
  });

  // Calculate age in months
  int get ageInMonths {
    final now = DateTime.now();
    return (now.year - birthDate.year) * 12 + (now.month - birthDate.month);
  }

  // Age as string for display
  String get ageDisplay {
    final months = ageInMonths;
    if (months < 1) return 'Newborn';
    if (months < 12) return '$months month${months == 1 ? '' : 's'}';
    final years = months ~/ 12;
    final remainingMonths = months % 12;
    if (remainingMonths == 0) return '$years year${years == 1 ? '' : 's'}';
    return '$years year${years == 1 ? '' : 's'}, $remainingMonths month${remainingMonths == 1 ? '' : 's'}';
  }

  Profile copyWith({
    String? id,
    String? name,
    DateTime? birthDate,
    String? avatarUrl,
    String? familyId,
    String? parentId,
    DateTime? createdAt,
  }) {
    return Profile(
      id: id ?? this.id,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      familyId: familyId ?? this.familyId,
      parentId: parentId ?? this.parentId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
