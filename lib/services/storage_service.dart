import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../core/constants.dart';

/// Uploads incident photos to Cloudinary and returns their public URL.
class StorageService {
  StorageService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Uri get _uploadUri => Uri.parse(
    'https://api.cloudinary.com/v1_1/${AppConstants.cloudinaryCloudName}/image/upload',
  );

  Future<String> uploadIncidentPhoto(File file) async {
    final request = http.MultipartRequest('POST', _uploadUri)
      ..fields['upload_preset'] = AppConstants.cloudinaryUploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    try {
      final streamed = await _client
          .send(request)
          .timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamed);
      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 200) {
        final error = body['error'] as Map<String, dynamic>?;
        throw StorageException(error?['message'] as String? ?? 'Upload failed');
      }
      return body['secure_url'] as String;
    } on StorageException {
      rethrow;
    } catch (_) {
      throw const StorageException(
        'Could not upload the photo. Check your connection.',
      );
    }
  }
}

class StorageException implements Exception {
  const StorageException(this.message);

  final String message;

  @override
  String toString() => message;
}
