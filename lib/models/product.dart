import 'package:elephant_mall/services/mock_api_service.dart';

import '../services/Category_service.dart';

class Product {
  final int id;
  final String name;
  final double price;
  final String category;
  final String image;
  final double rating;
  final int ratingCount;
  final String? description;
  final Seller? seller; //  Must be Seller? not String?
  final List<String>? productImages;
  final List<String> colors;
  final bool isNew;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.image,
    this.rating = 4.5,
    this.ratingCount = 0,
    this.description,
    this.seller,
    this.productImages,
    this.colors = const [],
    this.isNew=false,
  });

  // ============= IMAGE GETTERS =============
  String get mainColor {
    return colors.isNotEmpty ? colors.first : 'default';
  }

  // Main product image with local fallback
  String get proxiedImageUrl {
    // If using mock data
    if (ApiService.useMockDataStatic) {
      //  If image has a valid path, use it
      if (image.isNotEmpty &&
          (image.startsWith('images/') || image.startsWith('assets/'))) {
        return image;
      }
      // Otherwise get from mock service (for products without direct image path)
      return MockApiService.getProductImagePath(this);
    }

    // If backend is running
    if (image.isNotEmpty) {
      // If it's a local path, return as-is
      if (image.startsWith('images/') || image.startsWith('assets/')) {
        return image;
      }
      return ApiService.getProxiedImageUrl(image);
    }
    // Final fallback
    return MockApiService.getProductImagePath(this);
  }

  // 🔥 All product images (for gallery) - returns all colors
  List<String> get proxiedAllImages {
    if (ApiService.useMockDataStatic) {
      List<String> images = [];

      // Get the product folder from mock service
      String folder = MockApiService.getProductFolder(this);

      // Add all color images
      for (var color in colors) {
        images.add('$folder/$color.jpg');
      }

      // If no colors, use default
      if (images.isEmpty) {
        images.add(MockApiService.getProductImagePath(this));
      }

      return images;
    }

    // If backend is running
    final List<String> images = [image];
    if (productImages != null && productImages!.isNotEmpty) {
      images.addAll(productImages!);
    }
    return images.map((url) => ApiService.getProxiedImageUrl(url)).toList();
  }

  // String get proxiedImageUrl {
  //   return ApiService.getProxiedImageUrl(image);
  // }

  factory Product.fromJson(Map<String, dynamic> json) {
    //  DEBUG
    print(' Parsing product: ${json['name']}');
    print(' Seller data type: ${json['seller'].runtimeType}');

    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      category: json['category'] ?? '',
      image: json['imageUrl'] ?? json['image'] ?? '',
      rating: (json['rating'] ?? 4.5).toDouble(),
      ratingCount: json['ratingCount'] ?? 0,
      description: json['description'],
      //  IMPORTANT: Parse Seller as Map, not as String
      seller: json['seller'] != null && json['seller'] is Map<String, dynamic>
          ? Seller.fromJson(json['seller'] as Map<String, dynamic>)
          : null,
      productImages:
          json['productImages'] != null && json['productImages'] is List
          ? List<String>.from(json['productImages'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'category': category,
      'image': image,
      'rating': rating,
      'ratingCount': ratingCount,
      'description': description,
      'seller': seller?.toJson(),
      'productImages': productImages,
    };
  }
}

// ============= SELLER MODEL =============
class Seller {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String? avatarUrl;
  final double rating;
  final int ratingCount;
  final DateTime joinDate;
  final int productCount;

  Seller({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.avatarUrl,
    this.rating = 0,
    this.ratingCount = 0,
    required this.joinDate,
    this.productCount = 0,
  });

  factory Seller.fromJson(Map<String, dynamic> json) {
    return Seller(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'],
      phone: json['phone'],
      avatarUrl: json['avatarUrl'],
      rating: (json['rating'] ?? 0).toDouble(),
      ratingCount: json['ratingCount'] ?? 0,
      joinDate: json['joinDate'] != null
          ? DateTime.parse(json['joinDate'])
          : DateTime.now(),
      productCount: json['productCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'rating': rating,
      'ratingCount': ratingCount,
      'joinDate': joinDate.toIso8601String(),
      'productCount': productCount,
    };
  }
}
