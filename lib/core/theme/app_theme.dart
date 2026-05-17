import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_color_scheme.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() => _build(
    brightness: Brightness.light,
    colors: AppColorScheme.light,
  );

  static ThemeData dark() => _build(
    brightness: Brightness.dark,
    colors: AppColorScheme.dark,
  );

  static ThemeData _build({
    required Brightness brightness,
    required AppColorScheme colors,
  }) {
    final isLight = brightness == Brightness.light;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: colors.primary,
      brightness: brightness,
      surface: colors.surface,
      onSurface: colors.textPrimary,
    ).copyWith(
      primary: colors.primary,
      onPrimary: colors.onPrimary,
      primaryContainer: colors.inputFill,
      onPrimaryContainer: colors.textPrimary,
      secondary: colors.primary,
      onSecondary: colors.onPrimary,
      surface: colors.surface,
      onSurface: colors.textPrimary,
      surfaceContainerHighest: colors.inputFill,
      surfaceContainerHigh: colors.inputFill,
      surfaceContainer: colors.cardBackground,
      tertiaryContainer: colors.inputFill,
      onTertiaryContainer: colors.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: 'Manrope',
      extensions: [colors, AppTextStyles.defaults],
      scaffoldBackgroundColor: colors.background,
      colorScheme: colorScheme,

      textTheme: TextTheme(
        displayLarge:  TextStyle(fontFamily: 'Manrope', color: colors.textPrimary,   fontWeight: FontWeight.w800),
        headlineLarge: TextStyle(fontFamily: 'Manrope', color: colors.textPrimary,   fontWeight: FontWeight.w800,fontSize: 24),
        headlineMedium:TextStyle(fontFamily: 'Manrope', color: colors.textPrimary,   fontWeight: FontWeight.w700,fontSize: 22),
        titleLarge:    TextStyle(fontFamily: 'Manrope', color: colors.textPrimary,   fontWeight: FontWeight.w700,fontSize: 24),
        titleMedium:   TextStyle(fontFamily: 'Manrope', color: colors.textPrimary,   fontWeight: FontWeight.w600),
        bodyLarge:     TextStyle(fontFamily: 'Manrope', color: colors.textPrimary, fontSize: 16, height: 24/16),
        bodyMedium:    TextStyle(fontFamily: 'Manrope', color: colors.textSecondary),
        bodySmall:     TextStyle(fontFamily: 'Manrope', color: colors.textHint),
        labelLarge:    TextStyle(fontFamily: 'Manrope', color: colors.textPrimary,   fontWeight: FontWeight.bold,fontSize: 18),
        labelSmall:    TextStyle(fontFamily: 'Manrope', color: colors.textSecondary, letterSpacing: 0.8),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: colors.surface,
        foregroundColor: colors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Manrope',
          color: colors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: colors.textPrimary, size: 24),
        systemOverlayStyle: isLight
            ? const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.dark,
                statusBarBrightness: Brightness.light,
                systemNavigationBarColor: Colors.transparent,
              )
            : const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.light,
                statusBarBrightness: Brightness.dark,
                systemNavigationBarColor: Colors.transparent,
              ),
      ),

      cardTheme: CardThemeData(
        color: colors.cardBackground,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.error, width: 1.5),
        ),
        hintStyle: const TextStyle(fontFamily: 'Manrope', fontSize: 14, fontWeight: FontWeight.w400),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          disabledBackgroundColor: colors.primary.withOpacity(0.4),
          minimumSize: const Size(double.infinity, 52),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontFamily: 'Manrope', fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primary,
          side: BorderSide(color: colors.primary, width: 1.5),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontFamily: 'Manrope', fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primary,
          textStyle: const TextStyle(fontFamily: 'Manrope', fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        showDragHandle: true,
        dragHandleColor: colors.divider,
        dragHandleSize: const Size(40, 4),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      datePickerTheme: _datePickerTheme(colors),
      timePickerTheme: _timePickerTheme(colors),

      dividerTheme: DividerThemeData(color: colors.divider, thickness: 1, space: 1),

      chipTheme: ChipThemeData(
        backgroundColor: colors.inputFill,
        selectedColor: colors.primary,
        labelStyle: const TextStyle(fontFamily: 'Manrope', fontSize: 13),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide.none,
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        elevation: 4,
        shape: const CircleBorder(),
      ),
    );
  }

  /// Material date picker — white/grey surfaces, brand orange selection.
  static DatePickerThemeData _datePickerTheme(AppColorScheme colors) {
    return DatePickerThemeData(
      backgroundColor: colors.surface,
      headerBackgroundColor: colors.surface,
      headerForegroundColor: colors.textPrimary,
      surfaceTintColor: Colors.transparent,
      dividerColor: colors.divider,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      weekdayStyle: TextStyle(
        fontFamily: 'Manrope',
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: colors.textSecondary,
      ),
      dayStyle: TextStyle(
        fontFamily: 'Manrope',
        fontSize: 14,
        color: colors.textPrimary,
      ),
      yearStyle: TextStyle(
        fontFamily: 'Manrope',
        fontSize: 14,
        color: colors.textPrimary,
      ),
      headerHeadlineStyle: TextStyle(
        fontFamily: 'Manrope',
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: colors.textPrimary,
      ),
      headerHelpStyle: TextStyle(
        fontFamily: 'Manrope',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: colors.textSecondary,
      ),
      todayForegroundColor: WidgetStatePropertyAll(colors.primary),
      todayBackgroundColor: const WidgetStatePropertyAll(Colors.transparent),
      dayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return colors.onPrimary;
        if (states.contains(WidgetState.disabled)) return colors.textHint;
        return colors.textPrimary;
      }),
      dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return colors.primary;
        return Colors.transparent;
      }),
      yearForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return colors.onPrimary;
        return colors.textPrimary;
      }),
      yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return colors.primary;
        return Colors.transparent;
      }),
    );
  }

  /// Material time picker — white/grey surfaces, brand orange accents.
  static TimePickerThemeData _timePickerTheme(AppColorScheme colors) {
    final selectedHourFill = colors.primary.withValues(alpha: 0.12);

    return TimePickerThemeData(
      backgroundColor: colors.surface,
      dialBackgroundColor: colors.inputFill,
      dialHandColor: colors.primary,
      dialTextColor: colors.textPrimary,
      entryModeIconColor: colors.textSecondary,
      hourMinuteColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return selectedHourFill;
        return colors.inputFill;
      }),
      hourMinuteTextColor: colors.textPrimary,
      dayPeriodColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return colors.primary;
        return colors.inputFill;
      }),
      dayPeriodTextColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return colors.onPrimary;
        return colors.textPrimary;
      }),
      helpTextStyle: TextStyle(
        fontFamily: 'Manrope',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: colors.textSecondary,
      ),
      hourMinuteTextStyle: TextStyle(
        fontFamily: 'Manrope',
        fontSize: 56,
        fontWeight: FontWeight.w400,
        color: colors.textPrimary,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}
