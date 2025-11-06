import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _userEmail;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get userEmail => _userEmail;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
    _userEmail = prefs.getString('userEmail');
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // Mock validation
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Please fill all fields');
      }

      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        throw Exception('Please enter a valid email');
      }

      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      // Mock successful login
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAuthenticated', true);
      await prefs.setString('userEmail', email);

      _isAuthenticated = true;
      _userEmail = email;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUp(
    String email,
    String password,
    String confirmPassword,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2));

      // Validation
      if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
        throw Exception('Please fill all fields');
      }

      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        throw Exception('Please enter a valid email');
      }

      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      if (password != confirmPassword) {
        throw Exception('Passwords do not match');
      }

      // Mock successful signup
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAuthenticated', true);
      await prefs.setString('userEmail', email);

      _isAuthenticated = true;
      _userEmail = email;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    _isAuthenticated = false;
    _userEmail = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
