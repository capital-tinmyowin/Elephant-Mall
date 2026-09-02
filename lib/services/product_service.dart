import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../models/Category.dart';
import '../models/product_variant.dart';
import '../models/sell_product_model.dart';

class ProductService {
  // ============================================================
  // HARD-CODED SELL PRODUCTS
  // ============================================================

  final List<SellProductModel> _sellProducts = [
    SellProductModel(
      productCode: 1001,

      title: 'Traditional Myanmar Longyi',

      description:
          'Beautiful traditional Myanmar longyi made with high-quality material.',

      price: '35000',

      sku: 'LNG-1001',

      quantity: '10',

      phoneNumber: '09123456789',

      messengerLink: 'https://m.me/example',

      telegram: '@example',

      viber: '09123456789',

      categoryIds: [9, 10],

      variants: [
        ProductVariant(
          variantName: 'Red',
          sku: 'LNG-1001-RED',
          variant_Price: 35000,
        ),
        ProductVariant(
          variantName: 'Blue',
          sku: 'LNG-1001-BLUE',
          variant_Price: 36000,
        ),
      ],
    ),

    SellProductModel(
      productCode: 1002,

      title: 'Teak Wooden Bowl',

      description:
          'Handmade teak wooden bowl suitable for home decoration and daily use.',

      price: '25000',

      sku: 'BOWL-1002',

      quantity: '5',

      phoneNumber: '09876543210',

      messengerLink: 'https://m.me/example2',

      telegram: '@example2',

      viber: '09876543210',

      categoryIds: [2],

      variants: [
        ProductVariant(
          variantName: 'Small',
          sku: 'BOWL-1002-S',
          variant_Price: 25000,
        ),
        ProductVariant(
          variantName: 'Large',
          sku: 'BOWL-1002-L',
          variant_Price: 35000,
        ),
      ],
    ),
  ];

  // ============================================================
  // FIND SELL PRODUCT BY PRODUCT CODE
  // ============================================================

  SellProductModel? getSellProductByCode(int productCode) {
    for (final product in _sellProducts) {
      if (product.productCode == productCode) {
        return product;
      }
    }

    return null;
  }

  // ============================================================
  // CREATE PRODUCT
  // ============================================================

  Future<bool> createProduct({
    required String title,
    required String description,
    required String price,
    required String sku,
    required String quantity,
    required String phoneNumber,
    required String messengerLink,
    required String telegram,
    required String viber,
    required List<Uint8List?> images,
    required List<ProductVariant> variants,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://localhost:7138/api/Products/Create'),
    );

    request.fields['Title'] = title;
    request.fields['Description'] = description;
    request.fields['Price'] = price;
    request.fields['SKU'] = sku;
    request.fields['Quantity'] = quantity;
    request.fields['PhoneNumber'] = phoneNumber;
    request.fields['MessengerLink'] = messengerLink;
    request.fields['Telegram'] = telegram;
    request.fields['Viber'] = viber;

    // Product Variants
    for (int i = 0; i < variants.length; i++) {
      request.fields['Variants[$i].Variant_Name'] = variants[i].variantName;

      request.fields['Variants[$i].SKU'] = variants[i].sku;

      request.fields['Variants[$i].Price'] = variants[i].variant_Price
          .toString();
    }

    // Product Images
    int index = 0;

    for (final image in images) {
      if (image != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'Images',
            image,
            filename: 'image_$index.jpg',
          ),
        );

        index++;
      }
    }

    final response = await request.send();

    return response.statusCode == 200;
  }

  // ============================================================
  // GET CATEGORIES
  // ============================================================

  static const String _categoryUrl =
      'https://www.capital-sys.net/CKMMallAPI/api/category/all';

  Future<List<Category>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse(_categoryUrl),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }

      final List<dynamic> jsonData = jsonDecode(response.body);

      final categories = jsonData
          .map<Category>((json) => Category.fromJson(json))
          .where((category) => category.categoryName.toLowerCase() != 'root')
          .toList();

      return categories;
    } catch (e, stackTrace) {
      print('CATEGORY ERROR: $e');
      print(stackTrace);
      rethrow;
    }
  }
}
