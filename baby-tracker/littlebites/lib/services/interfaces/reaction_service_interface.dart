import '../../models/reaction.dart';

abstract class ReactionServiceInterface {
  // Get all reactions for a profile
  Future<List<Reaction>> getReactions(String profileId);

  // Stream of reactions for a profile (real-time updates)
  Stream<List<Reaction>> streamReactions(String profileId);

  // Get recent reactions
  Future<List<Reaction>> getRecentReactions(String profileId, {int limit = 10});

  // Add a new reaction
  Future<Reaction> addReaction(Reaction reaction);

  // Update an existing reaction
  Future<void> updateReaction(Reaction reaction);

  // Delete a reaction
  Future<void> deleteReaction(String reactionId);

  // Get reaction by ID
  Future<Reaction?> getReactionById(String reactionId);
}
