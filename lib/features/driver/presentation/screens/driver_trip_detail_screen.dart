import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/dummy/dummy_trips.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../res/font_res.dart';
import '../../../../shared/presentation/widgets/feedback/error_view.dart';
import '../../../../shared/presentation/widgets/navigation/app_bar_widget.dart';
import '../../../customer/presentation/widgets/customer_light_chrome.dart';
import '../providers/driver_trips_provider.dart';
import '../widgets/my_trips/driver_trip_detail_card.dart';
import '../widgets/my_trips/driver_trip_interest_customer_card.dart';
import '../widgets/my_trips/driver_my_trip_tokens.dart';

/// Driver-owned trip detail — Figma `1:4180`.
class DriverTripDetailScreen extends ConsumerWidget {
  const DriverTripDetailScreen({super.key, required this.tripId});

  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final trip = ref.watch(driverTripsProvider).byId(tripId);

    if (trip == null) {
      return CustomerLightChrome(
        child: Scaffold(
          appBar: FlowScreenAppBar(title: l10n.driverTripDetailsTitle),
          body: const ErrorView(message: 'Trip not found.'),
        ),
      );
    }

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
                      SizedBox(height: 30.h),
                      ...DummyTrips.interestedCustomers.map(
                        (name) => Padding(
                          padding: EdgeInsets.only(bottom: 10.h),
                          child: DriverTripInterestCustomerCard(
                            name: name,
                            onWhatsApp: () {},
                            onCall: () {},
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
