/// 8 dp grid. Ledger rows, gutters and touch targets are all multiples of
/// [unit] so the layout stays aligned without ad-hoc numbers in feature code.
class AppSpacing {
  const AppSpacing._();

  static const double unit = 8;

  static const double xs = unit * 0.5; // 4
  static const double sm = unit; // 8
  static const double md = unit * 2; // 16
  static const double lg = unit * 3; // 24
  static const double xl = unit * 4; // 32
  static const double xxl = unit * 6; // 48

  /// Minimum touch target for primary actions (Start day, Check in,
  /// Complete).
  static const double minTouchTarget = 56;

  /// Hairline rule thickness between ledger rows.
  static const double hairline = 1;

  /// Status colour rule on a row's left edge.
  static const double statusRule = 3;
}
