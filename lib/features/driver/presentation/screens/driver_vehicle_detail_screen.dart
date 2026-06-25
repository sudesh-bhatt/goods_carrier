import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/mixins/safe_set_state_mixin.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/external_launcher.dart';
import '../../../../core/extensions/svg_gen_image_extension.dart';
import '../../../../generated/assets.dart';
import '../../../../res/font_res.dart';
import '../../../../shared/domain/enums/driver_vehicle_status.dart';
import '../../../../shared/domain/models/driver_vehicle_detail.dart';
import '../../../../shared/domain/models/driver_vehicle_edit_result.dart';
import '../../../../shared/presentation/widgets/navigation/app_bar_widget.dart';
import '../../../../shared/presentation/widgets/profile/profile_image_content.dart';
import '../providers/driver_vehicles_provider.dart';
import '../widgets/vehicles/driver_vehicle_status_badge.dart';
import '../widgets/vehicles/driver_vehicle_tokens.dart';

/// Vehicle details — [Figma](https://www.figma.com/design/YxnNResvDQnbkcPhGejtxa/Mobile-App-UI--Developer-?node-id=1-114).
class DriverVehicleDetailScreen extends ConsumerStatefulWidget {
  const DriverVehicleDetailScreen({super.key, required this.vehicleId});

  final int vehicleId;

  @override
  ConsumerState<DriverVehicleDetailScreen> createState() =>
      _DriverVehicleDetailScreenState();
}

class _DriverVehicleDetailScreenState
    extends ConsumerState<DriverVehicleDetailScreen> with SafeSetStateMixin {
  DriverVehicleDetail? _detail;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    safeSetState(() {
      _loading = true;
      _error = null;
    });
    final detail =
        await ref.read(driverVehiclesProvider.notifier).fetchDetail(widget.vehicleId);
    if (!mounted) return;
    safeSetState(() {
      _detail = detail;
      _loading = false;
      _error = detail == null ? context.l10n.driverVehicleLoadFailed : null;
    });
  }

  Future<void> _openEdit(DriverVehicleDetail detail) async {
    final result = await context.push<DriverVehicleEditResult>(
      AppRoutes.driverEditVehicleOf(detail.id),
    );
    if (!mounted || result == null || !result.updated) return;
    final updated = result.detail;
    if (updated == null) return;
    safeSetState(() => _detail = updated);
    _showSnack(context.l10n.driverVehicleUpdated);
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _callDriver(DriverVehicleDetail detail) async {
    final l10n = context.l10n;
    if (!ExternalLauncher.hasCallableNumber(
      detail.driverCountryCode,
      detail.driverPhone,
    )) {
      _showSnack(l10n.driverPhoneUnavailable);
      return;
    }

    final launched = await ExternalLauncher.dialPhone(
      dialCode: detail.driverCountryCode,
      localNumber: detail.driverPhone,
    );
    if (!mounted) return;
    if (!launched) _showSnack(l10n.driverCallLaunchFailed);
  }

  Future<void> _openWhatsApp(DriverVehicleDetail detail) async {
    final l10n = context.l10n;
    if (!ExternalLauncher.hasCallableNumber(
      detail.driverCountryCode,
      detail.driverPhone,
    )) {
      _showSnack(l10n.driverPhoneUnavailable);
      return;
    }

    final launched = await ExternalLauncher.openWhatsApp(
      dialCode: detail.driverCountryCode,
      localNumber: detail.driverPhone,
    );
    if (!mounted) return;
    if (!launched) _showSnack(l10n.driverWhatsAppLaunchFailed);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final detail = _detail;

    return Scaffold(
      backgroundColor: DriverVehicleTokens.screenBg,
      appBar: FlowScreenAppBar(
        title: l10n.driverVehicleDetailsTitle,
        fallbackRoute: AppRoutes.driverVehicles,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : detail == null
              ? Center(child: Text(_error ?? l10n.driverVehicleLoadFailed))
              : Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
                        children: [
                          _HeroCard(detail: detail),
                          SizedBox(height: 20.h),
                          _DriverCard(
                            detail: detail,
                            onCall: () => _callDriver(detail),
                            onWhatsApp: () => _openWhatsApp(detail),
                          ),
                          SizedBox(height: 20.h),
                          _SpecificationsCard(detail: detail),
                        ],
                      ),
                    ),
                    _StickyEditBar(
                      label: l10n.driverEditVehicle,
                      onPressed: () => _openEdit(detail),
                    ),
                  ],
                ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.detail});

  final DriverVehicleDetail detail;

  @override
  Widget build(BuildContext context) {
    final (iconColor, iconBg) = vehicleIconColors(detail.status);
    final icon = vehicleTypeIcon(detail.vehicleTypeName);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color.fromRGBO(226, 191, 176, 0.1)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DriverVehicleIconBadge(
                icon: icon,
                tint: iconColor == DriverVehicleTokens.mutedGrey
                    ? DriverVehicleTokens.accentBrown
                    : iconColor,
                background: iconBg == DriverVehicleTokens.maintenanceBg
                    ? DriverVehicleTokens.iconBrownBg
                    : iconBg,
                radius: 9999,
              ),
              _DetailStatusBadge(status: detail.status),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            detail.vehicleTypeName,
            style: TextStyle(
              fontFamily: FontRes.MANROPE_EXTRABOLD,
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
              height: 32 / 24,
              letterSpacing: -0.6,
              color: DriverVehicleTokens.bodyDark,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            detail.registrationNumber,
            style: TextStyle(
              fontFamily: FontRes.MANROPE_MEDIUM,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              height: 24 / 16,
              color: DriverVehicleTokens.labelBrown,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailStatusBadge extends StatelessWidget {
  const _DetailStatusBadge({required this.status});

  final DriverVehicleStatus status;

  @override
  Widget build(BuildContext context) {
    if (status == DriverVehicleStatus.inMaintenance) {
      return DriverVehicleStatusBadge(status: status);
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: DriverVehicleTokens.statusBlueBg,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        'ACTIVE',
        style: TextStyle(
          fontFamily: FontRes.MANROPE_EXTRABOLD,
          fontSize: 10.sp,
          fontWeight: FontWeight.w800,
          height: 15 / 10,
          letterSpacing: 1,
          color: DriverVehicleTokens.statusBlueText,
        ),
      ),
    );
  }
}

class _DriverCard extends StatelessWidget {
  const _DriverCard({
    required this.detail,
    required this.onCall,
    required this.onWhatsApp,
  });

  final DriverVehicleDetail detail;
  final VoidCallback onCall;
  final VoidCallback onWhatsApp;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final subtitle = detail.driverSubtitle.trim().isNotEmpty
        ? detail.driverSubtitle
        : l10n.driverExpertDriverLabel;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: DriverVehicleTokens.driverCardBg,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24.r),
                child: SizedBox(
                  width: 56.w,
                  height: 56.w,
                  child: ProfileImageContent(
                    imageReference: detail.profilePhotoUrl,
                    placeholder: Container(
                      color: DriverVehicleTokens.cardFill,
                      child: Icon(
                        Icons.person_rounded,
                        color: DriverVehicleTokens.labelBrown,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: -4.w,
                bottom: -4.h,
                child: Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    color: DriverVehicleTokens.accentBrown,
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(
                      color: DriverVehicleTokens.driverCardBg,
                      width: 2,
                    ),
                  ),
                  child: Icon(Icons.check_rounded, size: 12.w, color: Colors.white),
                ),
              ),
            ],
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.driverName,
                  style: TextStyle(
                    fontFamily: FontRes.MANROPE_BOLD,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    height: 20 / 14,
                    color: DriverVehicleTokens.bodyDark,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: FontRes.MANROPE_MEDIUM,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    height: 15 / 10,
                    color: const Color(0xFF41484C),
                  ),
                ),
              ],
            ),
          ),
          _ActionIconButton(icon: Icons.phone_outlined, onTap: onCall),
          SizedBox(width: 12.w),
          _ActionIconButton(
            onTap: onWhatsApp,
            child: Assets.icWhatsapp.svgTint(
              width: 18.w,
              height: 18.w,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  const _ActionIconButton({
    required this.onTap,
    this.icon,
    this.child,
  });

  final IconData? icon;
  final Widget? child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: SizedBox(
          width: 42.w,
          height: 42.w,
          child: Center(
            child: child ?? Icon(icon, size: 15.w, color: Colors.black),
          ),
        ),
      ),
    );
  }
}

class _SpecificationsCard extends StatelessWidget {
  const _SpecificationsCard({required this.detail});

  final DriverVehicleDetail detail;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Opacity(
            opacity: 0.6,
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 12.w, color: DriverVehicleTokens.bodyDark),
                SizedBox(width: 8.w),
                Text(
                  l10n.driverVehicleSpecifications.toUpperCase(),
                  style: TextStyle(
                    fontFamily: FontRes.MANROPE_BOLD,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    height: 15 / 10,
                    letterSpacing: 1,
                    color: DriverVehicleTokens.bodyDark,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _SpecItem(
                  label: l10n.driverVehicleTypeLabel,
                  value: detail.vehicleTypeName,
                ),
              ),
              Expanded(
                child: _SpecItem(
                  label: l10n.driverVehicleRegistrationLabel,
                  value: detail.registrationNumber,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          _SpecItem(
            label: l10n.driverVehicleCapacityLabel,
            value: detail.capacityLabel,
          ),
        ],
      ),
    );
  }
}

class _SpecItem extends StatelessWidget {
  const _SpecItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontFamily: FontRes.MANROPE_BOLD,
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            height: 16 / 11,
            letterSpacing: -0.55,
            color: const Color.fromRGBO(89, 65, 54, 0.7),
          ),
        ),
        SizedBox(height: 4.5.h),
        Text(
          value,
          style: TextStyle(
            fontFamily: FontRes.MANROPE_BOLD,
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            height: 20 / 14,
            color: DriverVehicleTokens.bodyDark,
          ),
        ),
      ],
    );
  }
}

class _StickyEditBar extends StatelessWidget {
  const _StickyEditBar({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(24.w),
          decoration: const BoxDecoration(
            color: Color.fromRGBO(245, 250, 255, 0.95),
            borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(22, 28, 32, 0.05),
                blurRadius: 30,
                offset: Offset(0, -10),
              ),
            ],
          ),
          child: Material(
            color: DriverVehicleTokens.accentOrange,
            borderRadius: BorderRadius.circular(16.r),
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(16.r),
              child: SizedBox(
                height: 56.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit_outlined, color: Colors.white, size: 12.w),
                    SizedBox(width: 8.w),
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: FontRes.MANROPE_BOLD,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        height: 24 / 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
