class Product {
  final int productId;
  final String productName;
  final double price;
  final String imageUrl;
  final int favourite; // 0 = not fav, 1 = fav
  final double? rating; // optional for UI stars
  final String? description; // optional short desc

  Product({
    required this.productId,
    required this.productName,
    required this.price,
    required this.imageUrl,
    this.favourite = 0,
    this.rating,
    this.description,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['productId'] as int,
      productName: json['productName'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      favourite: json['favourite'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble(),
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'imageUrl': imageUrl,
      'favourite': favourite,
      if (rating != null) 'rating': rating,
      if (description != null) 'description': description,
    };
  }

  Product copyWith({
    int? productId,
    String? productName,
    double? price,
    String? imageUrl,
    int? favourite,
    double? rating,
    String? description,
  }) {
    return Product(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      favourite: favourite ?? this.favourite,
      rating: rating ?? this.rating,
      description: description ?? this.description,
    );
  }
}

class SellerInfo {
  final String name;
  final String? avatarUrl;
  final bool isFollowing;

  SellerInfo({
    required this.name,
    this.avatarUrl,
    this.isFollowing = false,
  });

  factory SellerInfo.fromJson(Map<String, dynamic> json) {
    return SellerInfo(
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      isFollowing: json['isFollowing'] as bool? ?? false,
    );
  }
}