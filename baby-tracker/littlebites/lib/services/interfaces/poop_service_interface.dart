import '../../models/poop_log.dart';

abstract class PoopServiceInterface {
  // Get all poop logs for a profile
  Future<List<PoopLog>> getPoopLogs(String profileId);

  // Stream of poop logs for a profile (real-time updates)
  Stream<List<PoopLog>> streamPoopLogs(String profileId);

  // Get recent poop logs
  Future<List<PoopLog>> getRecentPoopLogs(String profileId, {int limit = 10});

  // Add a new poop log
  Future<PoopLog> addPoopLog(PoopLog poopLog);

  // Update an existing poop log
  Future<void> updatePoopLog(PoopLog poopLog);

  // Delete a poop log
  Future<void> deletePoopLog(String poopLogId);

  // Get poop log by ID
  Future<PoopLog?> getPoopLogById(String poopLogId);
}
