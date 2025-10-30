import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  
  // Keys for stored values
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _roleKey = 'user_role';

  // Save authentication token
  static Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  // Get authentication token
  static Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  // Save user data (as JSON string)
  static Future<void> saveUserData(String userData) async {
    await _secureStorage.write(key: _userKey, value: userData);
  }

  // Get user data
  static Future<String?> getUserData() async {
    return await _secureStorage.read(key: _userKey);
  }

  // Save user role for quick access
  static Future<void> saveUserRole(String role) async {
    await _secureStorage.write(key: _roleKey, value: role);
  }

  // Get user role
  static Future<String?> getUserRole() async {
    return await _secureStorage.read(key: _roleKey);
  }

  // Clear all stored authentication data (for logout)
  static Future<void> clearAuthData() async {
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _userKey);
    await _secureStorage.delete(key: _roleKey);
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}