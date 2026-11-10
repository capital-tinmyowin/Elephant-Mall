import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:http/http.dart' as http;
import 'package:http/browser_client.dart' show BrowserClient;

import '../models/sellerpagemodel.dart';
import '../models/SellerInfo.dart';
import '../models/category.dart';
import '../models/new_in.dart';
import '../services/auth_service.dart';

import 'package:http/http.dart' as http;
import 'package:http/browser_client.dart';

class SellerListingService {
  static const String baseUrl = 'https://www.capital-sys.net/CKMMallAPI';

  Future<SellerInfo> fetchSellerInfo({
    required AuthService authService,
    required String? sellerId,
  }) async {
    if (sellerId == null || sellerId.isEmpty) {
      throw Exception('Seller ID is required.');
    }

    final url = Uri.parse('$baseUrl/api/User/getuserprofiledetail/$sellerId');

    late http.Response response;

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

    debugPrint('========== SELLER PROFILE ==========');
    debugPrint('URL: $url');
    debugPrint('Status: ${response.statusCode}');
    debugPrint('Body: ${response.body}');
    debugPrint('====================================');

    if (response.statusCode != 200) {
      throw Exception('Failed to load seller profile: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    return SellerInfo.fromJson(json);
  }

  // CATEGORIES
  Future<List<Category>> fetchCategories() async {
    final url = Uri.parse('$baseUrl/api/category/all');

    final response = await http.get(
      url,
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load categories. Status: ${response.statusCode}',
      );
    }

    final dynamic decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw Exception('Invalid category response.');
    }

    return decoded
        .map((item) => Category.fromJson(Map<String, dynamic>.from(item)))
        .where((c) => c.categoryName.toLowerCase() != 'root')
        .toList();
  }

  Future<bool> toggleFollow({
    required AuthService authService,
    required int sellerId,
    required bool follow,
  }) async {
    final action = follow ? 'follow' : 'unfollow';

    final uri = Uri.parse('$baseUrl/api/UserAction/$action/$sellerId');

    http.Client client;

    if (kIsWeb) {
      client = BrowserClient()..withCredentials = true;
    } else {
      client = http.Client();
    }

    try {
      final headers = <String, String>{'Accept': 'application/json'};

      if (!kIsWeb &&
          authService.authCookie != null &&
          authService.authCookie!.isNotEmpty) {
        headers['Cookie'] = authService.authCookie!;
      }

      late http.Response response;

      if (follow) {
        // Follow API uses POST
        response = await client.post(uri, headers: headers);
      } else {
        // Unfollow API uses DELETE
        response = await client.delete(uri, headers: headers);
      }

      debugPrint('========== $action SELLER ==========');
      debugPrint('URL: $uri');
      debugPrint('Method: ${follow ? 'POST' : 'DELETE'}');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Body: ${response.body}');
      debugPrint('====================================');

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      debugPrint('$action seller error: $e');
      return false;
    } finally {
      client.close();
    }
  }

  // NEWEST ARRIVALS
  Future<List<NewInModel>> fetchNewestArrivals({
    required AuthService authService,
  }) async {
    final url = Uri.parse(
      '$baseUrl/api/ProductShowcase/GetNewProductsLast10DaysAsync',
    );

    late http.Response response;

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

    if (response.statusCode != 200) {
      throw Exception('Failed to load newest arrivals: ${response.statusCode}');
    }

    final dynamic decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw Exception('Invalid newest arrivals response.');
    }

    return decoded
        .map((item) => NewInModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  // SALES PRODUCTS

  Future<List<NewInModel>> fetchSalesProducts({
    required AuthService authService,
  }) async {
    final url = Uri.parse(
      '$baseUrl/api/ProductShowcase/GetSaleProductsLast10DaysAsync',
    );

    late http.Response response;

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

    debugPrint('========== SALES PRODUCTS ==========');
    debugPrint('URL: $url');
    debugPrint('Status: ${response.statusCode}');
    debugPrint('Body: ${response.body}');
    debugPrint('====================================');

    if (response.statusCode != 200) {
      throw Exception('Failed to load sales products: ${response.statusCode}');
    }

    final dynamic decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception('Invalid sales products response.');
    }

    return decoded
        .map((item) => NewInModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  // SELLER PRODUCTS

  Future<List<Product>> fetchSellerProducts(
    String sellerId, {
    AuthService? authService,
  }) async {
    final url = Uri.parse('$baseUrl/api/Product/GetProductByUserId/$sellerId');

    late http.Response response;

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
      if (authService?.authCookie != null &&
          authService!.authCookie!.isNotEmpty) {
        headers['Cookie'] = authService.authCookie!;
      }
      response = await http.get(url, headers: headers);
    }

    debugPrint('========== SELLER PRODUCTS ==========');
    debugPrint('URL: $url');
    debugPrint('Status: ${response.statusCode}');
    debugPrint(
      'Body start: ${response.body.substring(0, response.body.length.clamp(0, 300))}',
    );
    debugPrint('=====================================');

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load seller products. Status: ${response.statusCode}',
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

  // FAVOURITE

  Future<bool> addFavourite({
    required AuthService authService,
    required int productId,
  }) async {
    final url = Uri.parse('$baseUrl/api/UserAction/addFavourite/$productId');

    try {
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
        final client = http.Client();
        try {
          response = await client.post(url, headers: headers);
        } finally {
          client.close();
        }
      }

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  Future<bool> removeFavourite({
    required AuthService authService,
    required int productId,
  }) async {
    final url = Uri.parse('$baseUrl/api/UserAction/removeFavourite/$productId');

    try {
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
        final client = http.Client();
        try {
          response = await client.post(url, headers: headers);
        } finally {
          client.close();
        }
      }

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }
}
