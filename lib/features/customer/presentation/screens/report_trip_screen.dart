import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/mixins/safe_set_state_mixin.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../res/font_res.dart';
import '../../../../shared/domain/entities/shipment.dart';
import '../../../../shared/presentation/widgets/feedback/error_view.dart';
import '../../../../shared/presentation/widgets/navigation/app_bar_widget.dart';
import '../models/report_trip_confirmation_args.dart';
import '../providers/customer_reported_trips_provider.dart';
import '../providers/customer_shipments_provider.dart';
import '../widgets/customer_light_chrome.dart';
import '../widgets/report_trip/report_trip_tokens.dart';

/// Report issue form — Figma `1:6058`.
class ReportTripScreen extends ConsumerStatefulWidget {
  const ReportTripScreen({
    super.key,
    this.shipment,
    this.shipmentId,
    this.isDriver = false,
  }) : assert(shipment != null || shipmentId != null);

  /// Preferred — passed from Trip Details so lookup is not required.
  final Shipment? shipment;
  final String? shipmentId;
  final bool isDriver;

  @override
  ConsumerState<ReportTripScreen> createState() => _ReportTripScreenState();
}

class _ReportTripScreenState extends ConsumerState<ReportTripScreen>
    with SafeSetStateMixin {
  static const _otherReasonId = 'other';

  String? _selectedReason;
  final _detailsController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  List<_ReasonOption> _reasons(AppLocalizations l10n) => [
        _ReasonOption('spam', l10n.reportReasonSpam),
        _ReasonOption('incorrect', l10n.reportReasonIncorrect),
        _ReasonOption('fraud', l10n.reportReasonFraud),
        _ReasonOption('inappropriate', l10n.reportReasonInappropriate),
        _ReasonOption('notAvailable', l10n.reportReasonNotAvailable),
        _ReasonOption(_otherReasonId, l10n.reportReasonOther),
      ];

  bool get _canSubmit =>
      _selectedReason != null &&
      !_isSubmitting &&
      (_selectedReason != _otherReasonId ||
          _detailsController.text.trim().isNotEmpty);

  Future<void> _submit(Shipment shipment) async {
    if (!_canSubmit) return;

    safeSetState(() => _isSubmitting = true);
    try {
      final reportId = await ref
          .read(customerReportedTripsProvider.notifier)
          .submitReport(
            shipment,
            reason: _selectedReason!,
            details: _selectedReason == _otherReasonId
                ? _detailsController.text.trim()
                : null,
          );
      if (!mounted) return;

      final displayTripId = shipment.id.startsWith('#')
          ? shipment.id
          : '#${shipment.id}';
      final args = ReportTripConfirmationArgs(
        reportId: reportId,
        submittedAt: DateTime.now(),
        tripId: displayTripId,
        fromCity: shipment.pickup.city,
        toCity: shipment.drop.city,
        isDriver: widget.isDriver,
      );
      context.pushReplacement(AppRoutes.reportTripSuccess, extra: args);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.errorGeneric)),
      );
    } finally {
      if (mounted) safeSetState(() => _isSubmitting = false);
    }
  }

  Shipment? _resolveShipment() {
    if (widget.shipment != null) return widget.shipment;
    final id = widget.shipmentId;
    if (id == null) return null;
    return ref
        .watch(customerShipmentsProvider)
        .shipments
        .where((s) => s.id == id)
        .firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final shipment = _resolveShipment();

    if (shipment == null) {
      return Scaffold(
        backgroundColor: ReportTripTokens.screenBg,
        appBar: FlowScreenAppBar(
          title: l10n.customerReportIssueTitle,
          fallbackRoute:
              widget.isDriver ? AppRoutes.driverHome : AppRoutes.customerHome,
        ),
        body: const ErrorView(message: 'Trip not found.'),
      );
    }

    final reasons = _reasons(l10n);

    return CustomerLightChrome(
      child: Scaffold(
        backgroundColor: ReportTripTokens.screenBg,
        appBar: FlowScreenAppBar(
          title: l10n.customerReportIssueTitle,
          backgroundColor: Colors.white.withValues(alpha: 0.8),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
                children: [
                  _ReportHeader(
                    title: l10n.reportTripHeadline,
                    description: l10n.reportTripDescription,
                  ),
                  SizedBox(height: 16.h),
                  ...reasons.map((reason) {
                    final selected = _selectedReason == reason.id;
                    final isOther = reason.id == _otherReasonId;
                    return Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _ReportReasonTile(
                            label: reason.label,
                            selected: selected,
                            onTap: () =>
                                safeSetState(() => _selectedReason = reason.id),
                          ),
                          if (isOther && selected) ...[
                            SizedBox(height: 16.h),
                            _OtherDetailsField(
                              controller: _detailsController,
                              hint: l10n.reportTripDetailsHint,
                              onChanged: (_) => safeSetState(() {}),
                            ),
                          ],
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(58.w, 0, 58.w, 24.h),
              child: SizedBox(
                width: double.infinity,
                height: 56.h,
                child: Material(
                  color: _canSubmit
                      ? ReportTripTokens.primaryOrange
                      : ReportTripTokens.primaryOrange.withValues(alpha: 0.4),
                  borderRadius:
                      BorderRadius.circular(ReportTripTokens.buttonRadius.r),
                  elevation: 0,
                  shadowColor:
                      ReportTripTokens.primaryOrange.withValues(alpha: 0.3),
                  child: InkWell(
                    onTap: _canSubmit ? () => _submit(shipment) : null,
                    borderRadius:
                        BorderRadius.circular(ReportTripTokens.buttonRadius.r),
                    child: Center(
                      child: _isSubmitting
                          ? SizedBox(
                              width: 22.w,
                              height: 22.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              l10n.reportTripSubmit,
                              style: TextStyle(
                                fontFamily: FontRes.MANROPE_BOLD,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
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

class _ReasonOption {
  const _ReasonOption(this.id, this.label);
  final String id;
  final String label;
}

class _ReportHeader extends StatelessWidget {
  const _ReportHeader({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48.w,
          height: 48.w,
          decoration: const BoxDecoration(
            color: ReportTripTokens.iconHalo,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.warning_amber_rounded,
            color: ReportTripTokens.primaryOrange,
            size: 22.w,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: FontRes.MANROPE_EXTRABOLD,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  height: 28 / 20,
                  letterSpacing: -0.5,
                  color: ReportTripTokens.bodyDark,
                ),
              ),
              SizedBox(height: 2.88.h),
              Text(
                description,
                style: TextStyle(
                  fontFamily: FontRes.MANROPE_REGULAR,
                  fontSize: 14.sp,
                  height: 23 / 14,
                  color: ReportTripTokens.bodyBrown,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReportReasonTile extends StatelessWidget {
  const _ReportReasonTile({
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
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(ReportTripTokens.optionRadius.r),
        side: selected
            ? const BorderSide(color: ReportTripTokens.selectedBorder, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(ReportTripTokens.optionRadius.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Container(
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? ReportTripTokens.priceBrown : Colors.white,
                  border: Border.all(
                    color: selected
                        ? ReportTripTokens.priceBrown
                        : ReportTripTokens.radioBorder,
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: selected
                    ? Icon(Icons.check, size: 12.w, color: Colors.white)
                    : null,
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: FontRes.MANROPE_SEMIBOLD,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    height: 22 / 15,
                    letterSpacing: -0.375,
                    color: ReportTripTokens.bodyDark,
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

class _OtherDetailsField extends StatelessWidget {
  const _OtherDetailsField({
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: ReportTripTokens.cardFill,
        borderRadius:
            BorderRadius.circular(ReportTripTokens.optionRadius.r),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        maxLines: 4,
        style: TextStyle(
          fontFamily: FontRes.MANROPE_REGULAR,
          fontSize: 15.sp,
          height: 24 / 15,
          color: ReportTripTokens.bodyDark,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontFamily: FontRes.MANROPE_REGULAR,
            fontSize: 15.sp,
            color: ReportTripTokens.hintGrey,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.all(16.w),
        ),
      ),
    );
  }
}
