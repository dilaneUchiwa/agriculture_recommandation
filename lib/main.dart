import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:agriculture_recommandation/controllers/homeController.dart';
import 'package:agriculture_recommandation/controllers/authController.dart';
import 'package:agriculture_recommandation/utils/message.dart';
import 'package:oktoast/oktoast.dart';
import 'package:agriculture_recommandation/routes/router.dart';
import 'package:agriculture_recommandation/services/utils/AuthManager.dart';
import 'package:agriculture_recommandation/themes/theme.dart';

/// Point d'entrée principal de l'application
/// Initialise Firebase, GetStorage et les contrôleurs globaux
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialisation de Firebase
    await Firebase.initializeApp();
    print('✅ Firebase initialisé avec succès');
    
    // Initialisation du stockage local
    await GetStorage.init();
    print('✅ GetStorage initialisé avec succès');
    
    // Initialisation des contrôleurs globaux
    _initializeGlobalControllers();
    
    runApp(const MyApp());
  } catch (e) {
    print('❌ Erreur lors de l\'initialisation: $e');
    // En cas d'erreur critique, on lance quand même l'app
    // mais avec des fonctionnalités limitées
    runApp(const MyApp());
  }
}

/// Initialise les contrôleurs globaux de l'application
void _initializeGlobalControllers() {
  try {
    // Gestionnaire d'authentification
    Get.put<AuthManager>(AuthManager(), permanent: true);
    print('✅ AuthManager initialisé');
    
    Get.put<Homecontroller>(Homecontroller(), permanent: true);
    
    // Contrôleur d'authentification
    Get.put<AuthController>(AuthController(), permanent: true);
    
    print('✅ Contrôleurs globaux initialisés');
  } catch (e) {
    print('⚠️ Erreur lors de l\'initialisation des contrôleurs: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Right Culture',
        theme: Themes.lightTheme,
        translations: Messages(),
        locale: const Locale('fr', 'FR'),
        fallbackLocale: const Locale('en', 'US'),
        initialRoute: '/splash',
        getPages: AppRouter.routes,
      ),
    );
  }
}