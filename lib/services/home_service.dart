import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/Category.dart';
import '../models/banner.dart';
import '../models/promo.dart';

class HomeService {
  static const String baseUrl = "http://localhost:5086/api";

  final http.Client client = http.Client();

  Future<List<BannerModel>> getBanners() async {
    final response = await client.get(
      Uri.parse("$baseUrl/Banners/GetBannerList"),
    );
    if (response.statusCode == 200) {
      final List jsonData = jsonDecode(response.body);
      return jsonData.map((e) => BannerModel.fromJson(e)).toList();
    }
    throw Exception("Failed to load banners");
  }

  Future<List<Category>> getCategories() async {
    final response = await client.get(
      Uri.parse("$baseUrl/Categories/GetCategoryList"),
    );

    if (response.statusCode == 200) {
      final List jsonData = jsonDecode(response.body);

      return jsonData.map((e) => Category.fromJson(e)).toList();
    }

    throw Exception("Failed to load categories");
  }

  Future<List<Product>> getProducts() async {
    final response = await client.get(
      Uri.parse("$baseUrl/Products/GetProductList"),
    );
    if (response.statusCode == 200) {
      final List jsonData = jsonDecode(response.body);
      return jsonData.map((e) => Product.fromJson(e)).toList();
    }
    throw Exception("Failed to load products");
  }

  Future<List<Promo>> getPromos() async {
    final response = await client.get(
      Uri.parse("$baseUrl/Promos/GetPromoList"),
    );
    if (response.statusCode == 200) {
      final List jsonData = jsonDecode(response.body);
      return jsonData.map((e) => Promo.fromJson(e)).toList();
    }
    throw Exception("Failed to load promos");
  }
}
