import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_color_scheme.dart';
import '../theme/app_text_styles.dart';

extension AppThemeExt on BuildContext {
  /// All localised strings — context.l10n.appName, context.l10n.actionSave …
  /// RULE: Never use hardcoded string literals in widget build methods.
  ///       Always go through context.l10n.<key>.
  AppLocalizations get l10n => AppLocalizations.of(this);

  /// Access custom design tokens — context.colors.primary, context.colors.cardBackground
  AppColorScheme get colors => Theme.of(this).extension<AppColorScheme>()!;

  /// Named text styles — context.appTextStyles.screenTitle, .sectionHeading …
  AppTextStyles get appTextStyles => Theme.of(this).extension<AppTextStyles>()!;

  TextTheme get textTheme => Theme.of(this).textTheme;

  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  /// Platform-aware card shadow.
  List<BoxShadow> get cardShadow => isDark
      ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ]
      : [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ];
}
