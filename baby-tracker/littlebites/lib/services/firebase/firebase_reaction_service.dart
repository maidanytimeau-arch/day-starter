import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/reaction.dart';
import '../interfaces/reaction_service_interface.dart';

class FirebaseReactionService implements ReactionServiceInterface {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'reactions';

  // Convert Reaction to Firestore document
  Map<String, dynamic> _reactionToMap(Reaction reaction) {
    return {
      'id': reaction.id,
      'profileId': reaction.profileId,
      'foodId': reaction.foodId,
      'foodName': reaction.foodName,
      'severity': reaction.severity,
      'symptoms': reaction.symptoms,
      'startTime': Timestamp.fromDate(reaction.startTime),
      'endTime': reaction.endTime != null
          ? Timestamp.fromDate(reaction.endTime!)
          : null,
      'notes': reaction.notes,
      'photoUrls': reaction.photoUrls ?? [],
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Convert Firestore document to Reaction
  Reaction _mapToReaction(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Reaction(
      id: data['id'] as String,
      profileId: data['profileId'] as String,
      foodId: data['foodId'] as String,
      foodName: data['foodName'] as String?,
      severity: data['severity'] as int,
      symptoms: List<String>.from(data['symptoms'] ?? []),
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: data['endTime'] != null
          ? (data['endTime'] as Timestamp).toDate()
          : null,
      notes: data['notes'] as String?,
      photoUrls: data['photoUrls'] != null
          ? List<String>.from(data['photoUrls'])
          : null,
    );
  }

  @override
  Future<List<Reaction>> getReactions(String profileId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('profileId', isEqualTo: profileId)
          .orderBy('startTime', descending: true)
          .get();

      return snapshot.docs.map(_mapToReaction).toList();
    } catch (e) {
      throw Exception('Failed to fetch reactions: $e');
    }
  }

  @override
  Stream<List<Reaction>> streamReactions(String profileId) {
    return _firestore
        .collection(_collection)
        .where('profileId', isEqualTo: profileId)
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_mapToReaction).toList());
  }

  @override
  Future<List<Reaction>> getRecentReactions(String profileId, {int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('profileId', isEqualTo: profileId)
          .orderBy('startTime', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map(_mapToReaction).toList();
    } catch (e) {
      throw Exception('Failed to fetch recent reactions: $e');
    }
  }

  @override
  Future<Reaction> addReaction(Reaction reaction) async {
    try {
      // Generate ID if not provided
      final id = reaction.id.isEmpty
          ? _firestore.collection(_collection).doc().id
          : reaction.id;

      final newReaction = reaction.copyWith(id: id);

      await _firestore
          .collection(_collection)
          .doc(id)
          .set(_reactionToMap(newReaction));

      return newReaction;
    } catch (e) {
      throw Exception('Failed to add reaction: $e');
    }
  }

  @override
  Future<void> updateReaction(Reaction reaction) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(reaction.id)
          .update(_reactionToMap(reaction));
    } catch (e) {
      throw Exception('Failed to update reaction: $e');
    }
  }

  @override
  Future<void> deleteReaction(String reactionId) async {
    try {
      await _firestore.collection(_collection).doc(reactionId).delete();
    } catch (e) {
      throw Exception('Failed to delete reaction: $e');
    }
  }

  @override
  Future<Reaction?> getReactionById(String reactionId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(reactionId).get();

      if (!doc.exists) return null;

      return _mapToReaction(doc);
    } catch (e) {
      throw Exception('Failed to fetch reaction: $e');
    }
  }
}
