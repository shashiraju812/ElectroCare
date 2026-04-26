// lib/services/auth_service.dart
// Firebase AuthService — uses FirebaseAuth + Firestore user profiles

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/user_role.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  // ── Getters ──────────────────────────────────────────────
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get userId => _currentUser?.uid;
  String? get userName => _currentUser?.name;
  String? get userPhone => _currentUser?.phone;
  bool get isAuthenticated => _currentUser != null;
  UserRole? get currentUserRole => _currentUser?.role;

  AuthService() {
    // Listen to auth state changes
    _auth.authStateChanges().listen((user) async {
      if (user != null) {
        await _loadUserProfile(user.uid);
      } else {
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  /// Load user profile from Firestore
  Future<void> _loadUserProfile(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        _currentUser = UserModel.fromMap(doc.data()!);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }
  }

  /// Save/update user profile to Firestore
  Future<void> _saveUserProfile(UserModel user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap(), SetOptions(merge: true));
  }

  // ── Guest Login (anonymous auth) ──────────────────────────
  Future<bool> loginAsGuest({UserRole role = UserRole.user}) async {
    _setLoading(true);
    try {
      final result = await _auth.signInAnonymously();
      final uid = result.user!.uid;
      _currentUser = UserModel(
        uid: uid,
        name: role == UserRole.owner
            ? 'Shop Owner'
            : role == UserRole.provider
                ? 'Electrician'
                : 'Guest User',
        email: 'demo@electrocare.app',
        phone: '9876543210',
        role: role,
        createdAt: DateTime.now(),
      );
      await _saveUserProfile(_currentUser!);
      _setLoading(false);
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = e.message ?? 'Login failed';
      _setLoading(false);
      return false;
    }
  }

  // ── Phone OTP ─────────────────────────────────────────────
  Future<void> sendOtp({
    required String phone,
    required UserRole role,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    _setLoading(true);
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phone.startsWith('+') ? phone : '+91$phone',
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verify on some Android devices
          await _auth.signInWithCredential(credential);
          final uid = _auth.currentUser!.uid;
          _currentUser = UserModel(
            uid: uid,
            name: 'User $phone',
            email: '',
            phone: phone,
            role: role,
            createdAt: DateTime.now(),
          );
          await _saveUserProfile(_currentUser!);
          _setLoading(false);
          notifyListeners();
        },
        verificationFailed: (FirebaseAuthException e) {
          _setLoading(false);
          onError(e.message ?? 'Verification failed');
        },
        codeSent: (String verificationId, int? resendToken) {
          _setLoading(false);
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      _setLoading(false);
      onError(e.toString());
    }
  }

  Future<bool> verifyOtp({
    required String verificationId,
    required String otp,
    required String phone,
    required UserRole role,
  }) async {
    _setLoading(true);
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      final result = await _auth.signInWithCredential(credential);
      final uid = result.user!.uid;
      _currentUser = UserModel(
        uid: uid,
        name: 'User $phone',
        email: '',
        phone: phone,
        role: role,
        createdAt: DateTime.now(),
      );
      await _saveUserProfile(_currentUser!);
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Invalid OTP: $e';
      _setLoading(false);
      return false;
    }
  }

  // ── Email + Password Login ────────────────────────────────
  Future<bool> loginWithEmail({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    _setLoading(true);
    try {
      UserCredential result;
      try {
        // Try sign in first
        result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          // Create account if not found
          result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
        } else {
          rethrow;
        }
      }

      final uid = result.user!.uid;

      // Check if profile already exists
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        _currentUser = UserModel.fromMap(doc.data()!);
      } else {
        _currentUser = UserModel(
          uid: uid,
          name: email.split('@').first,
          email: email,
          phone: '',
          role: role,
          createdAt: DateTime.now(),
        );
        await _saveUserProfile(_currentUser!);
      }

      _setLoading(false);
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = e.message ?? 'Authentication failed';
      _setLoading(false);
      return false;
    }
  }

  // ── Google Sign-In (mock — add google_sign_in package for real) ──
  Future<bool> loginWithGoogle({UserRole role = UserRole.user}) async {
    // For now, use anonymous auth as placeholder
    // To enable real Google Sign-In, add google_sign_in package
    return loginAsGuest(role: role);
  }

  // ── Logout ────────────────────────────────────────────────
  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
    _error = null;
    notifyListeners();
  }

  // ── Profile Update ────────────────────────────────────────
  Future<void> updateProfile({String? name, String? address}) async {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(name: name, address: address);
    await _saveUserProfile(_currentUser!);
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }
}
