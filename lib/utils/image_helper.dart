import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../constants/app_constants.dart';

class ImageHelper {
  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickImage({
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image == null) return null;

      final File file = File(image.path);

      // Validate file size
      final int fileSize = await file.length();
      if (fileSize > AppConstants.maxImageSizeInBytes) {
        throw Exception(
            'Image size exceeds ${AppConstants.maxImageSizeInBytes ~/ (1024 * 1024)}MB limit');
      }

      // Validate file extension
      final String extension = image.path.split('.').last.toLowerCase();
      if (!AppConstants.allowedImageExtensions.contains(extension)) {
        throw Exception('Only JPEG and PNG images are allowed');
      }

      return file;
    } catch (e) {
      rethrow;
    }
  }

  static Future<File?> pickImageFromGallery() async {
    return await pickImage(source: ImageSource.gallery);
  }

  static Future<File?> pickImageFromCamera() async {
    return await pickImage(source: ImageSource.camera);
  }
}
