import 'package:flutter/material.dart';

/// Four sizes, hierarchy by size and weight — never grey-on-grey. Body text
/// uses Instrument Sans; ticket ids, OTP digits, times and coordinates use
/// IBM Plex Mono with tabular figures so columns of numbers line up.
class AppTypography {
  const AppTypography._();

  static const _sans = 'Instrument Sans';
  static const _mono = 'IBM Plex Mono';

  /// Section titles, the active job's ticket id.
  static const TextStyle title = TextStyle(
    fontFamily: _sans,
    fontSize: 28,
    height: 1.2,
    fontWeight: FontWeight.w600,
  );

  /// Screen headings, card titles.
  static const TextStyle heading = TextStyle(
    fontFamily: _sans,
    fontSize: 20,
    height: 1.25,
    fontWeight: FontWeight.w600,
  );

  /// Default body text.
  static const TextStyle body = TextStyle(
    fontFamily: _sans,
    fontSize: 15,
    height: 1.4,
    fontWeight: FontWeight.w400,
  );

  /// Emphasised body text (row primary values, action labels).
  static const TextStyle bodyStrong = TextStyle(
    fontFamily: _sans,
    fontSize: 15,
    height: 1.4,
    fontWeight: FontWeight.w600,
  );

  /// Captions, muted secondary lines, status words.
  static const TextStyle caption = TextStyle(
    fontFamily: _sans,
    fontSize: 12,
    height: 1.35,
    fontWeight: FontWeight.w400,
  );

  /// Ticket ids, OTP cells, clocks, GPS coordinates — tabular figures so
  /// digits never shift width as they change.
  static const TextStyle mono = TextStyle(
    fontFamily: _mono,
    fontSize: 15,
    height: 1.3,
    fontWeight: FontWeight.w500,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Large mono for the OTP keypad and the running check-in clock.
  static const TextStyle monoLarge = TextStyle(
    fontFamily: _mono,
    fontSize: 28,
    height: 1.2,
    fontWeight: FontWeight.w600,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static TextTheme textTheme(Color ink, Color muted) {
    return TextTheme(
      headlineMedium: title.copyWith(color: ink),
      titleLarge: heading.copyWith(color: ink),
      bodyMedium: body.copyWith(color: ink),
      bodyLarge: bodyStrong.copyWith(color: ink),
      labelSmall: caption.copyWith(color: muted),
    );
  }
}
