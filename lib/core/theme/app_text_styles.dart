import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  static TextStyle heroTitle({Color color = AppColors.onSurface}) =>
      GoogleFonts.spaceGrotesk(
        fontSize: 64,
        fontWeight: FontWeight.bold,
        height: 1.1,
        letterSpacing: -1.2,
        color: color,
      );

  static TextStyle displayLg({Color color = AppColors.onSurface}) =>
      GoogleFonts.spaceGrotesk(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        height: 1.15,
        letterSpacing: -0.8,
        color: color,
      );

  static TextStyle headlineLg({Color color = AppColors.onSurface}) =>
      GoogleFonts.spaceGrotesk(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: color,
      );

  static TextStyle headlineMd({Color color = AppColors.onSurface}) =>
      GoogleFonts.spaceGrotesk(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        height: 1.25,
        color: color,
      );

  static TextStyle labelLg({Color color = AppColors.onSurface}) =>
      GoogleFonts.spaceGrotesk(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: color,
      );

  static TextStyle labelMd({Color color = AppColors.onSurface}) =>
      GoogleFonts.spaceGrotesk(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: color,
      );

  static TextStyle bodyXl({Color color = AppColors.onSurfaceMuted}) =>
      GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        height: 1.35,
        color: color,
      );

  static TextStyle bodyLg({Color color = AppColors.onSurfaceMuted}) =>
      GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.normal,
        height: 1.4,
        color: color,
      );

  static TextStyle bodyMd({Color color = AppColors.onSurfaceMuted}) =>
      GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        height: 1.4,
        color: color,
      );
}
