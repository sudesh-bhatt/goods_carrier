import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../generated/assets.dart';
import '../../../../core/mixins/safe_set_state_mixin.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/utils/media_permission_helper.dart';
import '../../../../core/utils/validators.dart';
import '../../../../res/font_res.dart';
import '../../../../shared/presentation/widgets/inputs/address_autocomplete_field.dart';
import '../../../../shared/presentation/widgets/sheets/app_modal_bottom_sheet.dart';
import '../providers/auth_provider.dart';

/// Figma profile field fill ([Create Profile](https://www.figma.com/design/wT5NdNeg7YVPPcq1nY9D2P/Goods-Carrier--Copy-?node-id=2013-1813)).
const _kProfileFieldFill = Color(0xFFF0F2F5);

/// Horizontal inset for the Create Profile CTA.
const _kCreateProfileButtonInset = 48.0;

/// Profile setup for new Customer accounts — matches Figma Create Your Profile.
class CustomerProfileSetupScreen extends ConsumerStatefulWidget {
  const CustomerProfileSetupScreen({super.key});

  @override
  ConsumerState<CustomerProfileSetupScreen> createState() =>
      _CustomerProfileSetupScreenState();
}

class _CustomerProfileSetupScreenState
    extends ConsumerState<CustomerProfileSetupScreen>
    with SafeSetStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _imagePicker = ImagePicker();
  bool _submitted = false;
  XFile? _profileImage;

  @override
  void initState() {
    super.initState();
    final raw = ref.read(authProvider).phoneNumber;
    _phoneCtrl.text = _formatPhoneDisplay(raw);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  String _formatPhoneDisplay(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 10 && digits.startsWith('91')) {
      final local = digits.substring(2);
      if (local.length == 10) return '+91 $local';
    }
    if (raw.startsWith('+')) return raw;
    return '+91 $raw';
  }

  String _phoneForSubmit() {
    final raw = ref.read(authProvider).phoneNumber;
    if (raw != null && raw.isNotEmpty) return raw;
    return _phoneCtrl.text.replaceAll(RegExp(r'\s'), '');
  }

  Future<void> _pickProfileImage() async {
    HapticFeedback.lightImpact();
    final l10n = context.l10n;

    final source = await AppModalBottomSheet.show<ImageSource>(
      context: context,
      isScrollControlled: false,
      backgroundColor: context.colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLg.r),
        ),
      ),
      builder: (sheetContext) {
        final colors = sheetContext.colors;
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(8.w, 8.h, 8.w, 8.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Text(
                    l10n.profilePhotoPickerTitle,
                    style: sheetContext.textTheme.titleMedium?.copyWith(
                      fontFamily: FontRes.MANROPE_BOLD,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.photo_camera_outlined, color: colors.primary),
                  title: Text(l10n.profilePhotoTakePhoto),
                  onTap: () =>
                      Navigator.pop(sheetContext, ImageSource.camera),
                ),
                ListTile(
                  leading: Icon(Icons.photo_library_outlined, color: colors.primary),
                  title: Text(l10n.profilePhotoChooseGallery),
                  onTap: () =>
                      Navigator.pop(sheetContext, ImageSource.gallery),
                ),
                ListTile(
                  leading: Icon(Icons.close, color: colors.textSecondary),
                  title: Text(l10n.actionCancel),
                  onTap: () => Navigator.pop(sheetContext),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source == null || !mounted) return;

    final canPick = await _ensureMediaPermission(source);
    if (!canPick || !mounted) return;

    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked != null && mounted) {
        safeSetState(() => _profileImage = picked);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  /// Returns `true` when the user may proceed to the system picker / camera.
  Future<bool> _ensureMediaPermission(ImageSource source) async {
    final l10n = context.l10n;

    if (source == ImageSource.camera) {
      final granted = await MediaPermissionHelper.ensureCamera();
      if (granted) return true;

      if (!mounted) return false;
      await _showPermissionDeniedDialog(
        message: l10n.profilePhotoCameraPermissionDenied,
      );
      return false;
    }

    final access = await MediaPermissionHelper.ensureGallery();
    switch (access) {
      case GalleryAccessResult.full:
        return true;
      case GalleryAccessResult.limited:
        if (!mounted) return false;
        return _showLimitedGalleryDialog();
      case GalleryAccessResult.denied:
      case GalleryAccessResult.permanentlyDenied:
        if (!mounted) return false;
        await _showPermissionDeniedDialog(
          message: l10n.profilePhotoGalleryPermissionDenied,
        );
        return false;
    }
  }

  Future<void> _showPermissionDeniedDialog({
    required String message,
  }) async {
    final l10n = context.l10n;

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.profilePhotoPickerTitle),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.actionCancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              MediaPermissionHelper.openSettings();
            },
            child: Text(l10n.actionOpenSettings),
          ),
        ],
      ),
    );
  }

  /// Explains partial gallery access; user can open Settings or continue.
  Future<bool> _showLimitedGalleryDialog() async {
    final l10n = context.l10n;

    final choice = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.profilePhotoLimitedTitle),
        content: Text(l10n.profilePhotoLimitedMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'continue'),
            child: Text(l10n.profilePhotoContinueWithLimited),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'settings'),
            child: Text(l10n.profilePhotoAllowFullAccess),
          ),
        ],
      ),
    );

    if (choice == 'settings') {
      await MediaPermissionHelper.openSettings();
      return false;
    }
    if (choice == 'continue') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.profilePhotoLimitedMessage),
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return true;
    }
    return false;
  }

  Future<void> _submit() async {
    safeSetState(() => _submitted = true);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    await ref.read(authProvider.notifier).submitCustomerProfile(
          name: _nameCtrl.text.trim(),
          phone: _phoneForSubmit(),
          address: _addressCtrl.text.trim(),
          email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final textTheme = context.textTheme;
    final appStyles = context.appTextStyles;
    final isLoading = ref.watch(authProvider).isLoading;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Text(
          l10n.profileSetupTitle,
          style: TextStyle(
            fontFamily: FontRes.MANROPE_BOLD,
            color: colors.textPrimary,
            fontSize: 18.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: Form(
            key: _formKey,
            autovalidateMode: _submitted
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h),
                  Center(
                    child: _ProfileAvatar(
                      colors: colors,
                      image: _profileImage,
                      onTap: _pickProfileImage,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    l10n.profileSetupSubtitle,
                    style: appStyles.sectionHeading.copyWith(
                      fontFamily: FontRes.MANROPE_EXTRABOLD,
                      color: const Color(0xFF1A1C1E),
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w400,
                      height: 1.25,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  _ProfileSetupField(
                    label: l10n.profileName,
                    hint: 'Johnathan Sterling',
                    controller: _nameCtrl,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    autofocus: true,
                    suffixIcon: Icons.person_outline_rounded,
                    validator: (v) => Validators.required(v, l10n.profileName),
                  ),
                  SizedBox(height: 16.h),
                  _ProfileSetupField(
                    label: l10n.profilePhone,
                    controller: _phoneCtrl,
                    readOnly: true,
                    suffixIcon: Icons.phone_outlined,
                  ),
                  SizedBox(height: 16.h),
                  _ProfileSetupField(
                    label: l10n.profileEmailOptional,
                    hint: 'j.sterling@logistics.com',
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    suffixIcon: Icons.mail_outline_rounded,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return null;
                      return Validators.email(v);
                    },
                  ),
                  SizedBox(height: 16.h),
                  AddressAutocompleteField(
                    label: l10n.profilePrimaryAddress,
                    hint: '123 Precision Avenue, Tech District',
                    controller: _addressCtrl,
                    fillColor: _kProfileFieldFill,
                    autovalidateMode: _submitted
                        ? AutovalidateMode.onUserInteraction
                        : AutovalidateMode.disabled,
                    validator: (v) =>
                        Validators.required(v, l10n.profilePrimaryAddress),
                  ),
                  SizedBox(height: 32.h),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: _kCreateProfileButtonInset.w,
                    ),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusLg.r,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colors.primary.withValues(alpha: 0.28),
                            blurRadius: 14,
                            offset: Offset(0, 6.h),
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52.h,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusLg.r,
                              ),
                            ),
                          ),
                          child: isLoading
                              ? SizedBox(
                                  width: 22.w,
                                  height: 22.w,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: colors.onPrimary,
                                  ),
                                )
                              : Text(
                                  l10n.profileCreateButton,
                                  style: textTheme.labelLarge?.copyWith(
                                    color: colors.onPrimary,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Avatar + camera (Figma) ────────────────────────────────────────────────────

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.colors,
    required this.onTap,
    this.image,
  });

  final AppColorScheme colors;
  final VoidCallback onTap;
  final XFile? image;

  @override
  Widget build(BuildContext context) {
    final hasImage = image != null;

    return SizedBox(
      width: 104.w,
      height: 104.w,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 96.w,
              height: 96.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.surface,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF000000).withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: EdgeInsets.all(4.w),
              child: ClipOval(
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: hasImage
                      ? Image.file(
                          File(image!.path),
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          width: double.infinity,
                          height: double.infinity,
                        )
                      : ColoredBox(
                          color: colors.primary.withValues(alpha: 0.12),
                          child: Icon(
                            Icons.person_outline_rounded,
                            size: 44.w,
                            color: colors.primary,
                          ),
                        ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 2.w,
            bottom: 2.w,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                width: 34.w,
                height: 34.w,
                decoration: BoxDecoration(
                  color: colors.primaryDark,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.surface, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF000000).withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Assets.icProfileCamera.svg(
                  width: 18.w,
                  height: 18.w,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Figma-styled field (caps label, right icon, pill fill) ───────────────────

class _ProfileSetupField extends StatelessWidget {
  const _ProfileSetupField({
    required this.label,
    required this.controller,
    this.hint,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction = TextInputAction.next,
    this.autofocus = false,
    this.readOnly = false,
    this.suffixIcon,
  });

  final String label;
  final String? hint;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final TextInputAction textInputAction;
  final bool autofocus;
  final bool readOnly;
  final IconData? suffixIcon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fieldRadius = BorderRadius.circular(AppDimensions.radiusLg.r);
    const noBorder = BorderSide(color: Colors.transparent, width: 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: context.textTheme.labelSmall?.copyWith(
            fontFamily: FontRes.MANROPE_SEMIBOLD,
            color: colors.brownText,
            fontSize: 11.sp,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.6,
            height: 1.2,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          textInputAction: textInputAction,
          autofocus: autofocus,
          readOnly: readOnly,
          style: context.textTheme.bodyMedium?.copyWith(
            fontFamily: FontRes.MANROPE_REGULAR,
            color: colors.textPrimary,
            fontSize: 15.sp,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: context.textTheme.bodyMedium?.copyWith(
              color: colors.textHint,
              fontSize: 15.sp,
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor: _kProfileFieldFill,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
            suffixIcon: suffixIcon != null
                ? Icon(suffixIcon, color: colors.textHint, size: 22.w)
                : null,
            border: OutlineInputBorder(borderRadius: fieldRadius, borderSide: noBorder),
            enabledBorder:
                OutlineInputBorder(borderRadius: fieldRadius, borderSide: noBorder),
            focusedBorder: OutlineInputBorder(
              borderRadius: fieldRadius,
              borderSide: BorderSide(color: colors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: fieldRadius,
              borderSide: BorderSide(color: colors.error, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: fieldRadius,
              borderSide: BorderSide(color: colors.error, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
