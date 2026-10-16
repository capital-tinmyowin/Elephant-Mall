import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/browser_client.dart' show BrowserClient;

import '../models/sale.dart';
import '../services/auth_service.dart';

class SaleService {
  static const String _saleUrl =
      'https://www.capital-sys.net/CKMMallAPI/api/ProductShowcase/GetSaleProductList';

  Future<List<SaleModel>> getSaleProducts({AuthService? authService}) async {
    try {
      http.Response response;

      if (kIsWeb) {
        final client = BrowserClient()..withCredentials = true;
        try {
          response = await client.get(
            Uri.parse(_saleUrl),
            headers: {'Accept': 'application/json'},
          );
        } finally {
          client.close();
        }
      } else {
        final headers = <String, String>{'Accept': 'application/json'};
        if (authService?.authCookie != null &&
            authService!.authCookie!.isNotEmpty) {
          headers['Cookie'] = authService.authCookie!;
        }
        response = await http.get(Uri.parse(_saleUrl), headers: headers);
      }

      debugPrint('SALE Status: ${response.statusCode}');
      debugPrint(
        'SALE Body start: ${response.body.substring(0, response.body.length.clamp(0, 200))}',
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load sale products: ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! List) {
        throw Exception('Expected List, got ${decoded.runtimeType}');
      }

      final list = <SaleModel>[];
      for (final item in decoded) {
        try {
          list.add(SaleModel.fromJson(Map<String, dynamic>.from(item as Map)));
        } catch (e) {
          debugPrint('Skip bad sale item: $e');
        }
      }
      return list;
    } catch (e, st) {
      debugPrint('SALE API ERROR: $e\n$st');
      rethrow;
    }
  }

  static const String _baseUrl = 'https://www.capital-sys.net/CKMMallAPI';

  /// POST addFavourite/{productId}
  Future<bool> addFavourite({
    required AuthService authService,
    required int productId,
  }) async {
    final url = Uri.parse('$_baseUrl/api/UserAction/addFavourite/$productId');
    final response = await _postOrDelete(url, authService, isDelete: false);

    if (response.statusCode == 401) {
      throw Exception('Unauthorized (401)');
    }
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  /// DELETE removeFavourite/{productId}
  Future<bool> removeFavourite({
    required AuthService authService,
    required int productId,
  }) async {
    final url = Uri.parse(
      '$_baseUrl/api/UserAction/removeFavourite/$productId',
    );
    final response = await _postOrDelete(url, authService, isDelete: true);

    if (response.statusCode == 401) {
      throw Exception('Unauthorized (401)');
    }
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  Future<http.Response> _postOrDelete(
    Uri url,
    AuthService authService, {
    required bool isDelete,
  }) async {
    if (kIsWeb) {
      final client = BrowserClient()..withCredentials = true;
      try {
        if (isDelete) {
          return await client.delete(
            url,
            headers: {'Accept': 'application/json'},
          );
        }
        return await client.post(url, headers: {'Accept': 'application/json'});
      } finally {
        client.close();
      }
    }

    final headers = <String, String>{'Accept': 'application/json'};
    if (authService.authCookie != null && authService.authCookie!.isNotEmpty) {
      headers['Cookie'] = authService.authCookie!;
    }

    if (isDelete) {
      return await http.delete(url, headers: headers);
    }
    return await http.post(url, headers: headers);
  }
}
