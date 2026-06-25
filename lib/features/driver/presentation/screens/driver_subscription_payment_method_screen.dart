import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../../core/config/env_config.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/mixins/safe_set_state_mixin.dart';
import '../../../../core/network/api_exception_mapper.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/services/razorpay_payment_service.dart';
import '../../../../res/font_res.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../shared/domain/models/initiate_subscription_payment.dart';
import '../../../../shared/domain/models/subscription_plan.dart';
import '../../../../shared/presentation/widgets/navigation/app_bar_widget.dart';
import '../models/subscription_flow_args.dart';
import '../providers/driver_subscription_provider.dart';
import '../widgets/subscription/subscription_payment_option_tile.dart';
import '../widgets/subscription/subscription_tokens.dart';

/// Payment method picker + Razorpay checkout — Figma `1:5084`.
class DriverSubscriptionPaymentMethodScreen extends ConsumerStatefulWidget {
  const DriverSubscriptionPaymentMethodScreen({
    super.key,
    required this.args,
  });

  final SubscriptionCheckoutArgs args;

  @override
  ConsumerState<DriverSubscriptionPaymentMethodScreen> createState() =>
      _DriverSubscriptionPaymentMethodScreenState();
}

class _DriverSubscriptionPaymentMethodScreenState
    extends ConsumerState<DriverSubscriptionPaymentMethodScreen>
    with SafeSetStateMixin {
  final _razorpay = RazorpayPaymentService();

  SubscriptionPaymentMethod _selected = SubscriptionPaymentMethod.upi;
  InitiateSubscriptionPaymentResult? _pendingInitiate;
  SubscriptionPlan? _activePlan;
  bool _isPaying = false;

  @override
  void initState() {
    super.initState();
    _razorpay.init(
      onSuccess: _onRazorpaySuccess,
      onError: _onRazorpayError,
    );
  }

  @override
  void dispose() {
    _razorpay.dispose();
    super.dispose();
  }

  Future<void> _securePay() async {
    if (_isPaying) return;
    HapticFeedback.lightImpact();
    safeSetState(() => _isPaying = true);

    try {
      final initiate = await ref
          .read(driverSubscriptionProvider.notifier)
          .initiatePayment(
            planId: widget.args.plan.id,
            paymentMethod: _selected.apiValue,
          );

      _pendingInitiate = initiate;
      _activePlan = widget.args.plan;

      final key = initiate.razorpayKey ?? EnvConfig.razorpayKey;
      if (!initiate.canOpenRazorpay && key.isEmpty) {
        if (!mounted) return;
        throw StateError(context.l10n.driverSubscriptionRazorpayConfigError);
      }

      if (initiate.canOpenRazorpay) {
        final user = ref.read(authProvider).user;
        _razorpay.openCheckout(
          key: key,
          orderId: initiate.razorpayOrderId!,
          amountPaise: initiate.amountPaise!,
          currency: initiate.currency,
          name: 'Goods Carrier',
          description: widget.args.plan.name,
          contact: user?.phone,
          email: user?.email,
          transactionId: initiate.transactionId,
          method: _selected.apiValue,
        );
        safeSetState(() => _isPaying = false);
        return;
      }

      final confirm = await ref
          .read(driverSubscriptionProvider.notifier)
          .confirmPayment(
            transactionId: initiate.transactionId,
            gatewayTransactionId: initiate.transactionId,
            success: initiate.status.toLowerCase() == 'success',
          );

      if (!mounted) return;
      _goToResult(
        success: confirm.success,
        initiate: initiate,
        plan: widget.args.plan,
        failureMessage: confirm.message,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ApiExceptionMapper.userMessage(e))),
      );
      safeSetState(() => _isPaying = false);
    }
  }

  Future<void> _onRazorpaySuccess(PaymentSuccessResponse response) async {
    final initiate = _pendingInitiate;
    final plan = _activePlan ?? widget.args.plan;
    if (initiate == null) return;

    safeSetState(() => _isPaying = true);
    try {
      final gatewayId =
          response.paymentId ?? response.orderId ?? initiate.transactionId;
      final confirm = await ref
          .read(driverSubscriptionProvider.notifier)
          .confirmPayment(
            transactionId: initiate.transactionId,
            gatewayTransactionId: gatewayId,
            success: true,
          );

      if (!mounted) return;
      _goToResult(
        success: confirm.success,
        initiate: initiate,
        plan: plan,
        gatewayTransactionId: gatewayId,
        failureMessage: confirm.message,
      );
    } catch (e) {
      if (!mounted) return;
      _goToResult(
        success: false,
        initiate: initiate,
        plan: plan,
        failureMessage: ApiExceptionMapper.userMessage(e),
      );
    } finally {
      safeSetState(() => _isPaying = false);
    }
  }

  void _onRazorpayError(PaymentFailureResponse response) {
    final initiate = _pendingInitiate;
    final plan = _activePlan ?? widget.args.plan;
    if (initiate == null) return;

    _goToResult(
      success: false,
      initiate: initiate,
      plan: plan,
      failureMessage: response.message ?? context.l10n.driverSubscriptionPaymentFailedBody,
    );
    safeSetState(() => _isPaying = false);
  }

  void _goToResult({
    required bool success,
    required InitiateSubscriptionPaymentResult initiate,
    required SubscriptionPlan plan,
    String? gatewayTransactionId,
    String? failureMessage,
  }) {
    final paidAt = DateTime.now();
    final expiresAt = paidAt.add(Duration(days: plan.durationDays));

    context.pushReplacement(
      AppRoutes.driverSubscriptionPaymentResult,
      extra: SubscriptionPaymentResultArgs(
        isSuccess: success,
        planName: plan.name,
        amount: plan.price,
        transactionId: initiate.transactionId,
        gatewayTransactionId: gatewayTransactionId,
        paidAt: paidAt,
        expiresAt: success ? expiresAt : null,
        failureMessage: failureMessage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isPaying =
        _isPaying || ref.watch(driverSubscriptionProvider).isProcessingPayment;

    return Scaffold(
      backgroundColor: SubscriptionTokens.paymentScreenBg,
      appBar: FlowScreenAppBar(
        title: l10n.driverSubscriptionPaymentMethodTitle,
        fallbackRoute: AppRoutes.driverSubscriptionPlans,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: SubscriptionTokens.secureBadgeBg,
                        borderRadius: BorderRadius.circular(9999.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.shield_outlined,
                            size: 12.w,
                            color: SubscriptionTokens.secureBadgeText,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            l10n.driverSubscriptionSecureTransaction,
                            style: TextStyle(
                              fontFamily: FontRes.MANROPE_BOLD,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                              color: SubscriptionTokens.secureBadgeText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      l10n.driverSubscriptionPaymentHeading,
                      style: TextStyle(
                        fontFamily: FontRes.MANROPE_EXTRABOLD,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w800,
                        height: 38 / 24,
                        letterSpacing: -0.75,
                        color: SubscriptionTokens.headingDark,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      l10n.driverSubscriptionPaymentSubtitle,
                      style: TextStyle(
                        fontFamily: FontRes.MANROPE_REGULAR,
                        fontSize: 16.sp,
                        height: 26 / 16,
                        color: SubscriptionTokens.mutedBrown,
                      ),
                    ),
                    SizedBox(height: 32.h),
                    SubscriptionPaymentOptionTile(
                      title: l10n.driverSubscriptionPaymentUpi,
                      subtitle: l10n.driverSubscriptionPaymentUpiSub,
                      icon: Icons.account_balance_wallet_outlined,
                      iconBackground: SubscriptionTokens.upiIconBg,
                      selected: _selected == SubscriptionPaymentMethod.upi,
                      onTap: () => safeSetState(
                        () => _selected = SubscriptionPaymentMethod.upi,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    SubscriptionPaymentOptionTile(
                      title: l10n.driverSubscriptionPaymentCard,
                      subtitle: l10n.driverSubscriptionPaymentCardSub,
                      icon: Icons.credit_card_outlined,
                      iconBackground: SubscriptionTokens.cardIconBg,
                      selected: _selected == SubscriptionPaymentMethod.card,
                      onTap: () => safeSetState(
                        () => _selected = SubscriptionPaymentMethod.card,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    SubscriptionPaymentOptionTile(
                      title: l10n.driverSubscriptionPaymentNetBanking,
                      subtitle: l10n.driverSubscriptionPaymentNetBankingSub,
                      icon: Icons.account_balance_outlined,
                      iconBackground: SubscriptionTokens.bankIconBg,
                      selected:
                          _selected == SubscriptionPaymentMethod.netbanking,
                      onTap: () => safeSetState(
                        () => _selected = SubscriptionPaymentMethod.netbanking,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    SubscriptionPaymentOptionTile(
                      title: l10n.driverSubscriptionPaymentWallet,
                      subtitle: l10n.driverSubscriptionPaymentWalletSub,
                      icon: Icons.wallet_outlined,
                      iconBackground: SubscriptionTokens.walletIconBg,
                      selected: _selected == SubscriptionPaymentMethod.wallet,
                      onTap: () => safeSetState(
                        () => _selected = SubscriptionPaymentMethod.wallet,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Opacity(
                      opacity: 0.7,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            size: 22.w,
                            color: SubscriptionTokens.radioSelected,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            l10n.driverSubscriptionTrustedPayments,
                            style: TextStyle(
                              fontFamily: FontRes.MANROPE_SEMIBOLD,
                              fontSize: 12.sp,
                              letterSpacing: 1.2,
                              color: SubscriptionTokens.brownText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
              child: Row(
                children: [
                  TextButton(
                    onPressed: isPaying ? null : () => context.pop(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.close,
                          size: 14.w,
                          color: SubscriptionTokens.brownText,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          l10n.actionCancel.toUpperCase(),
                          style: TextStyle(
                            fontFamily: FontRes.MANROPE_SEMIBOLD,
                            fontSize: 10.sp,
                            letterSpacing: 1,
                            color: SubscriptionTokens.brownText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Material(
                    color: SubscriptionTokens.primaryOrange,
                    borderRadius: BorderRadius.circular(16.r),
                    elevation: 0,
                    child: InkWell(
                      onTap: isPaying ? null : _securePay,
                      borderRadius: BorderRadius.circular(16.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 32.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromRGBO(255, 109, 0, 0.2),
                              blurRadius: 15,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: isPaying
                            ? SizedBox(
                                width: 120.w,
                                height: 21.h,
                                child: const Center(
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.lock_outline,
                                    size: 16.w,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    l10n.driverSubscriptionSecurePay,
                                    style: TextStyle(
                                      fontFamily: FontRes.MANROPE_BOLD,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.2,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
