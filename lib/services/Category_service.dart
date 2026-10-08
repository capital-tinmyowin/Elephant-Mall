import 'dart:convert';
import 'package:elephant_mall/models/productImage.dart';
import 'package:elephant_mall/models/product_variant.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/Category.dart';
import '../models/product.dart';
import '../models/cart_item.dart';

class ApiService extends ChangeNotifier {
  static const String baseUrl = 'http://localhost:5150/api';
  static String? _authCookie;
  static String? get authCookie => _authCookie;
  static void setAuthCookie(String? cookie) => _authCookie = cookie;
  // static const String baseUrl = 'https://www.capital-sys.net/CKMMallAPI/api';
  // Static variable for mock data flag
  static bool useMockDataStatic = false;
  static bool _apiAvailable = true;

  // Instance variable for mock data flag
  bool _useMockData = false;
  // Getter for useMockData
  bool get useMockData => _useMockData;

  // ============= CART STATE =============
  List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => _cartItems;
  int get cartItemCount => _cartItems.length;

  double get cartTotalPrice {
    return _cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  int get cartTotalQuantity {
    return _cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  // ============= CART METHODS =============
  void addItem(Product product) {
    addToCart(product);
  }

  void removeItem(int productId) {
    removeFromCart(productId);
  }

  void addToCart(Product product) {
    final existingItem = _cartItems.firstWhere(
      (item) => item.product.productId == product.productId,
      orElse: () => CartItem(product: product, quantity: 0),
    );

    if (existingItem.quantity > 0) {
      existingItem.quantity++;
    } else {
      _cartItems.add(CartItem(product: product));
    }
    notifyListeners();
  }

  void removeFromCart(int productId) {
    _cartItems.removeWhere((item) => item.product.productId == productId);
    notifyListeners();
  }

  void updateCartQuantity(int productId, int quantity) {
    final item = _cartItems.firstWhere(
      (item) => item.product.productId == productId,
      orElse: () => CartItem(
        product: Product(
          productId: -1,
          productCode: '',
          productName: '',
          price: 0,
          category: '',
          image: '',
        ),
        quantity: 0,
      ),
    );

    if (item.product.productId != -1) {
      if (quantity <= 0) {
        _cartItems.remove(item);
      } else {
        item.quantity = quantity;
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  bool isInCart(int productId) {
    return _cartItems.any((item) => item.product.productId == productId);
  }

  int getCartItemQuantity(int productId) {
    final item = _cartItems.firstWhere(
      (item) => item.product.productId == productId,
      orElse: () => CartItem(
        product: Product(
          productId: -1,
          productCode: '',
          productName: '',
          price: 0,
          category: '',
          image: '',
        ),
        quantity: 0,
      ),
    );
    return item.product.productId != -1 ? item.quantity : 0;
  }

  // ============= PRODUCT STATE =============
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  List<Category> _categories = [];
  List<Category> _sortedCategories = [];
  Product? _selectedProduct;
  late int _selectedCategory;
  late int _currentCategory;
  bool _isLoading = false;
  String? _errorMessage;

  // ============= GETTERS =============
  List<Product> get products => _filteredProducts;
  List<Product> get allProducts => _allProducts;
  List<Category> get categories => _sortedCategories;
  Product? get selectedProduct => _selectedProduct;
  int get selectedCategory => _selectedCategory;
  int get currentCategory => _currentCategory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ============= CATEGORY ORDER =============
  static const List<String> categoryOrder = [
    "All Items",
    "T-Shirts",
    "Blouses",
    "Bags",
    "Hats",
    "Shoes",
    "Jeans",
    "Accessories",
    "Electronics",
    "Headphones",
    "Power Banks",
    "Clearance",
    "Home Decor",
    "Appliances",
  ];

  set selectedProduct(Product? product) {
    _selectedProduct = product;
    notifyListeners();
  }

  // ============= IMAGE PROXY =============
//   static String getProxiedImageUrl(String originalUrl) {
//   if (originalUrl.isEmpty) return '';
//   if (originalUrl.contains('/image/proxy?url=')) return originalUrl;
//   if (originalUrl.startsWith('assets/')) return originalUrl;
//   if (originalUrl.startsWith('images/')) return 'assets/$originalUrl';

//   // ✅ If it's already a full https URL, just use it — no proxy
//   if (originalUrl.startsWith('https://')) return originalUrl;
//   if (originalUrl.startsWith('http://'))  return originalUrl;

//   // Only proxy relative paths
//   final encodedUrl = Uri.encodeComponent(originalUrl);
//   return '$baseUrl/image/proxy?url=$encodedUrl';
// }
static String getProxiedImageUrl(String originalUrl) {
  if (originalUrl.isEmpty) return '';
  if (originalUrl.contains('/image/proxy?url=')) return originalUrl;
  if (originalUrl.startsWith('assets/')) return originalUrl;
  if (originalUrl.startsWith('images/')) return 'assets/$originalUrl';

  // Hosts that DO send CORS headers on Web
  const corsSafeHosts = [
    'picsum.photos',
    'gstatic.com',            // encrypted-tbn*.gstatic.com works
    'images.unsplash.com',
    'placehold.co',
  ];
  final lower = originalUrl.toLowerCase();
  if (corsSafeHosts.any(lower.contains)) {
    return originalUrl;
  }

  // Everything else → placeholder (since we can't proxy)
  return 'https://picsum.photos/seed/${originalUrl.hashCode.abs()}/400/400';
}

  // ============= GET LOCAL IMAGE URL =============
  static String getLocalImageUrl(Product product) {
    if (product.image != null && product.image!.isNotEmpty) {
      return getProxiedImageUrl(product.image!);
    }
    // Final fallback
    return 'assets/images/placeholders/default_placeholder.jpg';
  }

  // ============= LOAD PRODUCTS =============
  Future<void> loadProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('🔄 LOADING PRODUCTS...');
      _allProducts = await _getProductsFromApi();
      _filteredProducts = _allProducts;
      print(' SUCCESS: Loaded ${_allProducts.length} products');

      if (_allProducts.isEmpty) {
        _errorMessage = 'No products found in database';
        print(' No products found');
      }
    } catch (e) {
      _errorMessage = 'Error loading products: $e';
      print(' ERROR: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Product>> _getProductsFromApi() async {
    try {
      final url = Uri.parse('$baseUrl/products');
      // final url = Uri.parse('$baseUrl/product/all');
      print(' Requesting: $url');

      final response = await http
          .get(url, headers: {'Content-Type': 'application/json'})
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              print(' API timeout, using mock data');
              // _apiAvailable = false;
              // useMockDataStatic = true;
              throw Exception('Timeout');
            },
          );

      print(' Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        print(' Response data type: ${data.runtimeType}');
        // Check if it's the backend format (with 'data' field)
        if (data is Map<String, dynamic> && data['data'] is List) {
          final List<dynamic> productsData = data['data'];
          print(' Found ${productsData.length} products (wrapped)');
          return productsData.map((j) => _parseProductFromJson(j)).toList();
        } else if (data is List) {
          print(' Found ${data.length} products (direct)');
          return data.map((j) => _parseProductFromJson(j)).toList();
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      print(' Products API Error: $e');
      print(' Using mock data as fallback');
      // _apiAvailable = false;
      // useMockDataStatic = true;
      return [];
    }
  }

  // Parse product from backend format
  Product _parseProductFromJson(Map<String, dynamic> json) {
    // ───── productId ─────
    int productId = 0;
    if (json['productId'] is int) {
      productId = json['productId'];
    } else if (json['productId'] != null) {
      productId = int.tryParse(json['productId'].toString()) ?? 0;
    }

    // ───── productCode ─────
    String productCode =
        json['productCode']?.toString() ?? productId.toString();

    // ───── userId ─────
    int? userId;
    if (json['userId'] != null) {
      userId = json['userId'] is int
          ? json['userId']
          : int.tryParse(json['userId'].toString());
    }

    // ───── name ─────
    final productName =
        json['productName']?.toString() ?? json['name']?.toString() ?? '';

    // ───── price ─────
    double price = 0;
    final rawPrice = json['price'];
    if (rawPrice is num) {
      price = rawPrice.toDouble();
    } else if (rawPrice is String) {
      price = double.tryParse(rawPrice.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    }

    // ───── category from pCategoryList ─────
    String category = '';
    if (json['pCategoryList'] is List &&
        (json['pCategoryList'] as List).isNotEmpty) {
      final first = (json['pCategoryList'] as List).first;
      if (first is Map && first['categoryName'] != null) {
        category = first['categoryName'].toString();
      }
    }
    if (category.isEmpty) {
      category =
          json['category']?.toString() ??
          json['categoryName']?.toString() ??
          '';
    }

    // ───── image ─────
    String imageUrl = '';
    // prefer first image from pImageList if product-level imageUrl is empty
    if (json['pImageList'] is List && (json['pImageList'] as List).isNotEmpty) {
      final first = (json['pImageList'] as List).first;
      if (first is Map &&
          first['imageUrl'] is String &&
          (first['imageUrl'] as String).isNotEmpty) {
        imageUrl = first['imageUrl'];
      }
    }
    if (imageUrl.isEmpty) {
      imageUrl =
          json['imageUrl']?.toString() ??
          json['ImageUrl']?.toString() ??
          json['image']?.toString() ??
          '';
    }
    if (imageUrl.isEmpty) {
      imageUrl = 'https://picsum.photos/seed/$productId/300/300';
    }

    // ───── product images (from pImageList) ─────
    List<ProductImage> productImages = [];
    if (json['pImageList'] is List) {
      for (var item in json['pImageList']) {
        if (item is Map<String, dynamic>) {
          final url = item['imageUrl']?.toString() ?? '';
          if (url.isNotEmpty) {
            productImages.add(
              ProductImage(
                id: item['id'] ?? 0,
                productId: item['productId'] ?? productId,
                imageUrl: url,
                sortOrder: item['sortOrder'] ?? 0,
              ),
            );
          }
        }
      }
    }

    // ───── variants (from pVariantList) ─────
    List<ProductVariant> variants = [];
    if (json['pVariantList'] is List) {
      for (var item in json['pVariantList']) {
        if (item is Map<String, dynamic>) {
          variants.add(ProductVariant.fromJson(item));
        }
      }
    }

    return Product(
      productId: productId,
      productCode: productCode,
      productName: productName,
      price: price,
      category: category,
      location: json['location']?.toString() ?? '',
      condition: json['condition']?.toString() ?? '',
      image: imageUrl,
      description: json['description']?.toString() ?? '',
      userId: userId,
      productImages: productImages,
      variants: variants,
      colors: const [],
    );
  }

  // ============= LOAD CATEGORIES =============
  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();
    try {
      _categories = await _getCategoriesFromApi();
      _sortedCategories = _sortCategoriesByOrder(_categories);
    } catch (e) {
      _sortedCategories = _categories;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Category>> _getCategoriesFromApi() async {
    try {
      // final url = Uri.parse('$baseUrl/categories');
      final url = Uri.parse(
        'https://www.capital-sys.net/CKMMallAPI/api/category/all',
      );
      final response = await http
          .get(url, headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('📦 Category data type: ${data.runtimeType}');
        List<dynamic> categoriesData = [];

        if (data is List) {
          categoriesData = data;
        } else if (data is Map<String, dynamic> && data['data'] is List) {
          categoriesData = data['data'];
        } else {
          throw Exception('Unexpected category format');
        }

        print('Found ${categoriesData.length} categories');
        return categoriesData.map((j) => _parseCategoryFromJson(j)).toList();
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      print(' Categories API error: $e');
      return []; //  empty, no mock
    }
  }

  Category _parseCategoryFromJson(Map<String, dynamic> json) {
    final id = json['id'] ?? json['categoryId'] ?? 0;
    final name = json['name'] ?? json['categoryName'] ?? '';
    String imagePath =
        json['categoryImageUrl'] ??
        json['photoPath'] ??
        json['imageUrl'] ??
        json['icon'] ??
        '';

    if (imagePath.isEmpty) {
      imagePath = 'assets/images/placeholders/category_placeholder.jpg';
    }
    if (imagePath.isNotEmpty && imagePath.startsWith('https://i.pinimg.com')) {
      imagePath = getProxiedImageUrl(imagePath);
    }
    print(id);
    return Category(categoryId: id, categoryName: name, photoPath: imagePath);
  }

  // ============= LOAD PRODUCT DETAIL =============
  Future<void> loadProductDetail(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // First check if product exists in loaded list
      Product? found;
      for (var p in _allProducts) {
        if (p.productId == id || p.productCode == id.toString()) {
          found = p;
          break;
        }
      }

      if (found != null) {
        _selectedProduct = found;
      } else {
        _selectedProduct = await _getProductByIdFromApi(id);
      }
    } catch (e) {
      _errorMessage = 'Error loading product: $e';
      _selectedProduct = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Future<Product> _getProductByIdFromApi(int id) async {
  //   print("productId $id");
  //   try {
  //     // final url = Uri.parse('$baseUrl/products/$id');
  //     final url = Uri.parse(
  //       'https://www.capital-sys.net/CKMMallAPI/api/Product/GetProductByProductID/$id',
  //     );
  //     print('📡 Fetching product: $url');

  //     final response = await http
  //         .get(url, headers: {'Content-Type': 'application/json'})
  //         .timeout(const Duration(seconds: 30)); //  Reduced from 8 to 5 seconds

  //     print('📡 Response: ${response.statusCode}');
  //     print('📡 Body: ${response.body}');
  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);

  //       List<dynamic> items = [];
  //       if (data is Map<String, dynamic> && data['data'] is List) {
  //         items = data['data'];
  //       } else if (data is List) {
  //         items = data;
  //       } else if (data is Map<String, dynamic>) {
  //         items = [data];
  //       }

  //       if (items.isEmpty) throw Exception('No product found');

  //       // Parse the FIRST item as the main product
  //       final mainJson = items.first as Map<String, dynamic>;
  //       final product = _parseProductFromJson(mainJson);

  //       //  Parse ALL items as variants
  //       final variants = items
  //           .map(
  //             (item) => ProductVariant.fromJson(item as Map<String, dynamic>),
  //           )
  //           .toList();
  //       return Product(
  //         productId: product.productId,
  //         productCode: product.productCode,
  //         productName: product.productName,
  //         price: product.price,
  //         category: product.category,
  //         location: product.location,
  //         condition: product.condition,
  //         image: product.image,
  //         description: product.description,
  //         userId: product.userId,
  //         productImages: product.productImages,
  //         variants: variants, //  attach here
  //         colors: product.colors,
  //       );
  //     } else {
  //       throw Exception('HTTP ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print(' Product detail error: $e');
  //     rethrow;
  //   }
  // }
  Future<Product> _getProductByIdFromApi(int id) async {
    print("productId $id");
    try {
      final url = Uri.parse(
        'https://www.capital-sys.net/CKMMallAPI/api/Product/GetProductByProductID/$id',
      );
      print('📡 Fetching product: $url');

      final response = await http
          .get(url, headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 30));

      print('📡 Response: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final data = json.decode(response.body);

      // 🔥 Handle both: single object or list
      Map<String, dynamic> mainJson;
      if (data is Map<String, dynamic>) {
        mainJson = data;
      } else if (data is List && data.isNotEmpty) {
        mainJson = data.first as Map<String, dynamic>;
      } else {
        throw Exception('No product found');
      }

      // 🔥 Parse the single product — variants + images come from within
      return _parseProductFromJson(mainJson);
    } catch (e) {
      print('❌ Product detail error: $e');
      rethrow;
    }
  }

  // ============= LOAD PRODUCTS BY CATEGORY =============
  Future<void> loadProductsByCategory(int categoryId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentCategory = categoryId;
      _selectedCategory = categoryId;

      final products = await _getProductsByCategoryFromApi(categoryId);

      //  For API data, DON'T expand color variations
      // Use products directly since API already returns proper products
      _filteredProducts = products;
      print('Loaded ${products.length} products for category: $categoryId');
      // for(int i=0;i<=products.length;i++){
      print(products);
      // }
    } catch (e) {
      _errorMessage = 'Error loading products by category: $e';
      print(' Error: $e');
      _filteredProducts = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Product>> _getProductsByCategoryFromApi(int categoryId) async {
    try {
      //  Log the exact URL being requested
      final url = Uri.parse(
        'https://www.capital-sys.net/CKMMallAPI/api/category/categoryproduct/$categoryId',
      );
      // final url = Uri.parse('$baseUrl/products/category/$category');
      print('📡 Requesting: $url');

      final response = await http
          .get(url, headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 15));

      print(' Status: ${response.statusCode}');
      print(' Body: ${response.body}'); //  Log full response

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        List<dynamic> productsData = [];

        // Handle both wrapped and direct responses
        if (data is Map<String, dynamic> && data['data'] is List) {
          productsData = data['data'];
        } else if (data is List) {
          productsData = data;
        } else {
          throw Exception('Unexpected response format: ${data.runtimeType}');
        }

        print(' Parsed ${productsData.length} products from API');
        return productsData.map((json) => _parseProductFromJson(json)).toList();
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      print(' API Error: $e');
      //  Return empty list, DON'T fall back to mock
      return [];
    }
  }

  // ============= GET TRENDING PRODUCTS =============
  List<Product> _trendingProducts = [];
  bool _isTrendingLoading = false;

  List<Product> get trendingProducts => _trendingProducts;
  bool get isTrendingLoading => _isTrendingLoading;

  // Load trending products from backend or mock
  Future<void> loadTrendingProducts() async {
    if (_isTrendingLoading) return;

    _isTrendingLoading = true;
    notifyListeners();

    try {
      _trendingProducts = await _fetchTrendingProducts();
      // print("_trendingProducts : $_trendingProducts");
    } catch (e) {
      _trendingProducts = [];
    } finally {
      _isTrendingLoading = false;
      notifyListeners();
    }
  }

  Future<List<Product>> _fetchTrendingProducts() async {
    try {
      // final url = Uri.parse('$baseUrl/products/trending');
      final url = Uri.parse(
        'https://www.capital-sys.net/CKMMallAPI/api/trending/GetTrendingProducts',
      );
      final response = await http
          .get(url, headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        List<dynamic> productsData = [];
        if (data is Map<String, dynamic> && data['data'] is List) {
          productsData = data['data'];
        } else if (data is List) {
          productsData = data;
        } else {
          throw Exception('Unexpected format');
        }

        return productsData.map((j) => _parseProductFromJson(j)).toList();
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      print(' Trending error: $e');
      return []; //  no mock
    }
  }

  // ============= SORTING =============
  List<Category> _sortCategoriesByOrder(List<Category> categories) {
    final orderMap = <String, int>{};
    for (int i = 0; i < categoryOrder.length; i++) {
      orderMap[categoryOrder[i]] = i;
    }
    categories.sort((a, b) {
      final indexA = orderMap[a.categoryName] ?? 999;
      final indexB = orderMap[b.categoryName] ?? 999;
      return indexA.compareTo(indexB);
    });
    return categories;
  }

  // ============= CLEAR SELECTED PRODUCT =============
  void clearSelectedProduct() {
    _selectedProduct = null;
    notifyListeners();
  }

  // ============= GET CATEGORY NAMES =============
  List<String> getCategoryNames() {
    return _sortedCategories.map((c) => c.categoryName).toList();
  }

  // ============= TOGGLE MOCK DATA =============
  void toggleMockData(bool useMock) {
    loadProducts();
    notifyListeners();
  }

  // ============= GET PRODUCTS WITH COLOR VARIATIONS =============
  List<Product> getProductsWithColorVariations(List<Product> products) {
    List<Product> expandedProducts = [];

    for (var product in products) {
      if (product.colors.isNotEmpty) {
        String baseName = _getProductNameWithoutColor(product.productName);
        for (var color in product.colors) {
          String colorName = _getColorName(color);
          String newName = '$baseName - $colorName';
          expandedProducts.add(
            Product(
              productCode: product.productCode,
              productName: newName,
              price: product.price,
              category: product.category,
              image: product.image ?? '',
              // rating: product.rating,
              // ratingCount: product.ratingCount,
              description: product.description,
              userId: product.userId,
              productImages: product.productImages,
              colors: [color],
            ),
          );
        }
      } else {
        expandedProducts.add(product);
      }
    }
    return expandedProducts;
  }

  String _getProductNameWithoutColor(String name) {
    List<String> colorNames = [
      'Black',
      'White',
      'Cream',
      'Blue',
      'Pink',
      'Sky Blue',
      'Brown',
      'Gray',
      'Flower',
      'Green',
      'Red',
      'Purple',
      'Orange',
    ];
    String cleanName = name;
    for (var c in colorNames) {
      cleanName = cleanName.replaceAll(c, '').trim();
    }
    cleanName = cleanName.replaceAll(RegExp(r'\s*-\s*$'), '');
    cleanName = cleanName.replaceAll(RegExp(r'^\s*-\s*'), '');
    return cleanName.isEmpty ? name : cleanName;
  }

  String _getColorName(String color) {
    final colorMap = {
      'black': 'Black',
      'white': 'White',
      'cream': 'Cream',
      'blue': 'Blue',
      'pink': 'Pink',
      'skyblue': 'Sky Blue',
      'brown': 'Brown',
      'gray': 'Gray',
      'flower': 'Flower',
      'green': 'Green',
      'red': 'Red',
    };
    return colorMap[color.toLowerCase()] ?? color;
  }
}
