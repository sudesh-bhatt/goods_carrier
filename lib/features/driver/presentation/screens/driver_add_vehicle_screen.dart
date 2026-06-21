import 'dart:io';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/config/env_config.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/mixins/safe_set_state_mixin.dart';
import '../../../../core/network/api_exception_mapper.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/media_permission_helper.dart';
import '../../../../core/utils/profile_image_utils.dart';
import '../../../../core/utils/validators.dart';
import '../../../../res/font_res.dart';
import '../../../../shared/domain/models/driver_vehicle_detail.dart';
import '../../../../shared/domain/models/driver_vehicle_masters.dart';
import '../../../../shared/presentation/widgets/inputs/app_phone_field.dart';
import '../../../../shared/presentation/widgets/navigation/app_bar_widget.dart';
import '../../../auth/presentation/widgets/driver_profile_form_widgets.dart';
import '../providers/driver_vehicles_provider.dart';
import '../widgets/vehicles/driver_vehicle_tokens.dart';

/// Add / edit vehicle — [Figma](https://www.figma.com/design/YxnNResvDQnbkcPhGejtxa/Mobile-App-UI--Developer-?node-id=1-185).
class DriverAddVehicleScreen extends ConsumerStatefulWidget {
  const DriverAddVehicleScreen({super.key, this.vehicleId});

  final int? vehicleId;

  @override
  ConsumerState<DriverAddVehicleScreen> createState() =>
      _DriverAddVehicleScreenState();
}

class _DriverAddVehicleScreenState extends ConsumerState<DriverAddVehicleScreen>
    with SafeSetStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _registrationCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController();
  final _driverNameCtrl = TextEditingController();
  final _driverPhoneCtrl = TextEditingController();
  final _imagePicker = ImagePicker();

  DriverVehicleMasters? _masters;
  DriverVehicleTypeOption? _selectedType;
  String _capacityUnit = 'TON';
  String _dialCode = '+91';
  bool _loading = true;
  bool _saving = false;
  bool _submitted = false;
  String? _loadError;

  String? _licenseFrontPath;
  String? _licenseBackPath;
  String? _profilePhotoPath;
  String? _vehiclePhotoPath;

  bool get _isEditing => widget.vehicleId != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    safeSetState(() {
      _loading = true;
      _loadError = null;
    });

    try {
      final masters =
          await ref.read(driverVehiclesProvider.notifier).fetchMasters();
      DriverVehicleDetail? existing;
      if (_isEditing) {
        existing = await ref
            .read(driverVehiclesProvider.notifier)
            .fetchDetail(widget.vehicleId!);
      }

      if (!mounted) return;
      safeSetState(() {
        _masters = masters;
        DriverVehicleTypeOption? selected;
        if (existing != null) {
          for (final type in masters.vehicleTypes) {
            if (type.id == existing.vehicleTypeId) {
              selected = type;
              break;
            }
          }
        }
        _selectedType = selected ??
            (masters.vehicleTypes.isNotEmpty ? masters.vehicleTypes.first : null);
        _capacityUnit = existing?.capacityUnit ??
            (masters.capacityUnits.isNotEmpty ? masters.capacityUnits.first : 'TON');

        if (existing != null) {
          _registrationCtrl.text = existing.registrationNumber;
          _capacityCtrl.text = existing.capacity == existing.capacity.truncateToDouble()
              ? existing.capacity.toInt().toString()
              : existing.capacity.toString();
          _driverNameCtrl.text = existing.driverName;
          _dialCode = existing.driverCountryCode;
          _driverPhoneCtrl.text = existing.driverPhone;
          _profilePhotoPath = existing.profilePhotoUrl;
          _licenseFrontPath = existing.licenseFrontUrl;
          _licenseBackPath = existing.licenseBackUrl;
          _vehiclePhotoPath = existing.vehiclePhotoUrl;
        }

        _loading = false;
        if (_isEditing && existing == null) {
          _loadError = context.l10n.driverVehicleLoadFailed;
        }
      });
    } catch (e) {
      if (!mounted) return;
      safeSetState(() {
        _loading = false;
        _loadError = ApiExceptionMapper.userMessage(e);
      });
    }
  }

  @override
  void dispose() {
    _registrationCtrl.dispose();
    _capacityCtrl.dispose();
    _driverNameCtrl.dispose();
    _driverPhoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(void Function(String path) onPicked) async {
    final access = await MediaPermissionHelper.ensureGallery();
    if (access == GalleryAccessResult.denied ||
        access == GalleryAccessResult.permanentlyDenied) {
      return;
    }
    final file = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) return;
    onPicked(file.path);
    safeSetState(() {});
  }

  Future<void> _submit() async {
    safeSetState(() => _submitted = true);
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.driverTripFormVehicleRequired)),
      );
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;

    safeSetState(() => _saving = true);
    try {
      if (!EnvConfig.useRemoteApi) {
        if (!mounted) return;
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? context.l10n.driverVehicleUpdated
                  : context.l10n.driverVehicleAdded,
            ),
          ),
        );
        return;
      }

      final formData = await _buildFormData();
      final client = ref.read(driverVehicleApiClientProvider);
      if (_isEditing) {
        await client.updateVehicle(widget.vehicleId!, formData);
      } else {
        await client.addVehicle(formData);
      }
      await ref.read(driverVehiclesProvider.notifier).load();
      if (!mounted) return;
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? context.l10n.driverVehicleUpdated
                : context.l10n.driverVehicleAdded,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ApiExceptionMapper.userMessage(e))),
      );
    } finally {
      if (mounted) safeSetState(() => _saving = false);
    }
  }

  Future<FormData> _buildFormData() async {
    final fields = <String, dynamic>{
      'vehicle_type_id': _selectedType!.id.toString(),
      'registration_number': _registrationCtrl.text.trim(),
      'capacity': _capacityCtrl.text.trim(),
      'capacity_unit': _capacityUnit,
      'driver_name': _driverNameCtrl.text.trim(),
      'driver_country_code': _dialCode,
      'driver_phone': _driverPhoneCtrl.text.trim(),
    };

    if (!EnvConfig.useRemoteApi) {
      return FormData.fromMap(fields);
    }

    if (ProfileImageUtils.isLocalFileAvailable(_licenseFrontPath)) {
      fields['license_front'] = await MultipartFile.fromFile(_licenseFrontPath!);
    }
    if (ProfileImageUtils.isLocalFileAvailable(_licenseBackPath)) {
      fields['license_back'] = await MultipartFile.fromFile(_licenseBackPath!);
    }
    if (ProfileImageUtils.isLocalFileAvailable(_profilePhotoPath)) {
      fields['profile_photo'] = await MultipartFile.fromFile(_profilePhotoPath!);
    }
    if (ProfileImageUtils.isLocalFileAvailable(_vehiclePhotoPath)) {
      fields['vehicle_photo'] = await MultipartFile.fromFile(_vehiclePhotoPath!);
    }

    return FormData.fromMap(fields);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: DriverVehicleTokens.screenBg,
      appBar: FlowScreenAppBar(
        title: _isEditing ? l10n.driverEditVehicleTitle : l10n.driverAddVehicleTitle,
        fallbackRoute: _isEditing
            ? AppRoutes.driverVehicleDetailOf(widget.vehicleId!)
            : AppRoutes.driverVehicles,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
              ? Center(child: Text(_loadError!))
              : Form(
                  key: _formKey,
                  autovalidateMode: _submitted
                      ? AutovalidateMode.onUserInteraction
                      : AutovalidateMode.disabled,
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView(
                          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
                          children: [
                            _HeroImageCard(
                              imagePath: _vehiclePhotoPath,
                              fleetCode: _registrationCtrl.text.isEmpty
                                  ? 'V-902-XLR'
                                  : _registrationCtrl.text,
                              onPick: () => _pickImage((p) => _vehiclePhotoPath = p),
                            ),
                            SizedBox(height: 32.h),
                            DriverProfileSectionCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _SectionHeading(
                                    icon: Icons.settings_outlined,
                                    title: l10n.driverTechnicalSpecifications,
                                  ),
                                  SizedBox(height: 24.h),
                                  _VehicleTypeDropdown(
                                    types: _masters?.vehicleTypes ?? const [],
                                    value: _selectedType,
                                    label: l10n.driverVehicleTypeLabel,
                                    onChanged: (v) => safeSetState(() => _selectedType = v),
                                  ),
                                  SizedBox(height: 24.h),
                                  DriverProfilePersonalField(
                                    label: l10n.driverVehicleRegistrationLabel,
                                    controller: _registrationCtrl,
                                    hint: 'MH-12-PQ-8834',
                                    textCapitalization: TextCapitalization.characters,
                                    validator: (v) => Validators.required(
                                      v,
                                      l10n.driverVehicleRegistrationLabel,
                                    ),
                                  ),
                                  SizedBox(height: 24.h),
                                  DriverProfilePersonalField(
                                    label: l10n.driverVehicleCapacityLabel,
                                    controller: _capacityCtrl,
                                    hint: '12',
                                    keyboardType: const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d*\.?\d{0,2}'),
                                      ),
                                    ],
                                    suffix: Text(
                                      _capacityUnit,
                                      style: TextStyle(
                                        fontFamily: FontRes.MANROPE_BOLD,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w700,
                                        color: DriverVehicleTokens.accentBrown,
                                      ),
                                    ),
                                    validator: (v) => Validators.required(
                                      v,
                                      l10n.driverVehicleCapacityLabel,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 32.h),
                            _SectionHeading(
                              icon: Icons.verified_user_outlined,
                              title: l10n.driverVerificationSection,
                              accentIcon: true,
                            ),
                            SizedBox(height: 12.h),
                            DriverProfileSectionCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  DriverProfilePersonalField(
                                    label: l10n.profileName,
                                    controller: _driverNameCtrl,
                                    hint: l10n.driverTripFormDriverNameHint,
                                    textCapitalization: TextCapitalization.words,
                                    validator: (v) =>
                                        Validators.required(v, l10n.profileName),
                                  ),
                                  SizedBox(height: 16.h),
                                  AppPhoneField(
                                    controller: _driverPhoneCtrl,
                                    dialCode: _dialCode,
                                    onDialCodeChanged: (code) => safeSetState(
                                      () => _dialCode = code.dialCode ?? '+91',
                                    ),
                                    label: l10n.profilePhone,
                                    labelStyle: AppPhoneFieldLabelStyle.profilePersonal,
                                    size: AppPhoneFieldSize.compact,
                                    validator: (v) =>
                                        Validators.phoneForCountry(_dialCode, v),
                                  ),
                                  SizedBox(height: 16.h),
                                  _UploadPairSection(
                                    title: l10n.driverLicenseUploadTitle,
                                    frontLabel: l10n.driverLicenseFront,
                                    backLabel: l10n.driverLicenseBack,
                                    frontPath: _licenseFrontPath,
                                    backPath: _licenseBackPath,
                                    onPickFront: () =>
                                        _pickImage((p) => _licenseFrontPath = p),
                                    onPickBack: () =>
                                        _pickImage((p) => _licenseBackPath = p),
                                  ),
                                  SizedBox(height: 16.h),
                                  _ProfilePhotoSection(
                                    title: l10n.driverProfilePhotoTitle,
                                    subtitle: l10n.driverProfilePhotoHint,
                                    body: l10n.driverProfilePhotoBody,
                                    imagePath: _profilePhotoPath,
                                    onPick: () =>
                                        _pickImage((p) => _profilePhotoPath = p),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      _StickySubmitBar(
                        label: _isEditing ? l10n.driverUpdateVehicle : l10n.driverAddVehicle,
                        loading: _saving,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _HeroImageCard extends StatelessWidget {
  const _HeroImageCard({
    required this.imagePath,
    required this.fleetCode,
    required this.onPick,
  });

  final String? imagePath;
  final String fleetCode;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final network = ProfileImageUtils.resolveNetworkUrl(imagePath);
    final local = ProfileImageUtils.isLocalFileAvailable(imagePath);

    return GestureDetector(
      onTap: onPick,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: SizedBox(
          height: 192.h,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (local)
                Image.file(File(imagePath!), fit: BoxFit.cover)
              else if (network != null)
                Image.network(network, fit: BoxFit.cover)
              else
                Container(
                  color: const Color(0xFF161C20),
                  child: Icon(Icons.local_shipping_rounded,
                      size: 64.w, color: Colors.white24),
                ),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Color.fromRGBO(22, 28, 32, 0.6),
                      Color.fromRGBO(22, 28, 32, 0),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 16.w,
                bottom: 16.h,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: DriverVehicleTokens.fleetBadgeBlue,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(
                        l10n.driverPrimaryFleetBadge,
                        style: TextStyle(
                          fontFamily: FontRes.MANROPE_BOLD,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          height: 15 / 10,
                          letterSpacing: 1,
                          color: DriverVehicleTokens.fleetBadgeText,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      fleetCode,
                      style: TextStyle(
                        fontFamily: FontRes.MANROPE_EXTRABOLD,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w800,
                        height: 32 / 24,
                        letterSpacing: -0.6,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.icon,
    required this.title,
    this.accentIcon = false,
  });

  final IconData icon;
  final String title;
  final bool accentIcon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w),
      child: Row(
        children: [
          Icon(
            icon,
            size: accentIcon ? 16.w : 15.w,
            color: accentIcon
                ? DriverVehicleTokens.accentOrange
                : DriverVehicleTokens.labelBrown,
          ),
          SizedBox(width: 8.w),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontFamily: FontRes.MANROPE_BOLD,
              fontSize: accentIcon ? 12.sp : 14.sp,
              fontWeight: FontWeight.w700,
              height: accentIcon ? 16 / 12 : 20 / 14,
              letterSpacing: accentIcon ? 1.2 : 1.4,
              color: DriverVehicleTokens.labelBrown,
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleTypeDropdown extends StatelessWidget {
  const _VehicleTypeDropdown({
    required this.types,
    required this.value,
    required this.label,
    required this.onChanged,
  });

  final List<DriverVehicleTypeOption> types;
  final DriverVehicleTypeOption? value;
  final String label;
  final ValueChanged<DriverVehicleTypeOption?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: FontRes.MANROPE_SEMIBOLD,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: DriverVehicleTokens.labelBrown,
            ),
          ),
        ),
        DropdownButtonFormField<DriverVehicleTypeOption>(
          value: value,
          items: types
              .map(
                (t) => DropdownMenuItem(
                  value: t,
                  child: Text(t.name),
                ),
              )
              .toList(growable: false),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: DriverVehicleTokens.fieldFill,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          ),
        ),
      ],
    );
  }
}

class _UploadPairSection extends StatelessWidget {
  const _UploadPairSection({
    required this.title,
    required this.frontLabel,
    required this.backLabel,
    required this.frontPath,
    required this.backPath,
    required this.onPickFront,
    required this.onPickBack,
  });

  final String title;
  final String frontLabel;
  final String backLabel;
  final String? frontPath;
  final String? backPath;
  final VoidCallback onPickFront;
  final VoidCallback onPickBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontFamily: FontRes.MANROPE_BOLD,
            fontSize: 10.sp,
            fontWeight: FontWeight.w700,
            height: 15 / 10,
            color: DriverVehicleTokens.labelBrown,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: _UploadTile(
                label: frontLabel,
                imagePath: frontPath,
                onTap: onPickFront,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _UploadTile(
                label: backLabel,
                imagePath: backPath,
                onTap: onPickBack,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _UploadTile extends StatelessWidget {
  const _UploadTile({
    required this.label,
    required this.imagePath,
    required this.onTap,
  });

  final String label;
  final String? imagePath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final local = ProfileImageUtils.isLocalFileAvailable(imagePath);
    final network = ProfileImageUtils.resolveNetworkUrl(imagePath);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        height: 98.h,
        decoration: BoxDecoration(
          color: DriverVehicleTokens.fieldFill,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: const Color.fromRGBO(226, 191, 176, 0.3),
            width: 2,
          ),
        ),
        child: local || network != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(14.r),
                child: local
                    ? Image.file(File(imagePath!), fit: BoxFit.cover, width: double.infinity)
                    : Image.network(network!, fit: BoxFit.cover, width: double.infinity),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined,
                      size: 22.w, color: DriverVehicleTokens.labelBrown),
                  SizedBox(height: 8.h),
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: FontRes.MANROPE_SEMIBOLD,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color.fromRGBO(89, 65, 54, 0.6),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _ProfilePhotoSection extends StatelessWidget {
  const _ProfilePhotoSection({
    required this.title,
    required this.subtitle,
    required this.body,
    required this.imagePath,
    required this.onPick,
  });

  final String title;
  final String subtitle;
  final String body;
  final String? imagePath;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final local = ProfileImageUtils.isLocalFileAvailable(imagePath);
    final network = ProfileImageUtils.resolveNetworkUrl(imagePath);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontFamily: FontRes.MANROPE_BOLD,
            fontSize: 10.sp,
            fontWeight: FontWeight.w700,
            color: DriverVehicleTokens.labelBrown,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            GestureDetector(
              onTap: onPick,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: Container(
                      width: 80.w,
                      height: 80.w,
                      color: const Color(0xFFDDE3E9),
                      child: local
                          ? Image.file(File(imagePath!), fit: BoxFit.cover)
                          : network != null
                              ? Image.network(network, fit: BoxFit.cover)
                              : Icon(Icons.person_rounded,
                                  color: DriverVehicleTokens.labelBrown),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 24.w,
                      height: 24.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(Icons.edit_outlined, size: 12.w),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: FontRes.MANROPE_MEDIUM,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: DriverVehicleTokens.bodyDark,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    body,
                    style: TextStyle(
                      fontFamily: FontRes.MANROPE_REGULAR,
                      fontSize: 10.sp,
                      height: 16 / 10,
                      color: DriverVehicleTokens.labelBrown,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StickySubmitBar extends StatelessWidget {
  const _StickySubmitBar({
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  final String label;
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(24.w),
          decoration: const BoxDecoration(
            color: Color.fromRGBO(245, 250, 255, 0.95),
            borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(22, 28, 32, 0.05),
                blurRadius: 30,
                offset: Offset(0, -10),
              ),
            ],
          ),
          child: Material(
            color: DriverVehicleTokens.accentOrange,
            borderRadius: BorderRadius.circular(16.r),
            child: InkWell(
              onTap: loading ? null : onPressed,
              borderRadius: BorderRadius.circular(16.r),
              child: SizedBox(
                height: 56.h,
                child: Center(
                  child: loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          label,
                          style: TextStyle(
                            fontFamily: FontRes.MANROPE_BOLD,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
