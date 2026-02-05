import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/poop_log.dart';
import '../interfaces/poop_service_interface.dart';

class FirebasePoopService implements PoopServiceInterface {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'poop_logs';

  // Convert PoopLog to Firestore document
  Map<String, dynamic> _poopLogToMap(PoopLog poopLog) {
    return {
      'id': poopLog.id,
      'profileId': poopLog.profileId,
      'timestamp': Timestamp.fromDate(poopLog.timestamp),
      'color': poopLog.color,
      'consistency': poopLog.consistency,
      'notes': poopLog.notes,
      'photoUrls': poopLog.photoUrls ?? [],
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Convert Firestore document to PoopLog
  PoopLog _mapToPoopLog(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PoopLog(
      id: data['id'] as String,
      profileId: data['profileId'] as String,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      color: data['color'] as String? ?? 'brown',
      consistency: data['consistency'] as String? ?? 'soft',
      notes: data['notes'] as String?,
      photoUrls: data['photoUrls'] != null
          ? List<String>.from(data['photoUrls'])
          : null,
    );
  }

  @override
  Future<List<PoopLog>> getPoopLogs(String profileId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('profileId', isEqualTo: profileId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map(_mapToPoopLog).toList();
    } catch (e) {
      throw Exception('Failed to fetch poop logs: $e');
    }
  }

  @override
  Stream<List<PoopLog>> streamPoopLogs(String profileId) {
    return _firestore
        .collection(_collection)
        .where('profileId', isEqualTo: profileId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_mapToPoopLog).toList());
  }

  @override
  Future<List<PoopLog>> getRecentPoopLogs(String profileId, {int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('profileId', isEqualTo: profileId)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map(_mapToPoopLog).toList();
    } catch (e) {
      throw Exception('Failed to fetch recent poop logs: $e');
    }
  }

  @override
  Future<PoopLog> addPoopLog(PoopLog poopLog) async {
    try {
      // Generate ID if not provided
      final id = poopLog.id.isEmpty
          ? _firestore.collection(_collection).doc().id
          : poopLog.id;

      final newPoopLog = poopLog.copyWith(id: id);

      await _firestore
          .collection(_collection)
          .doc(id)
          .set(_poopLogToMap(newPoopLog));

      return newPoopLog;
    } catch (e) {
      throw Exception('Failed to add poop log: $e');
    }
  }

  @override
  Future<void> updatePoopLog(PoopLog poopLog) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(poopLog.id)
          .update(_poopLogToMap(poopLog));
    } catch (e) {
      throw Exception('Failed to update poop log: $e');
    }
  }

  @override
  Future<void> deletePoopLog(String poopLogId) async {
    try {
      await _firestore.collection(_collection).doc(poopLogId).delete();
    } catch (e) {
      throw Exception('Failed to delete poop log: $e');
    }
  }

  @override
  Future<PoopLog?> getPoopLogById(String poopLogId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(poopLogId).get();

      if (!doc.exists) return null;

      return _mapToPoopLog(doc);
    } catch (e) {
      throw Exception('Failed to fetch poop log: $e');
    }
  }
}
