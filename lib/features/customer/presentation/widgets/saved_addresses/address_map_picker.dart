import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../../core/config/google_maps_config.dart';
import '../../../../../core/extensions/size_ext.dart';
import '../../../../../core/extensions/theme_ext.dart';
import '../../../../../core/mixins/safe_set_state_mixin.dart';
import '../../../../../core/services/google_maps_setup_checker.dart';
import '../../../../../core/utils/map_location_helper.dart';
import '../../../../../res/font_res.dart';
import 'saved_address_tokens.dart';

/// Map with centered pin — user pans map to adjust location (Figma `1:3201`).
class AddressMapPicker extends StatefulWidget {
  const AddressMapPicker({
    super.key,
    required this.position,
    required this.onPositionChanged,
  });

  final LatLng position;
  final ValueChanged<LatLng> onPositionChanged;

  @override
  State<AddressMapPicker> createState() => _AddressMapPickerState();
}

class _AddressMapPickerState extends State<AddressMapPicker>
    with SafeSetStateMixin {
  GoogleMapController? _mapController;
  late LatLng _mapCenter;
  bool _locating = false;
  bool _myLocationEnabled = false;
  bool _userDraggingMap = false;
  LatLng? _pendingCameraTarget;

  static final _mapGestures = <Factory<OneSequenceGestureRecognizer>>{
    Factory<EagerGestureRecognizer>(() => EagerGestureRecognizer()),
  };

  @override
  void initState() {
    super.initState();
    _mapCenter = widget.position;
    _refreshMyLocationLayer();
    GoogleMapsSetupChecker.logSetupHintsIfNeeded();
  }

  @override
  void didUpdateWidget(AddressMapPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.position != widget.position &&
        !_userDraggingMap &&
        _distance(widget.position, _mapCenter) > 0.0001) {
      _mapCenter = widget.position;
      _moveCameraTo(_mapCenter);
    }
  }

  Future<void> _refreshMyLocationLayer() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    final enabled = permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
    if (mounted && enabled != _myLocationEnabled) {
      safeSetState(() => _myLocationEnabled = enabled);
    }
  }

  double _distance(LatLng a, LatLng b) {
    return (a.latitude - b.latitude).abs() +
        (a.longitude - b.longitude).abs();
  }

  Future<void> _moveCameraTo(LatLng target, {double zoom = 16}) async {
    _mapCenter = target;
    _pendingCameraTarget = target;

    final controller = _mapController;
    if (controller == null) return;

    try {
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: target, zoom: zoom),
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AddressMapPicker] camera move failed: $e');
      }
    }
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    _mapController = controller;
    if (kDebugMode) {
      debugPrint(
        '[AddressMapPicker] map ready at '
        '${_mapCenter.latitude}, ${_mapCenter.longitude} '
        'envKeyConfigured=${GoogleMapsConfig.isConfigured}',
      );
    }
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final target = _pendingCameraTarget ?? _mapCenter;
    await _moveCameraTo(target);
  }

  Future<void> _goToCurrentLocation() async {
    safeSetState(() => _locating = true);
    try {
      await _refreshMyLocationLayer();
      final target = await MapLocationHelper.getFreshCurrentLocation();
      if (target == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.customerLocationPermissionNeeded),
            ),
          );
        }
        return;
      }

      safeSetState(() => _mapCenter = target);
      widget.onPositionChanged(target);
      await _moveCameraTo(target);
    } finally {
      if (mounted) safeSetState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = 224.h;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24.r),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _mapCenter,
                zoom: 16,
              ),
              gestureRecognizers: _mapGestures,
              onMapCreated: _onMapCreated,
              onCameraMoveStarted: () {
                _userDraggingMap = true;
              },
              onCameraMove: (position) {
                _mapCenter = position.target;
              },
              onCameraIdle: () {
                _userDraggingMap = false;
                widget.onPositionChanged(_mapCenter);
              },
              myLocationEnabled: _myLocationEnabled,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
              scrollGesturesEnabled: true,
              zoomGesturesEnabled: true,
              rotateGesturesEnabled: false,
              tiltGesturesEnabled: false,
              mapType: MapType.normal,
            ),
            if (!GoogleMapsConfig.isConfigured)
              Positioned.fill(
                child: ColoredBox(
                  color: SavedAddressTokens.fieldFill,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Text(
                        'Add GOOGLE_API_KEY to .env and run '
                        'dart run tool/sync_env.dart',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: FontRes.MANROPE_MEDIUM,
                          fontSize: 12.sp,
                          color: SavedAddressTokens.hintGrey,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            IgnorePointer(
              child: Center(child: _CenterMapPin()),
            ),
            Positioned(
              right: 16.w,
              bottom: 16.h,
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                elevation: 4,
                shadowColor: Colors.black.withValues(alpha: 0.12),
                child: InkWell(
                  onTap: _locating ? null : _goToCurrentLocation,
                  borderRadius: BorderRadius.circular(16.r),
                  child: SizedBox(
                    width: 38.w,
                    height: 38.w,
                    child: _locating
                        ? Padding(
                            padding: EdgeInsets.all(10.w),
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(
                            Icons.my_location_rounded,
                            size: 22.w,
                            color: SavedAddressTokens.cardTitle,
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterMapPin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 52.w,
          height: 52.w,
          decoration: BoxDecoration(
            color: SavedAddressTokens.chipSelected,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.5),
              width: 4,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.1),
                blurRadius: 15,
                offset: Offset(0, 10),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.location_on_rounded,
            size: 24.w,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 4.h),
        Container(
          width: 8.w,
          height: 8.w,
          decoration: const BoxDecoration(
            color: Color.fromRGBO(22, 28, 32, 0.2),
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}
