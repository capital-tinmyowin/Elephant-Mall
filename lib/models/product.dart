import 'package:elephant_mall/models/productImage.dart';
import 'package:elephant_mall/models/product_variant.dart';
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
  final int? userId; //  Must be Seller? not String?
  final List<ProductImage>? productImages;
  final List<ProductVariant>? variants;
  final List<String> colors;
  final bool isNew;

  Product({
    this.productId = 0,
    required this.productCode,
    required this.productName,
    required this.price,
    this.category = '',
    this.location = '',
    this.condition = '',
    this.image = '',
    // this.rating = 4.5,
    // this.ratingCount = 0,
    this.description,
    this.userId,
    this.productImages,
    this.variants,
    this.colors = const [],
    this.isNew = false,
  });

  // ============= IMAGE GETTERS =============
  String get mainColor {
    return colors.isNotEmpty ? colors.first : 'default';
  }

  String get proxiedImageUrl {
    return ApiService.getProxiedImageUrl(image);
  }

  List<String> get proxiedAllImages {
    final Set<String> uniqueUrls = {};

    if (image.isNotEmpty) uniqueUrls.add(image);

    if (productImages != null) {
      for (final pi in productImages!) {
        if (pi.imageUrl.isNotEmpty) uniqueUrls.add(pi.imageUrl);
      }
    }

    if (uniqueUrls.isEmpty) {
      uniqueUrls.add('https://picsum.photos/seed/$productCode/400/400');
    }

    return uniqueUrls.map((url) => ApiService.getProxiedImageUrl(url)).toList();
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    int productId = 0;
    final rawId = json['productId'] ?? json['id'];
    if (rawId is int) {
      productId = rawId;
    } else if (rawId is String) {
      productId = int.tryParse(rawId) ?? 0;
    }
    // Get productCode
    final productCode =
        (json['productCode'] ?? json['id'] ?? json['productId'] ?? '')
            .toString();

    // Get productName
    final productName = (json['productName'] ?? json['name'] ?? '').toString();

    // Get price
    double price = 0;
    final rawPrice = json['price'];
    if (rawPrice is num) {
      price = rawPrice.toDouble();
    } else if (rawPrice is String) {
      price = double.tryParse(rawPrice.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    }

    // Get category
    String category = json['category'] ?? json['categoryName'] ?? '';
    String imageUrl =
        json['ImageUrl'] ?? json['imageUrl'] ?? json['image'] ?? '';
    // Get colors
    List<String> colors = [];
    if (json['colors'] != null && json['colors'] is List) {
      colors = List<String>.from(json['colors']);
    }

    // Get seller
    int? userId;
    if (json['userId'] != null) {
      userId = json['userId'] is int
          ? json['userId']
          : int.tryParse(json['userId'].toString());
    }

    // Get product images
    List<ProductImage> productImages = [];
    if (json['pImageList'] is List) {
      productImages = (json['pImageList'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => ProductImage.fromJson(e))
          .toList();
    } else if (json['productImages'] is List) {
      productImages = (json['productImages'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => ProductImage.fromJson(e))
          .toList();
    }
    // if (productImages.isEmpty && imageUrl.isNotEmpty) {
    //   productImages = [imageUrl];
    // }
    List<ProductVariant>? variants;
    if (json['variants'] != null && json['variants'] is List) {
      variants = (json['variants'] as List)
          .map((v) => ProductVariant.fromJson(v))
          .toList();
    }
    return Product(
      productId: productId,
      productCode: productCode,
      productName: productName,
      userId: userId,
      price: price,
      category: category,
      image: imageUrl,
      // rating: (json['rating'] ?? 4.5).toDouble(),
      // ratingCount: json['ratingCount'] ?? 0,
      description: json['description'] ?? '',
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
      'userId': userId,
      'productImages': productImages,
      'variants': variants,
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
