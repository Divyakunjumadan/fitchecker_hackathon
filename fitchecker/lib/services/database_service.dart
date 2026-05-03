import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../models/measurement.dart';

class DatabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // ─── PROFILES ───────────────────────────────────────────

  /// Fetch all profiles for the current user
  Future<List<UserProfile>> getProfiles(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => UserProfile.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get a single profile by ID
  Future<UserProfile?> getProfile(String profileId) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', profileId)
          .maybeSingle();

      if (response == null) return null;
      return UserProfile.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Create a new profile
  Future<UserProfile> createProfile(UserProfile profile) async {
    try {
      final response = await _client
          .from('profiles')
          .insert(profile.toJson())
          .select()
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Update an existing profile
  Future<UserProfile> updateProfile(UserProfile profile) async {
    try {
      final response = await _client
          .from('profiles')
          .update(profile.toJson())
          .eq('id', profile.id!)
          .select()
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a profile and its measurements
  Future<void> deleteProfile(String profileId) async {
    try {
      // Delete measurements first (cascade)
      await _client.from('measurements').delete().eq('profile_id', profileId);
      // Then delete the profile
      await _client.from('profiles').delete().eq('id', profileId);
    } catch (e) {
      rethrow;
    }
  }

  // ─── MEASUREMENTS ──────────────────────────────────────

  /// Get measurements for a profile
  Future<Measurement?> getMeasurements(String profileId) async {
    try {
      final response = await _client
          .from('measurements')
          .select()
          .eq('profile_id', profileId)
          .maybeSingle();

      if (response == null) return null;
      return Measurement.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Create or update measurements for a profile
  Future<Measurement> upsertMeasurements(Measurement measurement) async {
    try {
      final response = await _client
          .from('measurements')
          .upsert(measurement.toJson(), onConflict: 'profile_id')
          .select()
          .single();

      return Measurement.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete measurements for a profile
  Future<void> deleteMeasurements(String profileId) async {
    try {
      await _client.from('measurements').delete().eq('profile_id', profileId);
    } catch (e) {
      rethrow;
    }
  }
}
