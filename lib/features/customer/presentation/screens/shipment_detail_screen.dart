import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/env_config.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/mixins/safe_set_state_mixin.dart';
import '../../../../core/network/api_exception_mapper.dart';
import '../../../../core/utils/external_launcher.dart';
import '../../../../core/utils/phone_utils.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../res/font_res.dart';
import '../../../../shared/domain/enums/shipment_status.dart';
import '../../../../shared/domain/entities/shipment.dart';
import '../../../../shared/domain/models/customer_shipment_detail.dart';
import '../../../../shared/presentation/widgets/feedback/error_view.dart';
import '../../../../shared/presentation/widgets/navigation/app_bar_widget.dart';
import '../models/customer_shipment_status_badge.dart';
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
      final apiId = ref
          .read(customerShipmentsProvider.notifier)
          .apiResourceIdFor(widget.shipmentId);
      CustomerShipmentDetail? fetched;
      try {
        fetched = await ref
            .read(shipmentRepositoryProvider)
            .getCustomerShipmentDetail(apiId);
      } catch (_) {
        final shipment =
            await ref.read(shipmentRepositoryProvider).getShipment(apiId);
        fetched = CustomerShipmentDetail(
          shipment: shipment,
          paymentSummary: ShipmentPaymentSummary(
            baseFare: shipment.estimatedPrice,
            totalAmount: shipment.estimatedPrice,
          ),
        );
      }
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
        _loadError = _detail == null ? ApiExceptionMapper.userMessage(e) : null;
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
              publishLabel:
                  customerShipmentStatusBadgeLabel(l10n, shipment.status),
              fromTitle: fromTitle,
              fromSubtitle: fromSub.isNotEmpty
                  ? fromSub
                  : shipment.pickup.fullAddress,
              toTitle: toTitle,
              toSubtitle:
                  toSub.isNotEmpty ? toSub : shipment.drop.fullAddress,
            ),
            if (detail.assignedDriver != null) ...[
              SizedBox(height: 32.h),
              PublishDriverInterestCard(
                driverName: detail.assignedDriver!.name,
                expertLabel: detail.assignedDriver!.subtitle ??
                    l10n.customerExpertDriver,
                vehicleName: detail.assignedDriver!.vehicleName.isNotEmpty
                    ? detail.assignedDriver!.vehicleName
                    : shipment.vehicleType.label,
                vehicleNumber:
                    detail.assignedDriver!.vehicleNumber.toUpperCase(),
                capacityLabel: l10n.tripCapacity,
                capacityValue: detail.assignedDriver!.capacityLabel.isNotEmpty
                    ? detail.assignedDriver!.capacityLabel.toUpperCase()
                    : shipment.loadCapacityLabel.toUpperCase(),
                avatarUrl: detail.assignedDriver!.avatarUrl,
                statusLabel: l10n.customerDriverAccepted,
                onTap: () => _onViewAssignedDriver(
                  context,
                  shipment,
                  detail.assignedDriver!,
                ),
                onCall: () => _contactDriver(
                  context,
                  detail.assignedDriver!,
                  whatsApp: false,
                ),
                onWhatsApp: () => _contactDriver(
                  context,
                  detail.assignedDriver!,
                  whatsApp: true,
                ),
              ),
            ] else if (detail.interestedDrivers.isNotEmpty) ...[
              SizedBox(height: 32.h),
              ...detail.interestedDrivers.map((driver) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: PublishDriverInterestCard(
                    driverName: driver.name,
                    expertLabel:
                        driver.subtitle ?? l10n.customerExpertDriver,
                    vehicleName: driver.vehicleName,
                    vehicleNumber: driver.vehicleNumber.toUpperCase(),
                    capacityLabel: l10n.tripCapacity,
                    capacityValue: driver.capacityLabel.toUpperCase(),
                    avatarUrl: driver.avatarUrl,
                    onTap: () => _onSelectDriver(context, shipment, driver),
                    onCall: () => _contactDriver(
                      context,
                      driver,
                      whatsApp: false,
                    ),
                    onWhatsApp: () => _contactDriver(
                      context,
                      driver,
                      whatsApp: true,
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

  Future<void> _onViewAssignedDriver(
    BuildContext context,
    Shipment shipment,
    ShipmentInterestedDriver driver,
  ) async {
    await DriverDetailSheet.show(
      context,
      driverId: driver.driverId,
      shipmentId: shipment.id,
      driver: driver,
      isAssigned: true,
    );
  }

  Future<void> _onSelectDriver(
    BuildContext context,
    Shipment shipment,
    ShipmentInterestedDriver driver,
  ) async {
    final result = await DriverDetailSheet.show(
      context,
      driverId: driver.driverId,
      shipmentId: shipment.id,
      driver: driver,
    );
    if (!mounted || result == null) return;

    final current = _detail;
    if (current == null) return;

    final assignedDriver = result.driver.capacityLabel.isNotEmpty
        ? result.driver
        : ShipmentInterestedDriver(
            driverId: result.driver.driverId,
            name: result.driver.name,
            subtitle: result.driver.subtitle,
            vehicleName: result.driver.vehicleName.isNotEmpty
                ? result.driver.vehicleName
                : current.shipment.vehicleType.label,
            vehicleNumber: result.driver.vehicleNumber,
            capacityLabel: current.shipment.loadCapacityLabel,
            phone: result.driver.phone,
            countryCode: result.driver.countryCode,
            avatarUrl: result.driver.avatarUrl ?? driver.avatarUrl,
            offeredPrice: result.driver.offeredPrice ?? driver.offeredPrice,
            note: result.driver.note ?? driver.note,
          );

    safeSetState(() {
      _detail = current.copyWith(
        shipment: current.shipment.copyWith(
          status: ShipmentStatus.assigned,
          assignedDriverId: result.driverId,
        ),
        assignedDriver: assignedDriver,
        interestedDrivers: const [],
      );
    });
  }

  Shipment? _resolveCachedShipment() {
    return ref
        .read(customerShipmentsProvider.notifier)
        .byId(widget.shipmentId);
  }

  Future<void> _contactDriver(
    BuildContext context,
    ShipmentInterestedDriver driver, {
    required bool whatsApp,
  }) async {
    final phone = driver.phone?.trim();
    if (phone == null || phone.isEmpty) return;

    final dialCode = driver.countryCode.isNotEmpty
        ? driver.countryCode
        : PhoneUtils.splitE164(phone).dialCode;
    final localNumber = phone.startsWith('+')
        ? PhoneUtils.splitE164(phone).localNumber
        : phone.replaceAll(RegExp(r'\D'), '');

    final launched = whatsApp
        ? await ExternalLauncher.openWhatsApp(
            dialCode: dialCode,
            localNumber: localNumber,
          )
        : await ExternalLauncher.dialPhone(
            dialCode: dialCode,
            localNumber: localNumber,
          );

    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            whatsApp
                ? context.l10n.driverWhatsAppLaunchFailed
                : 'Could not open phone dialer',
          ),
        ),
      );
    }
  }
}
