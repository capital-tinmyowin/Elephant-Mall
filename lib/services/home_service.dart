// import 'dart:convert';
// import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:elephant_mall/models/product.dart';
import 'package:elephant_mall/services/Category_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/Category.dart';
import '../models/banner.dart';
import '../models/promo.dart';

// class HomeService {
//   static const String baseUrl = "http://localhost:5086/api";

//   final http.Client client = http.Client();

//   Future<List<BannerModel>> getBanners() async {
//     final response = await client.get(
//       Uri.parse("$baseUrl/Banners/GetBannerList"),
//     );
//     if (response.statusCode == 200) {
//       final List jsonData = jsonDecode(response.body);
//       return jsonData.map((e) => BannerModel.fromJson(e)).toList();
//     }
//     throw Exception("Failed to load banners");
//   }

//   Future<List<Category>> getCategories() async {
//     final response = await client.get(
//       Uri.parse("$baseUrl/Categories/GetCategoryList"),
//     );

//     if (response.statusCode == 200) {
//       final List jsonData = jsonDecode(response.body);

//       return jsonData.map((e) => Category.fromJson(e)).toList();
//     }

//     throw Exception("Failed to load categories");
//   }

//   Future<List<Product>> getProducts() async {
//     final response = await client.get(
//       Uri.parse("$baseUrl/Products/GetProductList"),
//     );
//     if (response.statusCode == 200) {
//       final List jsonData = jsonDecode(response.body);
//       return jsonData.map((e) => Product.fromJson(e)).toList();
//     }
//     throw Exception("Failed to load products");
//   }

//   Future<List<Promo>> getPromos() async {
//     final response = await client.get(
//       Uri.parse("$baseUrl/Promos/GetPromoList"),
//     );
//     if (response.statusCode == 200) {
//       final List jsonData = jsonDecode(response.body);
//       return jsonData.map((e) => Promo.fromJson(e)).toList();
//     }
//     throw Exception("Failed to load promos");
//   }
// }
class HomeService {
  static const String _trendingUrl =
      'https://www.capital-sys.net/CKMMallAPI/api/trending/GetTrendingProducts';
  static const String _trendingCategoriesUrl =
      'https://www.capital-sys.net/CKMMallAPI/api/Trending/GetTrendingCategories';

  Future<List<BannerModel>> getBanners() async {
    final List jsonData = [
      {
        "bannerId": 1,
        "title": "YANGON SUMMER HEATWAVE SAVINGS!",
        "description": "Cool styles for Yangon’s hottest days.",
        "imagePath": "assets/home.png",
        "link": "/sale",
        "sortOrder": 1,
        "isActive": true,
      },

      // {
      //   "bannerId":2,
      //   "title":"NEW ARRIVALS",
      //   "description":"Discover latest fashion trends.",
      //   "imagePath":"assets/home1.png",
      //   "link":"/products/new",
      //   "sortOrder":2,
      //   "isActive":true
      // },
      // {
      //   "bannerId":3,
      //   "title":"BIG SALE 50% OFF",
      //   "description":"Don’t miss the best deals.",
      //   "imagePath":"assets/promotion-banner.png",
      //   "link":"/promotion",
      //   "sortOrder":3,
      //   "isActive":true
      // },
      // {
      //   "bannerId":4,
      //   "title":"NEW ARRIVALS",
      //   "description":"Discover latest fashion trends.",
      //   "imagePath":"assets/promotion-banner2.png",
      //   "link":"/products/new",
      //   "sortOrder":2,
      //   "isActive":true
      // },
    ];
    return jsonData.map((e) => BannerModel.fromJson(e)).toList();
  }

  // Future<List<Category>> getCategories() async {
  //   final List jsonData = [
  //     {
  //       "categoryId": 1,
  //       "categoryName": "T-Shirts",
  //       "photoPath": "assets/tshirt.png",
  //       "sortOrder": 1,
  //       "isActive": true,
  //     },
  //     {
  //       "categoryId": 2,
  //       "categoryName": "Blouses",
  //       "photoPath": "assets/store_banner.jpg",
  //       "sortOrder": 2,
  //       "isActive": true,
  //     },
  //     {
  //       "categoryId": 3,
  //       "categoryName": "Bags",
  //       "photoPath": "assets/bag.png",
  //       "sortOrder": 3,
  //       "isActive": true,
  //     },
  //     {
  //       "categoryId": 4,
  //       "categoryName": "Shoes",
  //       "photoPath": "assets/shoe.png",
  //       "sortOrder": 4,
  //       "isActive": true,
  //     },
  //     {
  //       "categoryId": 5,
  //       "categoryName": "တီရှပ်",
  //       "photoPath": "assets/tshirt.png",
  //       "sortOrder": 1,
  //       "isActive": true,
  //     },
  //     {
  //       "categoryId": 6,
  //       "categoryName": "အမျိုးသမီးဝတ်အင်္ကျီ",
  //       "photoPath": "assets/linen.webp",
  //       "sortOrder": 2,
  //       "isActive": true,
  //     },
  //     {
  //       "categoryId": 7,
  //       "categoryName": "အိတ်",
  //       "photoPath": "assets/bag.png",
  //       "sortOrder": 3,
  //       "isActive": true,
  //     },
  //     {
  //       "categoryId": 8,
  //       "categoryName": "Shoes",
  //       "photoPath": "assets/shoe.png",
  //       "sortOrder": 4,
  //       "isActive": true,
  //     },
  //     {
  //       "categoryId": 9,
  //       "categoryName": "T-Shirts",
  //       "photoPath": "assets/tshirt.png",
  //       "sortOrder": 1,
  //       "isActive": true,
  //     },
  //     {
  //       "categoryId": 10,
  //       "categoryName": "Blouses",
  //       "photoPath": "assets/store_banner.jpg",
  //       "sortOrder": 2,
  //       "isActive": true,
  //     },
  //     {
  //       "categoryId": 11,
  //       "categoryName": "အိတ်",
  //       "photoPath": "assets/bag.png",
  //       "sortOrder": 3,
  //       "isActive": true,
  //     },
  //     {
  //       "categoryId": 12,
  //       "categoryName": "Shoes",
  //       "photoPath": "assets/shoe.png",
  //       "sortOrder": 4,
  //       "isActive": true,
  //     },
  //     {
  //       "categoryId": 13,
  //       "categoryName": "Bags",
  //       "photoPath": "assets/bag.png",
  //       "sortOrder": 3,
  //       "isActive": true,
  //     },
  //     {
  //       "categoryId": 14,
  //       "categoryName": "ဖိနပ်",
  //       "photoPath": "assets/shoe.png",
  //       "sortOrder": 4,
  //       "isActive": true,
  //     },
  //     {
  //       "categoryId": 15,
  //       "categoryName": "T-Shirts",
  //       "photoPath": "assets/tshirt.png",
  //       "sortOrder": 1,
  //       "isActive": true,
  //     },
  //   ];

  //   return jsonData.map((e) => Category.fromJson(e)).toList();
  // }
  Future<List<Category>> getCategories() async {
    try {
      final response = await http
          .get(
            Uri.parse(_trendingCategoriesUrl),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        debugPrint('Trending categories status: ${response.statusCode}');
        return [];
      }

      final dynamic data = json.decode(response.body);

      List<dynamic> list = [];
      if (data is List) {
        list = data;
      } else if (data is Map<String, dynamic> && data['data'] is List) {
        list = data['data'];
      }

      return list
          .whereType<Map<String, dynamic>>()
          .map(_parseTrendingCategory)
          .toList();
    } catch (e) {
      debugPrint('Trending categories error: $e');
      return [];
    }
  }

  Category _parseTrendingCategory(Map<String, dynamic> json) {
    final idRaw = json['categoryId'] ?? json['id'];
    int id = 0;
    if (idRaw is int) {
      id = idRaw;
    } else if (idRaw is String) {
      id = int.tryParse(idRaw) ?? 0;
    }

    final nameRaw = json['categoryName'] ?? json['name'];
    final name = nameRaw is String ? nameRaw : '';

    // "/men.jpg" — prefix with the backend host
    String imgRaw = (json['categoryImageUrl'] ?? json['photoPath'] ?? '')
        .toString();
    imgRaw = _normalizeImageUrl(imgRaw);
    if (imgRaw.isEmpty) {
      imgRaw = 'assets/images/placeholders/category_placeholder.jpg';
    }

    return Category(
      categoryId: id,
      categoryName: name,
      photoPath: imgRaw,
      // if your Category model has sortOrder / isActive, keep their defaults
    );
  }

  // Future<List<Product>> getProducts() async {
  //   final List jsonData=[
  //     {
  //       "productCode":1,
  //       "productName":"ဖိနပ်",
  //       "description":"Comfort shoes",
  //       "price":150.45,
  //       "imagePath":"assets/man-sneaker.png",
  //       "rating":5
  //     },
  //     {
  //       "productCode":2,
  //       "productName":"Women's Wristwatch",
  //       "description":"Luxury watch",
  //       "price":65,
  //       "imagePath":"assets/woman-watch.png",
  //       "rating":4
  //     },
  //     {
  //       "productCode":3,
  //       "productName":"Leather Backpack",
  //       "description":"Travel bag",
  //       "price":11000,
  //       "imagePath":"assets/leatherBag.jpg",
  //       "rating":3
  //     },
  //     {
  //       "productCode":4,
  //       "productName":"အမျိုးသမီးဝတ်အင်္ကျီ",
  //       "description":"Fashion shirt",
  //       "price":45,
  //       "imagePath":"assets/linen.webp",
  //       "rating":2
  //     },
  //      {
  //       "productCode":5,
  //       "productName":"အားကစားဖိနပ်",
  //       "description":"Comfort shoes",
  //       "price":89,
  //       "imagePath":"assets/man-sneaker.png",
  //       "rating":1
  //     },
  //     {
  //       "productCode":6,
  //       "productName":"လက်ပတ်နာရီ",
  //       "description":"Luxury watch",
  //       "price":65,
  //       "imagePath":"assets/woman-watch.png",
  //       "rating":0
  //     },
  //     {
  //       "productCode":7,
  //       "productName":"Leather Backpack",
  //       "description":"Travel bag",
  //       "price":11,
  //       "imagePath":"assets/leatherBag.jpg",
  //       "rating":5
  //     },
  //     {
  //       "productCode":8,
  //       "productName":"အမျိုးသမီးဝတ်အင်္ကျီ",
  //       "description":"Fashion shirt",
  //       "price":45,
  //       "imagePath":"assets/linen.webp",
  //       "rating":4
  //     },
  //     {
  //       "productCode":9,
  //       "productName":"Men's Sneakers",
  //       "description":"Comfort shoes",
  //       "price":89,
  //       "imagePath":"assets/man-sneaker.png",
  //       "rating":5
  //     },
  //     {
  //       "productCode":10,
  //       "productName":"Women's Wristwatch",
  //       "description":"Luxury watch",
  //       "price":65,
  //       "imagePath":"assets/woman-watch.png",
  //       "rating":4
  //     },
  //     {
  //       "productCode":11,
  //       "productName":"သားရေကျောပိုးအိတ်",
  //       "description":"Travel bag",
  //       "price":11,
  //       "imagePath":"assets/leatherBag.jpg",
  //       "rating":5
  //     },
  //     {
  //       "productCode":12,
  //       "productName":"Linen Shirt",
  //       "description":"Fashion shirt",
  //       "price":45,
  //       "imagePath":"assets/linen.webp",
  //       "rating":4
  //     },
  //       {
  //       "productCode":13,
  //       "productName":"Leather Backpack",
  //       "description":"Travel bag",
  //       "price":11000,
  //       "imagePath":"assets/leatherBag.jpg",
  //       "rating":3
  //     },
  //     {
  //       "productCode":14,
  //       "productName":"Linen Shirt",
  //       "description":"Fashion shirt",
  //       "price":45,
  //       "imagePath":"assets/linen.webp",
  //       "rating":2
  //     },
  //   ];
  //   return jsonData
  //       .map((e)=>Product.fromJson(e))
  //       .toList();
  // }
  Future<List<Product>> getProducts() async {
    try {
      final response = await http
          .get(
            Uri.parse(_trendingUrl),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        return [];
      }

      final dynamic data = json.decode(response.body);

      List<dynamic> list = [];
      if (data is List) {
        list = data;
      } else if (data is Map<String, dynamic> && data['data'] is List) {
        list = data['data'];
      }

      return list
          .whereType<Map<String, dynamic>>()
          .map(_parseTrendingProduct)
          .toList();
    } catch (e) {
      debugPrint('trending error: $e');
      return [];
    }
  }

  Product _parseTrendingProduct(Map<String, dynamic> json) {
    // ── price: may be "100,000" (string) or a number ──
    double price = 0;
    final rawPrice = json['price'];
    if (rawPrice is num) {
      price = rawPrice.toDouble();
    } else if (rawPrice is String) {
      price = double.tryParse(rawPrice.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    }

    // ── id (used for both productId and productCode) ──
    final rawId = json['productId'];
    int productId = 0;
    if (rawId is int) {
      productId = rawId;
    } else if (rawId is String) {
      productId = int.tryParse(rawId) ?? 0;
    }

    // ── image: could be a full URL or a bare filename ──
    String image = _normalizeImageUrl((json['imageUrl'] ?? '').toString());
    if (image.isEmpty) {
      image = 'assets/images/placeholders/category_placeholder.jpg';
    }

    final name = (json['productName'] ?? '').toString();
    final category = (json['categoryName'] ?? '').toString();

    return Product(
      productId: productId,
      productCode: productId.toString(),
      productName: name,
      price: price,
      category: category,
      image: image,
      description: null,
      userId: null,
    );
  }

  Future<List<Promo>> getPromos() async {
    final List jsonData = [
      {
        "promoId": 1,
        "title": "Summer Sale 50% OFF",
        "imagePath": "assets/newitem.png",
        "link": "/sale",
        "sortOrder": 1,
        "isActive": true,
      },
      {
        "promoId": 2,
        "title": "New Fashion Collection",
        "imagePath": "assets/saleitem.png",
        "link": "/products/new",
        "sortOrder": 2,
        "isActive": true,
      },
    ];
    return jsonData.map((e) => Promo.fromJson(e)).toList();
  }

  String _normalizeImageUrl(String raw) {
    if (raw.isEmpty) return '';
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;

    // "C:/CKMMallImages/CategoryImages/men.jpg" → "/CKMMallImages/CategoryImages/men.jpg"
    final driveIdx = raw.indexOf(':/');
    if (driveIdx >= 0) {
      final path = raw.substring(driveIdx + 2); // skip "C:/"
      return 'https://www.capital-sys.net/$path';
    }

    // Already "CKMMallImages/..." or bare filename → prefix
    if (raw.startsWith('CKMMallImages/')) {
      return 'https://www.capital-sys.net/$raw';
    }
    return 'https://www.capital-sys.net/CKMMallImages/CategoryImages/$raw';
  }
}
