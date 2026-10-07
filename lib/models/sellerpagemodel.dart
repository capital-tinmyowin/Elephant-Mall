class Product {
  final int productId;
  final String productName;
  final double price;
  final String imageUrl;
  final int favourite;

  Product({
    required this.productId,
    required this.productName,
    required this.price,
    required this.imageUrl,
    this.favourite = 0,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: int.tryParse(
            json['productId']?.toString() ?? '',
          ) ??
          0,

      productName: json['productName']?.toString() ?? '',

      price: double.tryParse(
            json['price']?.toString() ?? '',
          ) ??
          0.0,

      imageUrl: json['imageUrl']?.toString() ?? '',

      favourite: int.tryParse(
            json['favourite']?.toString() ?? '',
          ) ??
          0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'imageUrl': imageUrl,
      'favourite': favourite,
    };
  }

  Product copyWith({
    int? productId,
    String? productName,
    double? price,
    String? imageUrl,
    int? favourite,
  }) {
    return Product(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      favourite: favourite ?? this.favourite,
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
      name: json['name']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString(),
      isFollowing: json['isFollowing'] == true,
    );
  }
}