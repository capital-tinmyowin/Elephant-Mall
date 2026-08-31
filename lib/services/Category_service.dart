import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/Category.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import 'mock_api_service.dart';

class ApiService extends ChangeNotifier {
  static const String baseUrl = 'http://localhost:5150/api';

  // Static variable for mock data flag
  static bool useMockDataStatic = false;
  static bool _apiAvailable = true;

  // Instance variable for mock data flag
  bool _useMockData = false;

  // Getter for useMockData
  bool get useMockData => _useMockData;

  // ============= AUTH METHODS =============
  Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password, {
    String? fullName,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/register'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'username': username,
              'email': email,
              'password': password,
              'fullName': fullName ?? username,
            }),
          )
          .timeout(const Duration(seconds: 10));

      final data = json.decode(response.body);
      print('Register response: $data');
      return data;
    } catch (e) {
      print('Register error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'username': username, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));

      final data = json.decode(response.body);
      print('Login response: $data');
      return data;
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  // ============= FAVORITE METHODS =============
  Future<Map<String, dynamic>> getUserFavorites(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/Favorites/user/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data['data'] ?? [],
          'message': data['message'] ?? 'Success',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to get favorites: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to get favorites: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> addFavorite(int userId, int productId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Favorites?userId=$userId&productId=$productId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        return {
          'success': false,
          'message': 'Failed to add favorite: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to add favorite: ${e.toString()}',
      };
    }
  }

  // Setter for useMockData
  set useMockData(bool value) {
    _useMockData = value;
    useMockDataStatic = value;
  }

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
      (item) => item.product.productCode == product.productCode,
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
    _cartItems.removeWhere((item) => item.product.productCode == productId);
    notifyListeners();
  }

  void updateCartQuantity(int productId, int quantity) {
    final item = _cartItems.firstWhere(
      (item) => item.product.productCode == productId,
      orElse: () => CartItem(
        product: Product(productCode: -1, productName: '', price: 0, category: '', image: ''),
        quantity: 0,
      ),
    );

    if (item.product.productCode != -1) {
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
    return _cartItems.any((item) => item.product.productCode == productId);
  }

  int getCartItemQuantity(int productId) {
    final item = _cartItems.firstWhere(
      (item) => item.product.productCode == productId,
      orElse: () => CartItem(
        product: Product(productCode: -1, productName: '', price: 0, category: '', image: ''),
        quantity: 0,
      ),
    );
    return item.product.productCode != -1 ? item.quantity : 0;
  }

  // ============= PRODUCT STATE =============
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  List<Category> _categories = [];
  List<Category> _sortedCategories = [];
  Product? _selectedProduct;
  String _selectedCategory = "All";
  String _currentCategory = "All";
  bool _isLoading = false;
  String? _errorMessage;

  // ============= GETTERS =============
  List<Product> get products => _filteredProducts;
  List<Product> get allProducts => _allProducts;
  List<Category> get categories => _sortedCategories;
  Product? get selectedProduct => _selectedProduct;
  String get selectedCategory => _selectedCategory;
  String get currentCategory => _currentCategory;
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

  // ============= IMAGE PROXY =============
  static String getProxiedImageUrl(String originalUrl) {
  if (originalUrl.isEmpty) return '';
  
  // 🔥 For Pinterest images, use your backend proxy
  if (originalUrl.contains('pinimg.com') || originalUrl.contains('pinterest')) {
    final encodedUrl = Uri.encodeComponent(originalUrl);
    return '$baseUrl/image/proxy?url=$encodedUrl';
  }
  
  // For other HTTP/HTTPS URLs, return directly
  if (originalUrl.startsWith('http://') || originalUrl.startsWith('https://')) {
    return originalUrl;
  }
  
  final encodedUrl = Uri.encodeComponent(originalUrl);
  return '$baseUrl/image/proxy?url=$encodedUrl';
}

  // ============= GET LOCAL IMAGE URL =============
  static String getLocalImageUrl(Product product) {
    // If mock data is enabled, use local images
    if (useMockDataStatic) {
      return MockApiService.getImageUrl(product);
    }
    // If not, use the product's image URL with proxy
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
      print('✅ SUCCESS: Loaded ${_allProducts.length} products');

      if (_allProducts.isEmpty) {
        _errorMessage = 'No products found in database';
        print('⚠️ No products found');
      }
    } catch (e) {
      _errorMessage = 'Error loading products: $e';
      print('❌ ERROR: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Product>> _getProductsFromApi() async {
    // 🔥 FIRST: Check if mock data is explicitly enabled
    if (_useMockData || useMockDataStatic) {
      print('📦 Using mock data (forced)');
      return MockApiService.getMockProducts();
    }

    // 🔥 SECOND: Check if API is known to be unavailable
    if (!_apiAvailable) {
      print('📦 API unavailable, using mock data');
      useMockDataStatic = true;
      return MockApiService.getMockProducts();
    }

    // 🔥 THIRD: Try to call the API
    try {
      final url = Uri.parse('$baseUrl/products');
      print('📡 Requesting: $url');

      final response = await http
          .get(url, headers: {'Content-Type': 'application/json'})
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              print('⏰ API timeout, using mock data');
              _apiAvailable = false;
              useMockDataStatic = true;
              throw Exception('Timeout');
            },
          );

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        print('📦 Response data type: ${data.runtimeType}');
        
        // Check if it's the backend format (with 'data' field)
        if (data is Map<String, dynamic> && data['data'] != null) {
          final List<dynamic> productsData = data['data'];
          print('✅ Found ${productsData.length} products from API (backend format)');
          _apiAvailable = true;
          // Parse with proper field mapping
          return productsData.map((json) => _parseProductFromJson(json)).toList();
        } 
        // Check if it's the direct format (array)
        else if (data is List) {
          print('✅ Found ${data.length} products from API (direct format)');
          _apiAvailable = true;
          return data.map((json) => _parseProductFromJson(json)).toList();
        } else {
          throw Exception('Unexpected API response format');
        }
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ API Error: $e');
      print('📦 Using mock data as fallback');
      _apiAvailable = false;
      useMockDataStatic = true;
      return MockApiService.getMockProducts();
    }
  }

  // 🔥 Parse product from backend format
  Product _parseProductFromJson(Map<String, dynamic> json) {
  final productCode = json['productCode'] ?? json['id'] ?? 0;
  final productName = json['productName'] ?? json['name'] ?? '';
  
  double price = 0;
  if (json['price'] != null) {
    price = (json['price'] as num).toDouble();
  }
  
  String category = json['category'] ?? json['categoryName'] ?? '';
  
  // Get image URL
  String imageUrl = json['imageUrl'] ?? json['ImageUrl'] ?? json['image'] ?? '';
  
  print('🖼️ Raw imageUrl from backend: ${json['imageUrl']}');
  
  // 🔥 DON'T use images.weserv.nl - let the backend proxy handle it
  // If it's a Pinterest image, keep the original URL - backend proxy will handle it
  if (imageUrl.contains('pinimg.com') || imageUrl.contains('pinterest')) {
    // Keep the original URL - don't proxy it here
    print('🖼️ Pinterest image detected, backend proxy will handle: $imageUrl');
  }
  
  // If empty, use placeholder
  if (imageUrl.isEmpty) {
    imageUrl = 'https://picsum.photos/seed/${productCode.toString()}/200/200';
  }
  
  print('🖼️ Product: $productName, Final ImageUrl: $imageUrl');
    
    // Get colors
    List<String> colors = [];
    if (json['colors'] != null && json['colors'] is List) {
      colors = List<String>.from(json['colors']);
    }
    
    // Get seller
    Seller? seller;
    if (json['seller'] != null && json['seller'] is Map<String, dynamic>) {
      seller = Seller.fromJson(json['seller']);
    }
    
    // Get product images
    List<String> productImages = [];
    if (json['productImages'] != null && json['productImages'] is List) {
      productImages = List<String>.from(json['productImages']);
    }
    if (productImages.isEmpty && imageUrl.isNotEmpty) {
      productImages = [imageUrl];
    }
    
    return Product(
      productCode: productCode,
      productName: productName,
      price: price,
      category: category,
      image: imageUrl,
      rating: (json['rating'] ?? 4.5).toDouble(),
      ratingCount: json['ratingCount'] ?? 0,
      description: json['description'] ?? '',
      seller: seller,
      productImages: productImages,
      colors: colors,
    );
  }

  // 🔥 Helper to check if domain is blocked
  // bool _isBlockedDomain(String url) {
  //   if (url.isEmpty) return true;
    
  //   final blockedDomains = [
  //     'pinimg.com',
  //     'pinterest',
  //     'walmartimages.com',
  //     'img.susercontent.com',
  //     'gstatic.com',
  //     'encrypted-tbn',
  //     'shopee',
  //     'walmart',
  //   ];
    
  //   return blockedDomains.any((domain) => url.contains(domain));
  // }

  // ============= LOAD CATEGORIES =============
  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();
    try {
      _categories = await _getCategoriesFromApi();
      _sortedCategories = _sortCategoriesByOrder(_categories);
      print('✅ Loaded ${_sortedCategories.length} categories');
    } catch (e) {
      print('❌ Error loading categories: $e');
      _sortedCategories = _categories;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Category>> _getCategoriesFromApi() async {
    if (_useMockData || useMockDataStatic) {
      return MockApiService.getMockCategories();
    }

    if (!_apiAvailable) {
      return MockApiService.getMockCategories();
    }

    try {
      final url = Uri.parse('$baseUrl/categories');
      final response = await http
          .get(url, headers: {'Content-Type': 'application/json'})
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              print('⏰ API timeout, using mock categories');
              _apiAvailable = false;
              useMockDataStatic = true;
              throw Exception('Timeout');
            },
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          List<dynamic> categoriesData = data['data'];
          print('✅ Found ${categoriesData.length} categories from API');
          _apiAvailable = true;
          return categoriesData.map((json) => _parseCategoryFromJson(json)).toList();
        } else if (data is List) {
          print('✅ Found ${data.length} categories from API (direct format)');
          _apiAvailable = true;
          return data.map((json) => _parseCategoryFromJson(json)).toList();
        } else {
          throw Exception('Unexpected category response format');
        }
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      print('❌ API Error: $e');
      print('📦 Using mock categories as fallback');
      _apiAvailable = false;
      useMockDataStatic = true;
      return MockApiService.getMockCategories();
    }
  }

  Category _parseCategoryFromJson(Map<String, dynamic> json) {
    final id = json['id'] ?? json['categoryId'] ?? 0;
    final name = json['name'] ?? json['categoryName'] ?? '';
    String imagePath = json['categoryImageUrl'] ?? json['photoPath'] ?? json['imageUrl'] ?? json['icon'] ?? '';
    
    if (imagePath.isEmpty) {
      imagePath = 'assets/images/placeholders/category_placeholder.jpg';
    }
    
    return Category(
      categoryId: id,
      categoryName: name,
      photoPath: imagePath,
    );
  }

  // ============= LOAD PRODUCT DETAIL =============
  Future<void> loadProductDetail(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _selectedProduct = await _getProductByIdFromApi(id);
      print('✅ Loaded product: ${_selectedProduct?.productName}');
    } catch (e) {
      _errorMessage = 'Error loading product detail: $e';
      print('❌ Error loading product detail: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Product> _getProductByIdFromApi(int id) async {
    if (_useMockData || useMockDataStatic) {
      return MockApiService.getMockProductById(id);
    }

    if (!_apiAvailable) {
      return MockApiService.getMockProductById(id);
    }

    try {
      final url = Uri.parse('$baseUrl/products/$id');
      final response = await http
          .get(url, headers: {'Content-Type': 'application/json'})
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              print('⏰ API timeout, using mock product');
              _apiAvailable = false;
              useMockDataStatic = true;
              throw Exception('Timeout');
            },
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          _apiAvailable = true;
          return _parseProductFromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to load product');
        }
      } else {
        throw Exception('Failed to load product');
      }
    } catch (e) {
      print('❌ API Error: $e');
      _apiAvailable = false;
      useMockDataStatic = true;
      return MockApiService.getMockProductById(id);
    }
  }

  // ============= LOAD PRODUCTS BY CATEGORY =============
  Future<void> loadProductsByCategory(String category) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _currentCategory = category;
      _selectedCategory = category;
      if (category == "All" || category == "All Items") {
        _filteredProducts = _allProducts;
      } else {
        _filteredProducts = await _getProductsByCategoryFromApi(category);
      }
      print('✅ Loaded ${_filteredProducts.length} products for category: $category');
    } catch (e) {
      _errorMessage = 'Error loading products by category: $e';
      print('❌ Error loading products by category: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Product>> _getProductsByCategoryFromApi(String category) async {
    if (_useMockData || useMockDataStatic) {
      return MockApiService.getMockProductsByCategory(category);
    }

    if (!_apiAvailable) {
      return MockApiService.getMockProductsByCategory(category);
    }

    try {
      final url = Uri.parse('$baseUrl/products/category/$category');
      final response = await http
          .get(url, headers: {'Content-Type': 'application/json'})
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              print('⏰ API timeout, using mock products');
              _apiAvailable = false;
              useMockDataStatic = true;
              throw Exception('Timeout');
            },
          );
          
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          List<dynamic> productsData = data['data'];
          _apiAvailable = true;
          return productsData.map((json) => _parseProductFromJson(json)).toList();
        } else if (data is List) {
          _apiAvailable = true;
          return data.map((json) => _parseProductFromJson(json)).toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to load products');
        }
      } else {
        throw Exception('Failed to load products by category');
      }
    } catch (e) {
      print('❌ API Error: $e');
      _apiAvailable = false;
      useMockDataStatic = true;
      return MockApiService.getMockProductsByCategory(category);
    }
  }

  // ============= GET TRENDING PRODUCTS =============
  List<Product> _trendingProducts = [];
bool _isTrendingLoading = false;

List<Product> get trendingProducts => _trendingProducts;
bool get isTrendingLoading => _isTrendingLoading;

// 🔥 Load trending products from backend or mock
Future<void> loadTrendingProducts() async {
  if (_isTrendingLoading) return;
  
  _isTrendingLoading = true;
  notifyListeners();

  try {
    _trendingProducts = await _fetchTrendingProducts();
  } catch (e) {
    print('❌ Error loading trending: $e');
    _trendingProducts = [];
  } finally {
    _isTrendingLoading = false;
    notifyListeners();
  }
}
  Future<List<Product>> _fetchTrendingProducts() async {
    if (_useMockData || useMockDataStatic) {
      return MockApiService.getMockTrendingProducts();
    }

    if (!_apiAvailable) {
      return MockApiService.getMockTrendingProducts();
    }

    try {
      final url = Uri.parse('$baseUrl/products/trending');
      final response = await http
          .get(url, headers: {'Content-Type': 'application/json'})
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              print('⏰ API timeout, using mock trending');
              _apiAvailable = false;
              useMockDataStatic = true;
              throw Exception('Timeout');
            },
          );
          
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          List<dynamic> productsData = data['data'];
          _apiAvailable = true;
          return productsData.map((json) => _parseProductFromJson(json)).toList();
        } else if (data is List) {
          _apiAvailable = true;
          return data.map((json) => _parseProductFromJson(json)).toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to load trending products');
        }
      } else {
        throw Exception('Failed to load trending products');
      }
    } catch (e) {
      print('❌ API Error: $e');
      _apiAvailable = false;
      useMockDataStatic = true;
      return MockApiService.getMockTrendingProducts();
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
    _useMockData = useMock;
    useMockDataStatic = useMock;
    _apiAvailable = !useMock;
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
              rating: product.rating,
              ratingCount: product.ratingCount,
              description: product.description,
              seller: product.seller,
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
      'Black', 'White', 'Cream', 'Blue', 'Pink', 'Sky Blue',
      'Brown', 'Gray', 'Flower', 'Green', 'Red', 'Purple', 'Orange'
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