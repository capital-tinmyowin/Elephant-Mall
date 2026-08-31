class SaleModel {
  final String productName;
  final String category;
  final double originalPrice;
  final double salePrice;
  final int discount;
  final double rating;
  final int reviewCount;
  final String imagePath;
  final bool isNew;

  SaleModel({
    required this.productName,
    required this.category,
    required this.originalPrice,
    required this.salePrice,
    required this.discount,
    required this.rating,
    required this.reviewCount,
    required this.imagePath,
    required this.isNew,
  });

  factory SaleModel.fromJson(Map<String, dynamic> json) {
    return SaleModel(
      productName: json['productName'] ?? '',
      category: json['category'] ?? '',
      originalPrice: (json['originalPrice'] as num).toDouble(),
      salePrice: (json['salePrice'] as num).toDouble(),
      discount: json['discount'] ?? 0,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      imagePath: json['imagePath'] ?? '',
      isNew: json['isNew'] ?? false,
    );
  }
}