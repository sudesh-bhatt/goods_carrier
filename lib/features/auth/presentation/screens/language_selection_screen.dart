import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

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
    extends ConsumerState<LanguageSelectionScreen> {
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
                          setState(() => _selectedCode = lang.code);
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
                            color: Colors.white,
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

    // ── Figma-exact token values ─────────────────────────────────────────
    // Selected:   bg #FFB692@20%, border #FF6D00 w2, name #582100
    // Unselected: bg #FFFFFF,     border #E2BFB0@30% w1, name #161C20
    // Subtitle: #594136 in both states
    const Color unselectedBorder = Color(0xFFE2BFB0);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFFB692).withOpacity(0.20)
              : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? colors.primary : unselectedBorder.withOpacity(0.30),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
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
                  color: isSelected ? colors.primary : unselectedBorder,
                  width: 2.0,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width:  8.w,
                        height: 8.w,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
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
