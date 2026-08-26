class NewInModel {
  final int productCode;
  final String productName;
  final String category;
  final double price;
  final double rating;
  final int reviewCount;
  final String imagePath;
  final bool isNew;

  NewInModel({
    required this.productCode,
    required this.productName,
    required this.category,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.imagePath,
    required this.isNew,
  });

  factory NewInModel.fromJson(Map<String, dynamic> json) {
    return NewInModel(
      productCode: json['productCode'],
      productName: json['productName'],
      category: json['category'],
      price: (json['price'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['reviewCount'],
      imagePath: json['imagePath'],
      isNew: json['isNew'] ?? false,
    );
  }
}
