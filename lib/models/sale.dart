class SaleModel {
  final int productId;
  final String productName;
  final String categoryId;
  final double originalPrice; // price
  final double salePrice;     // discount_Price
  final int discount;         // calculated %
  final String imageUrl;
  int favourite;
  final bool isEdit;

  SaleModel({
    required this.productId,
    required this.productName,
    required this.categoryId,
    required this.originalPrice,
    required this.salePrice,
    required this.discount,
    required this.imageUrl,
    required this.favourite,
    required this.isEdit,
  });

  static double _parseMoney(dynamic value) {
    if (value == null) return 0;
    return double.tryParse(value.toString().replaceAll(',', '')) ?? 0;
  }

  factory SaleModel.fromJson(Map<String, dynamic> json) {
    final original = _parseMoney(json['price']);
    final sale = _parseMoney(json['discount_Price']);

    int discountPct = 0;
    if (original > 0 && sale >= 0 && sale < original) {
      discountPct = (((original - sale) / original) * 100).round();
    }

    final rawImage = json['imageUrl']?.toString() ?? '';
    // Adjust base path if your images live elsewhere
    const imageBase = 'https://www.capital-sys.net/CKMMallAPI/uploads/';
    final imageUrl = rawImage.isEmpty
        ? ''
        : rawImage.startsWith('http')
            ? rawImage
            : '$imageBase$rawImage';

    return SaleModel(
      productId: int.tryParse(json['productId']?.toString() ?? '') ?? 0,
      productName: json['productName']?.toString() ?? '',
      categoryId: json['categoryId']?.toString() ?? '',
      originalPrice: original,
      salePrice: sale,
      discount: discountPct,
      imageUrl: imageUrl,
      favourite: int.tryParse(json['favourite']?.toString() ?? '') ?? 0,
      isEdit: json['is_Edit'] == true,
    );
  }
}