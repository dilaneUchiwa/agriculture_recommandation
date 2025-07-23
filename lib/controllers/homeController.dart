import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agriculture_recommandation/controllers/toastController.dart';
import 'package:agriculture_recommandation/domain/models/account.dart';
import 'package:agriculture_recommandation/domain/models/node.dart';
import 'package:agriculture_recommandation/routes/appRoutes.dart';
import 'package:agriculture_recommandation/services/utils/AuthManager.dart';
import 'package:agriculture_recommandation/services/firebase_auth_service.dart';
import 'package:agriculture_recommandation/utils/storageConstant.dart';

class Homecontroller extends GetxController {
  var hasConnection = true.obs;
  var previousConnection = false.obs;
  var currentBackPressTime = Rxn<DateTime>();
  var selectedNavIndex = 0.obs;
  var isLoading = false.obs;
  bool isChanged = false;
  final connectivity = Connectivity();

  // Informations utilisateur Firebase
  var currentUser = Rxn<User>();
  var userDisplayName = ''.obs;
  var userEmail = ''.obs;
  var userPhotoUrl = ''.obs;
  
  var account = Account(
    username: '',
    email: '',
    baseNode: BaseNode(
      id: 0,
      title: '',
      firstName: '',
      lastName: '',
      birthDate: DateTime.now(),
      gender: '',
      address: '',
      phone: '',
      interests: [],
      userId: 0,
      baseNode: false,
    ),
  ).obs;

  @override
  void onInit() async {
    super.onInit();
    _initializeUser();
    initData();
  }

  /// Initialiser les données utilisateur Firebase
  void _initializeUser() {
    currentUser.value = FirebaseAuthService.currentUser;
    if (currentUser.value != null) {
      userDisplayName.value = currentUser.value?.displayName ?? '';
      userEmail.value = currentUser.value?.email ?? '';
      userPhotoUrl.value = currentUser.value?.photoURL ?? '';
      
      // Écouter les changements d'état d'authentification
      FirebaseAuthService.authStateChanges.listen((User? user) {
        currentUser.value = user;
        if (user != null) {
          userDisplayName.value = user.displayName ?? '';
          userEmail.value = user.email ?? '';
          userPhotoUrl.value = user.photoURL ?? '';
        } else {
          // Utilisateur déconnecté, nettoyer les données
          _clearUserData();
          Get.offAllNamed(AppRoutes.modernAuth);
        }
      });
    }
  }

  /// Nettoyer les données utilisateur
  void _clearUserData() {
    userDisplayName.value = '';
    userEmail.value = '';
    userPhotoUrl.value = '';
    currentUser.value = null;
  }

  /// Déconnexion moderne avec Firebase
  Future<void> logoutUser([String? logoutMessage]) async {
    isLoading.value = true;
    
    try {
      // Enregistrer l'heure de déconnexion
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(now);
      GetStorage().write(StorageConstants.lastLoginTime, formattedDate);
      
      // Déconnexion Firebase
      await FirebaseAuthService.signOut();
      
      // Nettoyer le stockage local
      GetStorage().remove(StorageConstants.loggedIn);
      GetStorage().remove(StorageConstants.userId);
      GetStorage().remove(StorageConstants.userEmail);
      
      // Nettoyer les données utilisateur
      _clearUserData();
      
      // Afficher le message de déconnexion
      ToastController(
        title: 'Info',
        message: logoutMessage ?? 'logout_successful'.tr,
        type: ToastType.info,
      ).showToast();
      
      // Rediriger vers l'authentification
      Get.offAllNamed(AppRoutes.modernAuth);
      
    } catch (e) {
      ToastController(
        title: 'Erreur',
        message: 'Erreur lors de la déconnexion: ${e.toString()}',
        type: ToastType.error,
      ).showToast();
    } finally {
      isLoading.value = false;
    }
  }

  /// Méthode legacy pour compatibilité
  @deprecated
  void logoutUserLegacy(String logoutMessage) {
    var isLoggedIn = GetStorage().read(StorageConstants.loggedIn);
    isLoggedIn = isLoggedIn ?? false;
    if (isLoggedIn) {
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(now);
      GetStorage().write(StorageConstants.lastLoginTime, formattedDate);
      GetStorage().remove(StorageConstants.loggedIn);
      Get.find<AuthManager>().logout();
      ToastController(
              title: 'Info', message: logoutMessage, type: ToastType.info)
          .showToast();
      Get.offAllNamed(AppRoutes.modernAuth);
    }
  }

  Future<void> onRefresh() async {
    await resetState();
    initData();
  }

  void initData() async {
    var connectivityResult = await connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.mobile) {
      hasConnection(true);
    } else if (connectivityResult == ConnectivityResult.wifi) {
      hasConnection(true);
    } else {
      hasConnection(false);
    }
    // fetchuserProfile();
  }

  Future<Null> refreshHomePage() async {
    // Vérifier l'état d'authentification Firebase
    final user = FirebaseAuthService.currentUser;
    // if (user != null && user.emailVerified) {
    if (user != null && true) {
      // Utilisateur connecté et email vérifié
      // onRefreshBalance();
    } else if (user != null && !user.emailVerified) {
      // Email non vérifié, rediriger vers la vérification
      Get.offAllNamed(AppRoutes.emailVerification);
    } else {
      // Utilisateur non connecté
      logoutUser('logout_session_expired'.tr);
    }
  }
  
  Future<void> resetState() async {
    selectedNavIndex.value = 0;
    isChanged = false;
    hasConnection.value = true;
    previousConnection.value = false;
    currentBackPressTime.value = null;
  }

  /// Obtenir le nom d'affichage de l'utilisateur
  String getUserDisplayName() {
    if (userDisplayName.value.isNotEmpty) {
      return userDisplayName.value;
    } else if (userEmail.value.isNotEmpty) {
      return userEmail.value.split('@')[0];
    } else {
      return 'Utilisateur';
    }
  }

  /// Vérifier si l'utilisateur a une photo de profil
  bool hasUserPhoto() {
    return userPhotoUrl.value.isNotEmpty;
  }

  /// Obtenir l'URL de la photo de profil ou une valeur par défaut
  String getUserPhotoUrl() {
    return userPhotoUrl.value.isNotEmpty 
        ? userPhotoUrl.value 
        : 'https://via.placeholder.com/150x150.png?text=User';
  }
}
