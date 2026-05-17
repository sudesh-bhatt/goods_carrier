import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/extensions/num_ext.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../shared/domain/entities/shipment.dart';
import '../../../../shared/presentation/widgets/buttons/app_button.dart';
import '../../../../shared/presentation/widgets/sheets/app_modal_bottom_sheet.dart';
import '../../../../shared/presentation/widgets/route/route_timeline.dart';
import '../providers/driver_shipment_requests_provider.dart';

/// Bottom sheet for a driver to express interest in a shipment request.
///
/// The driver can accept the platform's estimate or enter a custom quote.
/// On confirm → [DriverShipmentRequestsNotifier.expressInterest] is called.
class ExpressInterestSheet extends ConsumerStatefulWidget {
  const ExpressInterestSheet._({required this.shipment});

  final Shipment shipment;

  static Future<bool?> show(
    BuildContext context, {
    required Shipment shipment,
  }) =>
      AppModalBottomSheet.show<bool>(
        context: context,
        builder: (_) => ExpressInterestSheet._(shipment: shipment),
      );

  @override
  ConsumerState<ExpressInterestSheet> createState() =>
      _ExpressInterestSheetState();
}

class _ExpressInterestSheetState
    extends ConsumerState<ExpressInterestSheet> {
  late final TextEditingController _quoteCtrl;
  bool _useCustomQuote = false;
  bool _isSubmitting   = false;

  @override
  void initState() {
    super.initState();
    _quoteCtrl = TextEditingController(
      text: widget.shipment.estimatedPrice.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _quoteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    // Simulated network delay — replace with API call in Session 7.
    await Future.delayed(const Duration(milliseconds: 500));

    ref
        .read(driverShipmentRequestsProvider.notifier)
        .expressInterest(widget.shipment.id);

    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final colors   = context.colors;
    final shipment = widget.shipment;

    return Padding(
      // Lift sheet above keyboard
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusLg.r),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.screenPadding.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Padding(
                  padding: EdgeInsets.symmetric(vertical: AppDimensions.sm.h),
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: colors.divider,
                      borderRadius: BorderRadius.circular(
                          AppDimensions.radiusFull.r),
                    ),
                  ),
                ),

                // Title
                Text(
                  context.l10n.tripExpressInterest,
                  style: context.textTheme.titleMedium?.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: AppDimensions.xl.h),

                // Route summary card
                Container(
                  padding: EdgeInsets.all(AppDimensions.base.w),
                  decoration: BoxDecoration(
                    color: colors.cardBackground,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusMd.r),
                    boxShadow: context.cardShadow,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: AppDimensions.sm.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: colors.primary.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusFull.r),
                            ),
                            child: Text(
                              shipment.id,
                              style: context.textTheme.labelSmall?.copyWith(
                                color: colors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${shipment.goods.type} · ${shipment.goods.weightLabel}',
                            style: context.textTheme.bodySmall?.copyWith(
                                color: colors.textSecondary),
                          ),
                        ],
                      ),
                      SizedBox(height: AppDimensions.sm.h),
                      RouteTimeline(
                        fromCity: shipment.pickup.city,
                        toCity:   shipment.drop.city,
                        compact:  true,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: AppDimensions.xl.h),

                // Platform estimate row
                Container(
                  padding: EdgeInsets.all(AppDimensions.base.w),
                  decoration: BoxDecoration(
                    color: colors.primary.withOpacity(0.06),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusMd.r),
                    border: Border.all(
                        color: colors.primary.withOpacity(0.20), width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded,
                          color: colors.primary, size: 18.w),
                      SizedBox(width: AppDimensions.sm.w),
                      Expanded(
                        child: Text(
                          'Platform estimate: ${shipment.estimatedPrice.inr}',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      // Toggle custom quote
                      GestureDetector(
                        onTap: () =>
                            setState(() => _useCustomQuote = !_useCustomQuote),
                        child: Text(
                          _useCustomQuote ? 'Use estimate' : 'Edit quote',
                          style: context.textTheme.labelSmall?.copyWith(
                            color: colors.primary,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Custom quote input
                if (_useCustomQuote) ...[
                  SizedBox(height: AppDimensions.base.h),
                  TextField(
                    controller: _quoteCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                      labelText: context.l10n.tripPrice,
                      prefixText: '₹ ',
                      filled: true,
                      fillColor: colors.inputFill,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusMd.r),
                        borderSide: BorderSide(color: colors.divider),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusMd.r),
                        borderSide:
                            BorderSide(color: colors.primary, width: 1.5),
                      ),
                    ),
                    autofocus: true,
                  ),
                ],

                SizedBox(height: AppDimensions.xxl.h),

                // Submit
                AppButton(
                  label: context.l10n.actionConfirm,
                  onPressed: _isSubmitting ? null : _submit,
                  isLoading: _isSubmitting,
                ),

                SizedBox(height: AppDimensions.base.h),

                // Cancel
                AppButton(
                  label: context.l10n.actionCancel,
                  variant: AppButtonVariant.ghost,
                  onPressed: _isSubmitting
                      ? null
                      : () => Navigator.of(context).pop(false),
                  isFullWidth: false,
                  height: 40,
                ),

                SizedBox(height: AppDimensions.base.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
