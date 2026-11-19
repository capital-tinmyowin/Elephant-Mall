import 'dart:convert';
import 'package:elephant_mall/services/new_in_service.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:http/http.dart' as http;
import 'package:http/browser_client.dart' show BrowserClient;

import '../models/new_in.dart'; // reuse NewInModel — same shape
import 'auth_service.dart';

class RecommendedService {
  static const String _baseUrl = 'https://www.capital-sys.net/CKMMallAPI/api';

  // Change this path if your backend uses a different route.
  static const String _recommendedUrl =
      '$_baseUrl/Search/UserRecommendProductList';

  /// Fetch ALL recommended products for the logged-in user.
  /// Uses the same cookie mechanism as NewInService.
  Future<List<NewInModel>> getRecommendedProducts({
    AuthService? authService,
  }) async {
    try {
      http.Response response;

      // ── WEB ──
      if (kIsWeb) {
        final client = BrowserClient()..withCredentials = true;
        try {
          response = await client.get(
            Uri.parse(_recommendedUrl),
            headers: {'Accept': 'application/json'},
          );
        } finally {
          client.close();
        }
      }
      // ── MOBILE ──
      else {
        final headers = <String, String>{'Accept': 'application/json'};
        if (authService?.authCookie != null &&
            authService!.authCookie!.isNotEmpty) {
          headers['Cookie'] = authService.authCookie!;
        }
        final client = http.Client();
        try {
          response = await client.get(
            Uri.parse(_recommendedUrl),
            headers: headers,
          );
        } finally {
          client.close();
        }
      }

      debugPrint('[Recommended] status=${response.statusCode}');

      if (response.statusCode == 401) {
        throw Exception('401 Unauthorized');
      }
      if (response.statusCode != 200) {
        throw Exception(
          'Failed to load recommended products: ${response.statusCode}',
        );
      }

      final decoded = jsonDecode(response.body);

      // Log the shape once so future-you can debug instantly.
      debugPrint('[Recommended] top-level type: ${decoded.runtimeType}');

      List<dynamic> items;

      if (decoded is List) {
        // Bare array (like GetNewProductList)
        items = decoded;
      } else if (decoded is Map<String, dynamic>) {
        final dataField = decoded['data'];

        // Case A: { "data": [ ... ] }
        if (dataField is List) {
          items = dataField;
        }
        // Case B: { "data": { "products": [ ... ] } }  ← your case
        else if (dataField is Map<String, dynamic> &&
            dataField['products'] is List) {
          items = dataField['products'] as List;
        }
        // Case C: other common envelope keys
        else if (decoded['products'] is List) {
          items = decoded['products'] as List;
        } else if (decoded['result'] is List) {
          items = decoded['result'] as List;
        } else {
          throw Exception(
            'Unexpected JSON shape. Keys: ${decoded.keys.toList()}, '
            'data keys: ${dataField is Map ? dataField.keys.toList() : dataField.runtimeType}',
          );
        }
      } else {
        throw Exception('Unexpected JSON type: ${decoded.runtimeType}');
      }

      return items
          .whereType<Map<String, dynamic>>()
          .map((j) => NewInModel.fromJson(j))
          .toList();
    } catch (e, stackTrace) {
      debugPrint('[Recommended] ERROR: $e');
      debugPrint('$stackTrace');
      rethrow;
    }
  }

  /// Load categories for the filter dropdown.
  Future<List<CategoryOption>> getCategories() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/category/all'),
      headers: {'Accept': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load categories: ${response.statusCode}');
    }
    final List<dynamic> jsonData = jsonDecode(response.body);
    return jsonData
        .map((json) {
          final id =
              json['categoryId']?.toString() ?? json['id']?.toString() ?? '';
          final name =
              json['categoryName']?.toString() ??
              json['name']?.toString() ??
              '';
          return CategoryOption(id: id, name: name);
        })
        .where((c) => c.name.toLowerCase() != 'root' && c.id.isNotEmpty)
        .toList();
  }

  /// Optional: record the view when opening a product from this page.
  Future<bool> saveRecentView({
    required AuthService authService,
    required int productId,
  }) async {
    final url = Uri.parse('$_baseUrl/Trending/SaveRecentViewData/$productId');
    http.Response response;

    if (kIsWeb) {
      final client = BrowserClient()..withCredentials = true;
      try {
        response = await client.post(
          url,
          headers: {'Accept': 'application/json'},
        );
      } finally {
        client.close();
      }
    } else {
      final headers = <String, String>{'Accept': 'application/json'};
      if (authService.authCookie != null &&
          authService.authCookie!.isNotEmpty) {
        headers['Cookie'] = authService.authCookie!;
      }
      response = await http.post(url, headers: headers);
    }

    if (response.statusCode == 401) {
      throw Exception('Please login or sign up first.');
    }
    return response.statusCode >= 200 && response.statusCode < 300;
  }
}
