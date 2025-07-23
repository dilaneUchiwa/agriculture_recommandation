import 'package:agriculture_recommandation/views/components/common/app_logo_fixed.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agriculture_recommandation/themes/theme.dart';
import 'package:agriculture_recommandation/views/components/common/app_logo.dart';
import 'package:agriculture_recommandation/controllers/homeController.dart';
import 'package:agriculture_recommandation/services/firebase_auth_service.dart';
import 'package:agriculture_recommandation/routes/appRoutes.dart';
import 'package:agriculture_recommandation/views/components/rotation/rotation_dialog.dart';
import 'package:agriculture_recommandation/views/components/home/recommendations_section.dart';

/// Page d'accueil principale de Right Culture
/// Affiche les recommandations agricoles, météo et informations utiles
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final Homecontroller homeController = Get.find<Homecontroller>();
    final User? currentUser = FirebaseAuthService.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(context, currentUser),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeSection(context, currentUser),
                const SizedBox(height: 24),
                const RecommendationsSection(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.toNamed(AppRoutes.recommendation);
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.agriculture, color: Colors.white),
        label: Text(
          'home.make_recommandation'.tr,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      // bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  /// Barre d'application avec logo et actions
  PreferredSizeWidget _buildAppBar(BuildContext context, User? user) {
    return AppBar(
      elevation: 0,



      backgroundColor: Colors.transparent,
      title: Row(
        children: [
          const AppLogo(size: 32, showText: false),
          const SizedBox(width: 12),
          Text(
            'app_name'.tr,
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            // Naviguer vers les notifications
          },
        ),
        PopupMenuButton<String>(
          icon: CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              user?.email?.substring(0, 1).toUpperCase() ?? 'U',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          onSelected: (value) {
            if (value == 'logout') {
              // _showLogoutDialog(context);
            } else if (value == 'profile') {
              // Naviguer vers le profil
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  const Icon(Icons.person_outline),
                  const SizedBox(width: 8),
                  Text('nav.profile'.tr),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  const Icon(Icons.logout),
                  const SizedBox(width: 8),
                  Text('profile.logout'.tr),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Section de bienvenue avec informations utilisateur
  Widget _buildWelcomeSection(BuildContext context, User? user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'home.welcome'.tr,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            user?.email ?? 'welcome_back'.tr,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.wb_sunny, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                '25°C • Ensoleillé',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

}