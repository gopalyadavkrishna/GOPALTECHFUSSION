import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract final class AppColors {
  static const primary = Color(0xFFFFB300);
  static const secondary = Color(0xFF1565C0);
  static const success = Color(0xFF00C853);
  static const warning = Color(0xFFFF6D00);
  static const error = Color(0xFFD50000);
  static const background = Color(0xFFF8FAFC);
  static const ink = Color(0xFF14213D);
}

final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);

class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  void setMode(ThemeMode mode) => state = mode;
}

abstract final class AppTheme {
  static ThemeData light() => _theme(Brightness.light, highContrast: false);

  static ThemeData dark() => _theme(Brightness.dark, highContrast: false);

  static ThemeData highContrastLight() =>
      _theme(Brightness.light, highContrast: true);

  static ThemeData highContrastDark() =>
      _theme(Brightness.dark, highContrast: true);

  static ThemeData _theme(Brightness brightness, {required bool highContrast}) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
      contrastLevel: highContrast ? 1 : 0,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      error: AppColors.error,
      surface: isDark ? const Color(0xFF121821) : Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark
          ? const Color(0xFF0B1017)
          : AppColors.background,
      textTheme: Typography.material2021().black.apply(
        bodyColor: isDark ? const Color(0xFFE7ECF3) : AppColors.ink,
        displayColor: isDark ? Colors.white : AppColors.ink,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark
            ? const Color(0xFF17202B).withValues(alpha: 0.92)
            : Colors.white.withValues(alpha: 0.94),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: highContrast
                ? scheme.onSurface
                : isDark
                ? Colors.white12
                : const Color(0xFFE7EBF0),
            width: highContrast ? 2 : 1,
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF17202B) : const Color(0xFFF1F5F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.secondary, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        indicatorColor: AppColors.primary.withValues(alpha: 0.22),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
      visualDensity: VisualDensity.standard,
    );
  }
}
