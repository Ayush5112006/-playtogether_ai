import 'package:flutter/material.dart';

class AppColors {
  // Master Prompt palette design tokens
  static const Color background = Color(0xFF0B0D14);
  static const Color surfaceLowest = Color(0xFF0B0D14);
  static const Color surfaceLow = Color(0xFF121522);
  static const Color surfaceContainer = Color(0xFF171B2B);
  static const Color surfaceHigh = Color(0xFF20263B);
  static const Color surfaceHighest = Color(0xFF2B324B);
  static const Color surfaceBright = Color(0xFF384161);

  static const Color primary = Color(0xFF7967FF);
  static const Color primaryContainer = Color(0xFF5B47F5);
  static const Color onPrimaryContainer = Color(0xFFE4E0FF);
  static const Color inversePrimary = Color(0xFF9D90FF);

  static const Color secondary = Color(0xFF00E5FF);
  static const Color secondaryContainer = Color(0xFF00B2CC);
  static const Color onSecondaryContainer = Color(0xFFE0FCFF);

  static const Color tertiary = Color(0xFFFF4081);
  static const Color tertiaryContainer = Color(0xFFD81B60);
  static const Color onTertiaryContainer = Color(0xFFFFE4EC);

  static const Color goldAccent = Color(0xFFFFC107);
  static const Color goldContainer = Color(0xFF997300);

  static const Color successGreen = Color(0xFF00E676);
  static const Color errorRed = Color(0xFFFF5252);

  static const Color onSurface = Color(0xFFF0F2FB);
  static const Color onSurfaceMuted = Color(0xFFA0A7C2);
  static const Color outline = Color(0xFF424B6B);
  static const Color outlineVariant = Color(0xFF2B324B);
}

class AppGradients {
  static const LinearGradient primaryButton = LinearGradient(
    colors: [AppColors.primary, AppColors.primaryContainer],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const RadialGradient ambientBloom1 = RadialGradient(
    center: Alignment(-0.6, -0.6),
    radius: 1.2,
    colors: [Color(0x337967FF), Colors.transparent],
  );
  static const RadialGradient ambientBloom2 = RadialGradient(
    center: Alignment(0.7, 0.7),
    radius: 1.2,
    colors: [Color(0x2200E5FF), Colors.transparent],
  );
}
