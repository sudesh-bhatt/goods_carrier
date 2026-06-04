import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/mixins/safe_set_state_mixin.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../res/font_res.dart';
import '../../../../shared/presentation/widgets/feedback/error_view.dart';
import '../../../../shared/presentation/widgets/navigation/app_bar_widget.dart';
import '../models/shipment_cancel_confirmation_args.dart';
import '../providers/customer_shipments_provider.dart';
import '../widgets/cancel_shipment/cancel_shipment_tokens.dart';
import '../widgets/customer_light_chrome.dart';

/// Cancel shipment reason form — Figma `1:3065`.
class CancelShipmentScreen extends ConsumerStatefulWidget {
  const CancelShipmentScreen({super.key, required this.shipmentId});

  final String shipmentId;

  @override
  ConsumerState<CancelShipmentScreen> createState() =>
      _CancelShipmentScreenState();
}

class _CancelShipmentScreenState extends ConsumerState<CancelShipmentScreen>
    with SafeSetStateMixin {
  String? _selectedReason;
  final _commentsController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  List<_ReasonOption> _reasons(AppLocalizations l10n) => [
        _ReasonOption('changeOfPlans', l10n.cancelReasonChangeOfPlans),
        _ReasonOption('betterPrice', l10n.cancelReasonBetterPrice),
        _ReasonOption('driverDelayed', l10n.cancelReasonDriverDelayed),
        _ReasonOption('incorrectDetails', l10n.cancelReasonIncorrectDetails),
        _ReasonOption('other', l10n.cancelReasonOther),
      ];

  Future<void> _submitCancellation() async {
    if (_selectedReason == null || _isSubmitting) return;

    final state = ref.read(customerShipmentsProvider);
    final shipment =
        state.shipments.where((s) => s.id == widget.shipmentId).firstOrNull;
    if (shipment == null) return;

    safeSetState(() => _isSubmitting = true);
    await ref
        .read(customerShipmentsProvider.notifier)
        .cancelShipment(shipment.id);
    if (!mounted) return;

    final displayId =
        shipment.id.startsWith('#') ? shipment.id : '#${shipment.id}';
    final args = ShipmentCancelConfirmationArgs(
      shipmentId: displayId,
      fromCity: shipment.pickup.city,
      toCity: shipment.drop.city,
      pickupDate: shipment.pickupDateTime,
      totalPrice: shipment.estimatedPrice,
    );

    context.pushReplacement(AppRoutes.shipmentCancelSuccess, extra: args);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(customerShipmentsProvider);
    final shipment =
        state.shipments.where((s) => s.id == widget.shipmentId).firstOrNull;

    if (shipment == null) {
      return Scaffold(
        backgroundColor: CancelShipmentTokens.screenBg,
        appBar: FlowScreenAppBar(
          title: l10n.customerCancelShipment,
          fallbackRoute: AppRoutes.customerHome,
        ),
        body: const ErrorView(message: 'Shipment not found.'),
      );
    }

    final reasons = _reasons(l10n);

    return CustomerLightChrome(
      child: Scaffold(
        backgroundColor: CancelShipmentTokens.screenBg,
        appBar: FlowScreenAppBar(
          title: l10n.customerCancelShipment,
          backgroundColor: Colors.white.withValues(alpha: 0.8),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
                children: [
                  Text(
                    l10n.cancelShipmentHeadline,
                    style: TextStyle(
                      fontFamily: FontRes.MANROPE_EXTRABOLD,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w800,
                      height: 32 / 24,
                      letterSpacing: -0.6,
                      color: CancelShipmentTokens.bodyDark,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    l10n.cancelShipmentDescription,
                    style: TextStyle(
                      fontFamily: FontRes.MANROPE_REGULAR,
                      fontSize: 16.sp,
                      height: 26 / 16,
                      color: CancelShipmentTokens.bodyGrey,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(24.w),
                    decoration: BoxDecoration(
                      color: CancelShipmentTokens.cardFill,
                      borderRadius:
                          BorderRadius.circular(CancelShipmentTokens.cardRadius.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: 16.h),
                          child: Text(
                            l10n.cancelShipmentReasonLegend.toUpperCase(),
                            style: TextStyle(
                              fontFamily: FontRes.MANROPE_BOLD,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              height: 20 / 14,
                              letterSpacing: 1.4,
                              color: CancelShipmentTokens.labelBrown,
                            ),
                          ),
                        ),
                        ...reasons.map(
                          (r) => Padding(
                            padding: EdgeInsets.only(bottom: 16.h),
                            child: _ReasonTile(
                              label: r.label,
                              selected: _selectedReason == r.id,
                              onTap: () =>
                                  safeSetState(() => _selectedReason = r.id),
                            ),
                          ),
                        ),
                        Text(
                          l10n.cancelShipmentCommentsLabel.toUpperCase(),
                          style: TextStyle(
                            fontFamily: FontRes.MANROPE_BOLD,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            height: 20 / 14,
                            letterSpacing: 1.4,
                            color: CancelShipmentTokens.labelBrown,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        TextField(
                          controller: _commentsController,
                          maxLines: 4,
                          style: TextStyle(
                            fontFamily: FontRes.MANROPE_REGULAR,
                            fontSize: 16.sp,
                            color: CancelShipmentTokens.bodyDark,
                          ),
                          decoration: InputDecoration(
                            hintText: l10n.cancelShipmentCommentsHint,
                            hintStyle: TextStyle(
                              fontFamily: FontRes.MANROPE_REGULAR,
                              fontSize: 16.sp,
                              color: CancelShipmentTokens.hintGrey,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                CancelShipmentTokens.optionRadius.r,
                              ),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.all(16.w),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.cancelShipmentNoticeTitle,
                        style: TextStyle(
                          fontFamily: FontRes.MANROPE_BOLD,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          height: 28 / 18,
                          color: CancelShipmentTokens.bodyDark,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        l10n.cancelShipmentNoticeBody,
                        style: TextStyle(
                          fontFamily: FontRes.MANROPE_REGULAR,
                          fontSize: 14.sp,
                          height: 23 / 14,
                          color: CancelShipmentTokens.noticeGrey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _CancelFooter(
              submitLabel: l10n.customerCancelShipment,
              keepLabel: l10n.cancelShipmentKeep,
              enabled: _selectedReason != null && !_isSubmitting,
              isLoading: _isSubmitting,
              onSubmit: _submitCancellation,
              onKeep: () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReasonOption {
  const _ReasonOption(this.id, this.label);
  final String id;
  final String label;
}

class _ReasonTile extends StatelessWidget {
  const _ReasonTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius:
          BorderRadius.circular(CancelShipmentTokens.optionRadius.r),
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(CancelShipmentTokens.optionRadius.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Container(
                width: 24.w,
                height: 24.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: selected
                        ? CancelShipmentTokens.primaryOrange
                        : CancelShipmentTokens.radioBorder,
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: selected
                    ? Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: const BoxDecoration(
                          color: CancelShipmentTokens.primaryOrange,
                          shape: BoxShape.circle,
                        ),
                      )
                    : null,
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: FontRes.MANROPE_MEDIUM,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    height: 24 / 16,
                    color: CancelShipmentTokens.bodyDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CancelFooter extends StatelessWidget {
  const _CancelFooter({
    required this.submitLabel,
    required this.keepLabel,
    required this.enabled,
    required this.isLoading,
    required this.onSubmit,
    required this.onKeep,
  });

  final String submitLabel;
  final String keepLabel;
  final bool enabled;
  final bool isLoading;
  final VoidCallback onSubmit;
  final VoidCallback onKeep;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: CancelShipmentTokens.screenBg.withValues(alpha: 0.8),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(22, 28, 32, 0.04),
            blurRadius: 30,
            offset: Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 64.h,
                child: Material(
                  color: enabled
                      ? CancelShipmentTokens.primaryOrange
                      : CancelShipmentTokens.primaryOrange.withValues(alpha: 0.4),
                  borderRadius:
                      BorderRadius.circular(CancelShipmentTokens.buttonRadius.r),
                  elevation: 0,
                  child: InkWell(
                    onTap: enabled ? onSubmit : null,
                    borderRadius:
                        BorderRadius.circular(CancelShipmentTokens.buttonRadius.r),
                    child: Center(
                      child: isLoading
                          ? SizedBox(
                              width: 24.w,
                              height: 24.w,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              submitLabel,
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
              SizedBox(height: 16.h),
              TextButton(
                onPressed: onKeep,
                child: Text(
                  keepLabel,
                  style: TextStyle(
                    fontFamily: FontRes.MANROPE_BOLD,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: CancelShipmentTokens.keepGrey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
