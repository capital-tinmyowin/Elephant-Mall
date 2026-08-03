import 'package:elephant_mall/models/product.dart';
import 'package:elephant_mall/services/Category_service.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';

class AuthService extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // 🔥 Register - sends username, email, password to backend
  Future<bool> register(String fullName, String email, String password, {String? username}) async {
  _isLoading = true;
  _errorMessage = null;
  notifyListeners();

  try {
    // If username not provided, generate from email
    final generatedUsername = username ?? email.split('@').first;
    
    final response = await _apiService.register(
      generatedUsername,  // username
      email,              // email
      password,           // password
      fullName: fullName, // fullName
    );
    
    if (response['success'] == true && response['user'] != null) {
      _currentUser = User.fromJson(response['user']);
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = response['message'] ?? 'Registration failed';
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

  // 🔥 Login - sends username, password to backend
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.login(username, password);
      
      if (response['success'] == true && response['user'] != null) {
        _currentUser = User.fromJson(response['user']);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Login failed';
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

// Get user's favorites
Future<List<Product>> getUserFavorites() async {
  if (_currentUser == null) return [];

  try {
    final response = await _apiService.getUserFavorites(_currentUser!.id);
    if (response['success'] == true && response['favorites'] != null) {
      final List favorites = response['favorites'];
      return favorites.map((json) => Product.fromJson(json)).toList();
    }
    return [];
  } catch (e) {
    return [];
  }
}
}