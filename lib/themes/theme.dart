import 'package:flutter/material.dart';

class AppColors {
  AppColors._();
  
  // Agricultural theme colors
  static const primary = Color(0xFF2E7D32); // Dark green for agriculture
  static const secondary = Color(0xFF4CAF50); // Lighter green
  static const tertiary = Color(0xFF8BC34A); // Light green
  static const accent = Color(0xFFFF9800); // Orange for harvest/sun
  
  static const accentColor = Color(0xFFE8F5E8);
  static const blueColor = Color(0xFF2280FF);
  static const blue2 = Color(0xFF004751);
  static const darkBlueColor = Color(0xFF0A2F61);
  static const buttonColor = Color(0xFF2E7D32);
  static const purple = Color(0xFFCABDFF);
  static const green = Color(0xFF4CAF50);

  static const cardColorLight = Colors.white;
  static const black = Color(0xFF1D1E25);
  static const black2 = Color(0xFF061423);
  static const fontColorLight = Color.fromARGB(255, 36, 30, 33);
  static const hintColor = Color(0xFF808D9E);
  static const greyColor3 = Color(0xFF7E8CA0);
  static const fontColorDarkTitle = Color(0xFF32353E);
  static const iconColorLight = Color.fromARGB(255, 36, 30, 33);

  static const whiteBackground = Color(0xFFF4F5F7);
  static const white = Colors.white;
  static const lightWhiteBackground = Color.fromARGB(255, 244, 244, 244);
  static const blackBackground = Color.fromARGB(255, 36, 30, 33);
  static const textBlackColor = Color.fromARGB(255, 29, 21, 3);
  static const textBlackColor1 = Color.fromARGB(255, 51, 51, 51);
  static const lightGreyColor = Color.fromARGB(255, 118, 120, 122);
  static const lightGreyColor1 = Color.fromARGB(255, 228, 229, 230);
  static final lightGreyColor2 = Color.fromARGB(255, 118, 118, 118);
  static final lightGreyColor3 = Color.fromARGB(255, 181, 181, 181);
  static final lightGreyColor4 = Color.fromARGB(255, 239, 239, 239);
  static final greyColor = Color.fromARGB(255, 102, 102, 102);
  static final greyColor1 = Color.fromARGB(255, 129, 129, 129);
  static final bottomBarDark = Color(0xFF202833);
  static final borderColor = Color.fromARGB(255, 219, 219, 219);
  static final borderColor1 = Color.fromARGB(255, 227, 227, 227);
  static final dividerColor = Color.fromARGB(255, 236, 236, 236);
  static final backgroundColor = Color.fromARGB(255, 228, 228, 228);
  static final backgroundColor1 = Color.fromARGB(255, 244, 242, 242);
  static final greyColor2 = Color.fromARGB(255, 226, 226, 226);
  static final greyColor4 = Color(0xFFF7F7F7);
  static final greyColor5 = Color(0xFFD9D9D9);
  static final greyColor6 = Color(0xFFD1D1D1);
  static final greyColor7 = Color(0xFFEEEEEE);
  static final yellow = Color(0xFFFECE20);

  static final navTextColor = Color.fromRGBO(118, 120, 122, 1);
}

class Themes {
  static final lightTheme = ThemeData(
    useMaterial3: false,
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    splashColor: AppColors.primary,
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: AppColors.primary,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 16,
      ),
      centerTitle: true,
    ),
    cardColor: AppColors.cardColorLight,
    canvasColor: Color(0xFFFFFFFF),
    scaffoldBackgroundColor: Color(0xFFF9F9F9),
    textSelectionTheme: TextSelectionThemeData(
        selectionColor: AppColors.fontColorLight,
        selectionHandleColor: AppColors.fontColorDarkTitle),
    dividerColor: AppColors.iconColorLight,
    hintColor: AppColors.hintColor,
    fontFamily: "Poppins",
    colorScheme: ThemeData().colorScheme.copyWith(
          secondary: AppColors.primary,
          primary: AppColors.primary,
        ),
    textTheme: TextTheme(
      headlineMedium: TextStyle(
        fontSize: 18,
        fontFamily: "Arial Bold",
        color: AppColors.textBlackColor,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: TextStyle(fontSize: 25, fontFamily: "Poppins Bold"),
      displayLarge: TextStyle(fontSize: 25, fontFamily: "Poppins Medium"),
      displayMedium: TextStyle(fontSize: 30, fontFamily: "Poppins"),
      bodyMedium: TextStyle(
          color: AppColors.black, fontFamily: "Poppins", fontSize: 15),
      bodyLarge: TextStyle(fontSize: 16, fontFamily: "Poppins"),
      titleMedium: TextStyle(fontSize: 16, fontFamily: "Poppins"),
      labelLarge: TextStyle(
        fontSize: 16,
        fontFamily: "Poppins",
        color: Colors.white,
      ),
      labelSmall: TextStyle(fontSize: 10, fontFamily: "Poppins"),
    ),
  );

  static final smallTextStyle =
      TextStyle(color: AppColors.primary, fontSize: 14, fontFamily: 'Poppins');

  static final largeTextStyle = TextStyle(
      color: AppColors.textBlackColor,
      fontSize: 24,
      fontFamily: 'Poppins Bold');

  static final labelStyle = Themes.smallTextStyle.merge(TextStyle(
    color: AppColors.textBlackColor1,
  ));
}
