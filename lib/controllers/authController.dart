import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:agriculture_recommandation/routes/appRoutes.dart';
import 'package:agriculture_recommandation/services/firebase_auth_service.dart';
import 'package:agriculture_recommandation/utils/storageConstant.dart';

/// Authentication management controller
/// Uses Firebase Authentication for all operations
class AuthController extends GetxController {
  // Text field controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final resetEmailController = TextEditingController();

  // Reactive states
  var isLoading = false.obs;
  var isPasswordVisible = false.obs;
  var isConfirmPasswordVisible = false.obs;
  var rememberMe = false.obs;
  var isLoginMode = true.obs; // true for login, false for registration
  var currentUser = Rxn<User>();

  // Form keys
  final loginFormKey = GlobalKey<FormState>();
  final registerFormKey = GlobalKey<FormState>();
  final resetFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    // Délayer l'écoute pour éviter l'erreur de navigation contextless
    Future.delayed(const Duration(milliseconds: 500), () {
      _listenToAuthChanges();
    });
  }

  /// Listen to authentication state changes
  void _listenToAuthChanges() {
    // Vérifier que GetX est prêt avant d'écouter les changements
    if (Get.isRegistered<GetMaterialController>()) {
      FirebaseAuthService.authStateChanges.listen((User? user) {
        currentUser.value = user;
        // if (user != null && user.emailVerified) {
        if (user != null && true) {
          // Utilisateur connecté et vérifié
          if (Get.currentRoute != AppRoutes.home) {
            Get.offAllNamed(AppRoutes.home);
          }
        } else if (user != null && !user.emailVerified) {
          // Email non vérifié
          if (Get.currentRoute != AppRoutes.emailVerification) {
            Get.offAllNamed(AppRoutes.emailVerification);
          }
        }
        // Ne pas rediriger vers auth si l'utilisateur est null
        // car cela pourrait être géré par le SplashScreen
      });
    }
  }

  /// Sign in with email and password
  Future<void> signInWithEmail() async {
    if (!loginFormKey.currentState!.validate()) return;

    isLoading.value = true;
    
    try {
      final user = await FirebaseAuthService.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (user != null) {
        _saveCredentialsIfRemembered();
        _clearFields();
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Register with email and password
  Future<void> registerWithEmail() async {
    if (!registerFormKey.currentState!.validate()) return;

    isLoading.value = true;
    
    try {
      final user = await FirebaseAuthService.registerWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
        confirmPassword: confirmPasswordController.text,
      );

      if (user != null) {
        _clearFields();
        // Redirect to email verification page
        Get.offAllNamed(AppRoutes.emailVerification);
        Get.offAllNamed(AppRoutes.home);
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    isLoading.value = true;
    
    try {
      final user = await FirebaseAuthService.signInWithGoogle();
      
      if (user != null) {
        _clearFields();
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Reset password
  Future<void> resetPassword() async {
    if (!resetFormKey.currentState!.validate()) return;

    isLoading.value = true;
    
    try {
      final success = await FirebaseAuthService.resetPassword(
        email: resetEmailController.text.trim(),
      );

      if (success) {
        Get.back(); // Close reset dialog
        resetEmailController.clear();
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    isLoading.value = true;
    
    try {
      await FirebaseAuthService.signOut();
    } finally {
      isLoading.value = false;
    }
  }

  /// Toggle between login and registration modes
  void toggleAuthMode() {
    isLoginMode.value = !isLoginMode.value;
    _clearFields();
  }

  /// Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  /// Toggle confirm password visibility
  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  /// Toggle remember me state
  void toggleRememberMe() {
    rememberMe.value = !rememberMe.value;
    GetStorage().write(StorageConstants.rememberMe, rememberMe.value);
  }

  /// Email validation
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'input.error_enter_email'.tr;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'input.error_invalid_email'.tr;
    }
    return null;
  }

  /// Password validation
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'input.error_enter_password'.tr;
    }
    if (value.length < 6) {
      return 'input.error_password_length'.tr;
    }
    if (isLoginMode.value) return null; // Simplified validation for login
    
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one digit';
    }
    return null;
  }

  /// Confirm password validation
  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'input.error_confirm_password'.tr;
    }
    if (value != passwordController.text) {
      return 'input.error_passwords_dont_match'.tr;
    }
    return null;
  }

  /// Load remember me state
  void _loadRememberMeState() {
    rememberMe.value = GetStorage().read(StorageConstants.rememberMe) ?? false;
    
    if (rememberMe.value) {
      final savedEmail = GetStorage().read(StorageConstants.savedEmail);
      if (savedEmail != null) {
        emailController.text = savedEmail;
      }
    }
  }

  /// Save credentials if remember me is enabled
  void _saveCredentialsIfRemembered() {
    if (rememberMe.value) {
      GetStorage().write(StorageConstants.savedEmail, emailController.text.trim());
    } else {
      GetStorage().remove(StorageConstants.savedEmail);
    }
  }

  /// Save user session
  void _saveUserSession(User user) {
    GetStorage().write(StorageConstants.loggedIn, true);
    GetStorage().write(StorageConstants.userId, user.uid);
    GetStorage().write(StorageConstants.userEmail, user.email);
  }

  /// Clear user session
  void _clearUserSession() {
    GetStorage().remove(StorageConstants.loggedIn);
    GetStorage().remove(StorageConstants.userId);
    GetStorage().remove(StorageConstants.userEmail);
  }

  /// Clear all fields
  void _clearFields() {
    if (!rememberMe.value) {
      emailController.clear();
    }
    passwordController.clear();
    confirmPasswordController.clear();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    resetEmailController.dispose();
    super.onClose();
  }
}
