import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/mixins/safe_set_state_mixin.dart';
import '../../../../core/network/api_exception_mapper.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../res/font_res.dart';
import '../../../../shared/domain/models/current_subscription.dart';
import '../../../../shared/domain/models/subscription_plan.dart';
import '../../../../shared/presentation/widgets/feedback/empty_state.dart';
import '../../../../shared/presentation/widgets/navigation/app_bar_widget.dart';
import '../providers/driver_subscription_checkout_coordinator.dart';
import '../providers/driver_subscription_provider.dart';
import '../widgets/subscription/subscription_active_plan_card.dart';
import '../widgets/subscription/subscription_logistics_background.dart';
import '../widgets/subscription/subscription_plan_card.dart';
import '../widgets/subscription/subscription_tokens.dart';

/// Driver subscription plans — Figma `1:5227` + active-plan manage mode.
///
/// Subscribe / Switch opens Razorpay via [driverSubscriptionCheckoutProvider].
class DriverSubscriptionPlansScreen extends ConsumerStatefulWidget {
  const DriverSubscriptionPlansScreen({super.key});

  @override
  ConsumerState<DriverSubscriptionPlansScreen> createState() =>
      _DriverSubscriptionPlansScreenState();
}

class _DriverSubscriptionPlansScreenState
    extends ConsumerState<DriverSubscriptionPlansScreen>
    with SafeSetStateMixin, SingleTickerProviderStateMixin {
  bool _isStartingCheckout = false;
  final _scrollController = ScrollController();
  final _plansSectionKey = GlobalKey();
  late final AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    )..forward();
    ref.read(driverSubscriptionCheckoutProvider);
    Future.microtask(
      () => ref.read(driverSubscriptionProvider.notifier).loadPlans(),
    );
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _scrollController.dispose();
    super.dispose();
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

  void _scrollToPlans() {
    HapticFeedback.selectionClick();
    final ctx = _plansSectionKey.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 480),
      curve: Curves.easeOutCubic,
      alignment: 0.08,
    );
  }

  Animation<double> _stagger(double begin, double end) {
    return CurvedAnimation(
      parent: _entranceController,
      curve: Interval(begin, end, curve: Curves.easeOutCubic),
    );
  }

  String _tripsLabel(CurrentSubscription sub, AppLocalizations l10n) {
    final limit = sub.tripLimit;
    final used = sub.tripsUsed;
    if (limit == null || used == null) return '';
    final remaining = sub.tripsRemaining ?? (limit - used);
    return l10n.driverSubscriptionTripsUsage(used, limit, remaining);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final state = ref.watch(driverSubscriptionProvider);
    ref.watch(driverSubscriptionCheckoutProvider);
    final showInitialLoading = state.isLoadingPlans && state.plans.isEmpty;
    final isPaying = _isStartingCheckout || state.isProcessingPayment;
    final active = state.currentSubscription;
    final hasActive = active?.isCurrentlyActive == true;
    final activePlanId = hasActive ? active!.planId : null;

    // Enrich active card price from plans list when API omitted nested price.
    final enrichedActive = hasActive
        ? _enrichActive(active!, state.plans)
        : null;

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
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          slivers: [
                            if (enrichedActive != null) ...[
                              SliverToBoxAdapter(
                                child: FadeTransition(
                                  opacity: _stagger(0, 0.45),
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0, 0.08),
                                      end: Offset.zero,
                                    ).animate(_stagger(0, 0.45)),
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(
                                        24.w,
                                        24.h,
                                        24.w,
                                        0,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            l10n.driverSubscriptionActiveSection,
                                            style: TextStyle(
                                              fontFamily:
                                                  FontRes.MANROPE_EXTRABOLD,
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 1.1,
                                              color:
                                                  SubscriptionTokens.bodyGrey,
                                            ),
                                          ),
                                          SizedBox(height: 16.h),
                                          AnimatedSwitcher(
                                            duration: const Duration(
                                              milliseconds: 420,
                                            ),
                                            switchInCurve: Curves.easeOutCubic,
                                            switchOutCurve: Curves.easeInCubic,
                                            transitionBuilder: (child, anim) {
                                              return FadeTransition(
                                                opacity: anim,
                                                child: SlideTransition(
                                                  position: Tween<Offset>(
                                                    begin:
                                                        const Offset(0, 0.06),
                                                    end: Offset.zero,
                                                  ).animate(anim),
                                                  child: child,
                                                ),
                                              );
                                            },
                                            child: SubscriptionActivePlanCard(
                                              key: ValueKey(
                                                '${enrichedActive.planId}-'
                                                '${enrichedActive.endDate.toIso8601String()}',
                                              ),
                                              subscription: enrichedActive,
                                              activeLabel: l10n
                                                  .driverSubscriptionActiveBadge,
                                              changePlanLabel: l10n
                                                  .driverSubscriptionChangePlan,
                                              perMonthLabel: l10n
                                                  .driverSubscriptionPerMonth,
                                              validTillLabel: l10n
                                                  .driverSubscriptionValidTill(
                                                SubscriptionActivePlanCard
                                                    .formatValidTill(
                                                  enrichedActive.endDate,
                                                  locale,
                                                ),
                                              ),
                                              tripsUsageLabel: _tripsLabel(
                                                enrichedActive,
                                                l10n,
                                              ),
                                              onChangePlan: _scrollToPlans,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SliverToBoxAdapter(
                                child: Padding(
                                  key: _plansSectionKey,
                                  padding: EdgeInsets.fromLTRB(
                                    24.w,
                                    40.h,
                                    24.w,
                                    0,
                                  ),
                                  child: FadeTransition(
                                    opacity: _stagger(0.2, 0.55),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l10n.driverSubscriptionChangeSection,
                                          style: TextStyle(
                                            fontFamily:
                                                FontRes.MANROPE_EXTRABOLD,
                                            fontSize: 22.sp,
                                            fontWeight: FontWeight.w800,
                                            height: 28 / 22,
                                            color: SubscriptionTokens.titleDark,
                                          ),
                                        ),
                                        SizedBox(height: 8.h),
                                        Text(
                                          l10n
                                              .driverSubscriptionChangeSectionSubtitle,
                                          style: TextStyle(
                                            fontFamily: FontRes.MANROPE_REGULAR,
                                            fontSize: 15.sp,
                                            height: 22 / 15,
                                            color: SubscriptionTokens.bodyGrey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ] else
                              SliverToBoxAdapter(
                                child: FadeTransition(
                                  opacity: _stagger(0, 0.4),
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
                                            fontFamily:
                                                FontRes.MANROPE_EXTRABOLD,
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
                              ),
                            SliverPadding(
                              padding: EdgeInsets.fromLTRB(
                                24.w,
                                hasActive ? 28.h : 64.h,
                                24.w,
                                128.h,
                              ),
                              sliver: SliverList.separated(
                                itemCount: state.plans.length,
                                separatorBuilder: (_, __) =>
                                    SizedBox(height: 32.h),
                                itemBuilder: (context, index) {
                                  final plan = state.plans[index];
                                  final isCurrent =
                                      activePlanId != null &&
                                          plan.id == activePlanId;
                                  final appear = _stagger(
                                    (0.28 + index * 0.08).clamp(0.0, 0.85),
                                    (0.55 + index * 0.08).clamp(0.35, 1.0),
                                  );
                                  return FadeTransition(
                                    opacity: appear,
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0, 0.1),
                                        end: Offset.zero,
                                      ).animate(appear),
                                      child: SubscriptionPlanCard(
                                        plan: plan,
                                        isCurrentPlan: isCurrent,
                                        forcePrimaryCta: hasActive && !isCurrent,
                                        currentPlanLabel: l10n
                                            .driverSubscriptionCurrentPlan,
                                        switchPlanLabel: hasActive && !isCurrent
                                            ? l10n.driverSubscriptionSwitchPlan
                                            : null,
                                        choosePlanLabel:
                                            l10n.driverSubscriptionChoosePlan,
                                        subscribeNowLabel:
                                            l10n.driverSubscriptionSubscribeNow,
                                        recommendedLabel:
                                            l10n.driverSubscriptionRecommended,
                                        perMonthLabel:
                                            l10n.driverSubscriptionPerMonth,
                                        onChoose: () {
                                          if (isPaying || isCurrent) return;
                                          _subscribe(plan);
                                        },
                                      ),
                                    ),
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

  CurrentSubscription _enrichActive(
    CurrentSubscription active,
    List<SubscriptionPlan> plans,
  ) {
    if (active.price != null) return active;
    for (final plan in plans) {
      if (plan.id == active.planId) {
        return CurrentSubscription(
          id: active.id,
          planId: active.planId,
          planName: active.planName.isNotEmpty ? active.planName : plan.name,
          status: active.status,
          startDate: active.startDate,
          endDate: active.endDate,
          isExpired: active.isExpired,
          price: plan.price,
          currency: plan.currency,
          tripLimit: active.tripLimit,
          tripsUsed: active.tripsUsed,
          tripsRemaining: active.tripsRemaining,
        );
      }
    }
    return active;
  }
}
