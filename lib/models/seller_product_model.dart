class SellerProduct {
  final int productId;
  final String productName;
  final double price;
  final String imageUrl;
  final bool favourite;

  SellerProduct({
    required this.productId,
    required this.productName,
    required this.price,
    required this.imageUrl,
    required this.favourite,
  });

  factory SellerProduct.fromJson(Map<String, dynamic> json) {
    return SellerProduct(
      productId: int.tryParse(
            json['productId']?.toString() ?? '0',
          ) ??
          0,

      productName: json['productName']?.toString() ?? '',

      price: double.tryParse(
            json['price']?.toString() ?? '0',
          ) ??
          0.0,

      imageUrl: json['imageUrl']?.toString() ?? '',

      favourite: json['favourite']?.toString() == '1',
    );
  }
}