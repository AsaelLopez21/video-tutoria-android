import 'package:flutter/material.dart';
import 'app_colors.dart';

final ThemeData appTheme = ThemeData(
  primaryColor: AppColors.primaryDarkViolet,
  scaffoldBackgroundColor: Colors.transparent,
  fontFamily: 'Inter',
  colorScheme: ColorScheme.fromSwatch().copyWith(
    secondary: AppColors.lightViolet,
    primary: AppColors.primaryDarkViolet,
  ),
);
