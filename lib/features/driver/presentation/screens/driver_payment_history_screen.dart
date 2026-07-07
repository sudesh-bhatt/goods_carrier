import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../core/mixins/safe_set_state_mixin.dart';
import '../../../../core/network/api_exception_mapper.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/presentation/widgets/feedback/empty_state.dart';
import '../../../../shared/presentation/widgets/navigation/app_bar_widget.dart';
import '../providers/driver_payments_provider.dart';
import '../widgets/subscription/payment_history_card.dart';
import '../widgets/subscription/subscription_tokens.dart';

/// Driver subscription payment history — Figma `1:5349`.
class DriverPaymentHistoryScreen extends ConsumerStatefulWidget {
  const DriverPaymentHistoryScreen({super.key});

  @override
  ConsumerState<DriverPaymentHistoryScreen> createState() =>
      _DriverPaymentHistoryScreenState();
}

class _DriverPaymentHistoryScreenState
    extends ConsumerState<DriverPaymentHistoryScreen> with SafeSetStateMixin {
  final _scrollController = ScrollController();
  int? _loadingInvoiceId;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(driverPaymentsProvider.notifier).load(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      ref.read(driverPaymentsProvider.notifier).loadMore();
    }
  }

  Future<void> _openInvoice(int paymentId) async {
    if (_loadingInvoiceId != null) return;
    safeSetState(() => _loadingInvoiceId = paymentId);

    try {
      final payment = ref
          .read(driverPaymentsProvider)
          .payments
          .firstWhere((item) => item.id == paymentId);
      final url = await ref
          .read(driverPaymentsProvider.notifier)
          .resolveInvoiceUrl(payment);
      final uri = Uri.parse(url);
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.driverPaymentHistoryInvoiceError)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ApiExceptionMapper.userMessage(e))),
      );
    } finally {
      safeSetState(() => _loadingInvoiceId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final state = ref.watch(driverPaymentsProvider);
    final showInitialLoading = state.isLoading && state.payments.isEmpty;

    return Scaffold(
      backgroundColor: SubscriptionTokens.paymentScreenBg,
      appBar: FlowScreenAppBar(
        title: l10n.profilePaymentHistory,
        fallbackRoute: AppRoutes.driverProfile,
      ),
      body: SafeArea(
        top: false,
        child: showInitialLoading
            ? const Center(child: CircularProgressIndicator())
            : state.error != null && state.payments.isEmpty
                ? EmptyState(
                    headline: l10n.driverPaymentHistoryLoadErrorTitle,
                    subtitle: state.error!,
                    actionLabel: l10n.actionRetry,
                    onAction: () =>
                        ref.read(driverPaymentsProvider.notifier).load(
                              refresh: true,
                            ),
                  )
                : state.payments.isEmpty
                    ? RefreshIndicator(
                        onRefresh: () => ref
                            .read(driverPaymentsProvider.notifier)
                            .load(refresh: true),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height: MediaQuery.sizeOf(context).height * 0.7,
                            child: EmptyState(
                              headline: l10n.driverPaymentHistoryEmptyTitle,
                              subtitle: l10n.driverPaymentHistoryEmptySubtitle,
                              fallbackIcon: Icons.receipt_long_outlined,
                            ),
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        color: context.colors.primary,
                        onRefresh: () => ref
                            .read(driverPaymentsProvider.notifier)
                            .load(refresh: true),
                        child: ListView.separated(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(16.w, 80.h, 16.w, 128.h),
                          itemCount: state.payments.length +
                              (state.isLoadingMore ? 1 : 0),
                          separatorBuilder: (_, __) => SizedBox(height: 16.h),
                          itemBuilder: (context, index) {
                            if (index >= state.payments.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            final payment = state.payments[index];
                            return PaymentHistoryCard(
                              payment: payment,
                              dateLabel: formatPaymentHistoryDate(
                                payment.paidAt,
                                locale,
                              ),
                              invoiceLabel: l10n.driverPaymentHistoryInvoice,
                              isLoadingInvoice: _loadingInvoiceId == payment.id,
                              onInvoiceTap: () => _openInvoice(payment.id),
                            );
                          },
                        ),
                      ),
      ),
    );
  }
}
