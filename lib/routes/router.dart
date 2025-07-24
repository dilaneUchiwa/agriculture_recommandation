import 'package:get/get.dart';
import 'package:agriculture_recommandation/routes/appRoutes.dart';
import 'package:agriculture_recommandation/views/pages/homePage.dart';
import 'package:agriculture_recommandation/views/pages/splashScreen.dart';
import 'package:agriculture_recommandation/views/pages/auth/modern_auth_page.dart';
import 'package:agriculture_recommandation/views/pages/auth/email_verification_page.dart';
import 'package:agriculture_recommandation/views/pages/rotation/recommendation_page.dart';
import 'package:agriculture_recommandation/views/pages/rotation/recommendation_details_page.dart';

class AppRouter {
  static final routes = [
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
      // binding: HomeBinding(),
    ),
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
    // Nouvelles routes d'authentification Firebase
    GetPage(
      name: AppRoutes.modernAuth,
      page: () => ModernAuthPage(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const EmailVerificationPage(),
    ),
    // Routes pour les recommandations
    GetPage(
      name: AppRoutes.recommendation,
      page: () => const RecommendationPage(),
    ),
    GetPage(
      name: AppRoutes.recommendationDetails,
      page: () => const RecommendationDetailsPage(),
    ),
  ];
}
