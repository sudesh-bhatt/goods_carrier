import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/mixins/safe_set_state_mixin.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/services/google_places_service.dart';
import '../../../../core/utils/map_location_helper.dart';
import '../../../../core/utils/validators.dart';
import '../../../../res/font_res.dart';
import '../../../../shared/domain/enums/saved_address_label.dart';
import '../../../../shared/presentation/widgets/navigation/app_bar_widget.dart';
import '../../../../shared/presentation/widgets/navigation/confirmation_bottom_sheet.dart';
import '../../../customer/presentation/widgets/saved_addresses/add_address_autocomplete_field.dart';
import '../../../customer/presentation/widgets/saved_addresses/add_address_form_widgets.dart';
import '../../../customer/presentation/widgets/saved_addresses/address_map_picker.dart';
import '../../../customer/presentation/widgets/saved_addresses/saved_address_tokens.dart';
import '../providers/driver_saved_addresses_provider.dart';

/// Driver add / edit saved address — API `/api/driver/addresses`.
class DriverAddAddressScreen extends ConsumerStatefulWidget {
  const DriverAddAddressScreen({super.key, this.addressId});

  final int? addressId;

  @override
  ConsumerState<DriverAddAddressScreen> createState() =>
      _DriverAddAddressScreenState();
}

class _DriverAddAddressScreenState extends ConsumerState<DriverAddAddressScreen>
    with SafeSetStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _fullAddressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _pincodeCtrl = TextEditingController();

  SavedAddressLabel _label = SavedAddressLabel.home;
  late LatLng _position;
  bool _initialized = false;
  bool _saving = false;
  bool _submitted = false;
  bool _isDefault = false;

  bool get _isEditing => widget.addressId != null;

  @override
  void initState() {
    super.initState();
    _position = MapLocationHelper.defaultPosition;
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final existing = _isEditing
        ? ref.read(driverSavedAddressesProvider.notifier).byId(
              widget.addressId!.toString(),
            )
        : null;

    if (existing != null) {
      safeSetState(() {
        _label = existing.labelEnum;
        _fullAddressCtrl.text = existing.addressLine;
        _cityCtrl.text = existing.city;
        _stateCtrl.text = existing.state;
        _pincodeCtrl.text = existing.pincode;
        _isDefault = existing.isDefault;
      });
    }

    final resolved = await MapLocationHelper.resolveInitialPosition(
      savedLatitude: existing?.latitudeValue,
      savedLongitude: existing?.longitudeValue,
    );

    if (mounted) {
      safeSetState(() {
        _position = resolved;
        _initialized = true;
      });
    }
  }

  @override
  void dispose() {
    _fullAddressCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _pincodeCtrl.dispose();
    super.dispose();
  }

  void _onPlaceSelected(PlaceAddressDetails details) {
    safeSetState(() {
      if (details.city.isNotEmpty) _cityCtrl.text = details.city;
      if (details.state.isNotEmpty) _stateCtrl.text = details.state;
      if (details.pincode.isNotEmpty) _pincodeCtrl.text = details.pincode;
      if (MapLocationHelper.isValidCoordinate(
        details.latitude,
        details.longitude,
      )) {
        _position = LatLng(details.latitude, details.longitude);
      }
    });
  }

  Future<void> _save() async {
    safeSetState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;

    safeSetState(() => _saving = true);
    final ok = await ref.read(driverSavedAddressesProvider.notifier).saveAddress(
          id: widget.addressId,
          label: _label,
          addressLine: _fullAddressCtrl.text.trim(),
          city: _cityCtrl.text.trim(),
          stateName: _stateCtrl.text.trim(),
          pincode: _pincodeCtrl.text.trim(),
          latitude: _position.latitude,
          longitude: _position.longitude,
          isDefault: _isDefault,
        );
    if (!mounted) return;
    safeSetState(() => _saving = false);

    if (!ok) {
      final error = ref.read(driverSavedAddressesProvider).error;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.customerAddressSaved)),
    );
    context.pop();
  }

  Future<void> _delete() async {
    final id = widget.addressId;
    if (id == null) return;

    final l10n = context.l10n;
    final confirmed = await ConfirmationBottomSheet.show(
      context,
      title: l10n.driverAddressDeleteTitle,
      body: l10n.driverAddressDeleteBody,
      confirmLabel: l10n.actionYes,
      cancelLabel: l10n.actionNo,
      headerIcon: Icons.delete_outline_rounded,
      isDangerous: true,
    );
    if (confirmed != true || !mounted) return;

    safeSetState(() => _saving = true);
    final ok =
        await ref.read(driverSavedAddressesProvider.notifier).deleteAddress(id);
    if (!mounted) return;
    safeSetState(() => _saving = false);

    if (!ok) {
      final error = ref.read(driverSavedAddressesProvider).error;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.driverAddressDeleted)),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final title = _isEditing
        ? l10n.customerEditAddressScreenTitle
        : l10n.customerAddAddressTitle;

    return Scaffold(
      backgroundColor: SavedAddressTokens.screenBg,
      appBar: FlowScreenAppBar(
        title: title,
        fallbackRoute: AppRoutes.driverSavedAddresses,
        actions: _isEditing
            ? [
                AppBarAction(
                  icon: Icons.delete_outline_rounded,
                  onTap: () {
                    if (!_saving) _delete();
                  },
                ),
              ]
            : const [],
      ),
      body: !_initialized
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => FocusScope.of(context).unfocus(),
                    behavior: HitTestBehavior.opaque,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
                      child: Form(
                        key: _formKey,
                        autovalidateMode: _submitted
                            ? AutovalidateMode.onUserInteraction
                            : AutovalidateMode.disabled,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AddressMapPicker(
                              position: _position,
                              onPositionChanged: (latLng) {
                                safeSetState(() => _position = latLng);
                              },
                            ),
                            SizedBox(height: 32.h),
                            AddAddressSectionLabel(
                              text: l10n.customerSelectAddressLabel,
                            ),
                            SizedBox(height: 16.h),
                            AddressLabelChipRow(
                              selected: _label,
                              onSelected: (v) =>
                                  safeSetState(() => _label = v),
                              homeLabel: l10n.customerAddressLabelHome,
                              officeLabel: l10n.customerAddressLabelOffice,
                              otherLabel: l10n.customerAddressLabelOther,
                            ),
                            SizedBox(height: 32.h),
                            AddAddressAutocompleteField(
                              label: l10n.customerAddressFullLine,
                              hint: l10n.customerAddressFullLineHint,
                              controller: _fullAddressCtrl,
                              onPlaceSelected: _onPlaceSelected,
                              textInputAction: TextInputAction.next,
                              autovalidateMode: _submitted
                                  ? AutovalidateMode.onUserInteraction
                                  : AutovalidateMode.disabled,
                              validator: (v) => Validators.required(
                                v,
                                l10n.customerAddressFullLine,
                              ),
                            ),
                            SizedBox(height: 24.h),
                            AddAddressTextField(
                              label: l10n.customerAddressCity,
                              hint: l10n.customerAddressCityHint,
                              controller: _cityCtrl,
                              icon: Icons.location_city_outlined,
                              textInputAction: TextInputAction.next,
                              validator: (v) =>
                                  Validators.required(v, l10n.customerAddressCity),
                            ),
                            SizedBox(height: 24.h),
                            AddAddressTextField(
                              label: l10n.customerAddressState,
                              hint: l10n.customerAddressStateHint,
                              controller: _stateCtrl,
                              icon: Icons.map_outlined,
                              textInputAction: TextInputAction.next,
                              validator: (v) =>
                                  Validators.required(v, l10n.customerAddressState),
                            ),
                            SizedBox(height: 24.h),
                            AddAddressTextField(
                              label: l10n.customerAddressPincode,
                              hint: l10n.customerAddressPincodeHint,
                              controller: _pincodeCtrl,
                              icon: Icons.pin_drop_outlined,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                              validator: (v) => Validators.required(
                                v,
                                l10n.customerAddressPincode,
                              ),
                            ),
                            SizedBox(height: 24.h),
                            SwitchListTile.adaptive(
                              contentPadding: EdgeInsets.zero,
                              value: _isDefault,
                              onChanged: _saving
                                  ? null
                                  : (value) =>
                                      safeSetState(() => _isDefault = value),
                              title: Text(
                                l10n.driverAddressSetDefault,
                                style: TextStyle(
                                  fontFamily: FontRes.MANROPE_BOLD,
                                  fontSize: 16.sp,
                                  color: SavedAddressTokens.cardTitle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                _StickySaveBar(
                  label: l10n.customerSaveAddress,
                  loading: _saving,
                  onPressed: _save,
                ),
              ],
            ),
    );
  }
}

class _StickySaveBar extends StatelessWidget {
  const _StickySaveBar({
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
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(24.w),
          color: SavedAddressTokens.screenBg.withValues(alpha: 0.8),
          child: Material(
            color: SavedAddressTokens.chipSelected,
            borderRadius: BorderRadius.circular(24.r),
            child: InkWell(
              onTap: loading ? null : onPressed,
              borderRadius: BorderRadius.circular(24.r),
              child: SizedBox(
                height: 68.h,
                child: Center(
                  child: loading
                      ? SizedBox(
                          width: 24.w,
                          height: 24.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          label,
                          style: TextStyle(
                            fontFamily: FontRes.MANROPE_BOLD,
                            fontSize: 18.sp,
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
