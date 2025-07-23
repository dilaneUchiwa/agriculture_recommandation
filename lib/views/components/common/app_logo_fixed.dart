import 'package:flutter/material.dart';
import 'package:agriculture_recommandation/themes/theme.dart';

/// Widget de logo pour l'application Right Culture
class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? backgroundColor;

  const AppLogo({
    Key? key,
    this.size = 100,
    this.showText = false,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (showText) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLogo(),
          const SizedBox(height: 12),
          Text(
            'Right Culture',
            style: TextStyle(
              fontSize: size * 0.15,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: 1.2,
            ),
          ),
        ],
      );
    } else {
      return _buildLogo();
    }
  }

  Widget _buildLogo() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.2),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.secondary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: size * 0.1,
            offset: Offset(0, size * 0.05),
          ),
        ],
      ),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size * 0.15),
          child: Image.asset(
            'assets/right_culture_logo.png',
            width: size * 0.7,
            height: size * 0.7,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // Fallback vers une icône si l'image ne se charge pas
              return Icon(
                Icons.agriculture,
                size: size * 0.5,
                color: Colors.white,
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Widget de logo avec texte complet
class AppLogoWithText extends StatelessWidget {
  final double logoSize;
  final double textSize;
  final bool isVertical;

  const AppLogoWithText({
    Key? key,
    this.logoSize = 80,
    this.textSize = 24,
    this.isVertical = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final logo = AppLogo(size: logoSize, showText: false);
    final text = Text(
      'Right Culture',
      style: TextStyle(
        fontSize: textSize,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
        letterSpacing: 1.2,
      ),
    );

    if (isVertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          logo,
          SizedBox(height: logoSize * 0.2),
          text,
        ],
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          logo,
          SizedBox(width: logoSize * 0.3),
          text,
        ],
      );
    }
  }
}
