import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase configuration for the application
/// Optimized for Android development with fallback support for other platforms
class FirebaseConfig {
  // Android configuration - Primary target platform
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDVoaANn8ZAfr5Bvcawp204s40y4B5BYfk',
    appId: '1:1012855690678:android:e537c4d07f9443d5db1d17',
    messagingSenderId: '1012855690678',
    projectId: 'test-firebase1-c4c79',
    storageBucket: 'test-firebase1-c4c79.firebasestorage.app',
    // Android specific configuration
    databaseURL: 'https://test-firebase1-c4c79-default-rtdb.firebaseio.com',
  );

  // iOS configuration - For future iOS support
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_STORAGE_BUCKET',
    iosClientId: 'YOUR_IOS_CLIENT_ID',
    iosBundleId: 'com.example.myFamilyMobileApp', // Update this to match your iOS bundle ID
    databaseURL: 'https://YOUR_PROJECT_ID-default-rtdb.firebaseio.com',
  );

  // Web configuration - For Firebase console and testing
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',
    appId: 'YOUR_WEB_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    authDomain: 'YOUR_PROJECT_ID.firebaseapp.com',
    storageBucket: 'YOUR_STORAGE_BUCKET',
    databaseURL: 'https://YOUR_PROJECT_ID-default-rtdb.firebaseio.com',
  );

  /// Returns Firebase options based on platform
  /// Optimized for Android as primary platform
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android; // Primary target
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return ios;
      // Fallback to Android configuration for other platforms during development
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      default:
        return android;
    }
  }

  /// Initialize Firebase with current platform configuration
  /// Includes error handling for Android development
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: currentPlatform,
      );
      if (kDebugMode) {
        print('✅ Firebase initialized successfully for ${defaultTargetPlatform.name}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Firebase initialization failed: $e');
        print('💡 Make sure you have:');
        print('   1. Added google-services.json to android/app/');
        print('   2. Updated firebase_config.dart with your project values');
        print('   3. Enabled Authentication in Firebase Console');
      }
      rethrow;
    }
  }

  /// Get Android application ID for Google Sign-In configuration
  static String get androidApplicationId => 'com.example.my_family_mobile_app';
  
  /// Get project-specific URLs
  static String get authDomain => '${currentPlatform.projectId}.firebaseapp.com';
  static String get databaseUrl => 'https://${currentPlatform.projectId}-default-rtdb.firebaseio.com';
}
