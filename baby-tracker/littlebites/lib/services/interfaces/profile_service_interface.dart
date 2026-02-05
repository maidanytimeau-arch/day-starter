import '../../models/profile.dart';

abstract class ProfileServiceInterface {
  // Get all profiles for current user
  Future<List<Profile>> getProfiles();

  // Stream of profiles (real-time updates)
  Stream<List<Profile>> streamProfiles();

  // Get active profile
  Future<Profile?> getActiveProfile();

  // Stream of active profile (real-time updates)
  Stream<Profile?> streamActiveProfile();

  // Set active profile
  Future<void> setActiveProfile(String profileId);

  // Add a new profile
  Future<Profile> addProfile(Profile profile);

  // Update an existing profile
  Future<void> updateProfile(Profile profile);

  // Delete a profile
  Future<void> deleteProfile(String profileId);

  // Get profile by ID
  Future<Profile?> getProfileById(String profileId);
}
