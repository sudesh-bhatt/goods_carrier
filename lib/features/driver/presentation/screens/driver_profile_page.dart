import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/mixins/safe_set_state_mixin.dart';
import '../../../../core/utils/media_permission_helper.dart';
import '../../../../core/utils/phone_utils.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/presentation/widgets/inputs/app_phone_field.dart';
import '../../../../features/customer/presentation/widgets/customer_profile_form_widgets.dart';
import '../../../../shared/domain/entities/user.dart';
import '../../../../shared/presentation/widgets/navigation/app_bar_widget.dart';
import '../../../../shared/presentation/widgets/sheets/app_bottom_sheet.dart';
import '../../../../shared/presentation/widgets/sheets/app_modal_bottom_sheet.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/driver_profile_form_widgets.dart';

/// Driver profile — Figma node `1:661` (setup) and edit profile.
///
/// [isEditMode] `false`: first-time complete profile after OTP.
/// [isEditMode] `true`: edit from My Profile → Edit Personal Information.
class DriverProfilePage extends ConsumerStatefulWidget {
  const DriverProfilePage({super.key, this.isEditMode = false});

  final bool isEditMode;

  @override
  ConsumerState<DriverProfilePage> createState() => _DriverProfilePageState();
}

class _DriverProfilePageState extends ConsumerState<DriverProfilePage>
    with SafeSetStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _scrollCtrl = ScrollController();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _postalCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _gstNameCtrl = TextEditingController();
  final _gstNumberCtrl = TextEditingController();
  final _businessEmailCtrl = TextEditingController();
  final _businessPhoneCtrl = TextEditingController();
  final _imagePicker = ImagePicker();
  bool _submitted = false;
  XFile? _profileImage;
  String? _savedImagePath;
  String _dialCode = '+91';
  String _businessDialCode = '+91';

  @override
  void initState() {
    super.initState();
    final auth = ref.read(authProvider);
    if (widget.isEditMode) {
      _loadUser(auth.user);
    } else {
      _applyPhone(auth.phoneNumber);
      _savedImagePath = auth.pendingProfileImageUrl;
    }
  }

  void _applyPhone(String? raw) {
    if (raw == null || raw.isEmpty) return;
    final split = PhoneUtils.splitE164(raw);
    _dialCode = split.dialCode;
    _phoneCtrl.text = split.localNumber;
  }

  String _resolvedPhone() {
    final built = PhoneUtils.buildE164(_dialCode, _phoneCtrl.text);
    final digits = built.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 2) return built;
    return ref.read(authProvider).phoneNumber ?? built;
  }

  void _loadUser(User? user) {
    if (user == null) return;
    if (user.name.trim().isNotEmpty) _nameCtrl.text = user.name;
    _applyPhone(user.phone.isNotEmpty ? user.phone : ref.read(authProvider).phoneNumber);
    if (user.email.trim().isNotEmpty) _emailCtrl.text = user.email;
    _savedImagePath = user.profileImageUrl;

    final addr = user.address?.trim();
    if (addr != null && addr.isNotEmpty) {
      final lines = addr.split('\n');
      if (lines.length >= 2) {
        _addressCtrl.text = lines.first.trim();
        final cityPostal = lines.sublist(1).join(' ').trim();
        final comma = cityPostal.lastIndexOf(',');
        if (comma >= 0) {
          _cityCtrl.text = cityPostal.substring(0, comma).trim();
          _postalCtrl.text = cityPostal.substring(comma + 1).trim();
        } else {
          _addressCtrl.text = addr;
        }
      } else {
        _addressCtrl.text = addr;
      }
    }

    if (user.companyName != null) _companyCtrl.text = user.companyName!;
    if (user.gstName != null) _gstNameCtrl.text = user.gstName!;
    if (user.gstNumber != null) _gstNumberCtrl.text = user.gstNumber!;
    if (user.businessEmail != null) _businessEmailCtrl.text = user.businessEmail!;
    if (user.businessPhone != null && user.businessPhone!.isNotEmpty) {
      final split = PhoneUtils.splitE164(user.businessPhone!);
      _businessDialCode = split.dialCode;
      _businessPhoneCtrl.text = split.localNumber;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _cityCtrl.dispose();
    _postalCtrl.dispose();
    _addressCtrl.dispose();
    _companyCtrl.dispose();
    _gstNameCtrl.dispose();
    _gstNumberCtrl.dispose();
    _businessEmailCtrl.dispose();
    _businessPhoneCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  String _buildFullAddress() {
    final parts = <String>[];
    final street = _addressCtrl.text.trim();
    final city = _cityCtrl.text.trim();
    final postal = _postalCtrl.text.trim();
    if (street.isNotEmpty) parts.add(street);
    if (city.isNotEmpty || postal.isNotEmpty) {
      parts.add([city, postal].where((s) => s.isNotEmpty).join(', '));
    }
    return parts.join('\n');
  }

  String? _optionalGst(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return Validators.gstNumber(value);
  }

  String? _resolvedProfileImagePath() =>
      _profileImage?.path ?? _savedImagePath;

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
                onTap: () =>
                    Navigator.pop(sheetContext, ImageSource.camera),
              ),
              ListTile(
                leading:
                    Icon(Icons.photo_library_outlined, color: colors.primary),
                title: Text(l10n.profilePhotoChooseGallery),
                onTap: () =>
                    Navigator.pop(sheetContext, ImageSource.gallery),
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
    if (!await _ensureMediaPermission(source) || !mounted) return;

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

  Future<void> _submit() async {
    safeSetState(() => _submitted = true);
    if (!(_formKey.currentState?.validate() ?? false)) {
      if (_scrollCtrl.hasClients) {
        await _scrollCtrl.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
      return;
    }
    FocusScope.of(context).unfocus();

    final businessPhoneRaw = _businessPhoneCtrl.text.trim();
    final businessPhone = businessPhoneRaw.isEmpty
        ? null
        : PhoneUtils.buildE164(_businessDialCode, businessPhoneRaw);
    final profileImageUrl = _resolvedProfileImagePath();
    final phone = _resolvedPhone();
    final notifier = ref.read(authProvider.notifier);

    if (widget.isEditMode) {
      final saved = await notifier.updateDriverProfile(
        name: _nameCtrl.text.trim(),
        phone: phone,
        email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
        address: _buildFullAddress(),
        companyName:
            _companyCtrl.text.trim().isEmpty ? null : _companyCtrl.text.trim(),
        gstName:
            _gstNameCtrl.text.trim().isEmpty ? null : _gstNameCtrl.text.trim(),
        gstNumber: _gstNumberCtrl.text.trim().isEmpty
            ? null
            : _gstNumberCtrl.text.trim(),
        businessEmail: _businessEmailCtrl.text.trim().isEmpty
            ? null
            : _businessEmailCtrl.text.trim(),
        businessPhone: businessPhone,
        profileImageUrl: profileImageUrl,
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
      context.go(AppRoutes.driverProfile);
      return;
    }

    await notifier.submitDriverProfile(
      name: _nameCtrl.text.trim(),
      phone: phone,
      email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
      address: _buildFullAddress(),
      companyName:
          _companyCtrl.text.trim().isEmpty ? null : _companyCtrl.text.trim(),
      gstName:
          _gstNameCtrl.text.trim().isEmpty ? null : _gstNameCtrl.text.trim(),
      gstNumber: _gstNumberCtrl.text.trim().isEmpty
          ? null
          : _gstNumberCtrl.text.trim(),
      businessEmail: _businessEmailCtrl.text.trim().isEmpty
          ? null
          : _businessEmailCtrl.text.trim(),
      businessPhone: businessPhone,
      profileImageUrl: profileImageUrl,
    );
    if (!mounted) return;
    if (ref.read(authProvider).error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ref.read(authProvider).error!)),
      );
      return;
    }
    context.go(AppRoutes.driverHome);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final isLoading = ref.watch(authProvider).isLoading;
    final title = widget.isEditMode
        ? l10n.driverProfileEditTitle
        : l10n.driverProfileCompleteTitle;
    final ctaLabel = widget.isEditMode
        ? l10n.customerUpdateProfileButton
        : l10n.driverProfileCompleteButton;

    return Scaffold(
      backgroundColor: kDriverProfileBackground,
      appBar: FlowScreenAppBar(
        title: title,
        showBack: true,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Form(
          key: _formKey,
          autovalidateMode: _submitted
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          child: SingleChildScrollView(
            controller: _scrollCtrl,
            padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 32.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: CustomerProfileAvatar(
                    colors: colors,
                    image: _profileImage,
                    savedImagePath: _savedImagePath,
                    onTap: _pickProfileImage,
                  ),
                ),
                SizedBox(height: 24.h),
                DriverProfilePersonalSectionHeader(
                  title: l10n.driverProfilePersonalDetails,
                ),
                SizedBox(height: 12.h),
                DriverProfileSectionCard(
                  child: Column(
                    children: [
                      DriverProfilePersonalField(
                        label: l10n.profileName,
                        hint: 'e.g. Vikram Singh',
                        controller: _nameCtrl,
                        keyboardType: TextInputType.name,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        autofocus: !widget.isEditMode,
                        validator: (v) => Validators.required(v, l10n.profileName),
                      ),
                      SizedBox(height: 16.h),
                      AppPhoneField(
                        label: l10n.profilePhone,
                        labelStyle: AppPhoneFieldLabelStyle.profilePersonal,
                        size: AppPhoneFieldSize.compact,
                        controller: _phoneCtrl,
                        dialCode: _dialCode,
                        onDialCodeChanged: (code) => safeSetState(
                          () => _dialCode = code.dialCode ?? '+91',
                        ),
                      ),
                      SizedBox(height: 16.h),
                      DriverProfilePersonalField(
                        label: l10n.profileEmailOptional,
                        hint: 'john@carrier.com',
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return null;
                          return Validators.email(v);
                        },
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: DriverProfilePersonalField(
                              label: l10n.profileCity,
                              hint: 'Ahmedabad',
                              controller: _cityCtrl,
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: DriverProfilePersonalField(
                              label: l10n.profilePostalCode,
                              hint: '001238',
                              controller: _postalCtrl,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      DriverProfileAddressField(
                        label: l10n.profileFullAddress,
                        hint: 'Street number, building...',
                        controller: _addressCtrl,
                        textInputAction: TextInputAction.next,
                        validator: (v) =>
                            Validators.required(v, l10n.profileFullAddress),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
                DriverProfileBusinessSectionHeader(
                  title: l10n.driverProfileBusinessDetails,
                ),
                SizedBox(height: 16.h),
                DriverProfileSectionCard(
                  borderRadius: 16,
                  gap: 20,
                  useBusinessShadow: true,
                  child: Column(
                    children: [
                      DriverProfileBusinessField(
                        label: l10n.profileCompanyName,
                        hint: 'Enter legally registered name',
                        controller: _companyCtrl,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                      ),
                      SizedBox(height: 20.h),
                      DriverProfileBusinessField(
                        label: l10n.profileGstName,
                        hint: 'GST name',
                        controller: _gstNameCtrl,
                        textInputAction: TextInputAction.next,
                      ),
                      SizedBox(height: 20.h),
                      DriverProfileBusinessField(
                        label: l10n.profileGstNumberOptional,
                        hint: '22AAAAA0000A1Z5',
                        controller: _gstNumberCtrl,
                        textCapitalization: TextCapitalization.characters,
                        textInputAction: TextInputAction.next,
                        validator: _optionalGst,
                      ),
                      SizedBox(height: 20.h),
                      DriverProfileBusinessField(
                        label: l10n.profileBusinessEmail,
                        hint: 'name@company.com',
                        controller: _businessEmailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return null;
                          return Validators.email(v);
                        },
                      ),
                      SizedBox(height: 20.h),
                      DriverProfileBusinessPhoneField(
                        label: l10n.profileBusinessPhone,
                        hint: '00000 00000',
                        controller: _businessPhoneCtrl,
                        dialCode: _businessDialCode,
                        onDialCodeChanged: (code) => safeSetState(
                          () => _businessDialCode = code.dialCode ?? '+91',
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
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
                          backgroundColor: colors.primary,
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
                                ctaLabel,
                                style: TextStyle(
                                  fontFamily: 'Manrope',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
