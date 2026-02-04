# Data Models - LittleBites

**Phase:** Development
**Created:** 2026-02-04
**Purpose:** Define data structures for Firestore and Flutter

---

## Model Overview

**Core Models:**
1. `User` - Caregiver account
2. `Profile` - Child profile
3. `Food` - Food item with allergens
4. `Log` - Generic log entry (meal, reaction, poop)
5. `Reaction` - Specific reaction log
6. `PoopLog` - Specific poop log
7. `Family` - Family/caregiver group

---

## 1. User Model

**Purpose:** Represents a caregiver/user account

**Firestore Collection:** `users/{userId}`

**Dart Model:**

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String email;
  final String name;
  final String? avatarUrl;
  final String? familyId;
  final DateTime createdAt;
  final DateTime? lastActiveAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
    this.familyId,
    required this.createdAt,
    this.lastActiveAt,
  });

  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      avatarUrl: data['avatarUrl'],
      familyId: data['familyId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastActiveAt: data['lastActiveAt'] != null
          ? (data['lastActiveAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'avatarUrl': avatarUrl,
      'familyId': familyId,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActiveAt': lastActiveAt != null
          ? Timestamp.fromDate(lastActiveAt!)
          : null,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? avatarUrl,
    String? familyId,
    DateTime? createdAt,
    DateTime? lastActiveAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      familyId: familyId ?? this.familyId,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }
}
```

**Firestore Structure:**

```javascript
users/{userId}/
{
  "email": "bob@email.com",
  "name": "Bob",
  "avatarUrl": "https://storage.googleapis.com/...",
  "familyId": "family_abc123",
  "createdAt": Timestamp(2026, 2, 4),
  "lastActiveAt": Timestamp(2026, 2, 4)
}
```

---

## 2. Profile Model (Child)

**Purpose:** Represents a child's profile

**Firestore Collection:** `profiles/{profileId}`

**Dart Model:**

```dart
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

  factory Profile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Profile(
      id: doc.id,
      name: data['name'] ?? '',
      birthDate: (data['birthDate'] as Timestamp).toDate(),
      avatarUrl: data['avatarUrl'],
      familyId: data['familyId'] ?? '',
      parentId: data['parentId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'birthDate': Timestamp.fromDate(birthDate),
      'avatarUrl': avatarUrl,
      'familyId': familyId,
      'parentId': parentId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Calculate age in months
  int get ageInMonths {
    final now = DateTime.now();
    final months = (now.year - birthDate.year) * 12 + now.month - birthDate.month;
    return months;
  }

  // Format age as "X months, Y weeks"
  String get formattedAge {
    final months = ageInMonths;
    final weeks = ((DateTime.now().difference(birthDate).inDays % 30) / 7).floor();
    return '$months months, $weeks weeks';
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
```

**Firestore Structure:**

```javascript
profiles/{profileId}/
{
  "name": "Emma",
  "birthDate": Timestamp(2025, 7, 15),
  "avatarUrl": "https://storage.googleapis.com/...",
  "familyId": "family_abc123",
  "parentId": "user_xyz789",
  "createdAt": Timestamp(2026, 2, 4)
}
```

---

## 3. Food Model

**Purpose:** Represents a food item with allergen information

**Firestore Collection:** `foods/{foodId}`

**Dart Model:**

```dart
enum FoodCategory {
  fruit,
  vegetable,
  protein,
  grain,
  dairy,
  other,
}

enum PreparationMethod {
  pureed,
  mashed,
  chopped,
  fingerFood,
  steamed,
  roasted,
  raw,
}

class Food {
  final String id;
  final String name;
  final List<String> allergens;
  final FoodCategory category;
  final String? preparation;
  final DateTime createdAt;

  Food({
    required this.id,
    required this.name,
    required this.allergens,
    required this.category,
    this.preparation,
    required this.createdAt,
  });

  factory Food.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Food(
      id: doc.id,
      name: data['name'] ?? '',
      allergens: List<String>.from(data['allergens'] ?? []),
      category: FoodCategory.values.firstWhere(
        (e) => e.name == data['category'],
        orElse: () => FoodCategory.other,
      ),
      preparation: data['preparation'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'allergens': allergens,
      'category': category.name,
      'preparation': preparation,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Check if food contains any of the specified allergens
  bool containsAllergen(List<String> allergensToCheck) {
    return allergens.any((a) => allergensToCheck.contains(a));
  }

  // Check if food is safe (no allergens)
  bool get isSafe => allergens.isEmpty;

  Food copyWith({
    String? id,
    String? name,
    List<String>? allergens,
    FoodCategory? category,
    String? preparation,
    DateTime? createdAt,
  }) {
    return Food(
      id: id ?? this.id,
      name: name ?? this.name,
      allergens: allergens ?? this.allergens,
      category: category ?? this.category,
      preparation: preparation ?? this.preparation,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
```

**Common Allergens:**
```dart
const commonAllergens = [
  'nuts',
  'peanuts',
  'dairy',
  'eggs',
  'soy',
  'wheat',
  'fish',
  'shellfish',
  'sesame',
];
```

**Firestore Structure:**

```javascript
foods/{foodId}/
{
  "name": "Banana",
  "allergens": [],
  "category": "fruit",
  "preparation": "fingerFood",
  "createdAt": Timestamp(2026, 2, 4)
}

foods/{foodId}/
{
  "name": "Peanut",
  "allergens": ["peanuts", "nuts"],
  "category": "protein",
  "preparation": null,
  "createdAt": Timestamp(2026, 2, 4)
}
```

---

## 4. Log Model (Generic)

**Purpose:** Generic log entry for meals, reactions, poop logs

**Firestore Collection:** `logs/{logId}`

**Dart Model:**

```dart
enum LogType {
  meal,
  reaction,
  poop,
}

class Log {
  final String id;
  final LogType type;
  final String profileId;
  final String familyId;
  final Map<String, dynamic> data; // Flexible data per log type
  final DateTime timestamp;
  final String loggedBy;
  final List<String> photos;
  final String? notes;

  Log({
    required this.id,
    required this.type,
    required this.profileId,
    required this.familyId,
    required this.data,
    required this.timestamp,
    required this.loggedBy,
    required this.photos,
    this.notes,
  });

  factory Log.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Log(
      id: doc.id,
      type: LogType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => LogType.meal,
      ),
      profileId: data['profileId'] ?? '',
      familyId: data['familyId'] ?? '',
      data: data['data'] ?? {},
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      loggedBy: data['loggedBy'] ?? '',
      photos: List<String>.from(data['photos'] ?? []),
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'profileId': profileId,
      'familyId': familyId,
      'data': data,
      'timestamp': Timestamp.fromDate(timestamp),
      'loggedBy': loggedBy,
      'photos': photos,
      'notes': notes,
    };
  }

  Log copyWith({
    String? id,
    LogType? type,
    String? profileId,
    String? familyId,
    Map<String, dynamic>? data,
    DateTime? timestamp,
    String? loggedBy,
    List<String>? photos,
    String? notes,
  }) {
    return Log(
      id: id ?? this.id,
      type: type ?? this.type,
      profileId: profileId ?? this.profileId,
      familyId: familyId ?? this.familyId,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
      loggedBy: loggedBy ?? this.loggedBy,
      photos: photos ?? this.photos,
      notes: notes ?? this.notes,
    );
  }
}
```

**Firestore Structure (Meal):**

```javascript
logs/{logId}/
{
  "type": "meal",
  "profileId": "profile_abc123",
  "familyId": "family_xyz789",
  "data": {
    "foods": [
      {"name": "Banana", "id": "food_123"},
      {"name": "Oatmeal", "id": "food_456"}
    ],
    "preparation": "pureed"
  },
  "timestamp": Timestamp(2026, 2, 4, 16, 30),
  "loggedBy": "user_abc123",
  "photos": ["https://storage.googleapis.com/..."],
  "notes": "She loved the banana!"
}
```

**Firestore Structure (Reaction):**

```javascript
logs/{logId}/
{
  "type": "reaction",
  "profileId": "profile_abc123",
  "familyId": "family_xyz789",
  "data": {
    "foodId": "food_456",
    "foodName": "Peanut",
    "severity": 3,
    "symptoms": ["rash", "hives"]
  },
  "timestamp": Timestamp(2026, 2, 4, 16, 30),
  "loggedBy": "user_abc123",
  "photos": [],
  "notes": "Mild rash on face"
}
```

**Firestore Structure (Poop):**

```javascript
logs/{logId}/
{
  "type": "poop",
  "profileId": "profile_abc123",
  "familyId": "family_xyz789",
  "data": {
    "color": "green",
    "consistency": "soft"
  },
  "timestamp": Timestamp(2026, 2, 4, 16, 30),
  "loggedBy": "user_abc123",
  "photos": ["https://storage.googleapis.com/..."],
  "notes": null
}
```

---

## 5. Reaction Helper Model

**Purpose:** Helper for reaction-specific logic

**Dart Model:**

```dart
enum ReactionSeverity {
  veryMild, // 1
  mild,     // 2
  moderate, // 3
  severe,   // 4
  verySevere, // 5
}

enum ReactionSymptom {
  rash,
  hives,
  swelling,
  vomiting,
  diarrhea,
  coughing,
  wheezing,
  runnyNose,
  sneezing,
  itchyEyes,
  other,
}

class ReactionData {
  final String? foodId;
  final String? foodName;
  final ReactionSeverity severity;
  final List<ReactionSymptom> symptoms;
  final DateTime? startTime;
  final DateTime? endTime;

  ReactionData({
    this.foodId,
    this.foodName,
    required this.severity,
    required this.symptoms,
    this.startTime,
    this.endTime,
  });

  factory ReactionData.fromMap(Map<String, dynamic> data) {
    return ReactionData(
      foodId: data['foodId'],
      foodName: data['foodName'],
      severity: ReactionSeverity.values[data['severity'] - 1],
      symptoms: (data['symptoms'] as List)
          .map((s) => ReactionSymptom.values.firstWhere(
                (e) => e.name == s,
                orElse: () => ReactionSymptom.other,
              ))
          .toList(),
      startTime: data['startTime'] != null
          ? (data['startTime'] as Timestamp).toDate()
          : null,
      endTime: data['endTime'] != null
          ? (data['endTime'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'foodId': foodId,
      'foodName': foodName,
      'severity': severity.index + 1,
      'symptoms': symptoms.map((s) => s.name).toList(),
      'startTime': startTime != null ? Timestamp.fromDate(startTime!) : null,
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
    };
  }

  // Check if reaction requires immediate medical attention
  bool get isEmergency => severity == ReactionSeverity.verySevere;

  // Check if reaction should alert family
  bool get shouldAlertFamily => severity.index >= 2; // moderate or worse

  // Format severity for display
  String get severityLabel {
    switch (severity) {
      case ReactionSeverity.veryMild:
        return 'Very Mild';
      case ReactionSeverity.mild:
        return 'Mild';
      case ReactionSeverity.moderate:
        return 'Moderate';
      case ReactionSeverity.severe:
        return 'Severe';
      case ReactionSeverity.verySevere:
        return 'Very Severe';
    }
  }

  // Format symptoms for display
  String get symptomsLabel {
    return symptoms.map((s) {
      switch (s) {
        case ReactionSymptom.rash:
          return 'Rash';
        case ReactionSymptom.hives:
          return 'Hives';
        case ReactionSymptom.swelling:
          return 'Swelling';
        case ReactionSymptom.vomiting:
          return 'Vomiting';
        case ReactionSymptom.diarrhea:
          return 'Diarrhea';
        case ReactionSymptom.coughing:
          return 'Coughing';
        case ReactionSymptom.wheezing:
          return 'Wheezing';
        case ReactionSymptom.runnyNose:
          return 'Runny nose';
        case ReactionSymptom.sneezing:
          return 'Sneezing';
        case ReactionSymptom.itchyEyes:
          return 'Itchy eyes';
        case ReactionSymptom.other:
          return 'Other';
      }
    }).join(', ');
  }
}
```

---

## 6. PoopLog Helper Model

**Purpose:** Helper for poop log-specific logic

**Dart Model:**

```dart
enum PoopColor {
  black,
  brown,
  green,
  yellow,
  red,
  grey,
}

enum PoopConsistency {
  hard,
  formed,
  soft,
  loose,
  watery,
}

class PoopData {
  final PoopColor color;
  final PoopConsistency consistency;

  PoopData({
    required this.color,
    required this.consistency,
  });

  factory PoopData.fromMap(Map<String, dynamic> data) {
    return PoopData(
      color: PoopColor.values.firstWhere(
        (e) => e.name == data['color'],
        orElse: () => PoopColor.brown,
      ),
      consistency: PoopConsistency.values.firstWhere(
        (e) => e.name == data['consistency'],
        orElse: () => PoopConsistency.formed,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'color': color.name,
      'consistency': consistency.name,
    };
  }

  // Check if poop is concerning
  bool get isConcerning {
    return color == PoopColor.red || 
           color == PoopColor.black ||
           consistency == PoopConsistency.watery;
  }

  // Format color for display
  String get colorLabel {
    switch (color) {
      case PoopColor.black:
        return 'Black';
      case PoopColor.brown:
        return 'Brown';
      case PoopColor.green:
        return 'Green';
      case PoopColor.yellow:
        return 'Yellow';
      case PoopColor.red:
        return 'Red';
      case PoopColor.grey:
        return 'Grey';
    }
  }

  // Format consistency for display
  String get consistencyLabel {
    switch (consistency) {
      case PoopConsistency.hard:
        return 'Hard';
      case PoopConsistency.formed:
        return 'Formed';
      case PoopConsistency.soft:
        return 'Soft';
      case PoopConsistency.loose:
        return 'Loose';
      case PoopConsistency.watery:
        return 'Watery';
    }
  }
}
```

---

## 7. Family Model

**Purpose:** Represents a family/caregiver group

**Firestore Collection:** `families/{familyId}`

**Dart Model:**

```dart
class Family {
  final String id;
  final String name;
  final List<String> memberIds; // User IDs
  final DateTime createdAt;

  Family({
    required this.id,
    required this.name,
    required this.memberIds,
    required this.createdAt,
  });

  factory Family.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Family(
      id: doc.id,
      name: data['name'] ?? '',
      memberIds: List<String>.from(data['memberIds'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'memberIds': memberIds,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Family copyWith({
    String? id,
    String? name,
    List<String>? memberIds,
    DateTime? createdAt,
  }) {
    return Family(
      id: id ?? this.id,
      name: name ?? this.name,
      memberIds: memberIds ?? this.memberIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
```

**Firestore Structure:**

```javascript
families/{familyId}/
{
  "name": "Bob's Family",
  "memberIds": ["user_abc123", "user_def456", "user_ghi789"],
  "createdAt": Timestamp(2026, 2, 4)
}
```

---

## Firestore Indexes

**Required indexes for queries:**

1. **Query logs by profile and timestamp (descending):**
   - Collection: `logs`
   - Fields: `profileId` (ascending), `timestamp` (descending)

2. **Query logs by family and timestamp (descending):**
   - Collection: `logs`
   - Fields: `familyId` (ascending), `timestamp` (descending)

3. **Query logs by profile, type, and timestamp (descending):**
   - Collection: `logs`
   - Fields: `profileId` (ascending), `type` (ascending), `timestamp` (descending)

**Create indexes in Firebase Console:**
- Firestore → Indexes → Create Index
- Or via CLI: `firebase deploy --only firestore:indexes`

---

## Model Relationships

```
User (1) ←→ (1) Family
    ↓
    └─→ (many) Profile (children)
          ↓
          └─→ (many) Log (meals, reactions, poop)
                ↓
                └─→ (many) Food (references)
```

**Access patterns:**
- User can access all profiles in their family
- Family members can access all logs for family profiles
- Food database is public read, authenticated write

---

## Usage Examples

### Create a new user
```dart
final user = User(
  id: FirebaseAuth.instance.currentUser!.uid,
  email: 'bob@email.com',
  name: 'Bob',
  createdAt: DateTime.now(),
);

await FirebaseFirestore.instance
    .collection('users')
    .doc(user.id)
    .set(user.toMap());
```

### Create a new child profile
```dart
final profile = Profile(
  id: FirebaseFirestore.instance.collection('profiles').doc().id,
  name: 'Emma',
  birthDate: DateTime(2025, 7, 15),
  familyId: 'family_abc123',
  parentId: user.id,
  createdAt: DateTime.now(),
);

await FirebaseFirestore.instance
    .collection('profiles')
    .doc(profile.id)
    .set(profile.toMap());
```

### Log a meal
```dart
final log = Log(
  id: FirebaseFirestore.instance.collection('logs').doc().id,
  type: LogType.meal,
  profileId: profile.id,
  familyId: user.familyId!,
  data: {
    'foods': [
      {'name': 'Banana', 'id': 'food_123'},
      {'name': 'Oatmeal', 'id': 'food_456'},
    ],
    'preparation': 'pureed',
  },
  timestamp: DateTime.now(),
  loggedBy: user.id,
  photos: [],
  notes: 'She loved it!',
);

await FirebaseFirestore.instance
    .collection('logs')
    .doc(log.id)
    .set(log.toMap());
```

### Query today's meals for a profile
```dart
final today = DateTime.now();
final startOfDay = DateTime(today.year, today.month, today.day);
final endOfDay = startOfDay.add(const Duration(days: 1));

final query = FirebaseFirestore.instance
    .collection('logs')
    .where('profileId', isEqualTo: profile.id)
    .where('type', isEqualTo: 'meal')
    .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
    .where('timestamp', isLessThan: Timestamp.fromDate(endOfDay))
    .orderBy('timestamp', descending: true)
    .withConverter(
      fromFirestore: (snapshot, _) => Log.fromFirestore(snapshot),
      toFirestore: (log, _) => log.toMap(),
    );

final snapshot = await query.get();
final meals = snapshot.docs.map((doc) => doc.data()).toList();
```

---

## Next Steps

1. ✅ Data models defined
2. ⏳ Create Flutter project
3. ⏳ Set up Firebase
4. ⏳ Implement Riverpod providers
5. ⏳ Build UI screens

---

*Models ready for implementation! 📊*
