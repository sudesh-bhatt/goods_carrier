import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';

/// 4-box OTP entry widget with auto-advance, backspace handling, and paste support.
///
/// Renders as 4 individual digit boxes backed by a single hidden [TextField].
/// Paste detection: if user pastes a 4-digit string the boxes fill instantly.
///
/// Usage:
/// ```dart
/// AppOtpField(
///   onCompleted: (otp) => _verify(otp),
///   onChanged: (value) => setState(() => _otp = value),
/// );
/// ```
class AppOtpField extends StatefulWidget {
  const AppOtpField({
    super.key,
    required this.onCompleted,
    this.onChanged,
    this.length = 4,
    this.autofocus = true,
    this.enabled = true,
    this.hasError = false,
    this.autoSubmitOnComplete = true,
    this.boxFillColor,
  });

  final void Function(String otp) onCompleted;
  final ValueChanged<String>? onChanged;

  /// Number of OTP boxes. Default is 4 per Figma design.
  final int length;
  final bool autofocus;
  final bool enabled;

  /// When false, [onCompleted] is not called automatically — use a CTA instead.
  final bool autoSubmitOnComplete;

  /// Optional fill for empty boxes (Figma login/OTP uses `#F0F2F5`).
  final Color? boxFillColor;

  /// Turns all box borders red — set to true on wrong-OTP server response.
  final bool hasError;

  @override
  State<AppOtpField> createState() => _AppOtpFieldState();
}

class _AppOtpFieldState extends State<AppOtpField> {
  late final TextEditingController _ctrl;
  late final FocusNode _focusNode;
  String _otp = '';

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController();
    _focusNode = FocusNode();
    _ctrl.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onTextChanged);
    _ctrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    // Strip anything that isn't a digit and cap at [length].
    final raw = _ctrl.text.replaceAll(RegExp(r'[^0-9]'), '');
    final capped = raw.length > widget.length ? raw.substring(0, widget.length) : raw;

    if (capped != _ctrl.text) {
      _ctrl.value = _ctrl.value.copyWith(
        text: capped,
        selection: TextSelection.collapsed(offset: capped.length),
      );
    }

    if (capped == _otp) return;

    setState(() => _otp = capped);
    widget.onChanged?.call(capped);

    if (capped.length == widget.length) {
      HapticFeedback.lightImpact();
      if (widget.autoSubmitOnComplete) {
        widget.onCompleted(capped);
      }
    }
  }

  void _requestFocus() {
    if (widget.enabled) _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _requestFocus,
      child: Stack(
        children: [
          // ── Visible boxes ───────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.length, (index) {
              final isFilled = index < _otp.length;
              final isActive = !widget.hasError &&
                  _focusNode.hasFocus &&
                  index == _otp.length;

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: AppDimensions.sm.w),
                child: _OtpBox(
                  digit: isFilled ? _otp[index] : null,
                  isActive: isActive,
                  hasError: widget.hasError,
                  fillColor: widget.boxFillColor,
                ),
              );
            }),
          ),

          // ── Hidden real TextField ───────────────────────────────────────
          Positioned.fill(
            child: Opacity(
              opacity: 0,
              child: TextField(
                controller: _ctrl,
                focusNode: _focusNode,
                autofocus: widget.autofocus,
                enabled: widget.enabled,
                keyboardType: TextInputType.number,
                maxLength: widget.length,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Single OTP box ───────────────────────────────────────────────────────────

class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.digit,
    required this.isActive,
    required this.hasError,
    this.fillColor,
  });

  final String? digit;
  final bool isActive;
  final bool hasError;
  final Color? fillColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final boxSize = 56.w;
    final boxFill = fillColor ?? colors.inputFill;

    final Color borderColor;
    final double borderWidth;
    if (hasError) {
      borderColor = colors.error;
      borderWidth = 1.5;
    } else if (isActive) {
      borderColor = colors.primary;
      borderWidth = 1.5;
    } else {
      borderColor = Colors.transparent;
      borderWidth = 0;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: boxSize,
      height: boxSize,
      decoration: BoxDecoration(
        color: boxFill,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      alignment: Alignment.center,
      child: digit != null
          ? Text(
              digit!,
              style: context.textTheme.headlineSmall?.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 22.sp,
              ),
            )
          : isActive
              ? _Cursor(color: colors.primary)
              : null,
    );
  }
}

// ─── Blinking cursor ──────────────────────────────────────────────────────────

class _Cursor extends StatefulWidget {
  const _Cursor({required this.color});
  final Color color;

  @override
  State<_Cursor> createState() => _CursorState();
}

class _CursorState extends State<_Cursor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 1, end: 0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        width: 2,
        height: 24.h,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}
