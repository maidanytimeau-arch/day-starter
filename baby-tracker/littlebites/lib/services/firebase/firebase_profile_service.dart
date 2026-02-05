import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/profile.dart';
import '../interfaces/profile_service_interface.dart';

class FirebaseProfileService implements ProfileServiceInterface {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collection = 'profiles';
  final String _userSettingsCollection = 'user_settings';

  // Convert Profile to Firestore document
  Map<String, dynamic> _profileToMap(Profile profile) {
    return {
      'id': profile.id,
      'name': profile.name,
      'birthDate': Timestamp.fromDate(profile.birthDate),
      'familyId': profile.familyId,
      'parentId': profile.parentId,
      'createdAt': Timestamp.fromDate(profile.createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Convert Firestore document to Profile
  Profile _mapToProfile(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Profile(
      id: data['id'] as String,
      name: data['name'] as String,
      birthDate: (data['birthDate'] as Timestamp).toDate(),
      familyId: data['familyId'] as String? ?? '',
      parentId: data['parentId'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  @override
  Future<List<Profile>> getProfiles() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final snapshot = await _firestore
          .collection(_collection)
          .where('parentId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map(_mapToProfile).toList();
    } catch (e) {
      throw Exception('Failed to fetch profiles: $e');
    }
  }

  @override
  Stream<List<Profile>> streamProfiles() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.error(Exception('User not authenticated'));
    }

    return _firestore
        .collection(_collection)
        .where('parentId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_mapToProfile).toList());
  }

  @override
  Future<Profile?> getActiveProfile() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final doc = await _firestore
          .collection(_userSettingsCollection)
          .doc(userId)
          .get();

      if (!doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>;
      final activeProfileId = data['activeProfileId'] as String?;

      if (activeProfileId == null) return null;

      return getProfileById(activeProfileId);
    } catch (e) {
      throw Exception('Failed to fetch active profile: $e');
    }
  }

  @override
  Future<void> setActiveProfile(String profileId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _firestore
          .collection(_userSettingsCollection)
          .doc(userId)
          .set({
        'activeProfileId': profileId,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to set active profile: $e');
    }
  }

  @override
  Future<Profile> addProfile(Profile profile) async {
    try {
      // Generate ID if not provided
      final id = profile.id.isEmpty
          ? _firestore.collection(_collection).doc().id
          : profile.id;

      final newProfile = profile.copyWith(id: id);

      await _firestore
          .collection(_collection)
          .doc(id)
          .set(_profileToMap(newProfile));

      // Set as active if it's the first profile
      final profiles = await getProfiles();
      if (profiles.isEmpty) {
        await setActiveProfile(id);
      }

      return newProfile;
    } catch (e) {
      throw Exception('Failed to add profile: $e');
    }
  }

  @override
  Future<void> updateProfile(Profile profile) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(profile.id)
          .update(_profileToMap(profile));
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  @override
  Future<void> deleteProfile(String profileId) async {
    try {
      await _firestore.collection(_collection).doc(profileId).delete();
    } catch (e) {
      throw Exception('Failed to delete profile: $e');
    }
  }

  @override
  Future<Profile?> getProfileById(String profileId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(profileId).get();

      if (!doc.exists) return null;

      return _mapToProfile(doc);
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
  }
}
