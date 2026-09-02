import 'dart:convert';

import '../models/new_in.dart';
import 'package:http/http.dart' as http;

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

  Future<List<NewInModel>> getNewInProducts() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    final List<dynamic> jsonData = jsonDecode(_mockJson);

    return jsonData.map((json) => NewInModel.fromJson(json)).toList();
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

}
