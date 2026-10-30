import 'product_variant.dart';

class SellProductModel {
  final int productId;
  final String productCode;
  final int userId;

  final String title;
  final String description;
  final String location;
  final String price;
  final String discountPrice;
  final String condition;
  final String status;
  final int businessContactGroupId;

  final String sku;
  final String quantity;

  final String phoneNumber;
  final String messengerLink;
  final String telegram;
  final String viber;

  final List<int> categoryIds;
  final List<ProductVariant> variants;

  final List<ProductImageItem> images;
  SellProductModel({
    required this.productId,
    required this.productCode,
    required this.userId,
    required this.title,
    required this.description,
    required this.location,
    required this.price,
    required this.discountPrice,
    required this.condition,
    required this.status,
    required this.businessContactGroupId,
    required this.sku,
    required this.quantity,
    required this.phoneNumber,
    required this.messengerLink,
    required this.telegram,
    required this.viber,
    required this.categoryIds,
    required this.variants,
    required this.images,
  });

  factory SellProductModel.fromJson(Map<String, dynamic> json) {
    // CATEGORIES

    final List<int> categoryIds = [];

    final categoryList = json['pCategoryList'];

    if (categoryList is List) {
      for (final item in categoryList) {
        if (item is Map) {
          final categoryId = int.tryParse(item['categoryId']?.toString() ?? '');

          if (categoryId != null && categoryId > 0) {
            categoryIds.add(categoryId);
          }
        }
      }
    }

    // if (categoryList is List) {
    //   for (final item in categoryList) {
    //     if (item is Map<String, dynamic>) {
    //       final categoryId = int.tryParse(item['categoryId']?.toString() ?? '');

    //       if (categoryId != null) {
    //         categoryIds.add(categoryId);
    //       }
    //     }
    //   }
    // }

    // VARIANTS

    final List<ProductVariant> variants = [];

    final variantList = json['pVariantList'];

    if (variantList is List) {
      for (final item in variantList) {
        if (item is Map<String, dynamic>) {
          // Strip commas / non-numeric chars before parsing
          double parseMoney(dynamic raw) {
            if (raw == null) return 0;
            if (raw is num) return raw.toDouble();
            final cleaned = raw.toString().replaceAll(RegExp(r'[^0-9.]'), '');
            return double.tryParse(cleaned) ?? 0;
          }

          final rawDiscount = item['discountPrice'];
          final double? discount =
              (rawDiscount == null || rawDiscount.toString().trim().isEmpty)
              ? null
              : parseMoney(rawDiscount);

          variants.add(
            ProductVariant(
              variantId:
                  item['variantId']?.toString() ??
                  item['variantID']?.toString() ??
                  '',
              variantName: item['variantName']?.toString() ?? '',
              price: parseMoney(item['price']),
              quantity: int.tryParse(item['quantity']?.toString() ?? '0') ?? 0,
              discountPrice: (discount != null && discount > 0)
                  ? discount
                  : null,
            ),
          );
        }
      }
    }

    // IMAGES

    // IMAGES
    final List<ProductImageItem> images = [];

    final imageList = json['pImageList'];
    if (imageList is List) {
      for (final item in imageList) {
        if (item is Map) {
          final map = Map<String, dynamic>.from(item);
          final imageUrl = map['imageUrl']?.toString() ?? '';
          final id = int.tryParse(map['id']?.toString() ?? '') ?? 0;

          if (imageUrl.isNotEmpty) {
            images.add(
              ProductImageItem(
                id: id,
                imageUrl: imageUrl,
                sortOrder:
                    int.tryParse(map['sortOrder']?.toString() ?? '') ?? 0,
              ),
            );
          }
        }
      }
      images.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    }

    // BUSINESS CONTACTS
    //
    // Location is NOT taken from businesscontact.
    // Location comes from product-level "location".
    // ==========================================================

    String phoneNumber = '';
    String messengerLink = '';
    String telegram = '';
    String viber = '';

    final contacts = json['businesscontact'];

    if (contacts is List) {
      for (final item in contacts) {
        if (item is! Map<String, dynamic>) {
          continue;
        }

        final type = item['type']?.toString() ?? '';
        final value = item['value']?.toString() ?? '';

        if (value.isEmpty) {
          continue;
        }

        if (type == 'Phone' && phoneNumber.isEmpty) {
          phoneNumber = value;
        } else if (type == 'Messenger' && messengerLink.isEmpty) {
          messengerLink = value;
        } else if (type == 'Telegram' && telegram.isEmpty) {
          telegram = value;
        } else if (type == 'Viber' && viber.isEmpty) {
          viber = value;
        }
      }
    }

    // PRODUCT PRICE / QUANTITY / SKU

    final String price = (() {
      final raw = json['price'];
      if (raw is num) return raw.toString();
      final cleaned = (raw?.toString() ?? '0').replaceAll(
        RegExp(r'[^0-9.]'),
        '',
      );
      return cleaned.isEmpty ? '0' : cleaned;
    })();

    final String discountPrice = (() {
      final raw = json['discountPrice'];
      if (raw == null) return '';
      if (raw is num) return raw.toString();
      final cleaned = raw.toString().replaceAll(RegExp(r'[^0-9.]'), '');
      return cleaned;
    })();

    String sku = '';
    String quantity = '0';

    // to use variantName as the SKU.
    if (variants.length == 1) {
      sku = variants.first.variantName;
      quantity = variants.first.quantity.toStringAsFixed(0);
    }

    // RETURN MODEL

    return SellProductModel(
      productId: int.tryParse(json['productId']?.toString() ?? '') ?? 0,

      productCode: json['productCode']?.toString() ?? '',

      userId: int.tryParse(json['userId']?.toString() ?? '') ?? 0,

      title: json['productName']?.toString() ?? '',

      description: json['description']?.toString() ?? '',

      location: json['location']?.toString() ?? '',

      price: price,

      discountPrice: discountPrice,

      condition: json['condition']?.toString() ?? '',

      status: json['status']?.toString() ?? '',

      businessContactGroupId:
          int.tryParse(json['businessContactGroupId']?.toString() ?? '') ?? 0,

      sku: sku,

      quantity: quantity,

      phoneNumber: phoneNumber,

      messengerLink: messengerLink,

      telegram: telegram,

      viber: viber,

      categoryIds: categoryIds,

      variants: variants,

      images: images,
    );
  }
}

class ProductImageItem {
  final int id;
  final String imageUrl;
  final int sortOrder;

  const ProductImageItem({
    required this.id,
    required this.imageUrl,
    required this.sortOrder,
  });
}
