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

/// Nested category / subcategory node from
/// GET /api/Category/getallsubcategoriesbycategoryId/{id}
class CategoryNode {
  final int id;
  final String name;
  final String categoryImageUrl;
  final List<CategoryNode> subcategories;

  CategoryNode({
    required this.id,
    required this.name,
    required this.categoryImageUrl,
    required this.subcategories,
  });

  factory CategoryNode.fromJson(Map<String, dynamic> json) {
    final rawSubs = json['subcategories'];
    final List<CategoryNode> children = [];
    if (rawSubs is List) {
      for (final item in rawSubs) {
        if (item is Map) {
          children.add(
            CategoryNode.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }
    return CategoryNode(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      categoryImageUrl: json['categoryImageUrl']?.toString() ?? '',
      subcategories: children,
    );
  }

  bool get hasChildren => subcategories.isNotEmpty;

  /// Flatten this node and all descendants (depth-first).
  List<CategoryNode> flatten() {
    final result = <CategoryNode>[this];
    for (final child in subcategories) {
      result.addAll(child.flatten());
    }
    return result;
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

  /// Extract only the filename from a full image URL or path.
  /// e.g. "https://.../uploads/PI_1_1_261102151447958.jpg" → "PI_1_1_261102151447958.jpg"
  static String _imageFileNameOnly(String imageUrlOrPath) {
    final trimmed = imageUrlOrPath.trim();
    if (trimmed.isEmpty) return '';

    try {
      final uri = Uri.parse(trimmed);
      if (uri.pathSegments.isNotEmpty) {
        final last = uri.pathSegments.last;
        if (last.isNotEmpty) return last;
      }
    } catch (_) {
      // fall through to slash-based parse
    }

    var path = trimmed.split('?').first.split('#').first;
    final slash = path.lastIndexOf('/');
    final backslash = path.lastIndexOf('\\');
    final sep = slash > backslash ? slash : backslash;
    if (sep >= 0 && sep < path.length - 1) {
      return path.substring(sep + 1);
    }
    return path;
  }

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
    );

    if (response.statusCode == 200) {
      return SellProductModel.fromJson(jsonDecode(response.body));
    }

    debugPrint('Get product failed: ${response.statusCode} - ${response.body}');

    return null;
  }

  // CREATE PRODUCT
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
        final client = BrowserClient();
        client.withCredentials = true;

        try {
          final streamedResponse = await client.send(request);
          response = await http.Response.fromStream(streamedResponse);
        } finally {
          client.close();
        }
      } else {
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

      if (response.statusCode == 401) {
        debugPrint('CREATE RESULT: 401 Unauthorized');

        return ProductApiResponse(
          success: false,
          message: 'Please login or sign up first.',
          statusCode: 401,
        );
      }

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
    List<Uint8List?> imageBytes = const [],
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

    // Existing image metadata — imageUrl as filename only
    final pImageList = images.map((image) {
      final fullImageUrl = (image['imageUrl'] ?? '').toString();
      final imageFileName = _imageFileNameOnly(fullImageUrl);

      return {
        'id': image['id'] ?? 0,
        'productId': productId,
        'imageUrl': imageFileName,
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

    final request = http.MultipartRequest('PUT', url);

    request.headers['Accept'] = 'application/json';
    request.fields['product'] = jsonEncode(product);

    // New images (same field name as create)
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

    debugPrint('Number of new image files: ${request.files.length}');

    debugPrint('========== UPDATE API REQUEST ==========');
    debugPrint('Method: ${request.method}');
    debugPrint('URL: $url');
    debugPrint('Product: ${request.fields['product']}');

    try {
      late http.Response response;

      if (kIsWeb) {
        final client = BrowserClient();
        client.withCredentials = true;

        try {
          final streamedResponse = await client.send(request);
          response = await http.Response.fromStream(streamedResponse);
        } finally {
          client.close();
        }
      } else {
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

      if (response.statusCode == 401) {
        return ProductApiResponse(
          success: false,
          message: 'Please login or sign up first.',
          statusCode: 401,
        );
      }

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

  /// Subcategories (nested tree) for a parent category.
  /// GET /api/Category/getallsubcategoriesbycategoryId/{categoryId}
  Future<List<CategoryNode>> getSubcategoriesByCategoryId(
    int categoryId,
  ) async {
    final url = Uri.parse(
      'https://www.capital-sys.net/CKMMallAPI/api/Category/getallsubcategoriesbycategoryId/$categoryId',
    );

    debugPrint('GET SUBCATEGORIES URL: $url');

    try {
      final response = await http.get(
        url,
        headers: {'Accept': 'application/json'},
      );

      debugPrint(
        'GET SUBCATEGORIES status=${response.statusCode} '
        'bodyLen=${response.body.length}',
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to load subcategories: ${response.statusCode}',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! List) {
        throw Exception('Invalid subcategories response (expected list).');
      }

      return decoded
          .whereType<Map>()
          .map((e) => CategoryNode.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e, st) {
      debugPrint('getSubcategoriesByCategoryId error: $e');
      debugPrint('$st');
      rethrow;
    }
  }

  // GET MAIN PRODUCT CATEGORIES (for sell form top-level list)
  // GET /api/Category/GetMainProductCategories
  // Flat list with parentId. We expose only direct children of root.
  static const String _categoryUrl =
      'https://www.capital-sys.net/CKMMallAPI/api/Category/GetMainProductCategories';

  Future<List<Category>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse(_categoryUrl),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! List) {
        throw Exception('Invalid categories response (expected list).');
      }

      final List<Map<String, dynamic>> rows = decoded
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

      // Root nodes: parentId == 0 or name == "root"
      final rootIds = <int>{};
      for (final row in rows) {
        final name = (row['name'] ?? '').toString().toLowerCase().trim();
        final parentId = int.tryParse(row['parentId']?.toString() ?? '') ?? -1;
        final id = int.tryParse(row['id']?.toString() ?? '') ?? 0;
        if (parentId == 0 || name == 'root') {
          rootIds.add(id);
        }
      }

      // Main categories = direct children of root
      final mainRows = rows.where((row) {
        final parentId = int.tryParse(row['parentId']?.toString() ?? '') ?? -1;
        final name = (row['name'] ?? '').toString().toLowerCase().trim();
        if (name == 'root') return false;
        return rootIds.contains(parentId);
      }).toList();

      // Map API fields (id/name/image) to Category.fromJson expected keys
      final categories = mainRows.map((row) {
        final mapped = <String, dynamic>{
          'id': row['id'],
          'categoryId': row['id'],
          'name': row['name'],
          'categoryName': row['name'],
          'categoryImageUrl': row['image'] ?? row['categoryImageUrl'] ?? '',
          'photoPath': row['image'] ?? row['photoPath'] ?? '',
          'imageUrl': row['image'],
        };
        return Category.fromJson(mapped);
      }).toList();

      debugPrint(
        'GetMainProductCategories: total=${rows.length}, '
        'main=${categories.length}, rootIds=$rootIds',
      );

      return categories;
    } catch (e, stackTrace) {
      print('CATEGORY ERROR: $e');
      print(stackTrace);
      rethrow;
    }
  }
}
