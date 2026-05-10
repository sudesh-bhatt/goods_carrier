import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/extensions/num_ext.dart';
import '../../../../core/extensions/size_ext.dart';
import '../../../../core/extensions/theme_ext.dart';
import '../../../../shared/presentation/widgets/feedback/empty_state.dart';
import '../../../../shared/presentation/widgets/navigation/app_bar_widget.dart';
import '../providers/driver_trips_provider.dart';

// ─── Dummy invoice model (local — no domain entity needed until Session 7) ─────

class _Invoice {
  const _Invoice({
    required this.id,
    required this.tripId,
    required this.amount,
    required this.date,
    required this.isPaid,
  });

  final String   id;     // INV-XXXX
  final String   tripId; // VB-XXXX
  final double   amount;
  final DateTime date;
  final bool     isPaid;
}

final _dummyInvoices = [
  _Invoice(
    id: 'INV-7721', tripId: 'VB-7701', amount: 5500,
    date: DateTime(2026, 3, 30), isPaid: true,
  ),
  _Invoice(
    id: 'INV-7655', tripId: 'VB-8814', amount: 8500,
    date: DateTime(2026, 4, 22), isPaid: true,
  ),
  _Invoice(
    id: 'INV-7890', tripId: 'VB-9928', amount: 2100,
    date: DateTime(2026, 4, 18), isPaid: false,
  ),
];

/// Driver earnings screen.
///
/// Shows INV-XXXX invoice list with paid/pending status and a totals summary
/// at the top. Data is sourced from [_dummyInvoices] (replaced by API in
/// Session 7).
class DriverEarningsScreen extends ConsumerWidget {
  const DriverEarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors   = context.colors;
    final invoices = _dummyInvoices;

    final totalEarned = invoices
        .where((i) => i.isPaid)
        .fold<double>(0, (sum, i) => sum + i.amount);
    final totalPending = invoices
        .where((i) => !i.isPaid)
        .fold<double>(0, (sum, i) => sum + i.amount);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBarWidget(title: 'Earnings'),
      body: SafeArea(
        child: invoices.isEmpty
            ? EmptyState(
                headline: 'No earnings yet',
                subtitle: 'Complete trips to start earning',
                fallbackIcon: Icons.currency_rupee_rounded,
              )
            : CustomScrollView(
                slivers: [
                  // ── Summary cards ────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppDimensions.screenPadding.w,
                        AppDimensions.xl.h,
                        AppDimensions.screenPadding.w,
                        AppDimensions.base.h,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _SummaryCard(
                              label: 'Total Earned',
                              amount: totalEarned,
                              icon: Icons.account_balance_wallet_outlined,
                              iconColor: colors.success,
                            ),
                          ),
                          SizedBox(width: AppDimensions.sm.w),
                          Expanded(
                            child: _SummaryCard(
                              label: 'Pending',
                              amount: totalPending,
                              icon: Icons.hourglass_top_rounded,
                              iconColor: colors.orangeText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Section label ─────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppDimensions.screenPadding.w,
                        AppDimensions.base.h,
                        AppDimensions.screenPadding.w,
                        AppDimensions.sm.h,
                      ),
                      child: Text(
                        'Invoice History',
                        style: context.textTheme.titleSmall?.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  // ── Invoice list ──────────────────────────────────────
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      AppDimensions.screenPadding.w,
                      0,
                      AppDimensions.screenPadding.w,
                      AppDimensions.xxxl.h,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) {
                          return Padding(
                            padding: EdgeInsets.only(
                                bottom: AppDimensions.base.h),
                            child: _InvoiceCard(invoice: invoices[i]),
                          );
                        },
                        childCount: invoices.length,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ─── Summary card ─────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.icon,
    required this.iconColor,
  });

  final String   label;
  final double   amount;
  final IconData icon;
  final Color    iconColor;

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
          Icon(icon, color: iconColor, size: AppDimensions.iconBase.w),
          SizedBox(height: AppDimensions.sm.h),
          Text(
            amount.inr,
            style: context.textTheme.titleLarge?.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: context.textTheme.bodySmall
                ?.copyWith(color: colors.textHint),
          ),
        ],
      ),
    );
  }
}

// ─── Invoice card ─────────────────────────────────────────────────────────────

class _InvoiceCard extends StatelessWidget {
  const _InvoiceCard({required this.invoice});
  final _Invoice invoice;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isPaid = invoice.isPaid;

    return Container(
      padding: EdgeInsets.all(AppDimensions.base.w),
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd.r),
        boxShadow: context.cardShadow,
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: (isPaid ? colors.success : colors.orangeText)
                  .withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPaid
                  ? Icons.check_circle_outline_rounded
                  : Icons.schedule_rounded,
              size: AppDimensions.iconBase.w,
              color: isPaid ? colors.success : colors.orangeText,
            ),
          ),
          SizedBox(width: AppDimensions.sm.w),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invoice.id,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Trip ${invoice.tripId}  ·  ${invoice.date.day}/${invoice.date.month}/${invoice.date.year}',
                  style: context.textTheme.bodySmall
                      ?.copyWith(color: colors.textHint),
                ),
              ],
            ),
          ),

          // Amount + status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                invoice.amount.inr,
                style: context.textTheme.titleSmall?.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.xs.w,
                  vertical: 2.h,
                ),
                decoration: BoxDecoration(
                  color: (isPaid ? colors.success : colors.orangeText)
                      .withOpacity(0.10),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusFull.r),
                ),
                child: Text(
                  isPaid ? 'Paid' : 'Pending',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: isPaid ? colors.success : colors.orangeText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
