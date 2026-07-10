import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../../../../shared/domain/entities/driver_trip.dart';
import '../../../../shared/domain/enums/trip_status.dart';
import '../../../../shared/domain/models/driver_trip_detail.dart';
import '../../../../shared/presentation/widgets/feedback/error_view.dart';
import '../../../../shared/presentation/widgets/navigation/app_bar_widget.dart';
import '../../../customer/presentation/widgets/customer_light_chrome.dart';
import '../../../../core/utils/external_launcher.dart';
import '../../../../core/utils/phone_utils.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/driver_trips_provider.dart';
import '../widgets/my_trips/driver_trip_detail_card.dart';
import '../widgets/my_trips/driver_trip_interest_customer_card.dart';
import '../widgets/my_trips/driver_my_trip_tokens.dart';

/// Driver-owned trip detail — Figma `1:4180`.
class DriverTripDetailScreen extends ConsumerStatefulWidget {
  const DriverTripDetailScreen({super.key, required this.tripId});

  final String tripId;

  @override
  ConsumerState<DriverTripDetailScreen> createState() =>
      _DriverTripDetailScreenState();
}

class _DriverTripDetailScreenState extends ConsumerState<DriverTripDetailScreen>
    with SafeSetStateMixin {
  DriverTripDetail? _detail;
  bool _isLoading = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDetail());
  }

  Future<void> _loadDetail() async {
    final cached = ref.read(driverTripsProvider.notifier).byId(widget.tripId);
    if (cached != null) {
      safeSetState(() {
        _detail = DriverTripDetail(trip: cached);
      });
    }

    safeSetState(() {
      _isLoading = cached == null || EnvConfig.useRemoteApi;
      _loadError = null;
    });

    try {
      final apiId = ref
          .read(driverTripsProvider.notifier)
          .apiResourceIdFor(widget.tripId);
      DriverTripDetail? fetched;
      try {
        fetched = await ref.read(tripRepositoryProvider).getTripDetail(apiId);
      } catch (_) {
        final trip = await ref.read(tripRepositoryProvider).getTrip(apiId);
        fetched = DriverTripDetail(trip: trip);
      }
      if (!mounted) return;
      final resolved = fetched!;
      final enriched = _enrichTrip(
        _mergeTrips(cached, resolved.trip),
      );
      safeSetState(() {
        _detail = DriverTripDetail(trip: enriched, requests: resolved.requests);
        _isLoading = false;
      });
      ref.read(driverTripsProvider.notifier).upsertTrip(enriched);
    } catch (e) {
      if (!mounted) return;
      safeSetState(() {
        _isLoading = false;
        _loadError = _detail == null ? ApiExceptionMapper.userMessage(e) : null;
      });
    }
  }

  DriverTrip _mergeTrips(DriverTrip? cached, DriverTrip fetched) {
    if (cached == null) return fetched;
    return fetched.copyWith(
      driverName: fetched.driverName.isNotEmpty
          ? fetched.driverName
          : cached.driverName,
      driverPhone: fetched.driverPhone ?? cached.driverPhone,
      driverAvatarUrl: fetched.driverAvatarUrl ?? cached.driverAvatarUrl,
      vehicleNumber: fetched.vehicleNumber.isNotEmpty
          ? fetched.vehicleNumber
          : cached.vehicleNumber,
      loadCapacity: fetched.loadCapacity ?? cached.loadCapacity,
      capacityUnit: fetched.capacityUnit ?? cached.capacityUnit,
    );
  }

  DriverTrip _enrichTrip(DriverTrip trip) {
    final user = ref.read(authProvider).user;
    if (user == null) return trip;

    var enriched = trip;
    if (enriched.driverName.trim().isEmpty && user.name.trim().isNotEmpty) {
      enriched = enriched.copyWith(driverName: user.name.trim());
    }
    if ((enriched.driverPhone == null || enriched.driverPhone!.trim().isEmpty) &&
        user.phone.trim().isNotEmpty) {
      final parsed = PhoneUtils.splitE164(user.phone);
      enriched = enriched.copyWith(driverPhone: parsed.localNumber);
    }
    if ((enriched.driverAvatarUrl == null ||
            enriched.driverAvatarUrl!.trim().isEmpty) &&
        user.profileImageUrl != null &&
        user.profileImageUrl!.trim().isNotEmpty) {
      enriched = enriched.copyWith(driverAvatarUrl: user.profileImageUrl);
    }
    return enriched;
  }

  Future<void> _contactCustomer(
    DriverTripRequest request, {
    required bool whatsApp,
  }) async {
    final phone = request.phone?.trim();
    if (phone == null || phone.isEmpty) return;

    final dialCode = request.countryCode.isNotEmpty
        ? request.countryCode
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

    if (!launched && mounted) {
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final detail = _detail;

    if (_isLoading && detail == null) {
      return CustomerLightChrome(
        child: Scaffold(
          appBar: FlowScreenAppBar(title: l10n.driverTripDetailsTitle),
          body: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (detail == null) {
      return CustomerLightChrome(
        child: Scaffold(
          appBar: FlowScreenAppBar(title: l10n.driverTripDetailsTitle),
          body: ErrorView(
            message: _loadError ?? 'Trip not found.',
            onRetry: _loadDetail,
          ),
        ),
      );
    }

    final trip = detail.trip;
    final pendingRequests =
        detail.requests.where((request) => request.isPending).toList();
    final canCancel = trip.status != TripStatus.cancelled &&
        trip.status != TripStatus.completed;

    return CustomerLightChrome(
      child: Scaffold(
        backgroundColor: DriverMyTripTokens.screenBg,
        appBar: FlowScreenAppBar(
          title: l10n.driverTripDetailsTitle,
          backgroundColor: Colors.white.withValues(alpha: 0.8),
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(25.w, 20.h, 25.w, 24.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DriverTripDetailCard(trip: trip),
                      if (_loadError != null) ...[
                        SizedBox(height: 12.h),
                        Text(
                          _loadError!,
                          style: TextStyle(
                            fontFamily: FontRes.MANROPE_REGULAR,
                            fontSize: 13.sp,
                            color: DriverMyTripTokens.cancelText,
                          ),
                        ),
                      ],
                      if (pendingRequests.isNotEmpty) ...[
                        SizedBox(height: 30.h),
                        ...pendingRequests.map(
                          (request) => Padding(
                            padding: EdgeInsets.only(bottom: 10.h),
                            child: DriverTripInterestCustomerCard(
                              name: request.customerName,
                              avatarUrl: request.avatarUrl,
                              phone: request.phone,
                              onWhatsApp: () => _contactCustomer(
                                request,
                                whatsApp: true,
                              ),
                              onCall: () => _contactCustomer(
                                request,
                                whatsApp: false,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (canCancel)
                Padding(
                  padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 16.h),
                  child: TextButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      context.push(AppRoutes.cancelTripOf(trip.id));
                    },
                    child: Text(
                      l10n.driverCancelTrip,
                      style: TextStyle(
                        fontFamily: FontRes.MANROPE_BOLD,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: DriverMyTripTokens.cancelText,
                      ),
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
