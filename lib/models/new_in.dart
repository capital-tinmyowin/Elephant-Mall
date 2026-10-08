class NewInModel {
  final int productId;
  final String productName;

  final String category;
  final double rating;
  final int reviewCount;

  final double price;
  final String imageUrl;
  final int favourite;

  NewInModel({
    required this.productId,
    required this.productName,
    required this.category,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    required this.favourite,
  });

  factory NewInModel.fromJson(Map<String, dynamic> json) {
    return NewInModel(
      productId: int.tryParse(
            json['productId']?.toString() ?? '',
          ) ??
          0,

      productName: json['productName']?.toString() ?? '',

      category: json['category']?.toString() ?? '',

      price: double.tryParse(
            json['price']?.toString().replaceAll(',', '') ?? '',
          ) ??
          0.0,

      rating: json['rating'] is num
          ? (json['rating'] as num).toDouble()
          : double.tryParse(
                json['rating']?.toString() ?? '',
              ) ??
              0.0,

      reviewCount: int.tryParse(
            json['reviewCount']?.toString() ?? '',
          ) ??
          0,

      imageUrl: json['imageUrl']?.toString() ?? '',

      favourite: int.tryParse(
            json['favourite']?.toString() ?? '',
          ) ??
          0,
    );
  }
}