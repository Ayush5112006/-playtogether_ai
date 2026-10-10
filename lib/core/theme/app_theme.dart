import 'package:flutter/material.dart';
import 'app_colors.dart';

export 'app_colors.dart';
export 'app_text_styles.dart';

class AppTheme {
  static ThemeData get tvDarkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.surfaceContainer,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.tertiary,
      ),
      useMaterial3: true,
    );
  }
}
