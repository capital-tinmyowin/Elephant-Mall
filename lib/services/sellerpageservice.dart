import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/sellerpagemodel.dart';

class SellerPageService {
  static const String baseUrl =
      'https://www.capital-sys.net/CKMMallAPI';

  Future<SellerInfo> fetchSellerInfo(String sellerId) async {
    // Seller info API is not provided yet.
    // Keep this temporary until the seller information API exists.

    return SellerInfo(
      name: "Sarah J's Full Store",
      avatarUrl: null,
      isFollowing: false,
    );
  }

  Future<List<Product>> fetchSellerProducts(
    String sellerId ,
  ) async {
    final url = Uri.parse(
      '$baseUrl/api/Product/GetProductByUserId/1',
    );

    print('');
    print('========== SELLER PRODUCTS API ==========');
    print('GET: $url');

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
      },
    );

    print('Status Code: ${response.statusCode}');
    print('Response: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load seller products. '
        'Status: ${response.statusCode}',
      );
    }

    final dynamic decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception(
        'Invalid seller products response.',
      );
    }

    final products = decoded
        .map(
          (item) => Product.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();

    print('Products loaded: ${products.length}');

    return products;
  }

  // ============================================================
  // FAVOURITE
  // ============================================================

  Future<bool> toggleFavourite(
    int productId,
    bool currentStatus,
  ) async {
    // Favourite API is not provided yet.
    // Local toggle for now.

    await Future.delayed(
      const Duration(milliseconds: 200),
    );

    return !currentStatus;
  }
}