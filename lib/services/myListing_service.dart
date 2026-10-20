import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:http/http.dart' as http;
import 'package:http/browser_client.dart' show BrowserClient;

import '../models/sellerpagemodel.dart';
import '../services/auth_service.dart';
import '../models/category.dart';
import '../models/new_in.dart';
import '../models/SellerInfo.dart';     

class SellerPageService {
  static const String baseUrl = 'https://www.capital-sys.net/CKMMallAPI';

  Future<SellerInfo> fetchSellerInfo({required AuthService authService}) async {
    final url = Uri.parse('$baseUrl/api/User/getuserprofiledetail');

    late http.Response response;

    try {
      if (kIsWeb) {
        final client = BrowserClient()..withCredentials = true;
        try {
          response = await client.get(
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

        response = await http.get(url, headers: headers);
      }

      debugPrint('========== SELLER INFO API ==========');
      debugPrint('URL: $url');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Body: ${response.body}');
      debugPrint('=====================================');

      if (response.statusCode == 401) {
        throw Exception('Please login or sign up first.');
      }

      if (response.statusCode != 200) {
        throw Exception('Failed to load seller info: ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body);

      // API returns a List
      if (decoded is List && decoded.isNotEmpty) {
        return SellerInfo.fromJson(
          Map<String, dynamic>.from(decoded.first as Map),
        );
      }

      if (decoded is Map) {
        return SellerInfo.fromJson(Map<String, dynamic>.from(decoded));
      }

      throw Exception('Invalid seller info response.');
    } catch (e, st) {
      debugPrint('SELLER INFO ERROR: $e\n$st');
      rethrow;
    }
  }

  // GET ALL CATEGORIES

  Future<List<Category>> fetchCategories() async {
    final url = Uri.parse('$baseUrl/api/category/all');

    final response = await http.get(
      url,
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load categories. '
        'Status: ${response.statusCode}',
      );
    }

    final dynamic decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception('Invalid category response.');
    }

    return decoded
        .map((item) => Category.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  // GET NEWEST ARRIVALS

  Future<List<NewInModel>> fetchNewestArrivals({
    required AuthService authService,
  }) async {
    final url = Uri.parse('$baseUrl/api/productshowcase/GetNewProductList');

    late http.Response response;

    if (kIsWeb) {
      final client = BrowserClient();
      client.withCredentials = true;

      try {
        response = await client.get(
          url,
          headers: {'Accept': 'application/json'},
        );
      } finally {
        client.close();
      }
    } else {
      final headers = <String, String>{'Accept': 'application/json'};

      final cookie = authService.authCookie;
      if (cookie != null && cookie.isNotEmpty) {
        headers['Cookie'] = cookie;
      }

      response = await http.get(url, headers: headers);
    }

    debugPrint('========== NEWEST ARRIVALS API ==========');
    debugPrint('URL: $url');
    debugPrint('Status: ${response.statusCode}');
    debugPrint('Response: ${response.body}');
    debugPrint('=========================================');

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load newest arrivals: '
        '${response.statusCode} - ${response.body}',
      );
    }

    final dynamic decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception('Invalid newest arrivals response.');
    }

    return decoded
        .map((item) => NewInModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  // ============================================================
  // SELLER PRODUCTS
  // ============================================================

  Future<List<Product>> fetchSellerProducts(String sellerId) async {
    final url = Uri.parse('$baseUrl/api/Product/GetProductByUserId/$sellerId');

    final response = await http.get(
      url,
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load seller products. '
        'Status: ${response.statusCode}',
      );
    }

    final dynamic decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception('Invalid seller products response.');
    }

    return decoded
        .map((item) => Product.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  // ============================================================
  // ADD TO FAVOURITE
  // ============================================================

  Future<bool> addFavourite({
    required AuthService authService,
    required int productId,
  }) async {
    final url = Uri.parse('$baseUrl/api/UserAction/addFavourite/$productId');

    try {
      http.Response response;

      // WEB
      if (kIsWeb) {
        final client = BrowserClient();

        client.withCredentials = true;

        try {
          response = await client.post(
            url,
            headers: {'Accept': 'application/json'},
          );
        } finally {
          client.close();
        }
      }
      // ANDROID / IOS
      else {
        final headers = <String, String>{'Accept': 'application/json'};

        if (authService.authCookie != null &&
            authService.authCookie!.isNotEmpty) {
          headers['Cookie'] = authService.authCookie!;
        }

        final client = http.Client();

        try {
          response = await client.post(url, headers: headers);
        } finally {
          client.close();
        }
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      }

      return false;
    } catch (_) {
      return false;
    }
  }

  // REMOVE FROM FAVOURITE

  Future<bool> removeFavourite({
    required AuthService authService,
    required int productId,
  }) async {
    final url = Uri.parse('$baseUrl/api/UserAction/removeFavourite/$productId');

    try {
      http.Response response;

      // ==========================================================
      // WEB
      // ==========================================================

      if (kIsWeb) {
        final client = BrowserClient();

        client.withCredentials = true;

        try {
          response = await client.post(
            url,
            headers: {'Accept': 'application/json'},
          );
        } finally {
          client.close();
        }
      }
      // ==========================================================
      // ANDROID / IOS
      // ==========================================================
      else {
        final headers = <String, String>{'Accept': 'application/json'};

        if (authService.authCookie != null &&
            authService.authCookie!.isNotEmpty) {
          headers['Cookie'] = authService.authCookie!;
        }

        final client = http.Client();

        try {
          response = await client.post(url, headers: headers);
        } finally {
          client.close();
        }
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      }

      return false;
    } catch (_) {
      return false;
    }
  }
}
