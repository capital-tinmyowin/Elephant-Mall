import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/Category_service.dart';

class AuthService extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  User? _currentUser;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  String? get token => _token;
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

      final response = await _apiService.register(
        generatedUsername,
        email,
        password,
        fullName: fullName,
      );

      print('🔍 Register response: $response');

      // 🔥 Backend returns: { message, userId, token, email, userName }
      final hasUserId = response['userId'] != null;
      final message = response['message']?.toString() ?? '';
      final isSuccess = hasUserId && message.toLowerCase().contains('success');

      if (isSuccess) {
        _token = response['token'];
        _currentUser = User(
          id: response['userId'] is int
              ? response['userId']
              : int.tryParse(response['userId'].toString()) ?? 0,
          username: response['userName'] ?? generatedUsername,
          email: response['email'] ?? email,
          fullName: fullName,
        );
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // Email already exists etc.
        _errorMessage = message.isNotEmpty ? message : 'Registration failed';
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
      // 🔥 Pass the token from signup (or empty string if new session)
      final response = await _apiService.login(
        email,
        password,
        token: _token,
      );

      print('🔍 Login response: $response');

      // 🔥 Backend returns: { message: "Login success (cookie issued).", loginID: 13 }
      final loginId = response['loginID'];
      final message = response['message']?.toString() ?? '';
      final isSuccess = loginId != null && message.toLowerCase().contains('success');

      if (isSuccess) {
        _currentUser = User(
          id: loginId is int ? loginId : int.tryParse(loginId.toString()) ?? 0,
          username: email.split('@').first,
          email: email,
          fullName: '',
        );
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = message.isNotEmpty
            ? message
            : (response['message'] ?? 'Login failed');
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

  void logout() {
    _currentUser = null;
    _token = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> addFavorite(int productId) async {
    if (_currentUser == null) {
      _errorMessage = 'Please login first';
      notifyListeners();
      return false;
    }

    try {
      final response = await _apiService.addFavorite(_currentUser!.id, productId);
      if (response['success'] == true) {
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Failed to add favorite';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Network error: $e';
      return false;
    }
  }
}