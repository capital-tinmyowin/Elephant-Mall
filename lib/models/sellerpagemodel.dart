class Product {
  final int productId;
  final String productName;
  final double price;
  final String imageUrl;
  final int favourite;
  final int? categoryId;
  final bool isEdit;

  Product({
    required this.productId,
    required this.productName,
    required this.price,
    required this.imageUrl,
    this.favourite = 0,
    this.categoryId,
    this.isEdit = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: int.tryParse(json['productId']?.toString() ?? '') ?? 0,
      productName: json['productName']?.toString() ?? '',
      price: double.tryParse(json['price']?.toString() ?? '') ?? 0.0,
      imageUrl: json['imageUrl']?.toString() ?? '',
      favourite: int.tryParse(json['favourite']?.toString() ?? '') ?? 0,
      categoryId: int.tryParse(
        json['categoryId']?.toString() ?? json['CategoryId']?.toString() ?? '',
      ),
      isEdit: json['is_Edit'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'imageUrl': imageUrl,
      'favourite': favourite,
      'categoryId': categoryId,
      'is_Edit': isEdit,
    };
  }

  Product copyWith({
    int? productId,
    String? productName,
    double? price,
    String? imageUrl,
    int? favourite,
    int? categoryId,
    bool? isEdit,
  }) {
    return Product(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      favourite: favourite ?? this.favourite,
      categoryId: categoryId ?? this.categoryId,
      isEdit: isEdit ?? this.isEdit,
    );
  }
}
