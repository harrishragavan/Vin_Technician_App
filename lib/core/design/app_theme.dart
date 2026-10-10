import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// The app's only theme module. Feature code must read colours and text
/// styles from `context.colors` (see `app_colors.dart`) and `AppTypography`
/// rather than hard-coding hex values or font sizes — Material's default
/// look (indigo seed colours, elevation shadows, filled pill badges) is
/// switched off everywhere below.
class AppTheme {
  const AppTheme._();

  static ThemeData light() => _build(AppColors.light, Brightness.light);

  static ThemeData dark() => _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColors palette, Brightness brightness) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: palette.signal,
      onPrimary: palette.onSignal,
      secondary: palette.signal,
      onSecondary: palette.onSignal,
      error: palette.danger,
      onError: palette.onSignal,
      surface: palette.paper,
      onSurface: palette.ink,
      surfaceContainerHighest: palette.surfaceAlt,
      outline: palette.rules,
    );

    final textTheme = AppTypography.textTheme(palette.ink, palette.muted);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: palette.paper,
      canvasColor: palette.paper,
      fontFamily: 'Instrument Sans',
      textTheme: textTheme,
      dividerTheme: DividerThemeData(
        color: palette.rules,
        thickness: AppSpacing.hairline,
        space: AppSpacing.hairline,
      ),
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: palette.paper,
        foregroundColor: palette.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTypography.heading.copyWith(color: palette.ink),
      ),
      cardTheme: CardThemeData(
        color: palette.paper,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: palette.rules),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: palette.signal,
          foregroundColor: palette.onSignal,
          minimumSize: const Size.fromHeight(AppSpacing.minTouchTarget),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          textStyle: AppTypography.bodyStrong,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.ink,
          side: BorderSide(color: palette.rules),
          minimumSize: const Size.fromHeight(AppSpacing.minTouchTarget),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          textStyle: AppTypography.bodyStrong,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.signal,
          textStyle: AppTypography.bodyStrong,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surfaceAlt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: palette.rules),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: palette.rules),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: palette.signal, width: 2),
        ),
        labelStyle: AppTypography.body.copyWith(color: palette.muted),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.ink,
        contentTextStyle: AppTypography.body.copyWith(color: palette.paper),
        behavior: SnackBarBehavior.floating,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        },
      ),
      extensions: [palette],
    );
  }
}
