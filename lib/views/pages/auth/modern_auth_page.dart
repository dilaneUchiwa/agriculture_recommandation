import 'package:agriculture_recommandation/views/components/common/app_logo_fixed.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:lottie/lottie.dart';
import 'package:agriculture_recommandation/controllers/authController.dart';
import 'package:agriculture_recommandation/themes/theme.dart';
import 'package:agriculture_recommandation/views/components/auth/auth_form_field.dart';
import 'package:agriculture_recommandation/views/components/auth/auth_button.dart';
import 'package:agriculture_recommandation/views/components/auth/social_auth_button.dart';
import 'package:agriculture_recommandation/views/components/auth/forgot_password_dialog.dart';
import 'package:agriculture_recommandation/views/components/common/app_logo.dart';

/// Page d'authentification moderne avec Firebase
/// Gère la connexion, l'inscription et l'authentification Google
class ModernAuthPage extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());

  ModernAuthPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.1),
              AppColors.secondary.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 40),
                  _buildAuthCard(context),
                  const SizedBox(height: 24),
                  _buildFooter(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// En-tête avec logo et animation de texte
  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        // Logo avec animation
        Hero(
          tag: 'app_logo',
          child: AppLogo(
            size: 120,
            showText: true,
          ),
        ),
        const SizedBox(height: 24),
        // Titre animé
        // AnimatedTextKit(
        //   animatedTexts: [
        //     TyperAnimatedText(
        //       'app_name'.tr,
        //       textStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
        //         fontWeight: FontWeight.bold,
        //         color: AppColors.primary,
        //         letterSpacing: 1.2,
        //       ),
        //       speed: const Duration(milliseconds: 100),
        //     ),
        //   ],
        //   totalRepeatCount: 1,
        // ),
        const SizedBox(height: 8),
        Text(
          'app_tagline'.tr,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Carte d'authentification principale
  Widget _buildAuthCard(BuildContext context) {
    return Card(
      elevation: 8,
      shadowColor: AppColors.primary.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAuthToggle(context),
            const SizedBox(height: 32),
            _buildAuthForm(context),
            const SizedBox(height: 24),
            _buildSocialAuth(context),
          ],
        ),
      ),
    );
  }

  /// Boutons de basculement entre connexion et inscription
  Widget _buildAuthToggle(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Obx(() => GestureDetector(
              onTap: () {
                if (!authController.isLoginMode.value) {
                  authController.toggleAuthMode();
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: authController.isLoginMode.value
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: authController.isLoginMode.value
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  'Connexion',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: authController.isLoginMode.value
                        ? Colors.white
                        : Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )),
          ),
          Expanded(
            child: Obx(() => GestureDetector(
              onTap: () {
                if (authController.isLoginMode.value) {
                  authController.toggleAuthMode();
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !authController.isLoginMode.value
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: !authController.isLoginMode.value
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  'Inscription',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: !authController.isLoginMode.value
                        ? Colors.white
                        : Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )),
          ),
        ],
      ),
    );
  }

  /// Formulaire d'authentification
  Widget _buildAuthForm(BuildContext context) {
    return Obx(() => Form(
      key: authController.isLoginMode.value
          ? authController.loginFormKey
          : authController.registerFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Champ email
          AuthFormField(
            controller: authController.emailController,
            hintText: 'Adresse email',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: authController.validateEmail,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          
          // Champ mot de passe
          Obx(() => AuthFormField(
            controller: authController.passwordController,
            hintText: 'Mot de passe',
            prefixIcon: Icons.lock_outline,
            obscureText: !authController.isPasswordVisible.value,
            validator: authController.validatePassword,
            textInputAction: authController.isLoginMode.value
                ? TextInputAction.done
                : TextInputAction.next,
            suffixIcon: IconButton(
              icon: Icon(
                authController.isPasswordVisible.value
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: Colors.grey[600],
              ),
              onPressed: authController.togglePasswordVisibility,
            ),
          )),
          
          // Champ confirmation mot de passe (inscription uniquement)
          if (!authController.isLoginMode.value) ...[
            const SizedBox(height: 16),
            Obx(() => AuthFormField(
              controller: authController.confirmPasswordController,
              hintText: 'Confirmer le mot de passe',
              prefixIcon: Icons.lock_outline,
              obscureText: !authController.isConfirmPasswordVisible.value,
              validator: authController.validateConfirmPassword,
              textInputAction: TextInputAction.done,
              suffixIcon: IconButton(
                icon: Icon(
                  authController.isConfirmPasswordVisible.value
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: Colors.grey[600],
                ),
                onPressed: authController.toggleConfirmPasswordVisibility,
              ),
            )),
          ],
          
          // Se souvenir de moi (connexion uniquement)
          if (authController.isLoginMode.value) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Obx(() => Checkbox(
                  value: authController.rememberMe.value,
                  onChanged: (_) => authController.toggleRememberMe(),
                  activeColor: AppColors.primary,
                )),
                Flexible(
                  child: Text(
                    'Se souvenir de moi',
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: TextButton(
                    onPressed: () => _showForgotPasswordDialog(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Mot de passe oublié ?',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Bouton d'authentification principal
          Obx(() => AuthButton(
            text: authController.isLoginMode.value ? 'Se connecter' : 'S\'inscrire',
            isLoading: authController.isLoading.value,
            onPressed: authController.isLoginMode.value
                ? authController.signInWithEmail
                : authController.registerWithEmail,
          )),
        ],
      ),
    ));
  }

  /// Section d'authentification sociale
  Widget _buildSocialAuth(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey[300])),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'ou',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey[300])),
          ],
        ),
        const SizedBox(height: 24),
        
        // Bouton Google
        Obx(() => SocialAuthButton(
          text: authController.isLoginMode.value
              ? 'Continuer avec Google'
              : 'S\'inscrire avec Google',
          icon: 'assets/google_icon.png', // Vous devrez ajouter cette icône
          onPressed: authController.signInWithGoogle,
          isLoading: authController.isLoading.value,
        )),
      ],
    );
  }

  /// Pied de page
  Widget _buildFooter(BuildContext context) {
    return Column(
      children: [
        Text(
          'En continuant, vous acceptez nos',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                // Naviguer vers les conditions d'utilisation
              },
              child: Text(
                'Conditions d\'utilisation',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              ' et ',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            TextButton(
              onPressed: () {
                // Naviguer vers la politique de confidentialité
              },
              child: Text(
                'Politique de confidentialité',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Afficher le dialogue de réinitialisation du mot de passe
  void _showForgotPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ForgotPasswordDialog(
        authController: authController,
      ),
    );
  }
}
