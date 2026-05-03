import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;

class StorageService {
  final SupabaseClient _client = Supabase.instance.client;

  static const String profileBucket = 'profile-images';
  static const String clothingBucket = 'clothing-images';

  /// Upload a profile image and return the public URL
  Future<String> uploadProfileImage({
    required String userId,
    required String profileId,
    required File imageFile,
  }) async {
    try {
      final ext = p.extension(imageFile.path).replaceFirst('.', '');
      final fileName = '$userId/$profileId/profile.$ext';
      final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';

      await _client.storage.from(profileBucket).upload(
            fileName,
            imageFile,
            fileOptions: FileOptions(
              contentType: mimeType,
              upsert: true,
            ),
          );

      final publicUrl = _client.storage
          .from(profileBucket)
          .getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      rethrow;
    }
  }

  /// Upload a clothing image and return the public URL
  Future<String> uploadClothingImage({
    required String userId,
    required File imageFile,
  }) async {
    try {
      final ext = p.extension(imageFile.path).replaceFirst('.', '');
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '$userId/clothing_$timestamp.$ext';
      final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';

      await _client.storage.from(clothingBucket).upload(
            fileName,
            imageFile,
            fileOptions: FileOptions(
              contentType: mimeType,
              upsert: true,
            ),
          );

      final publicUrl = _client.storage
          .from(clothingBucket)
          .getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a profile image
  Future<void> deleteProfileImage({
    required String userId,
    required String profileId,
  }) async {
    try {
      final files = await _client.storage
          .from(profileBucket)
          .list(path: '$userId/$profileId');

      if (files.isNotEmpty) {
        final filePaths = files
            .map((f) => '$userId/$profileId/${f.name}')
            .toList();
        await _client.storage.from(profileBucket).remove(filePaths);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get public URL for a file
  String getPublicUrl(String bucket, String path) {
    return _client.storage.from(bucket).getPublicUrl(path);
  }
}
