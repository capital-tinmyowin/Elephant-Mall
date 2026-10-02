class ProductVariant {
  String variantName;

  double price;

  double quantity;

  double? discountPrice;

  ProductVariant({
    required this.variantName,
    required this.price,
    required this.quantity,
    this.discountPrice,
  });
}