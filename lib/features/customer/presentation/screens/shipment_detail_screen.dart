import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/env_config.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/mixins/safe_set_state_mixin.dart';
import '../../../../core/network/api_exception_mapper.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../res/font_res.dart';
import '../../../../shared/domain/enums/shipment_status.dart';
import '../../../../shared/domain/entities/shipment.dart';
import '../../../../shared/domain/models/customer_shipment_detail.dart';
import '../../../../shared/presentation/widgets/feedback/error_view.dart';
import '../../../../shared/presentation/widgets/navigation/app_bar_widget.dart';
import '../providers/customer_shipments_provider.dart';
import '../widgets/customer_light_chrome.dart';
import '../widgets/driver_detail_sheet.dart';
import '../widgets/shipment_publish/shipment_publish_sections.dart';
import '../widgets/shipment_publish/shipment_publish_tokens.dart';

/// Shipment Details (Publish) — Figma `1:2540`.
///
/// Opened from **My Shipment** via [AppRoutes.shipmentDetailOf].
class ShipmentDetailScreen extends ConsumerStatefulWidget {
  const ShipmentDetailScreen({super.key, required this.shipmentId});

  final String shipmentId;

  @override
  ConsumerState<ShipmentDetailScreen> createState() =>
      _ShipmentDetailScreenState();
}

class _ShipmentDetailScreenState extends ConsumerState<ShipmentDetailScreen>
    with SafeSetStateMixin {
  CustomerShipmentDetail? _detail;
  bool _isLoading = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDetail());
  }

  Future<void> _loadDetail() async {
    final cached = _resolveCachedShipment();
    if (cached != null) {
      safeSetState(() {
        _detail = CustomerShipmentDetail(
          shipment: cached,
          paymentSummary: ShipmentPaymentSummary(
            baseFare: cached.estimatedPrice,
            totalAmount: cached.estimatedPrice,
          ),
        );
      });
    }

    if (!EnvConfig.useRemoteApi) return;

    safeSetState(() {
      _isLoading = cached == null;
      _loadError = null;
    });

    try {
      final apiId = cached?.apiResourceId ?? widget.shipmentId;
      final fetched = await ref
          .read(shipmentRepositoryProvider)
          .getCustomerShipmentDetail(apiId);
      if (!mounted) return;
      safeSetState(() {
        _detail = fetched;
        _isLoading = false;
      });
      ref.read(customerShipmentsProvider.notifier).upsertShipment(fetched.shipment);
    } catch (e) {
      if (!mounted) return;
      safeSetState(() {
        _isLoading = false;
        _loadError = cached == null ? ApiExceptionMapper.userMessage(e) : null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final detail = _detail;

    if (_isLoading && detail == null) {
      return Scaffold(
        backgroundColor: ShipmentPublishTokens.screenBg,
        appBar: FlowScreenAppBar(
          title: l10n.shipmentDetailsTitle,
          fallbackRoute: AppRoutes.customerHistory,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (detail == null) {
      return Scaffold(
        backgroundColor: ShipmentPublishTokens.screenBg,
        appBar: FlowScreenAppBar(
          title: l10n.shipmentDetailsTitle,
          fallbackRoute: AppRoutes.customerHistory,
        ),
        body: ErrorView(message: _loadError ?? 'Shipment not found.'),
      );
    }

    final shipment = detail.shipment;
    final displayId =
        shipment.id.startsWith('#') ? shipment.id : '#${shipment.id}';
    final (fromTitle, fromSub) =
        parseLocationLabel(shipment.pickup.displayLabel);
    final (toTitle, toSub) = parseLocationLabel(shipment.drop.displayLabel);

    return CustomerLightChrome(
      child: Scaffold(
        backgroundColor: ShipmentPublishTokens.screenBg,
        appBar: FlowScreenAppBar(
          title: l10n.shipmentDetailsTitle,
          fallbackRoute: AppRoutes.customerHistory,
          backgroundColor: Colors.white.withValues(alpha: 0.8),
        ),
        body: ListView(
          padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 32.h),
          children: [
            PublishRouteCard(
              tripIdLabel: l10n.tripId,
              displayId: displayId,
              publishLabel: _statusBadgeLabel(shipment.status, l10n),
              fromTitle: fromTitle,
              fromSubtitle: fromSub.isNotEmpty
                  ? fromSub
                  : shipment.pickup.fullAddress,
              toTitle: toTitle,
              toSubtitle:
                  toSub.isNotEmpty ? toSub : shipment.drop.fullAddress,
            ),
            if (detail.interestedDrivers.isNotEmpty) ...[
              SizedBox(height: 32.h),
              ...detail.interestedDrivers.map((driver) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: PublishDriverInterestCard(
                    driverName: driver.name,
                    expertLabel:
                        driver.subtitle ?? l10n.customerExpertDriver,
                    vehicleName: driver.vehicleName,
                    vehicleNumber: driver.vehicleNumber,
                    capacityLabel: l10n.tripCapacity,
                    capacityValue: driver.capacityLabel.toUpperCase(),
                    onTap: () => DriverDetailSheet.show(
                      context,
                      driverId: driver.driverId,
                      shipmentId: shipment.id,
                    ),
                    onCall: () => DriverDetailSheet.show(
                      context,
                      driverId: driver.driverId,
                      shipmentId: shipment.id,
                    ),
                    onWhatsApp: () => DriverDetailSheet.show(
                      context,
                      driverId: driver.driverId,
                      shipmentId: shipment.id,
                    ),
                  ),
                );
              }),
            ],
            SizedBox(height: 32.h),
            PublishPaymentSummaryCard(
              headerLabel: l10n.customerPaymentSummary,
              baseFareLabel: l10n.customerBaseFare,
              totalLabel: l10n.customerTotalAmount,
              amount: detail.paymentSummary.totalAmount,
              baseFare: detail.paymentSummary.baseFare,
            ),
            if (shipment.isPending ||
                shipment.status == ShipmentStatus.interestReceived) ...[
              SizedBox(height: 32.h),
              Center(
                child: TextButton(
                  onPressed: () =>
                      context.push(AppRoutes.cancelShipmentOf(shipment.id)),
                  child: Text(
                    l10n.customerCancelShipment,
                    style: TextStyle(
                      fontFamily: FontRes.MANROPE_BOLD,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: ShipmentPublishTokens.priceBrown,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _statusBadgeLabel(ShipmentStatus status, dynamic l10n) {
    if (status == ShipmentStatus.pending) {
      return l10n.customerShipmentPublishBadge;
    }
    return status.label.toUpperCase();
  }

  Shipment? _resolveCachedShipment() {
    return ref
        .read(customerShipmentsProvider.notifier)
        .byId(widget.shipmentId);
  }
}
