import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' hide Category;
import 'package:http/http.dart' as http;
import 'package:http/browser_client.dart' show BrowserClient;

import '../models/Category.dart';
import '../models/product_variant.dart';
import '../models/sell_product_model.dart';
import '../models/business_contact.dart';
import '../services/auth_service.dart';
import 'package:http_parser/http_parser.dart'; // for MediaType

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

  // GET BUYER CONTACT METHODS / GROUP IDS
  Future<List<BuyerContactMethod>> getBuyerContactMethods({
    required AuthService authService,
  }) async {
    final url = Uri.parse(
      'https://www.capital-sys.net/CKMMallAPI/api/User/contact-groupId',
    );

    try {
      late http.Response response;

      if (kIsWeb) {
        final client = BrowserClient();
        client.withCredentials = true;

        try {
          response = await client.get(
            url,
            headers: {'Accept': 'application/json'},
          );
        } finally {
          client.close();
        }
      } else {
        final headers = <String, String>{'Accept': 'application/json'};

        final cookie = authService.authCookie;
        if (cookie != null && cookie.isNotEmpty) {
          headers['Cookie'] = cookie;
        }

        final client = http.Client();

        try {
          response = await client.get(url, headers: headers);
        } finally {
          client.close();
        }
      }

      if (response.statusCode == 401) {
        throw Exception('Unauthorized (401). Please log in again.');
      }

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to load contact groups: '
          '${response.statusCode} - ${response.body}',
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! List) {
        throw Exception('Invalid contact-group API response.');
      }

      return List<BuyerContactMethod>.generate(decoded.length, (index) {
        final rawId = decoded[index];
        final groupId = int.tryParse(rawId.toString());

        if (groupId == null) {
          throw FormatException('Invalid contact group ID: $rawId');
        }

        return BuyerContactMethod(
          methodId: groupId,
          methodName: 'Contact ${index + 1}',
          userId: 0,
        );
      });
    } catch (e, st) {
      debugPrint('getBuyerContactMethods error: $e');
      debugPrint(st.toString());
      rethrow;
    }
  }

  Future<BuyerContactDetail> getBuyerContactDetail({
    required AuthService authService,
    required int groupId,
  }) async {
    final url = Uri.parse(
      'https://www.capital-sys.net/CKMMallAPI/api/User/getcontactinfoByGroupId/$groupId',
    );

    try {
      http.Response response;

      if (kIsWeb) {
        final client = BrowserClient();
        client.withCredentials = true;
        try {
          response = await client.get(
            url,
            headers: {'Accept': 'application/json'},
          );
        } finally {
          client.close();
        }
      } else {
        final headers = <String, String>{'Accept': 'application/json'};
        if (authService.authCookie != null &&
            authService.authCookie!.isNotEmpty) {
          headers['Cookie'] = authService.authCookie!;
        }
        final client = http.Client();
        try {
          response = await client.get(url, headers: headers);
        } finally {
          client.close();
        }
      }

      if (response.statusCode == 401) {
        throw Exception('Unauthorized (401)');
      }
      if (response.statusCode != 200) {
        throw Exception('Failed to load contact info: ${response.statusCode}');
      }

      final List<dynamic> list = jsonDecode(response.body);

      final contacts = list
          .map((e) => BusinessContact.fromJson(Map<String, dynamic>.from(e)))
          .where((c) => c.value.isNotEmpty)
          .toList();

      String pick(String type) {
        final matches = contacts
            .where((c) => c.typeKey == type.toLowerCase())
            .toList();
        if (matches.isEmpty) return '';
        final primary = matches.where((c) => c.isPrimary);
        if (primary.isNotEmpty) return primary.first.value;
        return matches.first.value;
      }

      return BuyerContactDetail(
        phoneNumber: pick('Phone'),
        telegram: pick('Telegram'),
        viber: pick('Viber'),
        messenger: pick('Messenger'),
        location: '', // API does not return location
      );
    } catch (e) {
      debugPrint('getBuyerContactDetail error: $e');
      rethrow;
    }
  }

  // FIND SELL PRODUCT BY PRODUCT CODE

  Future<SellProductModel?> getSellProductByCode(int productId) async {
    final url = Uri.parse(
      'https://www.capital-sys.net/CKMMallAPI/api/Product/GetProductByProductID/$productId',
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
    required AuthService authService,
    required String productCode,
    required int userId,
    required String productName,
    required String description,
    required String location,
    required String price,
    required String? discountPrice,
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
        'price': variant.price.toString(),
        'discountPrice': (variant.discountPrice ?? 0).toString(),
        'variantName': variant.variantName,
      };
    }).toList();

    final product = {
      'productId': 0,
      'productCode': productCode,
      'userId': userId,
      'productName': productName,
      'description': description,
      'location': location,
      'price': price,
      'discountPrice': discountPrice ?? '0',
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
    request.fields['product'] = jsonEncode(product);

    // Attach images 
    int imageIndex = 0;
    for (final bytes in imageBytes) {
      if (bytes != null && bytes.isNotEmpty) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'images', 
            bytes,
            filename: 'image_$imageIndex.jpg',
            contentType: MediaType('image', 'jpeg'), 
          ),
        );
        imageIndex++;
      }
    }

    debugPrint('========== CREATE API REQUEST ==========');
    debugPrint('Method: POST');
    debugPrint('URL: $url');
    debugPrint('Fields: ${request.fields}');
    debugPrint('Number of image files attached: ${request.files.length}');
    for (final f in request.files) {
      debugPrint(
        '  → file field="${f.field}", filename="${f.filename}", length=${f.length}',
      );
    }
    debugPrint('========================================');

    try {
      http.Response response;

      if (kIsWeb) {
        // Flutter Web:
        // Browser automatically sends the authentication cookie.
        final client = BrowserClient();
        client.withCredentials = true;

        try {
          final streamedResponse = await client.send(request);

          // IMPORTANT:
          // Convert the streamed response before closing the client.
          response = await http.Response.fromStream(streamedResponse);
        } finally {
          client.close();
        }
      } else {
        // Android / iOS:
        // Manually attach the cookie captured during login.
        if (authService.authCookie != null &&
            authService.authCookie!.isNotEmpty) {
          request.headers['Cookie'] = authService.authCookie!;

          debugPrint('CREATE AUTH: Authentication cookie attached.');
        } else {
          debugPrint('CREATE AUTH: No authentication cookie found.');
        }

        final client = http.Client();

        try {
          final streamedResponse = await client.send(request);

          // Convert before closing the client.
          response = await http.Response.fromStream(streamedResponse);
        } finally {
          client.close();
        }
      }

      debugPrint('========== CREATE API RESPONSE ==========');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');
      debugPrint('Response Headers: ${response.headers}');
      debugPrint('=========================================');

      // Authentication failure
      if (response.statusCode == 401) {
        debugPrint('CREATE RESULT: 401 Unauthorized');

        return ProductApiResponse(
          success: false,
          message: 'Please login or sign up first.',
          statusCode: 401,
        );
      }

      // Empty response
      if (response.body.isEmpty) {
        final isSuccess =
            response.statusCode >= 200 && response.statusCode < 300;

        return ProductApiResponse(
          success: isSuccess,
          message: isSuccess
              ? 'Product created successfully.'
              : 'Failed to create product.',
          statusCode: response.statusCode,
        );
      }

      dynamic decodedResponse;

      try {
        decodedResponse = jsonDecode(response.body);
      } catch (e) {
        debugPrint('CREATE JSON PARSE ERROR: $e');

        return ProductApiResponse(
          success: response.statusCode >= 200 && response.statusCode < 300,
          message: response.body.isNotEmpty
              ? response.body
              : 'Failed to create product.',
          statusCode: response.statusCode,
        );
      }

      if (decodedResponse is! Map<String, dynamic>) {
        return ProductApiResponse(
          success: response.statusCode >= 200 && response.statusCode < 300,
          message: decodedResponse.toString(),
          statusCode: response.statusCode,
        );
      }

      final apiResponse = ProductApiResponse.fromJson(
        decodedResponse,
        statusCode: response.statusCode,
      );

      debugPrint('========== PARSED CREATE RESPONSE ==========');
      debugPrint('Success: ${apiResponse.success}');
      debugPrint('Message: ${apiResponse.message}');
      debugPrint('ID: ${apiResponse.id}');
      debugPrint('Status Code: ${apiResponse.statusCode}');
      debugPrint('============================================');

      return apiResponse;
    } catch (e, stackTrace) {
      debugPrint('========== CREATE API ERROR ==========');
      debugPrint('Error: $e');
      debugPrint('StackTrace: $stackTrace');
      debugPrint('======================================');

      return ProductApiResponse(success: false, message: e.toString());
    }
  }

  // UPDATE PRODUCT

  // UPDATE PRODUCT USING PUT + MULTIPART
  Future<ProductApiResponse> updateProduct({
    required AuthService authService,
    required int productId,
    required String productCode,
    required int userId,
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
      'https://www.capital-sys.net/CKMMallAPI/api/Product/UpdateProduct/$productId',
    );

    // Categories
    final pCategoryList = categoryIds.map((categoryId) {
      return {
        'id': 0,
        'productId': productId,
        'categoryId': categoryId.toString(),
      };
    }).toList();

    // Existing image metadata
    final pImageList = images.map((image) {
      return {
        'id': image['id'] ?? 0,
        'productId': productId,
        'imageUrl': image['imageUrl'] ?? '',
        'sortOrder': image['sortOrder'] ?? 1,
      };
    }).toList();

    // Product variants
    final pVariantList = variants.map((variant) {
      return {
        'id': 0,
        'productId': productId,
        'variantID': variant.variantId,
        'quantity': variant.quantity,
        'price': variant.price.toString(),
        'discountPrice': (variant.discountPrice ?? 0).toString(),
        'variantName': variant.variantName,
      };
    }).toList();

    // Product payload
    final product = {
      'productId': productId,
      'productCode': productCode,
      'userId': userId,
      'productName': productName,
      'description': description,
      'location': location,
      'price': price.toString(),
      'discountPrice': (discountPrice ?? 0).toString(),
      'quantity': quantity,
      'condition': condition,
      'status': status,
      'businessContactGroupId': businessContactGroupId,
      'pCategoryList': pCategoryList,
      'pImageList': pImageList,
      'pVariantList': pVariantList,
      'businesscontact': businessContacts,
    };

    // IMPORTANT: PUT request with multipart/form-data
    final request = http.MultipartRequest('PUT', url);

    request.headers['Accept'] = 'application/json';
    request.fields['product'] = jsonEncode(product);

    debugPrint('========== UPDATE API REQUEST ==========');
    debugPrint('Method: ${request.method}');
    debugPrint('URL: $url');
    debugPrint('Product: ${request.fields['product']}');

    try {
      late http.Response response;

      if (kIsWeb) {
        // Web: send browser authentication cookies
        final client = BrowserClient();
        client.withCredentials = true;

        try {
          final streamedResponse = await client.send(request);
          response = await http.Response.fromStream(streamedResponse);
        } finally {
          client.close();
        }
      } else {
        // Android / iOS: attach authentication cookie
        final cookie = authService.authCookie;

        if (cookie != null && cookie.isNotEmpty) {
          request.headers['Cookie'] = cookie;
          debugPrint('UPDATE AUTH: Cookie attached.');
        } else {
          debugPrint('UPDATE AUTH: No authentication cookie found.');
        }

        final client = http.Client();

        try {
          final streamedResponse = await client.send(request);
          response = await http.Response.fromStream(streamedResponse);
        } finally {
          client.close();
        }
      }

      debugPrint('========== UPDATE API RESPONSE ==========');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');
      debugPrint('Response Headers: ${response.headers}');

      // Authentication failure
      if (response.statusCode == 401) {
        return ProductApiResponse(
          success: false,
          message: 'Please login or sign up first.',
          statusCode: 401,
        );
      }

      // Successful response with no body
      final isHttpSuccess =
          response.statusCode >= 200 && response.statusCode < 300;

      if (response.body.trim().isEmpty) {
        return ProductApiResponse(
          success: isHttpSuccess,
          message: isHttpSuccess
              ? 'Product updated successfully.'
              : 'Failed to update product.',
          statusCode: response.statusCode,
        );
      }

      // Parse JSON response
      dynamic decodedResponse;

      try {
        decodedResponse = jsonDecode(response.body);
      } catch (_) {
        return ProductApiResponse(
          success: isHttpSuccess,
          message: response.body,
          statusCode: response.statusCode,
        );
      }

      if (decodedResponse is Map<String, dynamic>) {
        final apiResponse = ProductApiResponse.fromJson(
          decodedResponse,
          statusCode: response.statusCode,
        );

        debugPrint('UPDATE SUCCESS: ${apiResponse.success}');
        debugPrint('UPDATE MESSAGE: ${apiResponse.message}');

        return ProductApiResponse(
          success: isHttpSuccess && apiResponse.success,
          message: apiResponse.message.isNotEmpty
              ? apiResponse.message
              : (isHttpSuccess
                    ? 'Product updated successfully.'
                    : 'Failed to update product.'),
          id: apiResponse.id,
          updatedAt: apiResponse.updatedAt,
          savedAt: apiResponse.savedAt,
          statusCode: response.statusCode,
        );
      }

      return ProductApiResponse(
        success: isHttpSuccess,
        message: decodedResponse.toString(),
        statusCode: response.statusCode,
      );
    } catch (e, stackTrace) {
      debugPrint('========== UPDATE API ERROR ==========');
      debugPrint('Error: $e');
      debugPrint('$stackTrace');

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

  // GET CATEGORIES

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
