import 'package:flutter/material.dart';

/// Workshop-ledger palette: paper and graphite, one signal colour for the
/// action that matters. Every screen reads colours from here (via
/// `context.colors`) instead of hard-coding hex values — see the lint note
/// in `app_theme.dart`.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.paper,
    required this.ink,
    required this.rules,
    required this.muted,
    required this.signal,
    required this.onSignal,
    required this.surfaceAlt,
    required this.danger,
  });

  /// Page background.
  final Color paper;

  /// Primary text.
  final Color ink;

  /// Hairline dividers between ledger rows.
  final Color rules;

  /// Secondary / caption text.
  final Color muted;

  /// The one signal colour: the main action and the live job.
  final Color signal;

  /// Text/icon colour drawn on top of [signal].
  final Color onSignal;

  /// A slightly offset surface for cards sitting on [paper] (e.g. the active
  /// job block, bottom sheets).
  final Color surfaceAlt;

  /// Reserved for destructive actions and hard failures only — never for
  /// decoration.
  final Color danger;

  static const light = AppColors(
    paper: Color(0xFFF3F1EC),
    ink: Color(0xFF1B1A17),
    rules: Color(0xFFD9D5CC),
    muted: Color(0xFF6B675F),
    signal: Color(0xFFE4572E),
    onSignal: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFEAE7DF),
    danger: Color(0xFFB3261E),
  );

  static const dark = AppColors(
    paper: Color(0xFF141413),
    ink: Color(0xFFECE9E2),
    rules: Color(0xFF2E2D29),
    muted: Color(0xFFA6A299),
    signal: Color(0xFFE4572E),
    onSignal: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFF1C1B19),
    danger: Color(0xFFE5887A),
  );

  @override
  AppColors copyWith({
    Color? paper,
    Color? ink,
    Color? rules,
    Color? muted,
    Color? signal,
    Color? onSignal,
    Color? surfaceAlt,
    Color? danger,
  }) {
    return AppColors(
      paper: paper ?? this.paper,
      ink: ink ?? this.ink,
      rules: rules ?? this.rules,
      muted: muted ?? this.muted,
      signal: signal ?? this.signal,
      onSignal: onSignal ?? this.onSignal,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      danger: danger ?? this.danger,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      paper: Color.lerp(paper, other.paper, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      rules: Color.lerp(rules, other.rules, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      signal: Color.lerp(signal, other.signal, t)!,
      onSignal: Color.lerp(onSignal, other.onSignal, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }
}

extension AppColorsContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
