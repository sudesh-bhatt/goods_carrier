import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_color_scheme.dart';

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
    final manrope = GoogleFonts.manropeTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      extensions: [colors],
      scaffoldBackgroundColor: colors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFFF6D00),
        brightness: brightness,
      ),

      textTheme: manrope.copyWith(
        displayLarge:  manrope.displayLarge?.copyWith(color: colors.textPrimary, fontWeight: FontWeight.w800),
        headlineLarge: manrope.headlineLarge?.copyWith(color: colors.textPrimary, fontWeight: FontWeight.w800),
        headlineMedium:manrope.headlineMedium?.copyWith(color: colors.textPrimary, fontWeight: FontWeight.w700),
        titleLarge:    manrope.titleLarge?.copyWith(color: colors.textPrimary, fontWeight: FontWeight.w700),
        titleMedium:   manrope.titleMedium?.copyWith(color: colors.textPrimary, fontWeight: FontWeight.w600),
        bodyLarge:     manrope.bodyLarge?.copyWith(color: colors.textPrimary),
        bodyMedium:    manrope.bodyMedium?.copyWith(color: colors.textSecondary),
        bodySmall:     manrope.bodySmall?.copyWith(color: colors.textHint),
        labelLarge:    manrope.labelLarge?.copyWith(color: colors.textPrimary, fontWeight: FontWeight.w600),
        labelSmall:    manrope.labelSmall?.copyWith(color: colors.textSecondary, letterSpacing: 0.8),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: colors.surface,
        foregroundColor: colors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: GoogleFonts.manrope(
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
        hintStyle: GoogleFonts.manrope(color: colors.textHint, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: colors.primary.withOpacity(0.4),
          minimumSize: const Size(double.infinity, 52),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primary,
          side: BorderSide(color: colors.primary, width: 1.5),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primary,
          textStyle: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w600),
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

      dividerTheme: DividerThemeData(color: colors.divider, thickness: 1, space: 1),

      chipTheme: ChipThemeData(
        backgroundColor: colors.inputFill,
        selectedColor: colors.primary,
        labelStyle: GoogleFonts.manrope(fontSize: 13),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide.none,
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
      ),
    );
  }
}
