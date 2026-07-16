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
  final Seller? seller;  //  Must be Seller? not String?
  final List<String>? productImages;

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
  });

  String get proxiedImageUrl {
    return ApiService.getProxiedImageUrl(image);
  }

  List<String> get allImages {
    final List<String> images = [image];
    if (productImages != null && productImages!.isNotEmpty) {
      images.addAll(productImages!);
    }
    return images;
  }

  List<String> get proxiedAllImages {
    return allImages.map((url) => ApiService.getProxiedImageUrl(url)).toList();
  }

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
      productImages: json['productImages'] != null && json['productImages'] is List
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