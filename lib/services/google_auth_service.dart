// services/google_auth_service.dart
// Google Sign-In authentication service with verification

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/user_role.dart';

class GoogleAuthService extends ChangeNotifier {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  GoogleSignInAccount? _currentGoogleUser;
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isVerified = false;

  // ── Getters ──────────────────────────────────────────────
  GoogleSignInAccount? get currentGoogleUser => _currentGoogleUser;
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isVerified => _isVerified;
  bool get isAuthenticated => _currentUser != null;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  /// Sign in with Google
  Future<UserModel?> signInWithGoogle({required UserRole role}) async {
    _setLoading(true);
    _setError(null);
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _setError('Google sign-in cancelled');
        _setLoading(false);
        return null;
      }

      _currentGoogleUser = googleUser;

      // Obtain the auth details from the user
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the credential
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // Mark as verified (Google login is verified by default)
        _isVerified = true;

        // Create or update user in Firestore
        _currentUser = UserModel(
          uid: firebaseUser.uid,
          name: firebaseUser.displayName ?? 'User',
          email: firebaseUser.email ?? '',
          phone: firebaseUser.phoneNumber ?? '',
          role: role,
          profileImageUrl: firebaseUser.photoURL,
          isVerified: true, // Google login is verified
          createdAt: DateTime.now(),
        );

        // Save to Firestore
        await _db.collection('users').doc(firebaseUser.uid).set(
              _currentUser!.toMap(),
              SetOptions(merge: true),
            );

        _setLoading(false);
        notifyListeners();
        return _currentUser;
      }

      _setError('Failed to create Firebase user');
      _setLoading(false);
      return null;
    } on FirebaseAuthException catch (e) {
      _setError('Firebase auth error: ${e.message}');
      _setLoading(false);
      return null;
    } catch (e) {
      _setError('Google sign-in error: ${e.toString()}');
      _setLoading(false);
      return null;
    }
  }

  /// Verify Google account details
  Future<bool> verifyGoogleAccount() async {
    if (_currentGoogleUser == null) {
      _setError('No Google account connected');
      return false;
    }

    try {
      // Get verified email and profile info
      final email = _currentGoogleUser!.email;
      final displayName = _currentGoogleUser!.displayName;

      if (email.isEmpty || displayName == null || displayName.isEmpty) {
        _setError('Incomplete Google profile information');
        return false;
      }

      _isVerified = true;
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Verification failed: ${e.toString()}');
      return false;
    }
  }

  /// Get verified user info from Google
  Map<String, dynamic>? getVerifiedUserInfo() {
    if (!_isVerified || _currentGoogleUser == null) {
      return null;
    }

    return {
      'name': _currentGoogleUser!.displayName,
      'email': _currentGoogleUser!.email,
      'photoUrl': _currentGoogleUser!.photoUrl,
      'id': _currentGoogleUser!.id,
    };
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      _currentGoogleUser = null;
      _currentUser = null;
      _isVerified = false;
      notifyListeners();
    } catch (e) {
      _setError('Sign out error: ${e.toString()}');
    }
  }

  /// Check if already signed in
  Future<bool> isSignedIn() async {
    final isSignedIn = await _googleSignIn.isSignedIn();
    if (isSignedIn) {
      _currentGoogleUser = await _googleSignIn.signInSilently();
      return true;
    }
    return false;
  }
}
