import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';

/// Feature-rich text field aligned with the Goods Carrier design system.
///
/// Usage:
/// ```dart
/// AppTextField(
///   label: context.l10n.authPhoneLabel,
///   hint: context.l10n.authPhoneHint,
///   controller: _phoneCtrl,
///   keyboardType: TextInputType.phone,
///   prefixIcon: const Icon(Icons.phone_outlined),
///   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
///   validator: Validators.phone,
/// );
/// ```
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction = TextInputAction.next,
    this.prefixIcon,
    this.suffixIcon,
    this.suffixText,
    this.inputFormatters,
    this.maxLength,
    this.maxLines = 1,
    this.minLines,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.autofocus = false,
    this.focusNode,
    this.onTap,
    this.helperText,
  });

  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final TextInputAction textInputAction;
  final Widget? prefixIcon;

  /// Replaces the default clear/reveal toggle — supply your own suffix action.
  final Widget? suffixIcon;

  /// Lightweight suffix label (e.g. unit strings like "KG", "Ton").
  final String? suffixText;

  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final int maxLines;
  final int? minLines;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final bool autofocus;
  final FocusNode? focusNode;
  final VoidCallback? onTap;
  final String? helperText;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
      borderSide: BorderSide(color: colors.divider, width: 1.0),
    );

    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
      borderSide: BorderSide(color: colors.primary, width: 1.5),
    );

    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
      borderSide: BorderSide(color: colors.error, width: 1.5),
    );

    final disabledBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
      borderSide: BorderSide(color: colors.divider.withOpacity(0.5), width: 1.0),
    );

    Widget? effectiveSuffix = widget.suffixIcon;
    if (widget.obscureText && widget.suffixIcon == null) {
      effectiveSuffix = IconButton(
        icon: Icon(
          _obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: AppDimensions.iconMd,
          color: colors.textHint,
        ),
        onPressed: () => setState(() => _obscured = !_obscured),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: context.textTheme.bodySmall?.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: AppDimensions.xs.h),
        ],
        TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          textCapitalization: widget.textCapitalization,
          textInputAction: widget.textInputAction,
          obscureText: _obscured,
          readOnly: widget.readOnly,
          enabled: widget.enabled,
          autofocus: widget.autofocus,
          focusNode: widget.focusNode,
          onTap: widget.onTap,
          maxLength: widget.maxLength,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          minLines: widget.minLines,
          inputFormatters: widget.inputFormatters,
          style: context.textTheme.bodyMedium?.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: context.textTheme.bodyMedium?.copyWith(
              color: colors.textHint,
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor: widget.enabled ? colors.inputFill : colors.inputFill.withOpacity(0.5),
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppDimensions.base.w,
              vertical: AppDimensions.md.h,
            ),
            prefixIcon: widget.prefixIcon != null
                ? Padding(
                    padding: EdgeInsets.only(
                      left: AppDimensions.md.w,
                      right: AppDimensions.sm.w,
                    ),
                    child: IconTheme(
                      data: IconThemeData(
                        color: colors.textHint,
                        size: AppDimensions.iconMd.w,
                      ),
                      child: widget.prefixIcon!,
                    ),
                  )
                : null,
            prefixIconConstraints: widget.prefixIcon != null
                ? const BoxConstraints(minWidth: 0, minHeight: 0)
                : null,
            suffixIcon: effectiveSuffix != null
                ? IconTheme(
                    data: IconThemeData(
                      color: colors.textHint,
                      size: AppDimensions.iconMd.w,
                    ),
                    child: effectiveSuffix,
                  )
                : null,
            suffix: widget.suffixText != null
                ? Text(
                    widget.suffixText!,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: colors.textSecondary,
                    ),
                  )
                : null,
            helperText: widget.helperText,
            helperStyle: context.textTheme.bodySmall?.copyWith(
              color: colors.textSecondary,
            ),
            errorStyle: context.textTheme.bodySmall?.copyWith(
              color: colors.error,
            ),
            counterText: '',   // suppress the default max-length counter
            enabledBorder: border,
            focusedBorder: focusedBorder,
            errorBorder: errorBorder,
            focusedErrorBorder: errorBorder,
            disabledBorder: disabledBorder,
            border: border,
          ),
        ),
      ],
    );
  }
}
