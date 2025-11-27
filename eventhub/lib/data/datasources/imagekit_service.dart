import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ImageKitService {
  // Your actual ImageKit.io credentials
  static const String _privateKey = 'private_96ppahcfit0+msTuHdT74Tk2Ltk=';

  static const String _uploadUrl =
      'https://upload.imagekit.io/api/v1/files/upload';

  // Upload image to ImageKit.io
  static Future<ImageKitResponse> uploadEventImage(
    XFile imageFile, {
    String? fileName,
  }) async {
    try {
      debugPrint('🔄 Starting image upload to ImageKit.io...');
      final fileBytes = await imageFile.readAsBytes();

      var request = http.MultipartRequest('POST', Uri.parse(_uploadUrl))
        ..fields['fileName'] =
            fileName ?? 'event_${DateTime.now().millisecondsSinceEpoch}'
        ..fields['useUniqueFileName'] = 'true'
        ..fields['folder'] = '/event_images'
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            fileBytes,
            filename: 'upload.jpg',
          ),
        );

      // Add authentication
      final authString = '$_privateKey:';
      final base64Auth = base64Encode(utf8.encode(authString));
      request.headers['Authorization'] = 'Basic $base64Auth';

      debugPrint('📤 Uploading image to ImageKit.io...');
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseData);

      if (response.statusCode == 200) {
        debugPrint('✅ Image uploaded successfully: ${jsonResponse['url']}');
        return ImageKitResponse.fromJson(jsonResponse);
      } else {
        debugPrint('❌ Image upload failed: ${jsonResponse['message']}');
        throw Exception('Upload failed: ${jsonResponse['message']}');
      }
    } catch (e) {
      debugPrint('❌ Image upload error: $e');
      throw Exception('Upload error: $e');
    }
  }

  // Upload profile picture
  static Future<ImageKitResponse> uploadProfilePicture(
    XFile imageFile,
    String userId,
  ) async {
    try {
      debugPrint('🔄 Uploading profile picture for user: $userId');
      final fileBytes = await imageFile.readAsBytes();

      var request = http.MultipartRequest('POST', Uri.parse(_uploadUrl))
        ..fields['fileName'] = 'profile_$userId'
        ..fields['useUniqueFileName'] = 'false'
        ..fields['folder'] = '/profile_pictures'
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            fileBytes,
            filename: 'profile.jpg',
          ),
        );

      final authString = '$_privateKey:';
      final base64Auth = base64Encode(utf8.encode(authString));
      request.headers['Authorization'] = 'Basic $base64Auth';

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseData);

      if (response.statusCode == 200) {
        debugPrint(
          '✅ Profile picture uploaded successfully: ${jsonResponse['url']}',
        );
        return ImageKitResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Upload failed: ${jsonResponse['message']}');
      }
    } catch (e) {
      throw Exception('Upload error: $e');
    }
  }

  // Generate optimized image URL with transformations
  static String getOptimizedUrl(
    String imageUrl, {
    int? width,
    int? height,
    int quality = 80,
    String format = 'webp',
  }) {
    if (!imageUrl.contains('ik.imagekit.io')) {
      return imageUrl; // Return original if not ImageKit URL
    }

    final transformations = <String>[];

    if (width != null || height != null) {
      transformations.add('w-$width,h-$height,c-maintain_ratio');
    }

    transformations.add('q-$quality');
    transformations.add('f-$format');

    return '$imageUrl?tr=${transformations.join(',')}';
  }

  // Generate thumbnail URL
  static String getThumbnailUrl(String imageUrl, {int size = 150}) {
    return getOptimizedUrl(imageUrl, width: size, height: size, quality: 70);
  }

  // Generate event image URL (400x300 optimized)
  static String getEventImageUrl(
    String imageUrl, {
    int width = 400,
    int height = 300,
  }) {
    return getOptimizedUrl(imageUrl, width: width, height: height, quality: 85);
  }

  // Delete image from ImageKit.io
  static Future<bool> deleteImage(String fileId) async {
    try {
      final response = await http.delete(
        Uri.parse('https://api.imagekit.io/v1/files/$fileId'),
        headers: {
          'Authorization':
              'Basic ${base64Encode(utf8.encode('$_privateKey:'))}',
        },
      );

      return response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }
}

class ImageKitResponse {
  final String fileId;
  final String name;
  final String url;
  final String thumbnailUrl;
  final int height;
  final int width;
  final int size;
  final String filePath;

  ImageKitResponse({
    required this.fileId,
    required this.name,
    required this.url,
    required this.thumbnailUrl,
    required this.height,
    required this.width,
    required this.size,
    required this.filePath,
  });

  factory ImageKitResponse.fromJson(Map<String, dynamic> json) {
    return ImageKitResponse(
      fileId: json['fileId'],
      name: json['name'],
      url: json['url'],
      thumbnailUrl: json['thumbnailUrl'],
      height: json['height'],
      width: json['width'],
      size: json['size'],
      filePath: json['filePath'],
    );
  }
}
