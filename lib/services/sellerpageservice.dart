import '../models/sellerpagemodel.dart';

class SellerPageService {
  /// Simulates fetching seller info from backend.
  /// Replace the body with your real API call (http / dio).
  Future<SellerInfo> fetchSellerInfo(String sellerId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 400));

    // TODO: Replace with real API
    // final response = await http.get(Uri.parse('https://api.example.com/seller/$sellerId'));
    // return SellerInfo.fromJson(jsonDecode(response.body));

    return SellerInfo(
      name: "Sarah J's Full Store",
      avatarUrl: null, // or a real image url
      isFollowing: false,
    );
  }

  /// Fetches product list for a seller.
  /// Uses the sample structure you provided.
  Future<List<Product>> fetchSellerProducts(String sellerId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // TODO: Replace with real API call
    // final response = await http.get(Uri.parse('https://api.example.com/seller/$sellerId/products'));
    // final List data = jsonDecode(response.body);
    // return data.map((e) => Product.fromJson(e)).toList();

    // Sample data matching your backend shape + extra UI fields for demo
    final List<Map<String, dynamic>> sampleJson = [
      {
        "productId": 3,
        "productName": "Phone1",
        "price": 100000.00,
        "imageUrl": "https://share.google/wAquMLs9OiKCCvb06/ph1.jpg",
        "favourite": 0,
        "rating": 4.7,
        "description": "High quality smartphone"
      },
      {
        "productId": 4,
        "productName": "Phone1",
        "price": 100000.00,
        "imageUrl": "https://share.google/wAquMLs9OiKCCvb06/ph1.jpg",
        "favourite": 0,
        "rating": 4.8,
        "description": "Latest model"
      },
      // Extra demo items so the grid looks good (remove when you connect real API)
      {
        "productId": 1,
        "productName": "Men's Wool Coat",
        "price": 45000.00,
        "imageUrl": "https://images.unsplash.com/photo-1591047139829-d91aecb6caea?w=400",
        "favourite": 0,
        "rating": 4.7,
        "description": "Warm wool coat with smooth finish"
      },
      {
        "productId": 2,
        "productName": "Straw Sun Hat",
        "price": 45000.00,
        "imageUrl": "https://images.unsplash.com/photo-1521369909029-2afed882baee?w=400",
        "favourite": 1,
        "rating": 4.8,
        "description": "Classic straw hat, wide brim"
      },
      {
        "productId": 5,
        "productName": "Leather Belt",
        "price": 45000.00,
        "imageUrl": "https://images.unsplash.com/photo-1624222247344-550fb605bf28?w=400",
        "favourite": 0,
        "rating": 4.7,
        "description": "Genuine leather belt"
      },
      {
        "productId": 6,
        "productName": "Patterned Scarf",
        "price": 45000.00,
        "imageUrl": "https://images.unsplash.com/photo-1601924994987-69e26d50dc26?w=400",
        "favourite": 0,
        "rating": 4.6,
        "description": "Soft patterned scarf"
      },
      {
        "productId": 7,
        "productName": "Men's Watch",
        "price": 120000.00,
        "imageUrl": "https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400",
        "favourite": 1,
        "rating": 4.8,
        "description": "Elegant stainless steel watch"
      },
      {
        "productId": 8,
        "productName": "Men's Jacket",
        "price": 85000.00,
        "imageUrl": "https://images.unsplash.com/photo-1551028719-00167b16eac5?w=400",
        "favourite": 0,
        "rating": 4.5,
        "description": "Casual bomber jacket"
      },
      {
        "productId": 9,
        "productName": "Leather Tote Bag",
        "price": 120000.00,
        "imageUrl": "https://images.unsplash.com/photo-1590874103328-eac38a683ce7?w=400",
        "favourite": 0,
        "rating": 4.9,
        "description": "Premium leather tote"
      },
      {
        "productId": 10,
        "productName": "Brown Fedora",
        "price": 38000.00,
        "imageUrl": "https://images.unsplash.com/photo-1514327605112-b64911c0eda9?w=400",
        "favourite": 0,
        "rating": 4.7,
        "description": "Classic felt fedora"
      },
    ];

    return sampleJson.map((e) => Product.fromJson(e)).toList();
  }

  /// Toggle favourite status (local for now).
  Future<bool> toggleFavourite(int productId, bool currentStatus) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return !currentStatus;
  }
}