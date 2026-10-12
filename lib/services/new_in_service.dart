import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' hide Category;
import 'package:http/http.dart' as http;
import 'package:http/browser_client.dart' show BrowserClient;

import '../models/new_in.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';

class NewInService {
  // ------------------------------------------------------------
  // MOCK API RESPONSE
  // ------------------------------------------------------------
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

  // ------------------------------------------------------------
  // GET NEW IN PRODUCTS
  // ------------------------------------------------------------

  static const String _newInUrl =
      'https://www.capital-sys.net/CKMMallAPI/api/productshowcase/GetNewProductList';

  Future<List<NewInModel>> getNewInProducts({AuthService? authService}) async {
    try {
      http.Response response;

      // ============================================================
      // WEB
      // ============================================================
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
      // ============================================================
      // ANDROID / iOS
      // ============================================================
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

      print('========== NEW IN API ==========');
      print('URL: $_newInUrl');
      print('Status Code: ${response.statusCode}');
      print('Response: ${response.body}');
      print('================================');

      if (response.statusCode != 200) {
        throw Exception('Failed to load new products: ${response.statusCode}');
      }

      final List<dynamic> jsonData = jsonDecode(response.body);

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

  static const String _categoryUrl =
      'https://www.capital-sys.net/CKMMallAPI/api/category/all';

  Future<List<String>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse(_categoryUrl),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }

      final List<dynamic> jsonData = jsonDecode(response.body);

      final categories = jsonData
          .map<String>((json) => json['name'].toString())
          .where((name) => name.toLowerCase() != 'root')
          .toList();

      return categories;
    } catch (e, stackTrace) {
      // print("========== CATEGORY ERROR ==========");
      // print("Error: $e");
      // print("StackTrace: $stackTrace");
      // print("====================================");

      rethrow;
    }
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

      // ============================================================
      // WEB
      // ============================================================
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
      // ============================================================
      // ANDROID / iOS
      // ============================================================
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
}
