import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/mixins/safe_set_state_mixin.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../features/settings/presentation/providers/locale_provider.dart';

// ─── Screen ───────────────────────────────────────────────────────────────────

class LanguageSelectionScreen extends ConsumerStatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  ConsumerState<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState
    extends ConsumerState<LanguageSelectionScreen> with SafeSetStateMixin {
  late String _selectedCode;

  @override
  void initState() {
    super.initState();
    _selectedCode = ref.read(localeProvider).languageCode;
  }

  Future<void> _onContinue() async {
    HapticFeedback.lightImpact();
    await ref.read(localeProvider.notifier).setLocale(Locale(_selectedCode));
    if (mounted) context.push(AppRoutes.terms);
  }

  @override
  Widget build(BuildContext context) {
    final l10n       = context.l10n;
    final colors     = context.colors;
    final textTheme  = context.textTheme;
    final appStyles  = context.appTextStyles;

    // Resolved at build time — locale-dependent strings kept out of data model.
    final languages = [
      (code: 'en', name: l10n.langEnglishName,  subtitle: l10n.langEnglishSubtitle),
      (code: 'hi', name: l10n.langHindiName,    subtitle: l10n.langHindiSubtitle),
      (code: 'gu', name: l10n.langGujaratiName, subtitle: l10n.langGujaratiSubtitle),
    ];

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    Padding(
                      padding:  EdgeInsets.all(16.w),
                      child: Column(
                        children: [
                          SizedBox(height: 16.h),

                          // ── Title — Manrope ExtraBold 30 sp ───────────────
                          Text(
                            l10n.langSelectionTitle,
                            textAlign: TextAlign.center,
                            style: appStyles.screenTitle.copyWith(
                              fontSize: 30.sp,
                              color: colors.textPrimary,
                            ),
                          ),

                          SizedBox(height: 8.h),

                          // ── Subtitle — Manrope Regular 16 sp, brownText ───
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: Text(
                              l10n.langSelectionSubtitle,
                              textAlign: TextAlign.center,
                              style: textTheme.bodyLarge?.copyWith(
                                color: colors.brownText,
                              ),
                            ),
                          ),

                          SizedBox(height: 32.h),
                        ],
                      ),
                    ),

                    // ── Language tiles ────────────────────────────────
                    ...languages.map((lang) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: _LangTile(
                        name:       lang.name,
                        subtitle:   lang.subtitle,
                        isSelected: _selectedCode == lang.code,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          safeSetState(() => _selectedCode = lang.code);
                        },
                      ),
                    )),

                    const Spacer(),

                    // ── Continue button ───────────────────────────────
                    SizedBox(
                      width:  double.infinity,
                      height: 52.h,
                      child: ElevatedButton(
                        onPressed: _onContinue,
                        child: Text(
                          l10n.actionContinue,
                          style: textTheme.labelLarge?.copyWith(
                            color: colors.onPrimary,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 28.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Language tile ────────────────────────────────────────────────────────────

class _LangTile extends StatelessWidget {
  const _LangTile({
    required this.name,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final String       name;
  final String       subtitle;
  final bool         isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors    = context.colors;
    final textTheme = context.textTheme;

    // Selected:   bg + border from [AppColorScheme]; name #582100 via selectedText
    // Unselected: surface + muted border; subtitle brownText in both states
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.languageTileSelectedFill
              : colors.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected
                ? colors.primary
                : colors.languageTileBorderUnselected.withOpacity(0.30),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? null
              : [
                  BoxShadow(
                    color: colors.languageTileShadow,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            // ── Language name + subtitle ──────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isSelected ? colors.selectedText : colors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.brownText,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: 12.w),

            // ── Radio indicator — filled orange circle with white dot ─
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width:  22.w,
              height: 22.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? colors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? colors.primary
                      : colors.languageTileBorderUnselected,
                  width: 2.0,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width:  8.w,
                        height: 8.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.onPrimary,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
