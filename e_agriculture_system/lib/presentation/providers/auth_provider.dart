import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/services/firebase_service.dart';
import '../../data/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseService _firebaseService = FirebaseService();

  User? _user;
  UserModel? _userModel;
  bool _isLoading = false;
  String? _errorMessage;
  
  // OTP verification properties
  String? _verificationId;
  String? _phoneNumber;
  Map<String, dynamic>? _pendingUserData;
  bool _isOtpSent = false;
  bool _isOtpVerified = false;

  // Getters
  User? get user => _user;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  bool get isOtpSent => _isOtpSent;
  bool get isOtpVerified => _isOtpVerified;
  String? get phoneNumber => _phoneNumber;

  // Role-based access control getters
  bool get isFarmer => _userModel?.isFarmer ?? false;
  bool get isBuyer => _userModel?.isBuyer ?? false;
  bool get isExpert => _userModel?.isExpert ?? false;
  bool get isAdmin => _userModel?.isAdmin ?? false;

  // Permission getters
  bool get canAccessFarmerDashboard => _userModel?.canAccessFarmerDashboard() ?? false;
  bool get canAccessBuyerDashboard => _userModel?.canAccessBuyerDashboard() ?? false;
  bool get canSellProducts => _userModel?.canSellProducts() ?? false;
  bool get canBuyProducts => _userModel?.canBuyProducts() ?? false;

  // Constructor
  AuthProvider() {
    try {
      _auth.authStateChanges().listen(_onAuthStateChanged);
    } catch (e) {
      debugPrint('Error setting up auth state listener: $e');
      // Continue without auth state changes if Firebase fails
    }
  }

  void _onAuthStateChanged(User? user) {
    try {
      _user = user;
      if (user != null) {
        _loadUserModel();
      } else {
        _userModel = null;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error in auth state change: $e');
    }
  }

  Future<void> _loadUserModel() async {
    if (_user != null) {
      try {
        _userModel = await _firebaseService.getUser(_user!.uid);
        notifyListeners();
      } catch (e) {
        debugPrint('Error loading user model: $e');
      }
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await _loadUserModel();
        _setLoading(false);
        return true;
      }
    } on FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e.code));
    } catch (e) {
      _setError('An unexpected error occurred');
    }

    _setLoading(false);
    return false;
  }

  // Register with role selection
  Future<bool> register({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
    required String userType, // 'farmer' or 'buyer'
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Validate user type
      if (userType != 'farmer' && userType != 'buyer') {
        throw Exception('Invalid user type. Must be either "farmer" or "buyer"');
      }

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Create user model with specified role
        final userModel = UserModel(
          id: credential.user!.uid,
          fullName: fullName,
          email: email,
          phoneNumber: phoneNumber,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          userType: userType, // Set the user type
        );

        // Save to Firestore
        await _firebaseService.createUser(userModel);

        // Send email verification
        await credential.user!.sendEmailVerification();

        _userModel = userModel;
        _setLoading(false);
        return true;
      }
    } on FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e.code));
    } catch (e) {
      _setError('An unexpected error occurred during registration: $e');
    }

    _setLoading(false);
    return false;
  }

  // Update user role (admin only)
  Future<bool> updateUserRole(String userId, String newRole) async {
    try {
      if (!isAdmin) {
        throw Exception('Only administrators can update user roles');
      }

      if (newRole != 'farmer' && newRole != 'buyer' && newRole != 'expert' && newRole != 'admin') {
        throw Exception('Invalid role. Must be farmer, buyer, expert, or admin');
      }

      await _firebaseService.updateUser(userId, {'userType': newRole});
      
      // If updating current user, reload the model
      if (userId == _user?.uid) {
        await _loadUserModel();
      }
      
      return true;
    } catch (e) {
      _setError('Failed to update user role: $e');
      return false;
    }
  }

  // Switch user role (for users with multiple roles)
  Future<bool> switchUserRole(String newRole) async {
    try {
      if (_userModel == null) {
        throw Exception('No user logged in');
      }

      // Check if user can switch to the new role
      if (newRole == 'farmer' && !canAccessFarmerDashboard) {
        throw Exception('User does not have permission to access farmer dashboard');
      }
      
      if (newRole == 'buyer' && !canAccessBuyerDashboard) {
        throw Exception('User does not have permission to access buyer dashboard');
      }

      // Update the user model with the new active role
      // This could be implemented as a temporary role switch or preference
      // For now, we'll just validate the permission
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to switch user role: $e');
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _auth.signOut();
      _userModel = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error during logout: $e');
    }
  }

  // Reset Password
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await _auth.sendPasswordResetEmail(email: email);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e.code));
    }

    _setLoading(false);
    return false;
  }

  // Update Profile
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _setLoading(true);
    _clearError();

    try {
      if (_userModel == null) {
        throw Exception('No user logged in');
      }

      // Update user model
      final updatedUserModel = _userModel!.copyWith(
        fullName: data['fullName'],
        phoneNumber: data['phoneNumber'],
        location: data['location'],
        latitude: data['latitude']?.toDouble(),
        longitude: data['longitude']?.toDouble(),
        updatedAt: DateTime.now(),
      );

      // Save to Firestore
      await _firebaseService.updateUser(_userModel!.id, updatedUserModel.toMap());
      
      _userModel = updatedUserModel;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update profile: $e');
      _setLoading(false);
      return false;
    }
  }

  // Phone Authentication Methods
  Future<void> sendOTP(String phoneNumber) async {
    _setLoading(true);
    _clearError();

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification if possible
          try {
            await _auth.signInWithCredential(credential);
            _isOtpVerified = true;
            notifyListeners();
          } catch (e) {
            _setError('Auto-verification failed: $e');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          _setError(_getAuthErrorMessage(e.code));
          _setLoading(false);
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _phoneNumber = phoneNumber;
          _isOtpSent = true;
          _setLoading(false);
          notifyListeners();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      _setError('Failed to send OTP: $e');
      _setLoading(false);
    }
  }

  Future<bool> verifyOTP(String otp) async {
    if (_verificationId == null) {
      _setError('No OTP sent. Please send OTP first.');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      await _auth.signInWithCredential(credential);
      _isOtpVerified = true;
      _setLoading(false);
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getAuthErrorMessage(e.code));
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Failed to verify OTP: $e');
      _setLoading(false);
      return false;
    }
  }

  // Helper Methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'invalid-verification-code':
        return 'Invalid verification code. Please try again.';
      case 'invalid-verification-id':
        return 'Invalid verification ID. Please request a new OTP.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  // Clear OTP state
  void clearOTPState() {
    _verificationId = null;
    _phoneNumber = null;
    _isOtpSent = false;
    _isOtpVerified = false;
    notifyListeners();
  }

  Future verifyOtpAndRegister(String otp) async {}

  Future resendOtp() async {}

  void cancelOtpVerification() {}
}
