import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color background = Color(0xFF0C0E16);
  static const Color surfaceLowest = Color(0xFF0C0E16);
  static const Color surfaceContainerLowest = Color(0xFF0C0E16);
  static const Color surfaceLow = Color(0xFF191B24);
  static const Color surfaceContainer = Color(0xFF1D1F28);
  static const Color surface = Color(0xFF1D1F28);
  static const Color surfaceHigh = Color(0xFF282A32);
  static const Color surfaceHighest = Color(0xFF33343E);
  static const Color surfaceBright = Color(0xFF373942);

  static const Color primary = Color(0xFFD0BCFF);
  static const Color primaryContainer = Color(0xFFA078FF);
  static const Color onPrimaryContainer = Color(0xFF340080);
  static const Color inversePrimary = Color(0xFF6D3BD7);

  static const Color secondary = Color(0xFF7BD0FF);
  static const Color secondaryFixed = Color(0xFFC4E7FF);
  static const Color secondaryContainer = Color(0xFF00A6E0);
  static const Color onSecondaryContainer = Color(0xFF00374D);

  static const Color tertiary = Color(0xFFFFB0CD);
  static const Color tertiaryContainer = Color(0xFFF751A1);
  static const Color onTertiaryContainer = Color(0xFF570032);

  static const Color onSurface = Color(0xFFE2E1EE);
  static const Color onSurfaceVariant = Color(0xFFCBC3D7);
  static const Color outline = Color(0xFF958EA0);
  static const Color outlineVariant = Color(0xFF494454);

  static const Color emeraldReady = Color(0xFF34D399);
  static const Color amberWarning = Color(0xFFF59E0B);
}

class AppGradients {
  static const LinearGradient primaryButton = LinearGradient(
    colors: [AppColors.primaryContainer, AppColors.inversePrimary, AppColors.secondary],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient focusRing = LinearGradient(
    colors: [AppColors.primaryContainer, AppColors.surfaceBright, AppColors.secondaryContainer],
  );

  static const RadialGradient ambientBloom1 = RadialGradient(
    center: Alignment(-0.64, -0.56),
    radius: 0.8,
    colors: [Color(0x2EA078FF), Color(0x000C0E16)],
  );

  static const RadialGradient ambientBloom2 = RadialGradient(
    center: Alignment(0.64, 0.4),
    radius: 0.75,
    colors: [Color(0x247BD0FF), Color(0x000C0E16)],
  );
}

class AppStyles {
  static TextStyle displayHero({Color color = AppColors.onSurface}) =>
      GoogleFonts.spaceGrotesk(
        fontSize: 64,
        fontWeight: FontWeight.bold,
        height: 1.15,
        letterSpacing: -1.0,
        color: color,
      );

  static TextStyle headlineXl({Color color = AppColors.onSurface}) =>
      GoogleFonts.spaceGrotesk(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        height: 1.2,
        letterSpacing: -0.5,
        color: color,
      );

  static TextStyle headlineLg({Color color = AppColors.onSurface}) =>
      GoogleFonts.spaceGrotesk(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        height: 1.25,
        color: color,
      );

  static TextStyle headlineMd({Color color = AppColors.onSurface}) =>
      GoogleFonts.spaceGrotesk(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        height: 1.3,
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

  static TextStyle bodyXl({Color color = AppColors.onSurfaceVariant}) =>
      GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        height: 1.35,
        color: color,
      );

  static TextStyle bodyLg({Color color = AppColors.onSurfaceVariant}) =>
      GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.normal,
        height: 1.4,
        color: color,
      );

  static TextStyle bodyMd({Color color = AppColors.onSurfaceVariant}) =>
      GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        height: 1.4,
        color: color,
      );

  static BoxDecoration focusSpotlightDecoration({Color glowColor = AppColors.secondary}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: glowColor.withValues(alpha: 0.45),
          blurRadius: 35,
          spreadRadius: 2,
        ),
        BoxShadow(
          color: AppColors.primaryContainer.withValues(alpha: 0.35),
          blurRadius: 45,
          spreadRadius: 4,
        ),
      ],
    );
  }
}
