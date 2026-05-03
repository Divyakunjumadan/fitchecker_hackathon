import 'dart:io';
import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/measurement.dart';
import '../services/database_service.dart';
import '../services/storage_service.dart';

class ProfileProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  final StorageService _storageService = StorageService();

  List<UserProfile> _profiles = [];
  UserProfile? _selectedProfile;
  Measurement? _selectedMeasurement;
  bool _isLoading = false;
  String? _error;

  List<UserProfile> get profiles => _profiles;
  UserProfile? get selectedProfile => _selectedProfile;
  Measurement? get selectedMeasurement => _selectedMeasurement;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasProfiles => _profiles.isNotEmpty;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Load all profiles for the current user
  Future<void> loadProfiles(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _profiles = await _dbService.getProfiles(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load profiles: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Select a profile and load its measurements
  Future<void> selectProfile(UserProfile profile) async {
    _selectedProfile = profile;
    notifyListeners();

    if (profile.id != null) {
      try {
        _selectedMeasurement = await _dbService.getMeasurements(profile.id!);
        notifyListeners();
      } catch (e) {
        print('Error loading measurements: $e');
      }
    }
  }

  /// Create a new profile with optional image upload
  Future<UserProfile?> createProfile({
    required String userId,
    required String name,
    required String gender,
    required double height,
    required double weight,
    File? profileImage,
    required Measurement measurements,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Create profile first
      var profile = UserProfile(
        userId: userId,
        name: name,
        gender: gender,
        height: height,
        weight: weight,
      );

      profile = await _dbService.createProfile(profile);

      // Upload profile image if provided
      String? imageUrl;
      if (profileImage != null && profile.id != null) {
        imageUrl = await _storageService.uploadProfileImage(
          userId: userId,
          profileId: profile.id!,
          imageFile: profileImage,
        );

        // Update profile with image URL
        profile = profile.copyWith(profileImageUrl: imageUrl);
        profile = await _dbService.updateProfile(profile);
      }

      // Save measurements
      final meas = Measurement(
        profileId: profile.id!,
        gender: gender,
        bust: measurements.bust,
        waist: measurements.waist,
        hip: measurements.hip,
        chest: measurements.chest,
        shoulder: measurements.shoulder,
      );

      await _dbService.upsertMeasurements(meas);

      // Refresh profiles list
      await loadProfiles(userId);

      _selectedProfile = profile;
      _selectedMeasurement = meas;
      _isLoading = false;
      notifyListeners();

      return profile;
    } catch (e) {
      _error = 'Failed to create profile: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Update an existing profile
  Future<bool> updateProfile({
    required UserProfile profile,
    File? newProfileImage,
    Measurement? measurements,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      var updatedProfile = profile;

      // Upload new image if provided
      if (newProfileImage != null && profile.id != null) {
        final imageUrl = await _storageService.uploadProfileImage(
          userId: profile.userId,
          profileId: profile.id!,
          imageFile: newProfileImage,
        );
        updatedProfile = updatedProfile.copyWith(profileImageUrl: imageUrl);
      }

      updatedProfile = await _dbService.updateProfile(updatedProfile);

      // Update measurements if provided
      if (measurements != null) {
        await _dbService.upsertMeasurements(measurements);
      }

      // Refresh
      await loadProfiles(profile.userId);
      _selectedProfile = updatedProfile;
      if (measurements != null) _selectedMeasurement = measurements;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update profile: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete a profile
  Future<bool> deleteProfile(String profileId, String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Delete image from storage
      await _storageService.deleteProfileImage(
        userId: userId,
        profileId: profileId,
      );

      // Delete from database
      await _dbService.deleteProfile(profileId);

      // Clear selection if this was selected
      if (_selectedProfile?.id == profileId) {
        _selectedProfile = null;
        _selectedMeasurement = null;
      }

      // Refresh profiles
      await loadProfiles(userId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete profile: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Clear all state (on logout)
  void clear() {
    _profiles = [];
    _selectedProfile = null;
    _selectedMeasurement = null;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
