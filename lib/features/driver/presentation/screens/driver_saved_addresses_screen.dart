import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/presentation/widgets/navigation/app_bar_widget.dart';
import '../../../customer/presentation/widgets/saved_addresses/saved_address_card.dart';
import '../../../customer/presentation/widgets/saved_addresses/saved_addresses_empty_placeholder.dart';
import '../../../customer/presentation/widgets/saved_addresses/saved_address_tokens.dart';
import '../../../customer/presentation/widgets/saved_addresses/saved_locations_section_header.dart';
import '../providers/driver_saved_addresses_provider.dart';

/// Driver saved addresses list — mirrors customer Figma `1:3130`.
class DriverSavedAddressesScreen extends ConsumerWidget {
  const DriverSavedAddressesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(driverSavedAddressesProvider);

    return Scaffold(
      backgroundColor: SavedAddressTokens.screenBg,
      appBar: FlowScreenAppBar(
        title: l10n.customerSavedAddresses,
        fallbackRoute: AppRoutes.driverHome,
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 8.h, right: 4.w),
        child: Material(
          color: SavedAddressTokens.accentUnderline,
          borderRadius: BorderRadius.circular(16.r),
          elevation: 8,
          shadowColor: const Color.fromRGBO(159, 66, 0, 0.3),
          child: InkWell(
            onTap: () => context.push(AppRoutes.driverAddAddress),
            borderRadius: BorderRadius.circular(16.r),
            child: SizedBox(
              width: 64.w,
              height: 64.w,
              child: Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 17.5.w,
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null && state.addresses.isEmpty
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Text(
                      state.error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: SavedAddressTokens.cardBody,
                      ),
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () =>
                      ref.read(driverSavedAddressesProvider.notifier).load(),
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 128.h),
                    itemCount: state.addresses.isEmpty
                        ? 2
                        : state.addresses.length + 1,
                    separatorBuilder: (_, index) {
                      if (index == 0) return SizedBox(height: 24.h);
                      return SizedBox(height: 28.h);
                    },
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return SavedLocationsSectionHeader(
                          label: l10n.customerSavedLocationsSection,
                        );
                      }
                      if (state.addresses.isEmpty) {
                        return Padding(
                          padding: EdgeInsets.only(top: 48.h),
                          child: const SavedAddressesEmptyPlaceholder(),
                        );
                      }
                      final address = state.addresses[index - 1];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (address.isDefault) ...[
                            Padding(
                              padding: EdgeInsets.only(bottom: 8.h, left: 4.w),
                              child: Text(
                                l10n.driverAddressDefaultBadge.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                  color: SavedAddressTokens.accentUnderline,
                                ),
                              ),
                            ),
                          ],
                          SavedAddressCard(
                            address: address.toDisplayAddress(),
                            onTap: () => context.push(
                              AppRoutes.driverEditAddressOf(address.id),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
    );
  }
}
