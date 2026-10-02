class ProductVariant {
  final String variantId;
  final String variantName;
  final double price;
  final int quantity;

  ProductVariant({
    required this.variantId,
    required this.variantName,
    required this.price,
    required this.quantity,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      variantId: json['variantId'] ?? json['variantID'] ?? '',
      variantName: json['variantName'] ?? '',
      price: (json['variantPrice'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'variantId': variantId,
      'variantName': variantName,
      'variantPrice': price,
      'quantity': quantity,
    };
  }
}