import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' hide Category;
import 'package:http/http.dart' as http;

import '../models/Category.dart';
import '../models/product_variant.dart';
import '../models/sell_product_model.dart';

class ProductApiResponse {
  final bool success;
  final String message;
  final String? id;
  final String? savedAt;
  final String? updatedAt;
  final int? statusCode;

  ProductApiResponse({
    required this.success,
    required this.message,
    this.id,
    this.savedAt,
    this.updatedAt,
    this.statusCode,
  });

  factory ProductApiResponse.fromJson(
    Map<String, dynamic> json, {
    int? statusCode,
  }) {
    return ProductApiResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      id: json['id']?.toString(),
      savedAt: json['savedAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      statusCode: statusCode,
    );
  }
}

class BuyerContactMethod {
  final int methodId;
  final String methodName;
  final int userId;

  BuyerContactMethod({
    required this.methodId,
    required this.methodName,
    required this.userId,
  });

  factory BuyerContactMethod.fromJson(Map<String, dynamic> json) {
    return BuyerContactMethod(
      methodId: int.tryParse(json['methodId'].toString()) ?? 0,
      methodName: json['methodName']?.toString() ?? '',
      userId: int.tryParse(json['userId'].toString()) ?? 0,
    );
  }
}

class BuyerContactDetail {
  final String phoneNumber;
  final String telegram;
  final String viber;
  final String messenger;
  final String location;

  BuyerContactDetail({
    required this.phoneNumber,
    required this.telegram,
    required this.viber,
    required this.messenger,
    required this.location,
  });

  factory BuyerContactDetail.fromJson(Map<String, dynamic> json) {
    return BuyerContactDetail(
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      telegram: json['telegram']?.toString() ?? '',
      viber: json['viber']?.toString() ?? '',
      messenger: json['messenger']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
    );
  }
}

class ProductService {
  // SAMPLE BUYER CONTACT METHODS
  final List<BuyerContactMethod> _buyerContactMethods = [
    BuyerContactMethod(methodId: 1, methodName: 'Contact 1', userId: 1),
    BuyerContactMethod(methodId: 2, methodName: 'Contact 2', userId: 1),
    BuyerContactMethod(methodId: 3, methodName: 'Contact 3', userId: 2),
  ];

  // SAMPLE BUYER CONTACT DETAILS

  final Map<int, BuyerContactDetail> _buyerContactDetails = {
    1: BuyerContactDetail(
      phoneNumber: '09123456789',
      telegram: '@mainbuyer',
      viber: '09123456789',
      messenger: 'https://m.me/mainbuyer',
      location: 'Yangon',
    ),

    2: BuyerContactDetail(
      phoneNumber: '09222222222',
      telegram: '@yangonbuyer',
      viber: '09222222222',
      messenger: 'https://m.me/yangonbuyer',
      location: 'Yangon',
    ),

    3: BuyerContactDetail(
      phoneNumber: '09333333333',
      telegram: '@mandalaybuyer',
      viber: '09333333333',
      messenger: 'https://m.me/mandalaybuyer',
      location: 'Mandalay',
    ),
  };

  // GET BUYER CONTACT METHODS

  Future<List<BuyerContactMethod>> getBuyerContactMethods() async {
    // GET BUYER CONTACT DETAIL BY METHOD ID
    // SAMPLE DATA

    await Future.delayed(const Duration(milliseconds: 300));

    return _buyerContactMethods;

    /*
    // REAL API EXAMPLE

    final url = Uri.parse(
      'https://www.capital-sys.net/CKMMallAPI/api/buyer/contact-methods',
    );

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load buyer contact methods: ${response.statusCode}',
      );
    }

    final List<dynamic> jsonData = jsonDecode(response.body);

    return jsonData
        .map<BuyerContactMethod>(
          (json) => BuyerContactMethod.fromJson(json),
        )
        .toList();
    */
  }

  Future<BuyerContactDetail> getBuyerContactDetail(int methodId) async {
    // ----------------------------------------------------------
    // SAMPLE DATA
    // ----------------------------------------------------------

    await Future.delayed(const Duration(milliseconds: 300));

    final detail = _buyerContactDetails[methodId];

    if (detail == null) {
      throw Exception('Buyer contact method not found.');
    }

    return detail;

    /*
    // REAL API EXAMPLE

    final url = Uri.parse(
      'https://www.capital-sys.net/CKMMallAPI/api/buyer/contact-method/$methodId',
    );

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load buyer contact detail: ${response.statusCode}',
      );
    }

    final Map<String, dynamic> jsonData = jsonDecode(response.body);

    return BuyerContactDetail.fromJson(jsonData);
    */
  }

  // FIND SELL PRODUCT BY PRODUCT CODE

  Future<SellProductModel?> getSellProductByCode(int productId) async {
    final url = Uri.parse(
      'https://www.capital-sys.net/CKMMallAPI/api/Product/GetProductDetailByProductId/$productId',
    );

    debugPrint('GET PRODUCT URL: $url');

    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    debugPrint(
      'Get product failed: ${response.statusCode} - ${response.body}',
    ); // debugPrint('GET PRODUCT RESPONSE: ${response.body}');

    if (response.statusCode == 200) {
      return SellProductModel.fromJson(jsonDecode(response.body));
    }

    debugPrint('Get product failed: ${response.statusCode} - ${response.body}');

    return null;
  }

  // CREATE PRODUCT
  // ============================================================

  Future<ProductApiResponse> createProduct({
    required String productCode,
    required String productName,
    required String description,
    required String location,
    required double price,
    required double? discountPrice,
    required int quantity,
    required String condition,
    required String status,
    required int businessContactGroupId,
    required List<int> categoryIds,
    required List<ProductVariant> variants,
    required List<Map<String, dynamic>> images,
    required List<Map<String, dynamic>> businessContacts,
    required List<Uint8List?> imageBytes,
  }) async {
    final url = Uri.parse(
      'https://www.capital-sys.net/CKMMallAPI/api/Product/SaveProduct',
    );

    final pCategoryList = categoryIds.map((categoryId) {
      return {'id': 0, 'productId': 0, 'categoryId': categoryId.toString()};
    }).toList();

    final pVariantList = variants.map((variant) {
      return {
        'id': 0,
        'productId': 0,
        'variantID': '',
        'quantity': variant.quantity,
        'price': variant.price,
        'discountPrice': variant.discountPrice,
        'variantName': variant.variantName,
      };
    }).toList();

    final product = {
      'productId': 0,
      'productCode': productCode,
      'userId': 1,
      'productName': productName,
      'description': description,
      'location': location,
      'price': price,
      'discountPrice': discountPrice,
      'condition': condition,
      'status': status,
      'businessContactGroupId': businessContactGroupId,
      'pCategoryList': pCategoryList,
      'pImageList': [],
      'pVariantList': pVariantList,
      'businesscontact': businessContacts,
    };

    final request = http.MultipartRequest('POST', url);

    request.headers['Accept'] = 'application/json';

    // Product JSON
    request.fields['product'] = jsonEncode(product);

    // Images
    // int imageIndex = 0;

    // for (final image in imageBytes) {
    //   if (image == null) {
    //     continue;
    //   }

    //   request.files.add(
    //     http.MultipartFile.fromBytes(
    //       'image',
    //       image,
    //       filename: 'image_$imageIndex.jpg',
    //     ),
    //   );

    //   imageIndex++;
    // }

    debugPrint('========== MULTIPART API REQUEST ==========');
    debugPrint('URL: $url');
    debugPrint('Product: ${jsonEncode(product)}');
    // debugPrint('Images: $imageIndex');
    debugPrint('===========================================');

    try {
      debugPrint('========== MULTIPART DETAILS ==========');
      debugPrint('Method: ${request.method}');
      debugPrint('URL: ${request.url}');
      debugPrint('Headers: ${request.headers}');
      debugPrint('Fields: ${request.fields}');
      debugPrint('Files count: ${request.files.length}');

      for (final file in request.files) {
        debugPrint(
          'File: field=${file.field}, filename=${file.filename}, length=${file.length}',
        );
      }

      debugPrint('=======================================');

      final streamedResponse = await request.send();

      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('========== API RESPONSE ==========');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');
      debugPrint('Response Headers: ${response.headers}');
      debugPrint('==================================');

      // 401 Unauthorized
      if (response.statusCode == 401) {
        return ProductApiResponse(
          success: false,
          message: 'Please login or sign up first.',
          statusCode: 401,
        );
      }

      if (response.body.isEmpty) {
        return ProductApiResponse(
          success: response.statusCode >= 200 && response.statusCode < 300,
          message: response.statusCode >= 200 && response.statusCode < 300
              ? 'Product saved successfully.'
              : 'Failed to save product.',
        );
      }

      final responseData = jsonDecode(response.body);

      final apiResponse = ProductApiResponse.fromJson(
        responseData,
        statusCode: response.statusCode,
      );
      debugPrint('========== PARSED API RESPONSE ==========');
      debugPrint('Success: ${apiResponse.success}');
      debugPrint('Message: ${apiResponse.message}');
      debugPrint('ID: ${apiResponse.id}');
      debugPrint('Saved At: ${apiResponse.savedAt}');
      debugPrint('Updated At: ${apiResponse.updatedAt}');
      debugPrint('==========================================');

      return apiResponse;
    } catch (e, stackTrace) {
      debugPrint('========== API ERROR ==========');
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());
      debugPrint('================================');

      return ProductApiResponse(success: false, message: e.toString());
    }
  }

  // ============================================================
  // UPDATE PRODUCT
  // ============================================================

  Future<ProductApiResponse> updateProduct({
    required int productId,
    required String productCode,
    required String productName,
    required String description,
    required String location,
    required double price,
    required double? discountPrice,
    required int quantity,
    required String condition,
    required String status,
    required int businessContactGroupId,
    required List<int> categoryIds,
    required List<ProductVariant> variants,
    required List<Map<String, dynamic>> images,
    required List<Map<String, dynamic>> businessContacts,
  }) async {
    final url = Uri.parse(
      'https://www.capital-sys.net/CKMMallAPI/api/saleitem/UpdateSaleItem',
    );

    // Categories
    final pCategoryList = categoryIds.map((categoryId) {
      return {
        'id': 0,
        'productId': productId,
        'categoryId': categoryId.toString(),
      };
    }).toList();

    // Variants
    final pVariantList = variants.map((variant) {
      return {
        'id': 0,
        'productId': productId,
        'variantID': '',
        'quantity': variant.quantity.toString(),
        'price': variant.price,
        'variantName': variant.variantName,
      };
    }).toList();

    // Images
    final pImageList = images.map((image) {
      return {
        'id': image['id'] ?? 0,
        'productId': productCode,
        'imageUrl': image['imageUrl'] ?? '',
        'sortOrder': image['sortOrder'] ?? 1,
      };
    }).toList();

    // Complete request body
    final body = {
      'productId': productId,
      'productCode': productCode,
      'userId': 1,
      'productName': productName,
      'description': description,
      'location': location,
      'price': price,
      'discountPrice': discountPrice,
      'condition': condition,
      'status': status,
      'businessContactGroupId': businessContactGroupId,

      // Categories
      'pCategoryList': categoryIds.map((categoryId) {
        return {'id': 0, 'productId': 0, 'categoryId': categoryId.toString()};
      }).toList(),

      // Images
      'pImageList': pImageList,

      // Variants
      'pVariantList': pVariantList,

      // Contacts
      'businesscontact': businessContacts,
    };

    final jsonBody = jsonEncode(body);

    debugPrint('========== UPDATE API REQUEST ==========');
    debugPrint(jsonBody);
    debugPrint('========================================');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonBody,
      );

      debugPrint('========== UPDATE API RESPONSE ==========');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');
      debugPrint('=========================================');

      // 401 Unauthorized
      if (response.statusCode == 401) {
        return ProductApiResponse(
          success: false,
          message: 'Please login or sign up first.',
          statusCode: 401,
        );
      }

      if (response.body.isEmpty) {
        return ProductApiResponse(
          success: response.statusCode >= 200 && response.statusCode < 300,
          message: response.statusCode >= 200 && response.statusCode < 300
              ? 'Product updated successfully.'
              : 'Failed to update product.',
        );
      }

      final responseData = jsonDecode(response.body);

      final apiResponse = ProductApiResponse.fromJson(
        responseData,
        statusCode: response.statusCode,
      );
      debugPrint('Update Success: ${apiResponse.success}');
      debugPrint('Update Message: ${apiResponse.message}');
      debugPrint('Updated Product ID: ${apiResponse.id}');
      debugPrint('Updated At: ${apiResponse.updatedAt}');

      return apiResponse;
    } catch (e, stackTrace) {
      debugPrint('========== UPDATE API ERROR ==========');
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());
      debugPrint('======================================');

      return ProductApiResponse(success: false, message: e.toString());
    }
  }
  // Future<bool> createProduct({
  //   required String title,
  //   required String description,
  //   required String price,
  //   required String sku,
  //   required String quantity,
  //   required String phoneNumber,
  //   required String messengerLink,
  //   required String telegram,
  //   required String viber,
  //   required List<Uint8List?> images,
  //   required List<ProductVariant> variants,
  // }) async {
  //   var request = http.MultipartRequest(
  //     'POST',
  //     Uri.parse('https://www.capital-sys.net/CKMMallAPI/api/saleitem/SaveSaleItem'),
  //   );

  //   request.fields['Title'] = title;
  //   request.fields['Description'] = description;
  //   request.fields['Price'] = price;
  //   request.fields['SKU'] = sku;
  //   request.fields['Quantity'] = quantity;
  //   request.fields['PhoneNumber'] = phoneNumber;
  //   request.fields['MessengerLink'] = messengerLink;
  //   request.fields['Telegram'] = telegram;
  //   request.fields['Viber'] = viber;

  //   // Product Variants
  //   for (int i = 0; i < variants.length; i++) {
  //     request.fields['Variants[$i].Variant_Name'] = variants[i].variantName;

  //     request.fields['Variants[$i].SKU'] = variants[i].sku;

  //     request.fields['Variants[$i].Price'] = variants[i].variant_Price
  //         .toString();
  //   }

  //   // Product Images
  //   int index = 0;

  //   for (final image in images) {
  //     if (image != null) {
  //       request.files.add(
  //         http.MultipartFile.fromBytes(
  //           'Images',
  //           image,
  //           filename: 'image_$index.jpg',
  //         ),
  //       );

  //       index++;
  //     }
  //   }

  //   final response = await request.send();

  //   return response.statusCode == 200;
  // }

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
