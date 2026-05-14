/// All spacing, radius and size constants.
/// Use with .w / .h / .r extensions in widget build methods.
class AppDimensions {
  AppDimensions._();

  // Spacing
  static const double xs   = 4;
  static const double sm   = 8;
  static const double md   = 12;
  static const double base = 16;
  static const double lg   = 20;
  static const double xl   = 24;
  static const double xxl  = 32;
  static const double xxxl = 48;

  // Radius
  static const double radiusSm   = 8;
  static const double radiusMd   = 12;
  static const double radiusLg   = 16;
  static const double radiusFull = 999;

  /// Login main card — Figma Login Screen (~28 dp corner radius).
  static const double radiusLoginCard = 28;

  // Component heights
  static const double buttonHeight      = 52;
  static const double inputHeight       = 52;
  static const double appBarHeight      = 56;
  static const double cardMinHeight     = 72;
  static const double bottomNavHeight   = 64;
  static const double fabSize           = 56;

  // Icon sizes
  static const double iconSm   = 16;
  static const double iconMd   = 20;
  static const double iconBase = 24;
  static const double iconLg   = 32;

  // Screen horizontal padding
  static const double screenPadding = 16;
}
