class ProductVariant {
  final String variantName;
  final double price;
  final int quantity;

  double? discountPrice;
  final String variantId;
 

  ProductVariant({
    required this.variantId,
    required this.variantName,
    required this.price,
    required this.quantity,
    this.discountPrice,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
  // variantId
  final variantId = (
        json['variantID'] ?? json['variantId'] ?? json['id'] ?? ''
      ).toString();

  // variantName
  final variantName = (
        json['variantName'] ?? json['name'] ?? ''
      ).toString();

  // price — check both `price` and `variantPrice`
  double price = 0;
  final rawPrice = json['price'] ?? json['variantPrice'];
  if (rawPrice is num) {
    price = rawPrice.toDouble();
  } else if (rawPrice is String) {
    price = double.tryParse(
          rawPrice.replaceAll(RegExp(r'[^0-9.]'), ''),
        ) ??
        0;
  }

  // quantity
  int quantity = 0;
  final rawQty = json['quantity'];
  if (rawQty is int) {
    quantity = rawQty;
  } else if (rawQty is String) {
    quantity = int.tryParse(rawQty) ?? 0;
  }

  return ProductVariant(
    variantId: variantId,
    variantName: variantName,
    price: price,
    quantity: quantity,
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