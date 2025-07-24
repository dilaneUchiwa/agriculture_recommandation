import 'package:agriculture_recommandation/routes/appRoutes.dart';
import 'package:agriculture_recommandation/utils/storageConstant.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agriculture_recommandation/services/firebase_auth_service.dart';

class SplashController extends GetxController {
  var isLoading = true.obs;
  var progress = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  /// Initialize application with Firebase verification
  Future<void> _initializeApp() async {
    try {
      // Simulate loading with progress animation
      await _updateProgress(0.2);
      
      // Check Firebase authentication state
      await _updateProgress(0.5);
      final user = FirebaseAuthService.currentUser;
      
      await _updateProgress(0.8);
      
      // Wait minimum delay for animation
      await Future.delayed(const Duration(milliseconds: 500));
      await _updateProgress(1.0);
      
      // Route user based on authentication state
      _routeUser(user);
      
    } catch (e) {
      print('Initialization error: $e');
      // In case of error, redirect to authentication
      Get.offAllNamed(AppRoutes.modernAuth);
    } finally {
      isLoading.value = false;
    }
  }

  /// Update progress with animation
  Future<void> _updateProgress(double newProgress) async {
    progress.value = newProgress;
    await Future.delayed(const Duration(milliseconds: 300));
  }

  /// Route user based on Firebase authentication state
  void _routeUser(User? user) {
    if (user != null) {
      // User is signed in
      if (user.emailVerified || true ) {
        // Email verified, go to home
        Get.offAllNamed(AppRoutes.home);
      } else {
        // Email not verified, go to verification page
        Get.offAllNamed(AppRoutes.home);
      }
    } else {
      // User not signed in, go to authentication
      Get.offAllNamed(AppRoutes.modernAuth);
    }
  }

  /// Legacy method for compatibility
  @deprecated
  startTime() async {
    return Timer(const Duration(seconds: 3, milliseconds: 0), () => _routeUser(null));
  }

  /// Legacy method for compatibility
  @deprecated
  void routeUser() async {
    final isLoggedIn = GetStorage().read(StorageConstants.loggedIn) ?? false;
    Get.offNamed(isLoggedIn ? AppRoutes.home : AppRoutes.modernAuth);
  }

  @override
  void onClose() {
    super.onClose();
  }
}
