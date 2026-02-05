import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../lib/firebase_options.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Firebase Connection Tests', () {
    late FirebaseFirestore firestore;

    setUp(() async {
      // Initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      firestore = FirebaseFirestore.instance;
    });

    test('Firebase should be initialized', () {
      expect(Firebase.apps.isNotEmpty, isTrue);
    });

    test('Should be able to write and read a test document', () async {
      final collection = firestore.collection('test');

      // Create a test document
      final docRef = await collection.add({
        'message': 'Hello from LittleBites!',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Read it back
      final snapshot = await docRef.get();

      expect(snapshot.exists, isTrue);
      expect(snapshot.data()?['message'], 'Hello from LittleBites!');

      // Clean up
      await docRef.delete();
    });

    test('Should be able to create a test profile', () async {
      final profiles = firestore.collection('profiles');

      final docRef = await profiles.add({
        'id': 'test_profile_1',
        'name': 'Test Baby',
        'birthDate': DateTime(2025, 1, 1),
        'familyId': 'test_family',
        'parentId': 'test_user',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final snapshot = await docRef.get();
      expect(snapshot.exists, isTrue);
      expect(snapshot.data()?['name'], 'Test Baby');

      // Clean up
      await docRef.delete();
    });

    test('Should be able to create a test meal', () async {
      final meals = firestore.collection('meals');

      final docRef = await meals.add({
        'id': 'test_meal_1',
        'profileId': 'test_profile_1',
        'foods': [
          {
            'id': 'food_1',
            'name': 'Test Food',
            'allergens': [],
            'category': 'fruit',
          }
        ],
        'timestamp': DateTime.now(),
        'notes': 'Test meal',
        'loggedBy': 'test_user',
        'photoUrls': [],
        'preparation': 'Pureed',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final snapshot = await docRef.get();
      expect(snapshot.exists, isTrue);
      expect(snapshot.data()?['notes'], 'Test meal');

      // Clean up
      await docRef.delete();
    });
  });
}
