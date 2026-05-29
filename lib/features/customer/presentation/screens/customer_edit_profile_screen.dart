import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/mixins/safe_set_state_mixin.dart';
import '../../../../core/utils/media_permission_helper.dart';
import '../../../../core/utils/validators.dart';
import '../../../../res/font_res.dart';
import '../../../../shared/presentation/widgets/inputs/address_autocomplete_field.dart';
import '../../../../shared/presentation/widgets/navigation/app_bar_widget.dart';
import '../../../../shared/presentation/widgets/sheets/app_modal_bottom_sheet.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/customer_edit_profile_address_card.dart';
import '../widgets/customer_profile_form_widgets.dart';

/// Edit customer profile — [Figma](https://www.figma.com/design/YxnNResvDQnbkcPhGejtxa/Mobile-App-UI--Developer-?node-id=1-1877).
class CustomerEditProfileScreen extends ConsumerStatefulWidget {
  const CustomerEditProfileScreen({super.key});

  @override
  ConsumerState<CustomerEditProfileScreen> createState() =>
      _CustomerEditProfileScreenState();
}

class _CustomerEditProfileScreenState extends ConsumerState<CustomerEditProfileScreen>
    with SafeSetStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _imagePicker = ImagePicker();
  bool _submitted = false;
  XFile? _profileImage;

  static const _kNameHint = 'Johnathan Sterling';
  static const _kEmailHint = 'j.sterling@logistics.com';
  static const _kAddressHint = '123 Precision Avenue, Tech District';

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    if (user != null) {
      if (user.name.trim().isNotEmpty) _nameCtrl.text = user.name;
      _phoneCtrl.text = _formatPhoneDisplay(user.phone);
      if (user.email.trim().isNotEmpty) _emailCtrl.text = user.email;
      if ((user.address ?? '').trim().isNotEmpty) {
        _addressCtrl.text = user.address!.trim();
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  String _formatPhoneDisplay(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 10 && digits.startsWith('91')) {
      final local = digits.substring(2);
      if (local.length == 10) return '+91 $local';
    }
    if (raw.startsWith('+')) return raw;
    return raw.isEmpty ? raw : '+91 $raw';
  }

  Future<bool> _ensureMediaPermission(ImageSource source) async {
    if (source == ImageSource.camera) {
      return MediaPermissionHelper.ensureCamera();
    }
    final access = await MediaPermissionHelper.ensureGallery();
    return access == GalleryAccessResult.full ||
        access == GalleryAccessResult.limited;
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
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.photo_camera_outlined, color: colors.primary),
                  title: Text(l10n.profilePhotoTakePhoto),
                  onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
                ),
                ListTile(
                  leading: Icon(Icons.photo_library_outlined, color: colors.primary),
                  title: Text(l10n.profilePhotoChooseGallery),
                  onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
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

  Future<void> _editAddress() async {
    HapticFeedback.selectionClick();
    final l10n = context.l10n;

    final saved = await AppModalBottomSheet.show<String>(
      context: context,
      backgroundColor: context.colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLg.r),
        ),
      ),
      builder: (sheetContext) => _AddressEditSheet(
        title: l10n.customerEditAddressTitle,
        label: l10n.customerDefaultShippingAddress,
        hint: _kAddressHint,
        saveLabel: l10n.actionSave,
        initialAddress: _addressCtrl.text,
      ),
    );

    if (saved != null) {
      safeSetState(() => _addressCtrl.text = saved);
    }
  }

  Future<void> _submit() async {
    safeSetState(() => _submitted = true);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    final user = ref.read(authProvider).user;
    if (user == null) return;

    await ref.read(authProvider.notifier).updateCustomerProfile(
          name: _nameCtrl.text.trim(),
          phone: user.phone,
          address: _addressCtrl.text.trim(),
          email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
        );

    if (!mounted) return;
    final error = ref.read(authProvider).error;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final isLoading = ref.watch(authProvider).isLoading;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: FlowScreenAppBar(title: l10n.customerEditProfileTitle),
      body: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: Form(
            key: _formKey,
            autovalidateMode: _submitted
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 32.h),
                  Center(
                    child: CustomerProfileAvatar(
                      colors: colors,
                      image: _profileImage,
                      onTap: _pickProfileImage,
                    ),
                  ),
                  SizedBox(height: 40.h),
                  CustomerProfileFormField(
                    label: l10n.profileName,
                    hint: _kNameHint,
                    controller: _nameCtrl,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    suffixIcon: Icons.person_outline_rounded,
                    fillColor: const Color(0xFFEFF4FA),
                    validator: (v) => Validators.required(v, l10n.profileName),
                  ),
                  SizedBox(height: 24.h),
                  CustomerProfileFormField(
                    label: l10n.profilePhone,
                    controller: _phoneCtrl,
                    readOnly: true,
                    suffixIcon: Icons.phone_outlined,
                    fillColor: const Color(0xFFEFF4FA),
                  ),
                  SizedBox(height: 24.h),
                  CustomerProfileFormField(
                    label: l10n.profileEmail,
                    hint: _kEmailHint,
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    suffixIcon: Icons.mail_outline_rounded,
                    fillColor: const Color(0xFFEFF4FA),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return null;
                      return Validators.email(v);
                    },
                  ),
                  SizedBox(height: 24.h),
                  Padding(
                    padding: EdgeInsets.only(left: 4.w),
                    child: Text(
                      l10n.customerDefaultShippingAddress.toUpperCase(),
                      style: TextStyle(
                        fontFamily: FontRes.MANROPE_EXTRABOLD,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.8,
                        height: 16 / 12,
                        color: colors.brownText,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  CustomerEditProfileAddressCard(
                    address: _addressCtrl.text,
                    placeholder: _kAddressHint,
                    onTap: _editAddress,
                  ),
                  SizedBox(height: 40.h),
                  Center(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: colors.primary.withValues(alpha: 0.3),
                            blurRadius: 24,
                            offset: Offset(0, 8.h),
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: 274.w,
                        height: 56.h,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
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
                                  l10n.customerUpdateProfileButton,
                                  style: TextStyle(
                                    fontFamily: FontRes.MANROPE_BOLD,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w700,
                                    height: 28 / 18,
                                    color: colors.onPrimary,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Address editor sheet — owns its [TextEditingController] until fully disposed.
class _AddressEditSheet extends StatefulWidget {
  const _AddressEditSheet({
    required this.title,
    required this.label,
    required this.hint,
    required this.saveLabel,
    required this.initialAddress,
  });

  final String title;
  final String label;
  final String hint;
  final String saveLabel;
  final String initialAddress;

  @override
  State<_AddressEditSheet> createState() => _AddressEditSheetState();
}

class _AddressEditSheetState extends State<_AddressEditSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialAddress);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    FocusScope.of(context).unfocus();
    Navigator.pop(context, _controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.title,
              style: TextStyle(
                fontFamily: FontRes.MANROPE_BOLD,
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: context.colors.textPrimary,
              ),
            ),
            SizedBox(height: 16.h),
            AddressAutocompleteField(
              label: widget.label,
              hint: widget.hint,
              controller: _controller,
              fillColor: kCustomerProfileFieldFill,
            ),
            SizedBox(height: 16.h),
            SizedBox(
              height: 48.h,
              child: ElevatedButton(
                onPressed: _save,
                child: Text(widget.saveLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
