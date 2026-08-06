import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/mixins/safe_set_state_mixin.dart';
import '../../../../core/network/api_exception_mapper.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../res/font_res.dart';
import '../../../../shared/domain/models/subscription_plan.dart';
import '../../../../shared/presentation/widgets/feedback/empty_state.dart';
import '../../../../shared/presentation/widgets/navigation/app_bar_widget.dart';
import '../providers/driver_subscription_checkout_coordinator.dart';
import '../providers/driver_subscription_provider.dart';
import '../widgets/subscription/subscription_logistics_background.dart';
import '../widgets/subscription/subscription_plan_card.dart';
import '../widgets/subscription/subscription_tokens.dart';

/// Driver subscription plans — Figma `1:5227`.
///
/// Subscribe Now initiates the order and opens Razorpay via
/// [driverSubscriptionCheckoutProvider] (lives across this screen's rebuilds
/// after Android CheckoutActivity returns).
class DriverSubscriptionPlansScreen extends ConsumerStatefulWidget {
  const DriverSubscriptionPlansScreen({super.key});

  @override
  ConsumerState<DriverSubscriptionPlansScreen> createState() =>
      _DriverSubscriptionPlansScreenState();
}

class _DriverSubscriptionPlansScreenState
    extends ConsumerState<DriverSubscriptionPlansScreen>
    with SafeSetStateMixin {
  bool _isStartingCheckout = false;

  @override
  void initState() {
    super.initState();
    // Touch keepAlive coordinator so Razorpay is ready before Subscribe Now.
    ref.read(driverSubscriptionCheckoutProvider);
    Future.microtask(
      () => ref.read(driverSubscriptionProvider.notifier).loadPlans(),
    );
  }

  Future<void> _subscribe(SubscriptionPlan plan) async {
    if (_isStartingCheckout) return;
    HapticFeedback.lightImpact();

    safeSetState(() => _isStartingCheckout = true);
    try {
      await ref.read(driverSubscriptionCheckoutProvider).subscribe(plan);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ApiExceptionMapper.userMessage(e))),
      );
    } finally {
      safeSetState(() => _isStartingCheckout = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(driverSubscriptionProvider);
    // Keep coordinator alive while this route is visible.
    ref.watch(driverSubscriptionCheckoutProvider);
    final showInitialLoading = state.isLoadingPlans && state.plans.isEmpty;
    final isPaying = _isStartingCheckout || state.isProcessingPayment;

    return Scaffold(
      backgroundColor: SubscriptionTokens.screenBg,
      appBar: FlowScreenAppBar(
        title: l10n.driverSubscriptionPlansTitle,
        fallbackRoute: AppRoutes.driverProfile,
      ),
      body: Stack(
        children: [
          SubscriptionLogisticsBackground.positioned(),
          SafeArea(
            top: false,
            child: showInitialLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null && state.plans.isEmpty
                    ? EmptyState(
                        headline: l10n.driverSubscriptionLoadErrorTitle,
                        subtitle: state.error!,
                        actionLabel: l10n.actionRetry,
                        onAction: () => ref
                            .read(driverSubscriptionProvider.notifier)
                            .loadPlans(),
                      )
                    : RefreshIndicator(
                        color: context.colors.primary,
                        onRefresh: () => ref
                            .read(driverSubscriptionProvider.notifier)
                            .loadPlans(),
                        child: CustomScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          slivers: [
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(
                                  24.w,
                                  32.h,
                                  24.w,
                                  0,
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      l10n.driverSubscriptionHeroTitle,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: FontRes.MANROPE_EXTRABOLD,
                                        fontSize: 36.sp,
                                        fontWeight: FontWeight.w800,
                                        height: 40 / 36,
                                        letterSpacing: -0.9,
                                        color: SubscriptionTokens.titleDark,
                                      ),
                                    ),
                                    SizedBox(height: 16.h),
                                    Text(
                                      l10n.driverSubscriptionHeroSubtitle,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: FontRes.MANROPE_REGULAR,
                                        fontSize: 18.sp,
                                        height: 28 / 18,
                                        color: SubscriptionTokens.bodyGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SliverPadding(
                              padding:
                                  EdgeInsets.fromLTRB(24.w, 64.h, 24.w, 128.h),
                              sliver: SliverList.separated(
                                itemCount: state.plans.length,
                                separatorBuilder: (_, __) =>
                                    SizedBox(height: 32.h),
                                itemBuilder: (context, index) {
                                  final plan = state.plans[index];
                                  return SubscriptionPlanCard(
                                    plan: plan,
                                    choosePlanLabel:
                                        l10n.driverSubscriptionChoosePlan,
                                    subscribeNowLabel:
                                        l10n.driverSubscriptionSubscribeNow,
                                    recommendedLabel:
                                        l10n.driverSubscriptionRecommended,
                                    perMonthLabel:
                                        l10n.driverSubscriptionPerMonth,
                                    onChoose: () {
                                      if (isPaying) return;
                                      _subscribe(plan);
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
          ),
          if (isPaying)
            const ColoredBox(
              color: Color(0x66000000),
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
