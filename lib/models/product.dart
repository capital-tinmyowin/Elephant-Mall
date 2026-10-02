import 'package:elephant_mall/models/product_variant.dart';
import 'package:elephant_mall/services/mock_api_service.dart';
import 'package:flutter/foundation.dart';

import '../services/Category_service.dart';

class Product {
  final int productId;
  final String productCode;
  final String productName;
  final double price;
  final String category;
  final String location;
  final String condition;
  final String image;
  // final double rating;
  // final int ratingCount;
  final String? description;
  final Seller? seller; //  Must be Seller? not String?
  final List<String>? productImages;
  final List<ProductVariant>? variants;
  final List<String> colors;
  final bool isNew;

  Product({
    this.productId = 0,
    required this.productCode,
    required this.productName,
    required this.price,
     this.category='',
     this.location='',
     this.condition='',
     this.image='',
    // this.rating = 4.5,
    // this.ratingCount = 0,
    this.description,
    this.seller,
    this.productImages,
    this.variants,
    this.colors = const [],
    this.isNew = false,
  });

  // ============= IMAGE GETTERS =============
  String get mainColor {
    return colors.isNotEmpty ? colors.first : 'default';
  }

//   String get proxiedImageUrl {
//   // If using mock data
//   if (ApiService.useMockDataStatic) {
//     if (image.isNotEmpty) {
//       if (image.startsWith('http://') || image.startsWith('https://')) {
//         return MockApiService.getProductImagePath(this);
//       }
//       if (image.startsWith('images/')) {
//         return 'assets/$image';
//       }
//       if (image.startsWith('assets/')) {
//         return image;
//       }
//       if (!image.contains('/')) {
//         return 'images/categories/${MockApiService.getCategoryFolder(category)}/$image';
//       }
//       return 'assets/$image';
//     }
//     return MockApiService.getProductImagePath(this);
//   }

//   // If image is empty, use placeholder
//   if (image.isEmpty) {
//     return 'https://picsum.photos/seed/${productCode.toString()}/200/200';
//   }
  
//   //  If image is from Pinterest, use the backend proxy
//   if (image.contains('pinimg.com') || 
//       image.contains('pinterest')) {
//     final encodedUrl = Uri.encodeComponent(image);
//     return '${ApiService.baseUrl}/image/proxy?url=$encodedUrl';
//   }
  
//   // If it's a valid URL, return directly
//   if (image.startsWith('http://') || image.startsWith('https://')) {
//     return image;
//   }
  
//   // For local paths
//   if (image.startsWith('images/') || image.startsWith('assets/')) {
//     return 'assets/$image';
//   }
  
//   // Fallback
//   return 'https://picsum.photos/seed/${productCode.toString()}/200/200';
// }
String get proxiedImageUrl {
  // If image is empty, use placeholder
  if (image.isEmpty) {
    return 'https://picsum.photos/seed/${productCode.toString()}/200/200';
  }
  
  // For Pinterest images, use backend proxy
  if (image.contains('pinimg.com') || image.contains('pinterest')) {
    final encodedUrl = Uri.encodeComponent(image);
    return '${ApiService.baseUrl}/image/proxy?url=$encodedUrl';
  }
  
  // If it's a valid URL, return directly
  if (image.startsWith('http://') || image.startsWith('https://')) {
    return image;
  }
  
  // For local paths - 🔥 FIX: Remove duplicate 'assets/'
  if (image.startsWith('assets/')) {
    return image; // It already has 'assets/'
  }
  if (image.startsWith('images/')) {
    return 'assets/$image';
  }
  
  // Fallback
  return 'https://picsum.photos/seed/${productCode.toString()}/200/200';
}
  // All product images (for gallery) - returns all colors
  List<String> proxiedAllImages(String img) {
    // if (ApiService.useMockDataStatic) {
    //   List<String> images = [];

    //   // Get the product folder from mock service
    //   String folder = MockApiService.getProductFolder(this);

    //   // Add all color images
    //   for (var color in colors) {
    //     images.add('$folder/$color.jpg');
    //   }

    //   // If no colors, use default
    //   if (images.isEmpty) {
    //     images.add(MockApiService.getProductImagePath(this));
    //   }

    //   return images;
    // }

    // If backend is running
    final List<String> images = [img];
    if (productImages != null && productImages!.isNotEmpty) {
      images.addAll(productImages!);
    }
    return images.map((url) => ApiService.getProxiedImageUrl(url)).toList();
  }

  // String get proxiedImageUrl {
  //   return ApiService.getProxiedImageUrl(image);
  // }

//   List<String> get proxiedAllImages {
//   // 🔥 Use a Set to deduplicate
//   final Set<String> uniqueUrls = {};

//   if (image.isNotEmpty) uniqueUrls.add(image);

//   if (productImages != null) {
//     for (var url in productImages!) {
//       if (url.isNotEmpty) uniqueUrls.add(url);
//     }
//   }

//   if (uniqueUrls.isEmpty) {
//     uniqueUrls.add('https://picsum.photos/seed/$productCode/400/400');
//   }

//   return uniqueUrls.map((url) => ApiService.getProxiedImageUrl(url)).toList();
// }
  factory Product.fromJson(Map<String, dynamic> json) {

    // Get productCode
    final productCode = json['productCode'] ?? json['id'] ?? 0;

    // Get productName
    final productName = json['productName'] ?? json['name'] ?? '';

    // Get price
    double price = 0;
    if (json['price'] != null) {
      price = (json['price'] as num).toDouble();
    }

    // Get category
    String category = json['category'] ?? json['categoryName'] ?? '';

    //  CRITICAL FIX: Check for ImageUrl (capital I) FIRST
    String imageUrl =
        json['ImageUrl'] ?? json['imageUrl'] ?? json['image'] ?? '';

    // If image is from blocked domain, use placeholder
    if (imageUrl.contains('pinimg.com') ||
        imageUrl.contains('pinterest') ||
        imageUrl.contains('walmartimages.com') ||
        imageUrl.contains('img.susercontent.com')) {
      final hash = imageUrl.hashCode.abs().toString();
      imageUrl = 'https://picsum.photos/seed/$hash/200/200';
    }

    // If empty, use placeholder
    if (imageUrl.isEmpty) {
      imageUrl = 'https://picsum.photos/seed/${productCode.toString()}/200/200';
    }

    // Get colors
    List<String> colors = [];
    if (json['colors'] != null && json['colors'] is List) {
      colors = List<String>.from(json['colors']);
    }

    // Get seller
    Seller? seller;
    if (json['seller'] != null && json['seller'] is Map<String, dynamic>) {
      seller = Seller.fromJson(json['seller']);
    }

    // Get product images
    List<String> productImages = [];
    if (json['productImages'] != null && json['productImages'] is List) {
      productImages = List<String>.from(json['productImages']);
    }
    if (productImages.isEmpty && imageUrl.isNotEmpty) {
      productImages = [imageUrl];
    }
    List<ProductVariant>? variants;
    if (json['variants'] != null && json['variants'] is List) {
      variants = (json['variants'] as List)
          .map((v) => ProductVariant.fromJson(v))
          .toList();
    }
    return Product(
      productCode: productCode,
      productName: productName,
      price: price,
      category: category,
      image: imageUrl,
      // rating: (json['rating'] ?? 4.5).toDouble(),
      // ratingCount: json['ratingCount'] ?? 0,
      description: json['description'] ?? '',
      seller: seller,
      productImages: productImages,
      variants: variants,
      colors: colors,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': productCode,
      'name': productName,
      'price': price,
      'category': category,
      'image': image,
      // 'rating': rating,
      // 'ratingCount': ratingCount,
      'description': description,
      'seller': seller?.toJson(),
      'productImages': productImages,
      'variants': variants
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
