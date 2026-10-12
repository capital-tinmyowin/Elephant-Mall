import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/browser_client.dart' show BrowserClient;
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
          _isLoading = false;
          notifyListeners();
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
  void logout() {
    _currentUser = null;
    _token = null;
    _authCookie = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ============= FAVORITES =============
  Future<List<Product>> getUserFavorites() async {
    if (_currentUser == null) return [];

    try {
      final response = await _client
          .get(
            Uri.parse('$_baseUrl/productshowcase/GetFavouriteProductList'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 15));

      print('=== FAVORITES DEBUG ===');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');
      print('kIsWeb: $kIsWeb');
      print('======================');

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

        return items.whereType<Map<String, dynamic>>().map((json) {
          debugPrint('🔵 About to parse: $json');
          final p = Product.fromJson(json);
          debugPrint(
            '🟢 Parsed → productId=${p.productId}, productCode=${p.productCode}',
          );
          return p;
        }).toList();
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

      print('Add favorite status: ${response.statusCode}');
      print('Add favorite body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
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
}
