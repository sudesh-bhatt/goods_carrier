import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/config/google_places_config.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/providers/google_places_provider.dart';
import '../../../../core/services/google_places_service.dart';
import '../../../../res/font_res.dart';

/// Profile-style address field with Google Places autocomplete (India).
///
/// Requires `--dart-define=GOOGLE_PLACES_API_KEY=...`. Without a key, behaves
/// as a normal text field.
class AddressAutocompleteField extends ConsumerStatefulWidget {
  const AddressAutocompleteField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.validator,
    this.textInputAction = TextInputAction.done,
    this.fillColor = const Color(0xFFF0F2F5),
    this.autovalidateMode = AutovalidateMode.disabled,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final FormFieldValidator<String>? validator;
  final TextInputAction textInputAction;
  final Color fillColor;
  final AutovalidateMode autovalidateMode;

  @override
  ConsumerState<AddressAutocompleteField> createState() =>
      _AddressAutocompleteFieldState();
}

class _AddressAutocompleteFieldState
    extends ConsumerState<AddressAutocompleteField> {
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
      setState(() => _predictions = []);
    } else {
      _sessionToken = _newSessionToken();
    }
  }

  void _onQueryChanged(String query) {
    _debounce?.cancel();
    if (!GooglePlacesConfig.isConfigured || query.trim().length < 3) {
      setState(() {
        _predictions = [];
        _isLoading = false;
        _error = null;
      });
      return;
    }

    setState(() {
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
        setState(() {
          _predictions = results;
          _isLoading = false;
        });
      } on GooglePlacesException catch (e) {
        if (!mounted) return;
        setState(() {
          _predictions = [];
          _isLoading = false;
          _error = e.status;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _predictions = [];
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _selectPrediction(PlacePrediction prediction) async {
    setState(() {
      _predictions = [];
      _isLoading = true;
    });
    FocusScope.of(context).unfocus();

    try {
      final service = ref.read(googlePlacesServiceProvider);
      final address = await service.fetchFormattedAddress(
        placeId: prediction.placeId,
        sessionToken: _sessionToken,
      );
      widget.controller.text =
          address.isNotEmpty ? address : prediction.description;
    } catch (_) {
      widget.controller.text = prediction.description;
    } finally {
      _sessionToken = _newSessionToken();
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fieldRadius = BorderRadius.circular(AppDimensions.radiusLg.r);
    const noBorder = BorderSide(color: Colors.transparent, width: 0);

    return FormField<String>(
      initialValue: widget.controller.text,
      validator: widget.validator,
      autovalidateMode: widget.autovalidateMode,
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.label.toUpperCase(),
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
              controller: widget.controller,
              focusNode: _focusNode,
              textInputAction: widget.textInputAction,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (value) {
                field.didChange(value);
                _onQueryChanged(value);
              },
              style: context.textTheme.bodyMedium?.copyWith(
                fontFamily: FontRes.MANROPE_REGULAR,
                color: colors.textPrimary,
                fontSize: 15.sp,
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: context.textTheme.bodyMedium?.copyWith(
                  color: colors.textHint,
                  fontSize: 15.sp,
                ),
                filled: true,
                fillColor: widget.fillColor,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 16.h,
                ),
                suffixIcon: _isLoading
                    ? Padding(
                        padding: EdgeInsets.all(14.w),
                        child: SizedBox(
                          width: 18.w,
                          height: 18.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colors.primary,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.location_on_outlined,
                        color: colors.textHint,
                        size: 22.w,
                      ),
                border: OutlineInputBorder(
                  borderRadius: fieldRadius,
                  borderSide: noBorder,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: fieldRadius,
                  borderSide: noBorder,
                ),
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
                errorText: field.errorText,
              ),
            ),
            if (_predictions.isNotEmpty) ...[
              SizedBox(height: 6.h),
              Material(
                elevation: 2,
                shadowColor: colors.shadowCard,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
                color: colors.surface,
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  itemCount: _predictions.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: colors.divider,
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
                              color: colors.primary,
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Text(
                                item.description,
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: colors.textPrimary,
                                  fontSize: 14.sp,
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
            ],
            if (_error != null && _error != 'ZERO_RESULTS') ...[
              SizedBox(height: 4.h),
              Text(
                _error!,
                style: context.textTheme.bodySmall?.copyWith(
                  color: colors.error,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
