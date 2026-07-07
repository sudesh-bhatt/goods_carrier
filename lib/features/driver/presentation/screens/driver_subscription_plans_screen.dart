import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../res/font_res.dart';
import '../../../../shared/presentation/widgets/feedback/empty_state.dart';
import '../../../../shared/presentation/widgets/navigation/app_bar_widget.dart';
import '../models/subscription_flow_args.dart';
import '../providers/driver_subscription_provider.dart';
import '../widgets/subscription/subscription_logistics_background.dart';
import '../widgets/subscription/subscription_plan_card.dart';
import '../widgets/subscription/subscription_tokens.dart';

/// Driver subscription plans — Figma `1:5227`.
class DriverSubscriptionPlansScreen extends ConsumerStatefulWidget {
  const DriverSubscriptionPlansScreen({super.key});

  @override
  ConsumerState<DriverSubscriptionPlansScreen> createState() =>
      _DriverSubscriptionPlansScreenState();
}

class _DriverSubscriptionPlansScreenState
    extends ConsumerState<DriverSubscriptionPlansScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(driverSubscriptionProvider.notifier).loadPlans(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(driverSubscriptionProvider);
    final showInitialLoading = state.isLoadingPlans && state.plans.isEmpty;

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
                            padding: EdgeInsets.fromLTRB(24.w, 64.h, 24.w, 128.h),
                            sliver: SliverList.separated(
                              itemCount: state.plans.length,
                              separatorBuilder: (_, __) => SizedBox(height: 32.h),
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
                                  perMonthLabel: l10n.driverSubscriptionPerMonth,
                                  onChoose: () => context.push(
                                    AppRoutes.driverSubscriptionPayment,
                                    extra: SubscriptionCheckoutArgs(plan: plan),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      ),
          ),
        ],
      ),
    );
  }
}
