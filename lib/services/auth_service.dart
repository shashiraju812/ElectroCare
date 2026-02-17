import 'package:flutter/material.dart';
import '../models/user_role.dart';

class AuthService extends ChangeNotifier {
  bool _isAuthenticated = false;
  UserRole? _currentUserRole;
  String? _userName;

  bool get isAuthenticated => _isAuthenticated;
  UserRole? get currentUserRole => _currentUserRole;
  String? get userName => _userName;

  Future<void> loginWithGoogle() async {
    // Simulate a network delay
    await Future.delayed(const Duration(seconds: 1));
    _isAuthenticated = true;
    _userName = "Test User"; // Mock user
    notifyListeners();
  }

  Future<void> sendOtp(String contact) async {
    await Future.delayed(const Duration(seconds: 1));
    // Mock OTP send
  }

  Future<bool> verifyOtp(String contact, String otp) async {
    await Future.delayed(const Duration(seconds: 1));
    if (otp == "1234") {
      _isAuthenticated = true;
      _userName = contact;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> loginWithPassword(String contact, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (password == "password123") {
      // Mock password
      _isAuthenticated = true;
      _userName = contact;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> registerUser(
    String name,
    String contact,
    String password,
  ) async {
    await Future.delayed(const Duration(seconds: 1));
    // Mock registration success
    _isAuthenticated = true;
    _userName = contact; // Or name
    notifyListeners();
    return true;
  }

  void setRole(UserRole role) {
    _currentUserRole = role;
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    _currentUserRole = null;
    _userName = null;
    notifyListeners();
  }
}
