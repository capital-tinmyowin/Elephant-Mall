import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/browser_client.dart' show BrowserClient;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/product.dart';

class AuthService extends ChangeNotifier {
  static const String _baseUrl = 'https://www.capital-sys.net/CKMMallAPI/api';

  //  Platform-aware HTTP client
  // Web: BrowserClient with cookies enabled
  // Mobile: standard http.Client (cookies handled manually if needed)
  final http.Client _client = kIsWeb
      ? (BrowserClient()..withCredentials = true)
      : http.Client();

  //  Cookie storage (mobile fallback — on web, browser handles it)
  String? _authCookie;
  String? get authCookie => _authCookie;

  // JWT from signup
  String? _token;
  String? get token => _token;

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final Set<int> _favoriteProductIds = {};
  Set<int> get favoriteProductIds => _favoriteProductIds;

  bool isFavorite(int productId) => _favoriteProductIds.contains(productId);
  static const _kLoggedInKey = 'is_logged_in';
  static const _kUserIdKey = 'user_id';
  static const _kUserEmailKey = 'user_email';
  static const _kAuthCookieKey = 'auth_cookie';

  void _addFavoriteId(int id) {
    _favoriteProductIds.add(id);
    notifyListeners();
  }

  void _removeFavoriteId(int id) {
    _favoriteProductIds.remove(id);
    notifyListeners();
  }

  // ============= REGISTER =============
  Future<bool> register(
    String fullName,
    String email,
    String password, {
    String? username,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final generatedUsername = username ?? email.split('@').first;

      final response = await _client
          .post(
            Uri.parse('$_baseUrl/auth/SignUp/'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'username': generatedUsername,
              'email': email,
              'password': password,
              'fullName': fullName,
            }),
          )
          .timeout(const Duration(seconds: 15));

      print('Register status: ${response.statusCode}');
      print('Register body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final userId = data['userId'];
        final message = data['message']?.toString() ?? '';
        final isSuccess =
            userId != null && message.toLowerCase().contains('success');

        if (isSuccess) {
          _token = data['token'];
          _currentUser = User(
            id: userId is int ? userId : int.tryParse(userId.toString()) ?? 0,
            username: data['userName'] ?? generatedUsername,
            email: data['email'] ?? email,
            fullName: fullName,
          );
          _isLoading = false;
          notifyListeners();
          await getUserFavorites();
          return true;
        } else {
          _errorMessage = message.isNotEmpty ? message : 'Registration failed';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } else {
        _errorMessage = 'Registration failed: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Network error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ============= LOGIN =============
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _client
          .post(
            Uri.parse('$_baseUrl/auth/login-web'),
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: {'Email': email, 'Password': password, 'token': _token ?? ''},
          )
          .timeout(const Duration(seconds: 15));

      print('Login status: ${response.statusCode}');
      print('Login headers: ${response.headers}');
      print('Login body: ${response.body}');

      if (response.statusCode == 200) {
        //  On mobile (not web), capture Set-Cookie manually
        if (!kIsWeb) {
          final setCookie = response.headers['set-cookie'];
          if (setCookie != null && setCookie.isNotEmpty) {
            _authCookie = setCookie.split(';').first.trim();
            print(' Captured cookie: $_authCookie');
          }
        }

        final data = json.decode(response.body);
        final loginId = data['loginID'];
        final message = data['message']?.toString() ?? '';
        final isSuccess =
            loginId != null && message.toLowerCase().contains('success');

        if (isSuccess) {
          _currentUser = User(
            id: loginId is int
                ? loginId
                : int.tryParse(loginId.toString()) ?? 0,
            username: email.split('@').first,
            email: email,
            fullName: '',
          );
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool(_kLoggedInKey, true);
          await prefs.setInt(_kUserIdKey, _currentUser!.id);
          await prefs.setString(_kUserEmailKey, email);
          if (_authCookie != null) {
            await prefs.setString(_kAuthCookieKey, _authCookie!);
          }
          _isLoading = false;
          notifyListeners();
          // 🔥 Pre-load favourites so the button state is correct on any screen
          await getUserFavorites();
          return true;
        } else {
          _errorMessage = 'Login failed';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } else if (response.statusCode == 401) {
        _errorMessage = 'Invalid email or password';
        _isLoading = false;
        notifyListeners();
        return false;
      } else {
        _errorMessage = 'Login failed: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Network error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ============= LOGOUT =============
  Future<void> logout() async {
    _currentUser = null;
    _token = null;
    _authCookie = null;
    _favoriteProductIds.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kLoggedInKey);
    await prefs.remove(_kUserIdKey);
    await prefs.remove(_kUserEmailKey);
    await prefs.remove(_kAuthCookieKey);
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ============= FAVORITES =============
  Future<Map<String, dynamic>?> getProductDetail(int id) async {
    try {
      final response = await _client
          .get(
            Uri.parse('$_baseUrl/Product/GetProductByProductID/$id'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 30));

      print('📡 Product detail status: ${response.statusCode}');
      print('📡 Product detail body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic>) return data;
        if (data is List && data.isNotEmpty) {
          return data.first as Map<String, dynamic>;
        }
      }
      _errorMessage = 'Product detail failed (${response.statusCode})';
      notifyListeners();
      return null;
    } catch (e) {
      _errorMessage = 'Network error: $e';
      notifyListeners();
      return null;
    }
  }

  Future<List<Product>> getUserFavorites() async {
    if (_currentUser == null) {
      _favoriteProductIds.clear();
      notifyListeners();
      return [];
    }

    try {
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (!kIsWeb && _authCookie != null) {
        headers['Cookie'] = _authCookie!;
      }
      final response = await _client
          .get(
            Uri.parse('$_baseUrl/productshowcase/GetFavouriteProductList'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 15));

      // print('=== FAVORITES DEBUG ===');
      // print('Status: ${response.statusCode}');
      // print('Body: ${response.body}');
      // print('kIsWeb: $kIsWeb');
      // print('======================');

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);

        List<dynamic> items = [];
        if (data is List) {
          items = data; // ← your case
        } else if (data is Map<String, dynamic>) {
          if (data['data'] is List) {
            items = data['data'];
          } else if (data['favorites'] is List) {
            items = data['favorites'];
          }
        }

         final products = items.whereType<Map<String, dynamic>>().map((json) {
          // 1. Extract categoryId (e.g., "9,10")
          final rawCatId = json['categoryId']?.toString() ?? '';
          
          // 2. Create the product from JSON
          final p = Product.fromJson(json);

          // 3. If the product category is empty, try to find the name
          if (p.category.isEmpty && rawCatId.isNotEmpty) {
            // Here we need the ApiService categories. 
            // Since we can't easily access it, we will resolve this in the UI.
            // For now, we will pass the rawCatId to a temporary variable 
            // (You might need to update your Product model to accept a list of IDs).
          }

          return p;
        }).toList();

        // FIX: Update the cached IDs so the Home page hearts turn red!
        _favoriteProductIds.clear();
        for (var p in products) {
          _favoriteProductIds.add(p.productId);
        }
        notifyListeners(); // Notify UI to update

        return products;
      }
      //  Show exact backend message + status code inline
      String backendMsg = '';
      try {
        final body = json.decode(response.body);
        if (body is Map<String, dynamic>) {
          backendMsg =
              (body['message'] ??
                      body['title'] ??
                      body['error'] ??
                      body['detail'] ??
                      '')
                  .toString();
        }
      } catch (_) {}

      _errorMessage = backendMsg.isNotEmpty
          ? '$backendMsg (${response.statusCode})'
          : 'Request failed (${response.statusCode})';

      notifyListeners();
      return [];
    } catch (e) {
      _errorMessage = 'Network error: $e';
      notifyListeners();
      return [];
    }
  }

  Future<bool> addFavorite(int productId) async {
    if (_currentUser == null) {
      _errorMessage = 'Please login first';
      notifyListeners();
      return false;
    }

    try {
      final headers = <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      };
      if (!kIsWeb && _authCookie != null) {
        headers['Cookie'] = _authCookie!;
      }

      final response = await _client
          .post(
            Uri.parse(
              'https://www.capital-sys.net/CKMMallAPI/api/UserAction/addFavourite/$productId',
            ),
            headers: headers,
          )
          .timeout(const Duration(seconds: 15));
           if (response.statusCode == 401) {
        await logout(); // Force logout locally
         _errorMessage = 'Session has expired (401)';
        notifyListeners();
        return false;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        _favoriteProductIds.add(productId);
        notifyListeners();
        return true;
      }

      print('Add favorite status: ${response.statusCode}');
      print('Add favorite body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        _favoriteProductIds.add(productId); // 🔥 update cache
        notifyListeners();
        return true;
      }

      //  Show exact backend message + status code inline
      String backendMsg = '';
      try {
        final body = json.decode(response.body);
        if (body is Map<String, dynamic>) {
          backendMsg =
              (body['message'] ??
                      body['title'] ??
                      body['error'] ??
                      body['detail'] ??
                      '')
                  .toString();
        }
      } catch (_) {}

      _errorMessage = backendMsg.isNotEmpty
          ? 'Failed to add favorite : $backendMsg (${response.statusCode})'
          : 'Failed to add favorite (${response.statusCode})';

      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Network error: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeFavorite(int productId) async {
    if (_currentUser == null) {
      _errorMessage = 'Please login first';
      notifyListeners();
      return false;
    }

    try {
      final uri = Uri.parse('$_baseUrl/UserAction/removeFavourite/$productId');
      final headers = <String, String>{};
      if (!kIsWeb && _authCookie != null) {
        headers['Cookie'] = _authCookie!;
      }

      debugPrint('========== REMOVE FAVOURITE REQUEST ==========');
      debugPrint('URL: $uri');
      debugPrint('Method: POST');
      debugPrint('Headers: $headers');
      debugPrint('kIsWeb: $kIsWeb');
      debugPrint('authCookie: $_authCookie');
      debugPrint('==============================================');

      final response = await _client
          .delete(uri, headers: headers)
          .timeout(const Duration(seconds: 15));

           if (response.statusCode == 401) {
        await logout(); // Force logout locally
         _errorMessage = 'Session has expired (401)';
        notifyListeners();
        return false;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        _favoriteProductIds.add(productId);
        notifyListeners();
        return true;
      }

      if (response.statusCode == 401) {
        await logout(); // Force logout locally
        _errorMessage = 'Your session has expired. Please log in again.';
        notifyListeners();
        return false;
      }
      debugPrint('========== REMOVE FAVOURITE RESPONSE ==========');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Headers: ${response.headers}');
      debugPrint('Body: ${response.body}');
      debugPrint('===============================================');

      if (response.statusCode == 200 || response.statusCode == 201) {
        _favoriteProductIds.remove(productId);
        notifyListeners();
        return true;
      }

      // Extract the backend's actual error message
      String backendMsg = '';
      try {
        final body = json.decode(response.body);
        if (body is Map<String, dynamic>) {
          backendMsg =
              (body['message'] ??
                      body['title'] ??
                      body['error'] ??
                      body['detail'] ??
                      '')
                  .toString();
        }
      } catch (_) {}

      _errorMessage = backendMsg.isNotEmpty
          ? '$backendMsg (${response.statusCode})'
          : 'Remove failed (${response.statusCode})';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Network error: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();

    final loggedIn = prefs.getBool(_kLoggedInKey) ?? false;
    if (!loggedIn) return false;

    final userId = prefs.getInt(_kUserIdKey);
    final email = prefs.getString(_kUserEmailKey) ?? '';

    // restore mobile cookie
    if (!kIsWeb) {
      _authCookie = prefs.getString(_kAuthCookieKey);
    }

    if (userId == null) return false;

    _currentUser = User(
      id: userId,
      username: email.split('@').first,
      email: email,
      fullName: '',
    );

    notifyListeners();

    // 🔥 now actually rehydrate favorites from the server
    await getUserFavorites();
    return true;
  }
}
