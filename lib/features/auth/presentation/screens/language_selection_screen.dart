import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../features/settings/presentation/providers/locale_provider.dart';
import '../../../../shared/presentation/widgets/buttons/app_button.dart';
import '../../../../shared/presentation/widgets/navigation/app_bar_widget.dart';

/// Lets the user pick their preferred language (EN / HI / GU) before entering
/// the rest of the onboarding flow.
class LanguageSelectionScreen extends ConsumerStatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  ConsumerState<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState
    extends ConsumerState<LanguageSelectionScreen> {
  late String _selectedCode;

  static const _languages = [
    _LangOption(code: 'en', nativeName: 'English',    localName: 'English'),
    _LangOption(code: 'hi', nativeName: 'हिन्दी',      localName: 'Hindi'),
    _LangOption(code: 'gu', nativeName: 'ગુજરાતી',    localName: 'Gujarati'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedCode = ref.read(localeProvider).languageCode;
  }

  Future<void> _onContinue() async {
    HapticFeedback.lightImpact();
    await ref
        .read(localeProvider.notifier)
        .setLocale(Locale(_selectedCode));
    if (mounted) context.go(AppRoutes.terms);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBarWidget(title: context.l10n.settingsLanguage),
      body: SafeArea(
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: AppDimensions.screenPadding.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppDimensions.xl.h),

              Text(
                'Choose your preferred language',
                style: context.textTheme.titleMedium?.copyWith(
                  color: colors.textSecondary,
                ),
              ),

              SizedBox(height: AppDimensions.xl.h),

              // ── Language tiles ────────────────────────────────────────
              ..._languages.map((lang) => _LangTile(
                    lang: lang,
                    isSelected: _selectedCode == lang.code,
                    onTap: () => setState(() => _selectedCode = lang.code),
                    colors: colors,
                  )),

              const Spacer(),

              AppButton(
                label: context.l10n.actionContinue,
                onPressed: _onContinue,
              ),

              SizedBox(height: AppDimensions.xl.h),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Data class ───────────────────────────────────────────────────────────────

class _LangOption {
  const _LangOption({
    required this.code,
    required this.nativeName,
    required this.localName,
  });
  final String code;
  final String nativeName;
  final String localName;
}

// ─── Language tile ────────────────────────────────────────────────────────────

class _LangTile extends StatelessWidget {
  const _LangTile({
    required this.lang,
    required this.isSelected,
    required this.onTap,
    required this.colors,
  });

  final _LangOption lang;
  final bool isSelected;
  final VoidCallback onTap;
  final dynamic colors;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: EdgeInsets.only(bottom: AppDimensions.md.h),
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.base.w,
          vertical: AppDimensions.base.h,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary.withOpacity(0.06)
              : colors.cardBackground,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
          border: Border.all(
            color: isSelected ? colors.primary : colors.divider,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          children: [
            // Language flag/icon placeholder
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: isSelected
                    ? colors.primary.withOpacity(0.12)
                    : colors.inputFill,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  lang.code.toUpperCase(),
                  style: context.textTheme.labelSmall?.copyWith(
                    color: isSelected ? colors.primary : colors.textSecondary,
                    fontWeight: FontWeight.w800,
                    fontSize: 11.sp,
                  ),
                ),
              ),
            ),

            SizedBox(width: AppDimensions.base.w),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang.nativeName,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    lang.localName,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            AnimatedOpacity(
              opacity: isSelected ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 150),
              child: Icon(
                Icons.check_circle_rounded,
                size: AppDimensions.iconBase.w,
                color: colors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
