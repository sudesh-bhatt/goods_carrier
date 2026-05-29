import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/config/google_places_config.dart';
import '../../../../../core/extensions/size_ext.dart';
import '../../../../../core/mixins/safe_set_state_mixin.dart';
import '../../../../../core/providers/google_places_provider.dart';
import '../../../../../core/services/google_places_service.dart';
import '../../../../../res/font_res.dart';
import 'saved_address_tokens.dart';

/// Full address line with Google Places suggestions — Add/Edit Address styling.
class AddAddressAutocompleteField extends ConsumerStatefulWidget {
  const AddAddressAutocompleteField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.onPlaceSelected,
    this.validator,
    this.textInputAction,
    this.autovalidateMode = AutovalidateMode.disabled,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final ValueChanged<PlaceAddressDetails> onPlaceSelected;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final AutovalidateMode autovalidateMode;

  @override
  ConsumerState<AddAddressAutocompleteField> createState() =>
      _AddAddressAutocompleteFieldState();
}

class _AddAddressAutocompleteFieldState
    extends ConsumerState<AddAddressAutocompleteField>
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
      // Delay clear so a tap on a suggestion registers before the list closes.
      Future<void>.delayed(const Duration(milliseconds: 180), () {
        if (mounted && !_focusNode.hasFocus) {
          safeSetState(() => _predictions = []);
        }
      });
    } else {
      _sessionToken = _newSessionToken();
    }
  }

  void _onQueryChanged(String query) {
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

  Future<void> _selectPrediction(PlacePrediction prediction) async {
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
      widget.controller.text = details.fullAddressLine.isNotEmpty
          ? details.fullAddressLine
          : prediction.description;
      widget.onPlaceSelected(details);
    } on GooglePlacesException catch (_) {
      if (!mounted) return;
      widget.controller.text = prediction.description;
    } finally {
      _sessionToken = _newSessionToken();
      if (mounted) safeSetState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w),
          child: Text(
            widget.label,
            style: TextStyle(
              fontFamily: FontRes.MANROPE_BOLD,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              height: 16 / 12,
              color: SavedAddressTokens.labelBrown,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          textInputAction: widget.textInputAction,
          autovalidateMode: widget.autovalidateMode,
          validator: widget.validator,
          onChanged: _onQueryChanged,
          style: TextStyle(
            fontFamily: FontRes.MANROPE_MEDIUM,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: SavedAddressTokens.cardTitle,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(
              fontFamily: FontRes.MANROPE_MEDIUM,
              fontSize: 16.sp,
              color: SavedAddressTokens.hintGrey,
            ),
            filled: true,
            fillColor: SavedAddressTokens.fieldFill,
            contentPadding: EdgeInsets.fromLTRB(48.w, 17.h, 16.w, 17.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24.r),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24.r),
              borderSide: BorderSide(
                color: SavedAddressTokens.chipSelected,
                width: 1.5,
              ),
            ),
            prefixIcon: Padding(
              padding: EdgeInsets.only(left: 16.w, right: 8.w),
              child: Icon(
                Icons.map_outlined,
                size: 18.w,
                color: SavedAddressTokens.hintGrey,
              ),
            ),
            prefixIconConstraints: BoxConstraints(minWidth: 42.w),
            suffixIcon: _isLoading
                ? Padding(
                    padding: EdgeInsets.all(14.w),
                    child: SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: SavedAddressTokens.chipSelected,
                      ),
                    ),
                  )
                : null,
          ),
        ),
        if (_predictions.isNotEmpty) ...[
          SizedBox(height: 6.h),
          Material(
            elevation: 2,
            shadowColor: Colors.black.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16.r),
            color: Colors.white,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 220.h),
              child: ListView.separated(
                shrinkWrap: true,
                primary: false,
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.symmetric(vertical: 4.h),
                itemCount: _predictions.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: SavedAddressTokens.fieldFill,
                ),
                itemBuilder: (context, index) {
                  final item = _predictions[index];
                  return InkWell(
                    onTap: () => _selectPrediction(item),
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
                            color: SavedAddressTokens.chipSelected,
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              item.description,
                              style: TextStyle(
                                fontFamily: FontRes.MANROPE_MEDIUM,
                                fontSize: 14.sp,
                                color: SavedAddressTokens.cardTitle,
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
              fontFamily: FontRes.MANROPE_MEDIUM,
              fontSize: 12.sp,
              color: Colors.red.shade700,
            ),
          ),
        ],
      ],
    );
  }
}
