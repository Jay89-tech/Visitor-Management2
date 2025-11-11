import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import '../models/visitor_model.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseService _firebaseService;

  User? _currentUser;
  VisitorModel? _visitorProfile;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider(this._firebaseService) {
    _initializeAuth();
  }

  // Getters
  User? get currentUser => _currentUser;
  VisitorModel? get visitorProfile => _visitorProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  void _initializeAuth() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _currentUser = user;
      if (user != null) {
        _loadVisitorProfile(user.uid);
      } else {
        _visitorProfile = null;
      }
      notifyListeners();
    });
  }

  Future<bool> checkAuthState() async {
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      await _loadVisitorProfile(_currentUser!.uid);
      return true;
    }
    return false;
  }

  Future<void> _loadVisitorProfile(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('visitors')
          .doc(userId)
          .get();

      if (doc.exists) {
        _visitorProfile = VisitorModel.fromFirestore(doc);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading visitor profile: $e');
    }
  }

  // Sign Up
  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String company,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Create Firebase Auth user
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create visitor profile in Firestore
      final visitor = VisitorModel(
        id: userCredential.user!.uid,
        email: email,
        fullName: fullName,
        phone: phone,
        company: company,
        photoUrl: null,
        fcmToken: await _firebaseService.getFCMToken(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('visitors')
          .doc(visitor.id)
          .set(visitor.toMap());

      // Update display name
      await userCredential.user!.updateDisplayName(fullName);

      _currentUser = userCredential.user;
      _visitorProfile = visitor;
      _isLoading = false;
      notifyListeners();

      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getAuthErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign In
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _currentUser = userCredential.user;
      await _loadVisitorProfile(userCredential.user!.uid);

      // Update FCM token
      final fcmToken = await _firebaseService.getFCMToken();
      if (fcmToken != null) {
        await updateFCMToken(fcmToken);
      }

      _isLoading = false;
      notifyListeners();

      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getAuthErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      _currentUser = null;
      _visitorProfile = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }

  // Reset Password
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getAuthErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update Profile
  Future<bool> updateProfile({
    String? fullName,
    String? phone,
    String? company,
    String? photoUrl,
  }) async {
    if (_currentUser == null || _visitorProfile == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (fullName != null) updates['fullName'] = fullName;
      if (phone != null) updates['phone'] = phone;
      if (company != null) updates['company'] = company;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;

      await FirebaseFirestore.instance
          .collection('visitors')
          .doc(_currentUser!.uid)
          .update(updates);

      // Update display name in Auth
      if (fullName != null) {
        await _currentUser!.updateDisplayName(fullName);
      }

      await _loadVisitorProfile(_currentUser!.uid);
      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = 'Failed to update profile';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update FCM Token
  Future<void> updateFCMToken(String token) async {
    if (_currentUser == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('visitors')
          .doc(_currentUser!.uid)
          .update({
        'fcmToken': token,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating FCM token: $e');
    }
  }

  // Clear Error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
