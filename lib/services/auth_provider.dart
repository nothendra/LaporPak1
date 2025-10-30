import 'dart:convert';
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _token;
  Map<String, dynamic>? _userData;
  String? _userRole;
  bool _isLoading = false;

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  Map<String, dynamic>? get userData => _userData;
  String? get userRole => _userRole;
  bool get isLoading => _isLoading;

  AuthProvider() {
    // Check if user is already logged in
    _initializeAuthState();
  }

  Future<void> _initializeAuthState() async {
    _isLoading = true;
    notifyListeners();

    try {
      final isLoggedIn = await StorageService.isLoggedIn();
      if (isLoggedIn) {
        _token = await StorageService.getToken();
        final userDataStr = await StorageService.getUserData();
        if (userDataStr != null) {
          _userData = json.decode(userDataStr);
        }
        _userRole = await StorageService.getUserRole();
        _isAuthenticated = true;
      }
    } catch (e) {
      // If there's an error, ensure user is logged out
      await logout();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register a new user
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.register(
        name: name,
        email: email,
        password: password,
        role: role,
      );

      _token = response['token'];
      _userData = response['user'];
      _userRole = _userData?['role'];

      // Save data to secure storage
      await StorageService.saveToken(_token!);
      await StorageService.saveUserData(json.encode(_userData));
      await StorageService.saveUserRole(_userRole!);

      _isAuthenticated = true;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Login user
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.login(
        email: email,
        password: password,
      );

      _token = response['token'];
      _userData = response['user'];
      _userRole = _userData?['role'];

      // Save data to secure storage
      await StorageService.saveToken(_token!);
      await StorageService.saveUserData(json.encode(_userData));
      await StorageService.saveUserRole(_userRole!);

      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Logout user
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_token != null) {
        await ApiService.logout(_token!);
      }
    } catch (e) {
      // Even if API call fails, we still want to clear local data
    } finally {
      // Clear all stored data
      await StorageService.clearAuthData();
      
      _token = null;
      _userData = null;
      _userRole = null;
      _isAuthenticated = false;
      _isLoading = false;
      notifyListeners();
    }
  }
}