import 'package:flutter/material.dart';

abstract class AppColors {
  // Primary Palette (Violeta/Índigo oscuro)
  static const Color primary = Color(0xFF7C4DFF);
  static const Color primaryLight = Color(0xFF9E77FF);
  static const Color primaryDark = Color(0xFF5C35CC);

  // Accent (Turquesa/Cian vibrante)
  static const Color accent = Color(0xFF00E5CC);
  static const Color accentLight = Color(0xFF64FFDA);

  // Backgrounds (Dark mode base)
  static const Color bgDark = Color(0xFF0D0D1A);
  static const Color bgCard = Color(0xFF161629);
  static const Color bgCardLight = Color(0xFF1E1E38);
  static const Color bgSurface = Color(0xFF12121F);

  // Text
  static const Color textPrimary = Color(0xFFF0F0FF);
  static const Color textSecondary = Color(0xFF9898B8);
  static const Color textHint = Color(0xFF5A5A7A);

  // Semantic colors
  static const Color success = Color(0xFF00C896);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFFF4B6E);
  static const Color info = Color(0xFF40C4FF);

  // Category colors
  static const Color catSchool = Color(0xFF7C4DFF);
  static const Color catWork = Color(0xFF00B0FF);
  static const Color catHealth = Color(0xFF00E676);
  static const Color catPersonal = Color(0xFFFF6D00);
  static const Color catFinance = Color(0xFFFFD740);

  // Feature colors
  static const Color catTasks = Color(0xFF4FC3F7); // Azul cielo
  static const Color catHabits = Color(0xFF00E5CC); // Turquesa (accent)

  // Glassmorphism
  static Color glassWhite = Colors.white.withValues(alpha: 0.07);
  static Color glassBorder = Colors.white.withValues(alpha: 0.12);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF7C4DFF), Color(0xFF00E5CC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [Color(0xFF0D0D1A), Color(0xFF0A0A22)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient morningGradient = LinearGradient(
    colors: [Color(0xFF1A0533), Color(0xFF0D2B6B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient afternoonGradient = LinearGradient(
    colors: [Color(0xFF0D1B38), Color(0xFF1A0D38)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient eveningGradient = LinearGradient(
    colors: [Color(0xFF1A0D1A), Color(0xFF0D0D1A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
