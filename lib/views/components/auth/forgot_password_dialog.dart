import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agriculture_recommandation/controllers/authController.dart';
import 'package:agriculture_recommandation/themes/theme.dart';
import 'package:agriculture_recommandation/views/components/auth/auth_form_field.dart';
import 'package:agriculture_recommandation/views/components/auth/auth_button.dart';

/// Dialogue de réinitialisation du mot de passe
/// Interface moderne avec validation et feedback utilisateur
class ForgotPasswordDialog extends StatelessWidget {
  final AuthController authController;

  const ForgotPasswordDialog({
    Key? key,
    required this.authController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 16,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              AppColors.primary.withOpacity(0.02),
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildForm(context),
            const SizedBox(height: 24),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  /// En-tête du dialogue
  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(32),
          ),
          child: Icon(
            Icons.lock_reset,
            size: 32,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Mot de passe oublié ?',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Entrez votre adresse email et nous vous enverrons un lien pour réinitialiser votre mot de passe.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Formulaire de réinitialisation
  Widget _buildForm(BuildContext context) {
    return Form(
      key: authController.resetFormKey,
      child: AuthFormField(
        controller: authController.resetEmailController,
        hintText: 'Votre adresse email',
        prefixIcon: Icons.email_outlined,
        keyboardType: TextInputType.emailAddress,
        validator: authController.validateEmail,
        textInputAction: TextInputAction.done,
        onEditingComplete: () {
          if (authController.resetFormKey.currentState!.validate()) {
            authController.resetPassword();
          }
        },
      ),
    );
  }

  /// Actions du dialogue
  Widget _buildActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Obx(() => AuthButton(
          text: 'Envoyer le lien',
          onPressed: authController.resetPassword,
          isLoading: authController.isLoading.value,
          icon: Icons.send,
        )),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () {
            authController.resetEmailController.clear();
            Get.back();
          },
          child: Text(
            'Annuler',
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
