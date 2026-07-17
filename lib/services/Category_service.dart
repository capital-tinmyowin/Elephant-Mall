import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/Category.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import 'mock_api_service.dart';

class ApiService extends ChangeNotifier {
  static const String baseUrl = 'http://localhost:5150/api';
  
  //  Static variable for mock data flag
  static bool useMockDataStatic = false;
  
  //  Instance variable for mock data flag
  bool _useMockData = false;

  //  Getter for useMockData
  bool get useMockData => _useMockData;
  
  //  Setter for useMockData
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

void updateQuantity(int productId, int quantity) {
  updateCartQuantity(productId, quantity);
}
  void addToCart(Product product) {
    final existingItem = _cartItems.firstWhere(
      (item) => item.product.id == product.id,
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
    _cartItems.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void updateCartQuantity(int productId, int quantity) {
    final item = _cartItems.firstWhere(
      (item) => item.product.id == productId,
      orElse: () => CartItem(
        product: Product(id: -1, name: '', price: 0, category: '', image: ''),
        quantity: 0,
      ),
    );
    
    if (item.product.id != -1) {
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
    return _cartItems.any((item) => item.product.id == productId);
  }

  int getCartItemQuantity(int productId) {
    final item = _cartItems.firstWhere(
      (item) => item.product.id == productId,
      orElse: () => CartItem(
        product: Product(id: -1, name: '', price: 0, category: '', image: ''),
        quantity: 0,
      ),
    );
    return item.product.id != -1 ? item.quantity : 0;
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
    final encodedUrl = Uri.encodeComponent(originalUrl);
    return '$baseUrl/image/proxy?url=$encodedUrl';
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
    if (_useMockData || useMockDataStatic) {
      print(' Using mock data (forced)');
      return MockApiService.getMockProducts();
    }

    try {
      final url = Uri.parse('$baseUrl/products');
      print(' Requesting: $url');
      
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print(' API timeout, using mock data');
          throw Exception('Timeout');
        },
      );

      print(' Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> productsData = data['data'];
          print('Found ${productsData.length} products from API');
          return productsData.map((json) => Product.fromJson(json)).toList();
        } else {
          throw Exception(data['message'] ?? 'API returned error');
        }
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      print(' API Error: $e');
      print(' Using mock data as fallback');
      return MockApiService.getMockProducts();
    }
  }

  // ============= LOAD CATEGORIES =============
  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      _categories = await _getCategoriesFromApi();
      _sortedCategories = _sortCategoriesByOrder(_categories);
      print(' Loaded ${_sortedCategories.length} categories');
    } catch (e) {
      print(' Error loading categories: $e');
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

    try {
      final url = Uri.parse('$baseUrl/categories');
      
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print(' API timeout, using mock data');
          throw Exception('Timeout');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          List<dynamic> categoriesData = data['data'];
          return categoriesData.map((json) => Category.fromJson(json)).toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to load categories');
        }
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      print(' API Error: $e');
      print(' Using mock categories as fallback');
      return MockApiService.getMockCategories();
    }
  }

  // ============= LOAD PRODUCT DETAIL =============
  Future<void> loadProductDetail(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedProduct = await _getProductByIdFromApi(id);
      print(' Loaded product: ${_selectedProduct?.name}');
    } catch (e) {
      _errorMessage = 'Error loading product detail: $e';
      print(' Error loading product detail: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Product> _getProductByIdFromApi(int id) async {
    if (_useMockData || useMockDataStatic) {
      return MockApiService.getMockProductById(id);
    }

    try {
      final url = Uri.parse('$baseUrl/products/$id');
      
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print(' API timeout, using mock data');
          throw Exception('Timeout');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Product.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to load product');
        }
      } else {
        throw Exception('Failed to load product');
      }
    } catch (e) {
      print(' API Error: $e');
      return MockApiService.getMockProductById(id);
    }
  }

  // ============= FILTER BY CATEGORY =============
  void filterByCategory(String category) {
    _currentCategory = category;
    _selectedCategory = category;
    if (category == "All" || category == "All Items") {
      _filteredProducts = _allProducts;
    } else {
      _filteredProducts = _allProducts.where((p) => p.category == category).toList();
    }
    print(' Filtered to ${_filteredProducts.length} products');
    notifyListeners();
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    filterByCategory(category);
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
      print(' Loaded ${_filteredProducts.length} products for category: $category');
    } catch (e) {
      _errorMessage = 'Error loading products by category: $e';
      print(' Error loading products by category: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Product>> _getProductsByCategoryFromApi(String category) async {
    if (_useMockData || useMockDataStatic) {
      return MockApiService.getMockProductsByCategory(category);
    }

    try {
      final url = Uri.parse('$baseUrl/products/category/$category');
      
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print(' API timeout, using mock data');
          throw Exception('Timeout');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          List<dynamic> productsData = data['data'];
          return productsData.map((json) => Product.fromJson(json)).toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to load products');
        }
      } else {
        throw Exception('Failed to load products by category');
      }
    } catch (e) {
      print(' API Error: $e');
      return MockApiService.getMockProductsByCategory(category);
    }
  }

  // ============= GET TRENDING PRODUCTS =============
  Future<List<Product>> getTrendingProducts() async {
    if (_useMockData || useMockDataStatic) {
      return MockApiService.getMockTrendingProducts();
    }

    try {
      final url = Uri.parse('$baseUrl/products/trending');
      
      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print(' API timeout, using mock data');
          throw Exception('Timeout');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          List<dynamic> productsData = data['data'];
          return productsData.map((json) => Product.fromJson(json)).toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to load trending products');
        }
      } else {
        throw Exception('Failed to load trending products');
      }
    } catch (e) {
      print(' API Error: $e');
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
  //  RENAMED: Changed from useMockData to toggleMockData to avoid conflict
  void toggleMockData(bool useMock) {
    _useMockData = useMock;
    useMockDataStatic = useMock;
    loadProducts();
    notifyListeners();
  }
}