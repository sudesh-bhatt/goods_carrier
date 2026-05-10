import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/extensions/num_ext.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../shared/domain/entities/driver_trip.dart';
import '../../../../shared/domain/enums/trip_status.dart';
import '../../../../shared/presentation/widgets/buttons/app_button.dart';
import '../../../../shared/presentation/widgets/feedback/error_view.dart';
import '../../../../shared/presentation/widgets/navigation/app_bar_widget.dart';
import '../../../../shared/presentation/widgets/navigation/confirmation_bottom_sheet.dart';
import '../../../../shared/presentation/widgets/route/route_timeline.dart';
import '../../../../shared/presentation/widgets/status/status_chip.dart';
import '../providers/driver_trips_provider.dart';

/// Full detail view for a single driver trip.
///
/// Receives [tripId] via GoRouter path parameter `:id`.
/// Shows route, vehicle, schedule, earnings, and cancel CTA for active trips.
class DriverTripDetailScreen extends ConsumerWidget {
  const DriverTripDetailScreen({super.key, required this.tripId});

  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final state  = ref.watch(driverTripsProvider);
    final trip   = state.byId(tripId);

    if (trip == null) {
      return Scaffold(
        appBar: AppBarWidget(title: tripId),
        body: ErrorView(message: 'Trip not found.'),
      );
    }

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBarWidget(title: trip.id),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.screenPadding.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppDimensions.xl.h),

              // ── Status + earnings row ────────────────────────────────
              Row(
                children: [
                  StatusChip.trip(context: context, status: trip.status),
                  const Spacer(),
                  Text(
                    trip.estimatedPrice.inr,
                    style: context.textTheme.titleLarge?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),

              SizedBox(height: AppDimensions.xl.h),

              // ── Route ─────────────────────────────────────────────────
              _SectionCard(
                title: 'Route',
                child: RouteTimeline(
                  fromCity: trip.fromCity,
                  toCity:   trip.toCity,
                ),
              ),

              SizedBox(height: AppDimensions.base.h),

              // ── Vehicle ───────────────────────────────────────────────
              _SectionCard(
                title: 'Vehicle',
                child: Column(
                  children: [
                    _DetailRow(
                      icon: Icons.local_shipping_outlined,
                      label: context.l10n.tripVehicle,
                      value: trip.vehicleCategory.label,
                    ),
                    Divider(
                        height: AppDimensions.xl.h, color: colors.divider),
                    _DetailRow(
                      icon: Icons.directions_car_outlined,
                      label: context.l10n.profileVehicleNumber,
                      value: trip.vehicleNumber,
                    ),
                    Divider(
                        height: AppDimensions.xl.h, color: colors.divider),
                    _DetailRow(
                      icon: Icons.scale_outlined,
                      label: context.l10n.tripCapacity,
                      value: '${trip.loadCapacityTons} Ton',
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppDimensions.base.h),

              // ── Schedule ──────────────────────────────────────────────
              _SectionCard(
                title: 'Schedule',
                child: Column(
                  children: [
                    _DetailRow(
                      icon: Icons.play_circle_outline_rounded,
                      label: 'Start Date',
                      value: _fmtDate(trip.estimatedStartDate),
                    ),
                    Divider(
                        height: AppDimensions.xl.h, color: colors.divider),
                    _DetailRow(
                      icon: Icons.flag_outlined,
                      label: 'End Date',
                      value: _fmtDate(trip.estimatedEndDate),
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppDimensions.base.h),

              // ── Accepted shipment placeholder ─────────────────────────
              _SectionCard(
                title: 'Accepted Shipment',
                child: trip.status == TripStatus.confirmed ||
                        trip.status == TripStatus.active
                    ? _AcceptedShipmentInfo()
                    : Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: AppDimensions.sm.h),
                        child: Text(
                          'No shipment assigned yet',
                          style: context.textTheme.bodyMedium?.copyWith(
                              color: colors.textHint),
                        ),
                      ),
              ),

              SizedBox(height: AppDimensions.xxxl.h),
            ],
          ),
        ),
      ),

      // ── Cancel CTA ────────────────────────────────────────────────────
      bottomNavigationBar: (trip.status == TripStatus.active ||
              trip.status == TripStatus.pendingConfirmation)
          ? SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppDimensions.screenPadding.w,
                  AppDimensions.sm.h,
                  AppDimensions.screenPadding.w,
                  AppDimensions.base.h,
                ),
                child: AppButton(
                  label: 'Cancel Trip',
                  variant: AppButtonVariant.secondary,
                  onPressed: () async {
                    final confirmed = await ConfirmationBottomSheet.show(
                      context,
                      title:       'Cancel Trip?',
                      body:        'This will cancel trip ${trip.id}. This action cannot be undone.',
                      confirmLabel: context.l10n.actionYes,
                      isDangerous:  true,
                    );
                    if (confirmed == true && context.mounted) {
                      ref
                          .read(driverTripsProvider.notifier)
                          .cancelTrip(trip.id);
                      context.pop();
                    }
                  },
                ),
              ),
            )
          : null,
    );
  }

  String _fmtDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
}

// ─── Accepted shipment info (dummy placeholder) ────────────────────────────────

class _AcceptedShipmentInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Container(
          width: 44.w,
          height: 44.w,
          decoration: BoxDecoration(
            color: colors.primary.withOpacity(0.10),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.inventory_2_outlined,
              size: AppDimensions.iconBase.w, color: colors.primary),
        ),
        SizedBox(width: AppDimensions.sm.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TRK-6645 — FMCG Goods',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Pune, MH → Ahmedabad, GJ · 2000 KG',
                style: context.textTheme.bodySmall?.copyWith(
                    color: colors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: EdgeInsets.all(AppDimensions.base.w),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
        boxShadow: context.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.textTheme.labelMedium?.copyWith(
              color: colors.textHint,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: AppDimensions.sm.h),
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String   label;
  final String   value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: AppDimensions.iconMd.w, color: colors.primary),
        SizedBox(width: AppDimensions.sm.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: context.textTheme.bodySmall
                    ?.copyWith(color: colors.textHint),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
