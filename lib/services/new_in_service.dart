import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' hide Category;
import 'package:http/http.dart' as http;
import 'package:http/browser_client.dart' show BrowserClient;

import '../models/new_in.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';

class CategoryOption {
  final String id;
  final String name;
  CategoryOption({required this.id, required this.name});
}

class NewInService {
  // MOCK API RESPONSE
  static const String _mockJson = '''
  [
    {
      "productCode": 1,
      "productName": "Men's Sneakers",
      "category": "Shoes",
      "price": 89.00,
      "rating": 4.5,
      "reviewCount": 24,
      "imagePath": "assets/man-sneaker.png",
        "isNew": true
    },
    {
      "productCode": 2,
      "productName": "Women's Wristwatch",
      "category": "Accessories",
      "price": 65.00,
      "rating": 4.5,
      "reviewCount": 18,
      "imagePath": "assets/womenwatch.jpg",
        "isNew": true
    },
    {
      "productCode": 3,
      "productName": "Leather Backpack",
      "category": "Bags",
      "price": 110.00,
      "rating": 4.0,
      "reviewCount": 12,
      "imagePath": "assets/leatherbagpack.jpg",
        "isNew": true
    },
    {
      "productCode": 4,
      "productName": "Linen Shirt (New Item)",
      "category": "Clothing",
      "price": 45.00,
      "rating": 4.5,
      "reviewCount": 15,
      "imagePath": "assets/linenshirt.jpg",
        "isNew": true
    },
    {
      "productCode": 5,
      "productName": "Straw Hat (New Item)",
      "category": "Accessories",
      "price": 25.00,
      "rating": 4.0,
      "reviewCount": 21,
      "imagePath": "assets/strawhat.png",
        "isNew": true
    },
    {
      "productCode": 6,
      "productName": "Cotton Blouse",
      "category": "Clothing",
      "price": 38.00,
      "rating": 4.5,
      "reviewCount": 17,
      "imagePath": "assets/cottonblouse.jpg",
        "isNew": true
    },
    {
      "productCode": 7,
      "productName": "Canvas Tote Bag",
      "category": "Bags",
      "price": 29.00,
      "rating": 4.5,
      "reviewCount": 16,
      "imagePath": "assets/totebag.jpg",
        "isNew": true
    },
    {
      "productCode": 8,
      "productName": "Leather Sandals",
      "category": "Shoes",
      "price": 55.00,
      "rating": 4.0,
      "reviewCount": 14,
      "imagePath": "assets/leatherscandal.jpg",
        "isNew": true
    },
    {
      "productCode": 9,
      "productName": "Polarized Sunglasses",
      "category": "Accessories",
      "price": 35.00,
      "rating": 4.5,
      "reviewCount": 14,
      "imagePath": "assets/sunglass.jpg",
        "isNew": true
    },
    {
      "productCode": 10,
      "productName": "Heart Pendant Necklace",
      "category": "Jewelry",
      "price": 28.00,
      "rating": 4.5,
      "reviewCount": 13,
      "imagePath": "assets/necklace.jpg",
      "isNew": true
    }
  ]
  ''';

  // GET NEW IN PRODUCTS

  static const String _newInUrl =
      'https://www.capital-sys.net/CKMMallAPI/api/productshowcase/GetNewProductList';

  Future<List<NewInModel>> getNewInProducts({AuthService? authService}) async {
    try {
      http.Response response;

      // WEB
      if (kIsWeb) {
        final client = BrowserClient();
        client.withCredentials = true; // send login cookie

        try {
          response = await client.get(
            Uri.parse(_newInUrl),
            headers: {'Accept': 'application/json'},
          );
        } finally {
          client.close();
        }
      }
      // ANDROID / iOS
      else {
        final headers = <String, String>{'Accept': 'application/json'};

        if (authService?.authCookie != null &&
            authService!.authCookie!.isNotEmpty) {
          headers['Cookie'] = authService.authCookie!;
          print('GET NEW IN AUTH: Cookie attached');
        }

        final client = http.Client();
        try {
          response = await client.get(Uri.parse(_newInUrl), headers: headers);
        } finally {
          client.close();
        }
      }

      debugPrint('Status: ${response.statusCode}');
      debugPrint('Body length: ${response.body.length}');
      debugPrint(
        'Body start: ${response.body.substring(0, response.body.length.clamp(0, 300))}',
      );

      final decoded = jsonDecode(response.body);
      debugPrint('Decoded type: ${decoded.runtimeType}');

      if (decoded is! List) {
        throw Exception('Expected List, got ${decoded.runtimeType}: $decoded');
      }

      final List<dynamic> jsonData = decoded;
      print('Item count: ${jsonData.length}');

      if (response.statusCode != 200) {
        throw Exception('Failed to load new products: ${response.statusCode}');
      }

      // final List<dynamic> jsonData = jsonDecode(response.body);

      return jsonData
          .map((json) => NewInModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      print('========== NEW IN API ERROR ==========');
      print(e);
      print(stackTrace);
      print('======================================');
      rethrow;
    }
  }

  static const String _saveRecentViewBaseUrl =
      'https://www.capital-sys.net/CKMMallAPI/api/Trending/SaveRecentViewData';

  /// POST /api/Trending/SaveRecentViewData/{productId}
  /// Requires authentication (cookie).
  Future<bool> saveRecentView({
    required AuthService authService,
    required int productId,
  }) async {
    final url = Uri.parse('$_saveRecentViewBaseUrl/$productId');

    debugPrint('========== SAVE RECENT VIEW API ==========');
    debugPrint('URL: $url');
    debugPrint('ProductId: $productId');

    try {
      http.Response response;

      // WEB
      if (kIsWeb) {
        final client = BrowserClient();
        client.withCredentials = true; // send login cookie
        try {
          response = await client.post(
            url,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          );
        } finally {
          client.close();
        }
      }
      // ANDROID / iOS
      else {
        final headers = <String, String>{
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        };
        if (authService.authCookie != null &&
            authService.authCookie!.isNotEmpty) {
          headers['Cookie'] = authService.authCookie!;
          debugPrint('SAVE RECENT VIEW AUTH: Cookie attached');
        } else {
          debugPrint('SAVE RECENT VIEW AUTH: No authentication cookie found');
        }

        final client = http.Client();
        try {
          response = await client.post(url, headers: headers);
        } finally {
          client.close();
        }
      }

      // Debug after API call
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');
      debugPrint('Headers: ${response.headers}');

      if (response.statusCode == 401) {
        debugPrint('SAVE RECENT VIEW: 401 Unauthorized');
        throw Exception('Please login or sign up first.');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final decoded = jsonDecode(response.body);
          debugPrint('Decoded response: $decoded');
          if (decoded is Map && decoded['success'] == true) {
            debugPrint(
              'SAVE RECENT VIEW: success = true, message = ${decoded['message']}',
            );
            return true;
          }
        } catch (e) {
          debugPrint('SAVE RECENT VIEW: JSON decode error → $e');
        }
        return true;
      }

      debugPrint('SAVE RECENT VIEW: Unexpected status ${response.statusCode}');
      throw Exception(
        'Failed to save recent view: ${response.statusCode} - ${response.body}',
      );
    } catch (e, stackTrace) {
      print('========== SAVE RECENT VIEW API ERROR ==========');
      print(e);
      print(stackTrace);
      print('================================================');
      rethrow;
    }
  }

  static const String _categoryUrl =
      'https://www.capital-sys.net/CKMMallAPI/api/category/all';

  Future<List<CategoryOption>> getCategories() async {
    final response = await http.get(
      Uri.parse(_categoryUrl),
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

  static const String _addFavBaseUrl =
      'https://www.capital-sys.net/CKMMallAPI/api/UserAction/addFavourite';

  /// Calls: POST /api/UserAction/addFavourite/{productId}
  Future<bool> addFavourite({
    required AuthService authService,
    required int productId,
  }) async {
    final url = Uri.parse('$_addFavBaseUrl/$productId');

    print('========== ADD FAV API ==========');
    print('URL: $url');

    try {
      http.Response response;

      // WEB
      if (kIsWeb) {
        final client = BrowserClient();
        client.withCredentials = true; // browser will send the login cookie

        try {
          response = await client.post(
            url,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          );
        } finally {
          client.close();
        }
      }
      // ANDROID / iOS
      else {
        final headers = <String, String>{
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        };

        if (authService.authCookie != null &&
            authService.authCookie!.isNotEmpty) {
          headers['Cookie'] = authService.authCookie!;
          print('ADD FAV AUTH: Authentication cookie attached.');
        } else {
          print('ADD FAV AUTH: No authentication cookie found.');
        }

        final client = http.Client();
        try {
          response = await client.post(url, headers: headers);
        } finally {
          client.close();
        }
      }

      print('Status Code: ${response.statusCode}');
      print('Response: ${response.body}');
      print('=================================');

      // 401 → user not logged in
      if (response.statusCode == 401) {
        throw Exception('Please login or sign up first.');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }

      throw Exception('Failed to add favourite: ${response.statusCode}');
    } catch (e, stackTrace) {
      print('========== ADD FAV API ERROR ==========');
      print(e);
      print(stackTrace);
      print('=======================================');
      rethrow;
    }
  }

  static const String _removeFavBaseUrl =
      'https://www.capital-sys.net/CKMMallAPI/api/UserAction/removeFavourite';

  /// DELETE /api/UserAction/removeFavourite/{productId}
  Future<bool> removeFavourite({
    required AuthService authService,
    required int productId,
  }) async {
    final url = Uri.parse('$_removeFavBaseUrl/$productId');

    print('========== REMOVE FAV API ==========');
    print('URL: $url');

    try {
      http.Response response;

      if (kIsWeb) {
        final client = BrowserClient()..withCredentials = true;
        try {
          response = await client.delete(
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
        response = await http.delete(url, headers: headers);
      }

      print('Status Code: ${response.statusCode}');
      print('Response: ${response.body}');

      if (response.statusCode == 401) {
        throw Exception('Please login or sign up first.');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      }

      throw Exception('Failed to remove favourite: ${response.statusCode}');
    } catch (e, stackTrace) {
      print('========== REMOVE FAV API ERROR ==========');
      print(e);
      print(stackTrace);
      rethrow;
    }
  }
}
