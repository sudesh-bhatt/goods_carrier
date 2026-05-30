import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/config/google_places_config.dart';
import '../../../../../core/extensions/size_ext.dart';
import '../../../../../core/extensions/theme_ext.dart';
import '../../../../../core/mixins/safe_set_state_mixin.dart';
import '../../../../../core/providers/google_places_provider.dart';
import '../../../../../core/services/google_places_service.dart';
import '../../../../../res/font_res.dart';
import 'shipment_form_tokens.dart';

/// Shipment form route field with Google Places autocomplete (India).
class ShipmentFormPlacesAutocomplete extends ConsumerStatefulWidget {
  const ShipmentFormPlacesAutocomplete({
    super.key,
    required this.leading,
    required this.controller,
    required this.hint,
    required this.onPlaceSelected,
    this.validator,
  });

  final Widget leading;
  final TextEditingController controller;
  final String hint;
  final ValueChanged<PlaceAddressDetails> onPlaceSelected;
  final String? Function(String?)? validator;

  @override
  ConsumerState<ShipmentFormPlacesAutocomplete> createState() =>
      _ShipmentFormPlacesAutocompleteState();
}

class _ShipmentFormPlacesAutocompleteState
    extends ConsumerState<ShipmentFormPlacesAutocomplete>
    with SafeSetStateMixin {
  static const _debounceMs = 350;

  final _focusNode = FocusNode();
  Timer? _debounce;
  String _sessionToken = _newSessionToken();
  List<PlacePrediction> _predictions = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  static String _newSessionToken() =>
      '${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(1 << 32)}';

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      Future<void>.delayed(const Duration(milliseconds: 180), () {
        if (mounted && !_focusNode.hasFocus) {
          safeSetState(() => _predictions = []);
        }
      });
    } else {
      _sessionToken = _newSessionToken();
    }
  }

  void _onQueryChanged(String query, FormFieldState<String> field) {
    field.didChange(query);
    _debounce?.cancel();

    if (!GooglePlacesConfig.isConfigured || query.trim().length < 3) {
      safeSetState(() {
        _predictions = [];
        _isLoading = false;
        _error = null;
      });
      return;
    }

    safeSetState(() {
      _isLoading = true;
      _error = null;
    });

    _debounce = Timer(const Duration(milliseconds: _debounceMs), () async {
      try {
        final service = ref.read(googlePlacesServiceProvider);
        final results = await service.fetchPredictions(
          input: query,
          sessionToken: _sessionToken,
        );
        if (!mounted) return;
        safeSetState(() {
          _predictions = results;
          _isLoading = false;
        });
      } on GooglePlacesException catch (e) {
        if (!mounted) return;
        safeSetState(() {
          _predictions = [];
          _isLoading = false;
          _error = e.displayMessage;
        });
      } catch (_) {
        if (!mounted) return;
        safeSetState(() {
          _predictions = [];
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _selectPrediction(
    PlacePrediction prediction,
    FormFieldState<String> field,
  ) async {
    safeSetState(() {
      _predictions = [];
      _isLoading = true;
    });
    FocusScope.of(context).unfocus();

    try {
      final service = ref.read(googlePlacesServiceProvider);
      final details = await service.fetchPlaceAddressDetails(
        placeId: prediction.placeId,
        sessionToken: _sessionToken,
      );
      if (!mounted) return;
      final display = prediction.description;
      widget.controller.text = display;
      field.didChange(display);
      widget.onPlaceSelected(details);
    } on GooglePlacesException catch (_) {
      if (!mounted) return;
      widget.controller.text = prediction.description;
      field.didChange(prediction.description);
    } finally {
      _sessionToken = _newSessionToken();
      if (mounted) safeSetState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return FormField<String>(
      initialValue: widget.controller.text,
      validator: widget.validator,
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 54.h,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: ShipmentFormTokens.fieldFill,
                borderRadius: BorderRadius.circular(12.r),
                border: field.hasError
                    ? Border.all(color: colors.error, width: 1.5)
                    : null,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  widget.leading,
                  SizedBox(width: 12.w),
                  Expanded(
                    child: TextFormField(
                      controller: widget.controller,
                      focusNode: _focusNode,
                      onChanged: (v) => _onQueryChanged(v, field),
                      maxLines: 1,
                      textAlignVertical: TextAlignVertical.center,
                      style: TextStyle(
                        fontFamily: FontRes.MANROPE_MEDIUM,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: ShipmentFormTokens.heading,
                      ),
                      cursorColor: colors.primary,
                      decoration: InputDecoration(
                        hintText: widget.hint,
                        hintStyle: TextStyle(
                          fontFamily: FontRes.MANROPE_REGULAR,
                          fontSize: 16.sp,
                          color: ShipmentFormTokens.hint,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        filled: false,
                        fillColor: Colors.transparent,
                        isDense: true,
                        isCollapsed: true,
                        contentPadding: EdgeInsets.zero,
                        errorStyle: const TextStyle(height: 0, fontSize: 0),
                      ),
                    ),
                  ),
                  if (_isLoading)
                    SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: ShipmentFormTokens.primary,
                      ),
                    ),
                ],
              ),
            ),
            if (_predictions.isNotEmpty) ...[
              SizedBox(height: 6.h),
              Material(
                elevation: 2,
                shadowColor: Colors.black.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12.r),
                color: Colors.white,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 200.h),
                  child: ListView.separated(
                    shrinkWrap: true,
                    primary: false,
                    physics: const ClampingScrollPhysics(),
                    padding: EdgeInsets.symmetric(vertical: 4.h),
                    itemCount: _predictions.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: ShipmentFormTokens.fieldFill,
                    ),
                    itemBuilder: (context, index) {
                      final item = _predictions[index];
                      return InkWell(
                        onTap: () => _selectPrediction(item, field),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 12.h,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 18.w,
                                color: ShipmentFormTokens.primary,
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Text(
                                  item.description,
                                  style: TextStyle(
                                    fontFamily: FontRes.MANROPE_MEDIUM,
                                    fontSize: 14.sp,
                                    color: ShipmentFormTokens.heading,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
            if (_error != null && _error != 'ZERO_RESULTS') ...[
              SizedBox(height: 4.h),
              Text(
                _error!,
                style: TextStyle(
                  fontFamily: FontRes.MANROPE_REGULAR,
                  fontSize: 12.sp,
                  color: colors.error,
                ),
              ),
            ],
            if (field.hasError && field.errorText != null)
              Padding(
                padding: EdgeInsets.only(top: 6.h, left: 2.w),
                child: Text(
                  field.errorText!,
                  style: TextStyle(
                    fontFamily: FontRes.MANROPE_REGULAR,
                    fontSize: 12.sp,
                    color: colors.error,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
