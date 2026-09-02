import 'product_variant.dart';

class SellProductModel {
  final int productCode;

  final String title;
  final String description;
  final String price;
  final String sku;
  final String quantity;

  final String phoneNumber;
  final String messengerLink;
  final String telegram;
  final String viber;

  final List<int> categoryIds;
  final List<ProductVariant> variants;

  SellProductModel({
    required this.productCode,
    required this.title,
    required this.description,
    required this.price,
    required this.sku,
    required this.quantity,
    required this.phoneNumber,
    required this.messengerLink,
    required this.telegram,
    required this.viber,
    required this.categoryIds,
    required this.variants,
  });
}
