import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';
import 'package:agriculture_recommandation/controllers/toastController.dart';

/// Firebase Authentication Service
/// Handles all authentication operations for the application
class FirebaseAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Currently signed in user
  static User? get currentUser => _auth.currentUser;

  /// Stream of authentication state changes
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign in with email and password
  ///
  /// [email] - User's email address
  /// [password] - User's password
  ///
  /// Returns [User?] if sign in succeeds, null otherwise
  static Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Input validation
      if (!_isValidEmail(email)) {
        ToastController(
          title: 'error.authentication'.tr,
          message: 'input.error_invalid_email'.tr,
          type: ToastType.error,
        ).showToast();
        return null;
      }
      if (!_isValidPassword(password)) {
        ToastController(
          title: 'error.authentication'.tr,
          message: 'input.error_password_length'.tr,
          type: ToastType.error,
        ).showToast();
        return null;
      }

      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      ToastController(
        title: 'success.login'.tr,
        message: 'logged_in_successfully'.tr,
        type: ToastType.success,
      ).showToast();

      return credential.user;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return null;
    } catch (e) {
      ToastController(
        title: 'error.authentication'.tr,
        message: 'error.general'.tr,
        type: ToastType.error,
      ).showToast();
      print('Sign in error: $e');
      return null;
    }
  }

  /// Register with email and password
  /// 
  /// [email] - User's email address
  /// [password] - User's password
  /// [confirmPassword] - Password confirmation
  /// 
  /// Returns [User?] if registration succeeds, null otherwise
  static Future<User?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      // Input validation
      if (!_isValidEmail(email)) {
        ToastController(
          title: 'error.authentication'.tr,
          message: 'input.error_invalid_email'.tr,
          type: ToastType.error,
        ).showToast();
        return null;
      }

      if (!_isValidPassword(password)) {
        ToastController(
          title: 'error.authentication'.tr,
          message: 'Password must contain at least 6 characters, one uppercase letter and one digit',
          type: ToastType.error,
        ).showToast();
        return null;
      }

      if (password != confirmPassword) {
        ToastController(
          title: 'error.authentication'.tr,
          message: 'input.error_passwords_dont_match'.tr,
          type: ToastType.error,
        ).showToast();
        return null;
      }

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Send email verification
      await credential.user?.sendEmailVerification();

      ToastController(
        title: 'success.registration'.tr,
        message: 'Account created! Check your email to activate your account.',
        type: ToastType.success,
      ).showToast();

      return credential.user;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return null;
    } catch (e) {
      ToastController(
        title: 'Error',
        message: 'An unexpected error occurred',
        type: ToastType.error,
      ).showToast();
      print('Registration error: $e');
      return null;
    }
  }

  /// Sign in with Google
  /// 
  /// Returns [User?] if sign in succeeds, null otherwise
  static Future<User?> signInWithGoogle() async {
    try {
      // Trigger the Google authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User cancelled the sign-in
        ToastController(
          title: 'login.google'.tr,
          message: 'Sign-in cancelled',
          type: ToastType.info,
        ).showToast();
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      final userCredential = await _auth.signInWithCredential(credential);

      ToastController(
        title: 'success.login'.tr,
        message: 'account_linked_successfully'.tr,
        type: ToastType.success,
      ).showToast();

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return null;
    } catch (e) {
      ToastController(
        title: 'error.authentication'.tr,
        message: 'Error during Google sign-in',
        type: ToastType.error,
      ).showToast();
      print('Google sign-in error: $e');
      return null;
    }
  }

  /// Password reset
  /// 
  /// [email] - User's email address
  static Future<bool> resetPassword({required String email}) async {
    try {
      if (!_isValidEmail(email)) {
        ToastController(
          title: 'error.authentication'.tr,
          message: 'input.error_invalid_email'.tr,
          type: ToastType.error,
        ).showToast();
        return false;
      }

      await _auth.sendPasswordResetEmail(email: email.trim());

      ToastController(
        title: 'success.email_sent'.tr,
        message: 'password_reset.email_sent'.tr,
        type: ToastType.success,
      ).showToast();

      return true;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return false;
    } catch (e) {
      ToastController(
        title: 'error.authentication'.tr,
        message: 'error.general'.tr,
        type: ToastType.error,
      ).showToast();
      print('Password reset error: $e');
      return false;
    }
  }

  /// Sign out
  static Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);

      ToastController(
        title: 'Information',
        message: 'Sign out successful',
        type: ToastType.info,
      ).showToast();
    } catch (e) {
      print('Sign out error: $e');
    }
  }

  /// Delete user account
  static Future<bool> deleteAccount() async {
    try {
      await currentUser?.delete();
      await _googleSignIn.signOut();

      ToastController(
        title: 'Information',
        message: 'Account deleted successfully',
        type: ToastType.info,
      ).showToast();

      return true;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return false;
    } catch (e) {
      ToastController(
        title: 'Error',
        message: 'Error deleting account',
        type: ToastType.error,
      ).showToast();
      print('Account deletion error: $e');
      return false;
    }
  }

  /// Email address validation
  static bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Password validation
  static bool _isValidPassword(String password) {
    // At least 6 characters, one uppercase letter and one digit
    return password.length >= 6 &&
           RegExp(r'[A-Z]').hasMatch(password) &&
           RegExp(r'[0-9]').hasMatch(password);
  }

  /// Firebase Auth error handling with translations
  static void _handleAuthError(FirebaseAuthException e) {
    String message;
    
    switch (e.code) {
      case 'user-not-found':
        message = 'No user found with this email address.';
        break;
      case 'wrong-password':
        message = 'error.invalid_credentials'.tr;
        break;
      case 'email-already-in-use':
        message = 'This email address is already in use.';
        break;
      case 'weak-password':
        message = 'The password is too weak.';
        break;
      case 'invalid-email':
        message = 'input.error_invalid_email'.tr;
        break;
      case 'user-disabled':
        message = 'This account has been disabled.';
        break;
      case 'too-many-requests':
        message = 'Too many attempts. Please try again later.';
        break;
      case 'operation-not-allowed':
        message = 'This sign-in method is not enabled.';
        break;
      case 'requires-recent-login':
        message = 'Please sign in again to perform this action.';
        break;
      default:
        message = 'error.authentication'.tr + ': ${e.message}';
    }

    ToastController(
      title: 'error.authentication'.tr,
      message: message,
      type: ToastType.error,
    ).showToast();

    print('Firebase Auth error [${e.code}]: ${e.message}');
  }
}
