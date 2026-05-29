import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/mixins/safe_set_state_mixin.dart';
import '../../../../res/font_res.dart';
import '../../../../core/utils/map_location_helper.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/services/google_places_service.dart';
import '../../../../shared/domain/enums/saved_address_label.dart';
import '../../../../shared/domain/entities/saved_address.dart';
import '../providers/customer_saved_addresses_provider.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/presentation/widgets/navigation/app_bar_widget.dart';
import '../widgets/saved_addresses/add_address_autocomplete_field.dart';
import '../widgets/saved_addresses/add_address_form_widgets.dart';
import '../widgets/saved_addresses/address_map_picker.dart';
import '../widgets/saved_addresses/saved_address_tokens.dart';

/// Add / edit address with map pin — [Figma](https://www.figma.com/design/YxnNResvDQnbkcPhGejtxa/Mobile-App-UI--Developer-?node-id=1-3201).
class AddAddressScreen extends ConsumerStatefulWidget {
  const AddAddressScreen({super.key, this.addressId});

  final String? addressId;

  @override
  ConsumerState<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends ConsumerState<AddAddressScreen>
    with SafeSetStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _fullAddressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _pincodeCtrl = TextEditingController();
  final _landmarkCtrl = TextEditingController();

  SavedAddressLabel _label = SavedAddressLabel.home;
  late LatLng _position;
  bool _initialized = false;
  bool _saving = false;
  bool _submitted = false;

  bool get _isEditing => widget.addressId != null;

  @override
  void initState() {
    super.initState();
    _position = MapLocationHelper.defaultPosition;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootstrap();
    });
  }

  Future<void> _bootstrap() async {
    SavedAddress? existing;
    if (_isEditing) {
      existing = ref
          .read(customerSavedAddressesProvider.notifier)
          .byId(widget.addressId!);
    }

    if (existing != null) {
      safeSetState(() {
        _label = existing!.label;
        _fullAddressCtrl.text = existing.fullAddressLine;
        _cityCtrl.text = existing.city;
        _pincodeCtrl.text = existing.pincode;
        _landmarkCtrl.text = existing.landmark ?? '';
      });
    }

    final resolved = await MapLocationHelper.resolveInitialPosition(
      savedLatitude: existing?.latitude,
      savedLongitude: existing?.longitude,
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
    _pincodeCtrl.dispose();
    _landmarkCtrl.dispose();
    super.dispose();
  }

  String _titleForLabel(SavedAddressLabel label) {
    final l10n = context.l10n;
    return switch (label) {
      SavedAddressLabel.home => l10n.customerAddressLabelHome,
      SavedAddressLabel.office => l10n.customerAddressLabelOffice,
      SavedAddressLabel.other => l10n.customerAddressLabelOther,
    };
  }

  void _onPlaceSelected(PlaceAddressDetails details) {
    safeSetState(() {
      if (details.city.isNotEmpty) {
        _cityCtrl.text = details.city;
      }
      if (details.pincode.isNotEmpty) {
        _pincodeCtrl.text = details.pincode;
      }
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
    try {
      final existing = widget.addressId != null
          ? ref
              .read(customerSavedAddressesProvider.notifier)
              .byId(widget.addressId!)
          : null;
      await ref.read(customerSavedAddressesProvider.notifier).upsert(
            id: widget.addressId,
            label: _label,
            title: existing?.title ?? _titleForLabel(_label),
            fullAddressLine: _fullAddressCtrl.text.trim(),
            city: _cityCtrl.text.trim(),
            pincode: _pincodeCtrl.text.trim(),
            latitude: _position.latitude,
            longitude: _position.longitude,
            landmark: _landmarkCtrl.text.trim(),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.customerAddressSaved)),
      );
      context.pop();
    } finally {
      if (mounted) safeSetState(() => _saving = false);
    }
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
        fallbackRoute: AppRoutes.customerHome,
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
                              label: l10n.customerAddressPincode,
                              hint: l10n.customerAddressPincodeHint,
                              controller: _pincodeCtrl,
                              icon: Icons.pin_drop_outlined,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              validator: (v) =>
                                  Validators.required(v, l10n.customerAddressPincode),
                            ),
                            SizedBox(height: 24.h),
                            AddAddressTextField(
                              label: l10n.customerAddressLandmark,
                              hint: l10n.customerAddressLandmarkHint,
                              controller: _landmarkCtrl,
                              icon: Icons.flag_outlined,
                              textInputAction: TextInputAction.done,
                            ),
                            SizedBox(height: 24.h),
                            AddressLandmarkHintCard(
                              message: l10n.customerAddressLandmarkTip,
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
            elevation: 0,
            shadowColor: SavedAddressTokens.chipSelected.withValues(alpha: 0.5),
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
