import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/mixins/safe_set_state_mixin.dart';
import '../../../../core/services/google_places_service.dart';
import '../../../../core/utils/map_location_helper.dart';
import '../../../../core/utils/media_permission_helper.dart';
import '../../../../core/utils/phone_utils.dart';
import '../../../../core/utils/profile_image_utils.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/presentation/widgets/inputs/app_phone_field.dart';
import '../../../../res/font_res.dart';
import '../../../../shared/presentation/widgets/inputs/address_autocomplete_field.dart';
import '../../../../shared/presentation/widgets/navigation/app_bar_widget.dart';
import '../../../../shared/presentation/widgets/sheets/app_bottom_sheet.dart';
import '../../../../shared/presentation/widgets/sheets/app_modal_bottom_sheet.dart';
import '../../../../shared/domain/enums/saved_address_label.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/customer_saved_addresses_provider.dart';
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
  String? _savedImagePath;
  String _dialCode = '+91';

  static const _kNameHint = 'Johnathan Sterling';
  static const _kEmailHint = 'j.sterling@logistics.com';
  static const _kAddressHint = '123 Precision Avenue, Tech District';

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    if (user != null) {
      if (user.name.trim().isNotEmpty) _nameCtrl.text = user.name;
      _applyPhone(user.phone);
      if (user.email.trim().isNotEmpty) _emailCtrl.text = user.email;
      if ((user.address ?? '').trim().isNotEmpty) {
        _addressCtrl.text = user.address!.trim();
      }
      _savedImagePath = user.profileImageUrl;
    }
  }

  void _applyPhone(String? raw) {
    if (raw == null || raw.isEmpty) return;
    final split = PhoneUtils.splitE164(raw);
    _dialCode = split.dialCode;
    _phoneCtrl.text = split.localNumber;
  }

  String _resolvedPhone() =>
      PhoneUtils.buildE164(_dialCode, _phoneCtrl.text);

  String? _resolvedProfileImagePath() =>
      ProfileImageUtils.resolveForApiSubmission(
        pickedPath: _profileImage?.path,
        savedReference: _savedImagePath,
      );

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
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
      builder: (sheetContext) {
        final colors = sheetContext.colors;
        return AppBottomSheetContainer(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppBottomSheetHeaderIcon(icon: Icons.camera_alt_outlined),
              SizedBox(height: AppBottomSheetTokens.sectionGap.h),
              AppBottomSheetTitle(text: l10n.profilePhotoPickerTitle),
              SizedBox(height: AppBottomSheetTokens.sectionGap.h),
              ListTile(
                leading:
                    Icon(Icons.photo_camera_outlined, color: colors.primary),
                title: Text(l10n.profilePhotoTakePhoto),
                onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
              ),
              ListTile(
                leading:
                    Icon(Icons.photo_library_outlined, color: colors.primary),
                title: Text(l10n.profilePhotoChooseGallery),
                onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
              ),
              SizedBox(height: AppBottomSheetTokens.sectionGap.h),
              AppBottomSheetSecondaryButton(
                label: l10n.actionNo,
                onPressed: () => Navigator.pop(sheetContext),
              ),
            ],
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
        safeSetState(() {
          _profileImage = picked;
          _savedImagePath = picked.path;
        });
        await ref.read(authProvider.notifier).stageProfileImage(picked.path);
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

    final saved = await ref.read(authProvider.notifier).updateCustomerProfile(
          name: _nameCtrl.text.trim(),
          phone: _resolvedPhone(),
          address: _addressCtrl.text.trim(),
          email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
          profileImageUrl: _resolvedProfileImagePath(),
        );

    if (!mounted) return;
    if (!saved) {
      final error = ref.read(authProvider).error;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
      return;
    }

    context.go(AppRoutes.customerProfile);
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
                      savedImagePath: _savedImagePath,
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
                  AppPhoneField(
                    label: l10n.profilePhone,
                    labelStyle: AppPhoneFieldLabelStyle.profilePersonal,
                    size: AppPhoneFieldSize.compact,
                    controller: _phoneCtrl,
                    dialCode: _dialCode,
                    fillColor: const Color(0xFFEFF4FA),
                    onDialCodeChanged: (code) => safeSetState(
                      () => _dialCode = code.dialCode ?? '+91',
                    ),
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
class _AddressEditSheet extends ConsumerStatefulWidget {
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
  ConsumerState<_AddressEditSheet> createState() => _AddressEditSheetState();
}

class _AddressEditSheetState extends ConsumerState<_AddressEditSheet>
    with SafeSetStateMixin {
  late final TextEditingController _controller;
  PlaceAddressDetails? _selectedPlace;
  bool _saving = false;

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

  void _onPlaceSelected(PlaceAddressDetails details) {
    safeSetState(() => _selectedPlace = details);
  }

  Future<void> _save() async {
    final addressLine = _controller.text.trim();
    final requiredError = Validators.required(
      addressLine,
      context.l10n.customerDefaultShippingAddress,
    );
    if (requiredError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(requiredError)),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    if (_selectedPlace != null) {
      safeSetState(() => _saving = true);
      final details = _selectedPlace!;
      final latitude = MapLocationHelper.isValidCoordinate(
            details.latitude,
            details.longitude,
          )
          ? details.latitude
          : MapLocationHelper.defaultPosition.latitude;
      final longitude = MapLocationHelper.isValidCoordinate(
            details.latitude,
            details.longitude,
          )
          ? details.longitude
          : MapLocationHelper.defaultPosition.longitude;

      final ok =
          await ref.read(customerSavedAddressesProvider.notifier).saveAddress(
                label: SavedAddressLabel.home,
                addressLine: addressLine,
                city: details.city,
                stateName: details.state,
                pincode: details.pincode,
                latitude: latitude,
                longitude: longitude,
                isDefault: true,
              );

      if (!mounted) return;
      safeSetState(() => _saving = false);

      if (!ok) {
        final error = ref.read(customerSavedAddressesProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? context.l10n.errorGeneric),
          ),
        );
        return;
      }
    }

    if (!mounted) return;
    Navigator.pop(context, addressLine);
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomSheetContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppBottomSheetTitle(text: widget.title),
          SizedBox(height: AppBottomSheetTokens.sectionGap.h),
          AddressAutocompleteField(
            label: widget.label,
            hint: widget.hint,
            controller: _controller,
            fillColor: kCustomerProfileFieldFill,
            onPlaceSelected: _onPlaceSelected,
          ),
          SizedBox(height: AppBottomSheetTokens.sectionGap.h),
          AppBottomSheetActionRow(
            secondaryLabel: context.l10n.actionNo,
            primaryLabel: widget.saveLabel,
            onSecondary: _saving ? null : () => Navigator.pop(context),
            onPrimary: _saving ? null : _save,
            isPrimaryLoading: _saving,
          ),
        ],
      ),
    );
  }
}
