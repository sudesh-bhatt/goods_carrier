import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/mixins/safe_set_state_mixin.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../res/font_res.dart';
import '../../../../shared/domain/entities/shipment.dart';
import '../../../../shared/domain/enums/vehicle_type.dart';
import '../../../../shared/domain/models/shipment_filter.dart';
import '../../../../shared/presentation/widgets/filters/filter_search_sheet.dart';
import '../../../../shared/presentation/widgets/feedback/empty_state.dart';
import '../../../../shared/presentation/widgets/feedback/skeleton_card.dart';
import '../../../../shared/presentation/widgets/navigation/customer_bottom_nav_bar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/customer_notifications_provider.dart';
import '../providers/customer_shipments_provider.dart';
import '../widgets/customer_home_trip_card.dart';
import '../widgets/customer_light_chrome.dart';
import '../widgets/customer_navigation.dart';

/// Customer Home — [Figma `2013:1402`](https://www.figma.com/design/wT5NdNeg7YVPPcq1nY9D2P/Goods-Carrier--Copy-?node-id=2013-1402).
class CustomerHomeScreen extends ConsumerStatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  ConsumerState<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends ConsumerState<CustomerHomeScreen>
    with SafeSetStateMixin {
  final _searchCtrl = TextEditingController();

  ShipmentFilter _shipmentFilter = const ShipmentFilter();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Shipment> _filterShipments(List<Shipment> source) {
    final query = _searchCtrl.text.trim().toLowerCase();
    return source.where((s) {
      if (!_shipmentFilter.matches(s)) return false;
      if (query.isEmpty) return true;
      final haystack = [
        s.id,
        s.pickup.city,
        s.drop.city,
        s.vehicleType.label,
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final state = ref.watch(customerShipmentsProvider);
    final user = ref.watch(authProvider).user;
    final unreadCount = ref.watch(customerUnreadCountProvider);
    final activeList = _filterShipments(state.active);

    return CustomerLightChrome(
      child: Scaffold(
        backgroundColor: colors.background,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CustomerHomeHeader(
              title: l10n.customerHomeBrandTitle,
              unreadCount: unreadCount,
              userName: user?.name,
              onNotifications: () =>
                  context.push(AppRoutes.customerNotifications),
              onProfile: () => context.push(AppRoutes.customerProfile),
            ),
            Expanded(
              child: RefreshIndicator(
                color: colors.primary,
                onRefresh: () =>
                    Future.delayed(const Duration(milliseconds: 600)),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(25.w, 20.h, 25.w, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _HomeSearchRow(
                              controller: _searchCtrl,
                              hint: l10n.customerHomeSearchHint,
                              onChanged: (_) => safeSetState(() {}),
                              onFilterTap: () async {
                                final result = await FilterSearchSheet.show(
                                  context,
                                  initial: _shipmentFilter,
                                );
                                if (result != null) {
                                  safeSetState(() => _shipmentFilter = result);
                                }
                              },
                            ),
                            SizedBox(height: 24.h),
                            Text(
                              l10n.customerHomeDriverTrips,
                              style: TextStyle(
                                fontFamily: FontRes.MANROPE_EXTRABOLD,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w800,
                                height: 1.2,
                                color: colors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            _VehicleTypeChips(
                              selected: _shipmentFilter.vehicleClass,
                              onSelected: (type) => safeSetState(() {
                                _shipmentFilter =
                                    _shipmentFilter.vehicleClass == type
                                        ? _shipmentFilter.copyWith(
                                            clearVehicleClass: true,
                                          )
                                        : _shipmentFilter.copyWith(
                                            vehicleClass: type,
                                          );
                              }),
                            ),
                            SizedBox(height: 20.h),
                          ],
                        ),
                      ),
                    ),
                    if (state.isLoading)
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, __) => Padding(
                            padding: EdgeInsets.fromLTRB(
                              25.w,
                              0,
                              25.w,
                              AppDimensions.sm.h,
                            ),
                            child: const SkeletonCard(),
                          ),
                          childCount: 3,
                        ),
                      )
                    else if (state.active.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 25.w),
                          child: EmptyState(
                            headline: l10n.emptyShipments,
                            subtitle: l10n.emptyShipmentsSubtitle,
                            fallbackIcon: Icons.local_shipping_outlined,
                            actionLabel: l10n.shipmentPostNew,
                            onAction: () =>
                                context.push(AppRoutes.postShipment),
                          ),
                        ),
                      )
                    else if (activeList.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 25.w),
                          child: EmptyState(
                            headline: l10n.emptyHistory,
                            subtitle: l10n.customerHomeSearchHint,
                            fallbackIcon: Icons.search_off_rounded,
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          25.w,
                          0,
                          25.w,
                          120.h,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final shipment = activeList[index];
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: AppDimensions.base.h,
                                ),
                                child: CustomerHomeTripCard(
                                  shipment: shipment,
                                  onTap: () => context.push(
                                    AppRoutes.shipmentDetailOf(shipment.id),
                                  ),
                                  onViewDetails: () => context.push(
                                    AppRoutes.shipmentDetailOf(shipment.id),
                                  ),
                                ),
                              );
                            },
                            childCount: activeList.length,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: Padding(
          padding: EdgeInsets.only(bottom: 12.h, right: 4.w),
          child: Material(
            elevation: 6,
            shadowColor: colors.primary.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(18.r),
            color: colors.primary,
            child: InkWell(
              onTap: () => context.push(AppRoutes.postShipment),
              borderRadius: BorderRadius.circular(18.r),
              child: SizedBox(
                width: 64.w,
                height: 64.w,
                child: Icon(
                  Icons.add_rounded,
                  color: colors.onPrimary,
                  size: 28.w,
                ),
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        bottomNavigationBar: CustomerBottomNavBar(
          currentTab: CustomerMainTab.home,
          onTabSelected: (tab) => navigateCustomerTab(context, tab),
        ),
      ),
    );
  }
}

// ─── Header: title only + bell + avatar (Figma 2013:1540) ───────────────────

class _CustomerHomeHeader extends StatelessWidget {
  const _CustomerHomeHeader({
    required this.title,
    required this.unreadCount,
    required this.userName,
    required this.onNotifications,
    required this.onProfile,
  });

  final String title;
  final int unreadCount;
  final String? userName;
  final VoidCallback onNotifications;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final initial = (userName?.trim().isNotEmpty == true)
        ? userName!.trim()[0].toUpperCase()
        : '?';

    return ColoredBox(
      color: colors.surface,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 56.h,
          padding: EdgeInsets.symmetric(horizontal: 25.w),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: FontRes.MANROPE_EXTRABOLD,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: 40.w, minHeight: 40.w),
                onPressed: onNotifications,
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      Icons.notifications_none_rounded,
                      size: 24.w,
                      color: colors.primary,
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: BoxDecoration(
                            color: colors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colors.surface,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: onProfile,
                child: CircleAvatar(
                  radius: 17.w,
                  backgroundColor: colors.primary.withValues(alpha: 0.12),
                  backgroundImage: null,
                  child: Text(
                    initial,
                    style: TextStyle(
                      fontFamily: FontRes.MANROPE_BOLD,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: colors.primaryDark,
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

// ─── Search + filter — two white boxes (Figma 2013:1405) ─────────────────────

class _HomeSearchRow extends StatelessWidget {
  const _HomeSearchRow({
    required this.controller,
    required this.hint,
    required this.onChanged,
    required this.onFilterTap,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterTap;

  static BoxDecoration _whiteBoxDecoration(AppColorScheme colors) =>
      BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: colors.shadowCard,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fieldHeight = AppDimensions.inputHeight.h;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            height: fieldHeight,
            decoration: _whiteBoxDecoration(colors),
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            alignment: Alignment.center,
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  size: 20.w,
                  color: colors.textHint,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    style: TextStyle(
                      fontFamily: FontRes.MANROPE_REGULAR,
                      fontSize: 14.sp,
                      height: 1.25,
                      color: colors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: TextStyle(
                        fontFamily: FontRes.MANROPE_REGULAR,
                        fontSize: 14.sp,
                        color: colors.textHint,
                      ),
                      filled: true,
                      fillColor: colors.surface,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onFilterTap,
            borderRadius: BorderRadius.circular(16.r),
            child: Container(
              width: fieldHeight,
              height: fieldHeight,
              decoration: _whiteBoxDecoration(colors),
              alignment: Alignment.center,
              child: Icon(
                Icons.tune_rounded,
                size: 20.w,
                color: colors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Vehicle chips — Mini / Pickup / Truck only (Figma 2013:1417) ─────────────

class _VehicleTypeChips extends StatelessWidget {
  const _VehicleTypeChips({
    required this.selected,
    required this.onSelected,
  });

  final VehicleType? selected;
  final ValueChanged<VehicleType> onSelected;

  static const _chips = [
    (VehicleType.mini, 'Mini', Icons.local_shipping_outlined),
    (VehicleType.pickupTruck, 'Pickup', Icons.fire_truck_outlined),
    (VehicleType.truck, 'Truck', Icons.local_shipping_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44.h,
      child: Row(
        children: [
          for (var i = 0; i < _chips.length; i++) ...[
            if (i > 0) SizedBox(width: 10.w),
            Expanded(
              child: _VehicleChip(
                label: _chips[i].$2,
                icon: _chips[i].$3,
                selected: selected == _chips[i].$1,
                onTap: () => onSelected(_chips[i].$1),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _VehicleChip extends StatelessWidget {
  const _VehicleChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fg = selected ? colors.onPrimary : colors.textPrimary;
    final bg = selected ? colors.primary : const Color(0xFFF0F2F5);

    return Material(
      color: bg,
      elevation: selected ? 4 : 0,
      shadowColor: colors.primary.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(22.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22.r),
        child: SizedBox(
          height: 44.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16.w, color: fg),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  fontFamily: FontRes.MANROPE_SEMIBOLD,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
