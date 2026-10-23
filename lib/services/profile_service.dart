import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/browser_client.dart' show BrowserClient;
import 'package:image_picker/image_picker.dart';

import '../models/profile_model.dart';
import 'auth_service.dart';

class ProfileService {
  static const String _profileUrl =
      'https://www.capital-sys.net/CKMMallAPI/api/User/profile';

  // static const String _uploadAvatarUrl =
  //     'https://www.capital-sys.net/CKMMallAPI/api/User/UploadAvatar';

  // static const String _uploadCoverUrl =
  //     'https://www.capital-sys.net/CKMMallAPI/api/User/UploadCover';

  final AuthService authService;

  ProfileService({required this.authService});

  // ============================================================
  // GET PROFILE
  // ============================================================
  Future<ProfileModel> fetchProfile() async {
    final url = Uri.parse(_profileUrl);

    debugPrint('========== PROFILE API REQUEST ==========');
    debugPrint('Method: GET');
    debugPrint('URL: $url');
    debugPrint('Platform: ${kIsWeb ? "Web" : "Mobile"}');

    late http.Response response;

    if (kIsWeb) {
      final client = BrowserClient()..withCredentials = true;

      try {
        response = await client.get(
          url,
          headers: const {'Accept': 'application/json'},
        );
      } finally {
        client.close();
      }
    } else {
      final headers = <String, String>{'Accept': 'application/json'};

      final cookie = authService.authCookie;

      if (cookie != null && cookie.isNotEmpty) {
        headers['Cookie'] = cookie;
        debugPrint('PROFILE AUTH: Cookie attached.');
      } else {
        debugPrint('PROFILE AUTH WARNING: No authentication cookie.');
      }

      final client = http.Client();

      try {
        response = await client.get(url, headers: headers);
      } finally {
        client.close();
      }
    }

    debugPrint('PROFILE STATUS: ${response.statusCode}');
    debugPrint('PROFILE BODY: ${response.body}');
    debugPrint('==========================================');

    if (response.statusCode == 401) {
      throw Exception('Unauthorized (401). Please log in again.');
    }

    if (response.statusCode == 403) {
      throw Exception('Forbidden (403). You cannot access this profile.');
    }

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load profile: '
        '${response.statusCode} - ${response.body}',
      );
    }

    if (response.body.trim().isEmpty) {
      throw Exception('The profile API returned an empty response.');
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid profile API response format.');
    }

    return ProfileModel.fromJson(decoded);
  }

  // AVATAR AND COVER UPLOAD

  static const String _uploadAvatarUrl =
      'https://www.capital-sys.net/CKMMallAPI/api/User/UploadAvatar';

  static const String _uploadCoverUrl =
      'https://www.capital-sys.net/CKMMallAPI/api/User/UploadCover';

  Future<Map<String, dynamic>> uploadAvatar(XFile image) {
    return _uploadImage(_uploadAvatarUrl, image, fieldName: 'avatar');
  }

  Future<Map<String, dynamic>> uploadCover(XFile image) {
    return _uploadImage(_uploadCoverUrl, image, fieldName: 'cover');
  }

  Future<Map<String, dynamic>> _uploadImage(
    String endpoint,
    XFile image, {
    required String fieldName,
  }) async {
    final url = Uri.parse(endpoint);
    final imageBytes = await image.readAsBytes();

    if (imageBytes.isEmpty) {
      throw Exception('The selected image is empty.');
    }

    final request = http.MultipartRequest('POST', url);

    request.headers['Accept'] = 'application/json';

    // Match the authentication pattern used in ProductService.
    if (kIsWeb) {
      debugPrint('PROFILE UPLOAD AUTH: Browser credentials enabled.');
    } else {
      final cookie = authService.authCookie;

      if (cookie != null && cookie.isNotEmpty) {
        request.headers['Cookie'] = cookie;
        debugPrint('PROFILE UPLOAD AUTH: Cookie attached.');
      } else {
        debugPrint('PROFILE UPLOAD AUTH: No authentication cookie found.');
      }
    }

    // Match Postman: Body -> form-data -> avatar/cover -> File.
    request.files.add(
      http.MultipartFile.fromBytes(fieldName, imageBytes, filename: image.name),
    );

    debugPrint('========== PROFILE IMAGE UPLOAD REQUEST ==========');
    debugPrint('Method: ${request.method}');
    debugPrint('URL: $url');
    debugPrint('Form field: $fieldName');
    debugPrint('Filename: ${image.name}');
    debugPrint('File size: ${imageBytes.length} bytes');
    debugPrint('Multipart file count: ${request.files.length}');
    debugPrint('===================================================');

    try {
      late http.Response response;

      if (kIsWeb) {
        final client = BrowserClient();
        client.withCredentials = true;

        try {
          final streamedResponse = await client.send(request);
          response = await http.Response.fromStream(streamedResponse);
        } finally {
          client.close();
        }
      } else {
        final client = http.Client();

        try {
          final streamedResponse = await client.send(request);
          response = await http.Response.fromStream(streamedResponse);
        } finally {
          client.close();
        }
      }

      debugPrint('========== PROFILE IMAGE UPLOAD RESPONSE ==========');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Body: ${response.body}');
      debugPrint('===================================================');

      if (response.statusCode == 401) {
        throw Exception('Unauthorized (401). Please log in again.');
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Image upload failed (${response.statusCode}): ${response.body}',
        );
      }

      if (response.body.trim().isEmpty) {
        return <String, dynamic>{'success': true};
      }

      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return <String, dynamic>{'data': decoded};
    } catch (e, stackTrace) {
      debugPrint('========== PROFILE IMAGE UPLOAD ERROR ==========');
      debugPrint('Endpoint: $endpoint');
      debugPrint('Form field: $fieldName');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('================================================');

      rethrow;
    }
  }

  // ============================================================
  // LOG AND PARSE UPLOAD RESPONSE
  // ============================================================
  Map<String, dynamic> _parseUploadResponse(
    http.Response response, {
    required String uploadType,
    required String endpoint,
  }) {
    debugPrint('========== $uploadType UPLOAD RESPONSE ==========');
    debugPrint('URL: $endpoint');
    debugPrint('HTTP Status: ${response.statusCode}');
    debugPrint('Response Headers: ${response.headers}');
    debugPrint('Response Body: ${response.body}');
    debugPrint('==================================================');

    if (response.statusCode == 401) {
      throw Exception(
        '$uploadType upload failed: Unauthorized (401). '
        'Please log in again.',
      );
    }

    if (response.statusCode == 403) {
      throw Exception('$uploadType upload failed: Forbidden (403).');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        '$uploadType upload failed '
        '(${response.statusCode}): ${response.body}',
      );
    }

    if (response.body.trim().isEmpty) {
      debugPrint('$uploadType upload succeeded with an empty response body.');
      return <String, dynamic>{};
    }

    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return <String, dynamic>{'data': decoded};
    } catch (_) {
      // Some APIs return plain text after a successful upload.
      return <String, dynamic>{'message': response.body};
    }
  }
}
