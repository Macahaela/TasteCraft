import 'dart:developer';
import 'package:cloudinary_sdk/cloudinary_sdk.dart';

class CloudinaryService {
  final Cloudinary _cloudinary = Cloudinary.full(
    apiKey: '273888646819587',
    apiSecret: 'aQuinaO1HyX7xpmLAdkKZpcVZIU',
    cloudName: 'datggxdch',
  );

  Future<String?> uploadImage(dynamic imageFile) async {
    if (imageFile == null || imageFile.path.isEmpty) {
      log('Invalid file or file path is empty');
      return null;
    }

    try {
      log('Uploading image: ${imageFile.path}');
      final response = await _cloudinary.uploadResource(
        CloudinaryUploadResource(
          filePath: imageFile.path,
          resourceType: CloudinaryResourceType.image,
          folder: 'recipe-images', // Upload ke folder 'recipe-images'
        ),
      );

      if (response.isSuccessful && response.secureUrl != null) {
        log('Image uploaded successfully: ${response.secureUrl}');
        return response.secureUrl; // URL ini digunakan untuk Firestore
      } else {
        final errorMessage = response.error ?? 'Unknown Cloudinary error';
        log('Cloudinary upload failed: $errorMessage');
        return null;
      }
    } catch (e) {
      log('Exception during Cloudinary upload: $e');
      return null;
    }
  }
}
