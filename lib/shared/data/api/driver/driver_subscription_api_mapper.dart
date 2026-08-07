import '../../../domain/models/confirm_subscription_payment.dart';
import '../../../domain/models/current_subscription.dart';
import '../../../domain/models/initiate_subscription_payment.dart';
import '../../../domain/models/subscription_plan.dart';

abstract final class DriverSubscriptionApiMapper {
  static SubscriptionPlan planFromJson(Map<String, dynamic> json) {
    final featuresRaw = json['features'];
    final features = <String>[];
    if (featuresRaw is List) {
      for (final item in featuresRaw) {
        if (item is String && item.trim().isNotEmpty) {
          features.add(item.trim());
        } else if (item is Map<String, dynamic>) {
          final label = item['label'] ?? item['name'] ?? item['text'];
          if (label != null && label.toString().trim().isNotEmpty) {
            features.add(label.toString().trim());
          }
        }
      }
    }

    return SubscriptionPlan(
      id: _readInt(json['id']) ?? 0,
      name: json['name']?.toString() ?? '',
      tagline: _nullableString(json['tagline'] ?? json['subtitle']),
      description: _nullableString(json['description']),
      price: _readDouble(json['price']) ?? 0,
      currency: json['currency']?.toString() ?? 'INR',
      durationDays: _readInt(json['duration_days']) ?? 30,
      isActive: json['is_active'] as bool? ?? true,
      isRecommended: json['is_recommended'] as bool? ?? false,
      features: features,
    );
  }

  static InitiateSubscriptionPaymentResult initiateFromJson(
    Map<String, dynamic> json,
  ) =>
      InitiateSubscriptionPaymentResult(
        transactionId: json['transaction_id']?.toString() ?? '',
        status: json['status']?.toString() ?? 'pending',
        paymentUrl: _nullableString(json['payment_url']),
        upiIntent: _nullableString(json['upi_intent']),
        razorpayOrderId: _nullableString(
          json['razorpay_order_id'] ?? json['order_id'],
        ),
        razorpayKey: _nullableString(
          json['razorpay_key'] ?? json['key'] ?? json['key_id'],
        ),
        // Paise, never rupees. Razorpay takes the authoritative amount from
        // the order, so a unit mismatch surfaces as a checkout error rather
        // than a silently wrong charge.
        amountPaise: _readInt(json['amount_paise'] ?? json['amount']),
        currency: json['currency']?.toString() ?? 'INR',
        reused: json['reused'] == true,
      );

  static ConfirmSubscriptionPaymentResult confirmFromJson(
    Map<String, dynamic> json,
  ) =>
      ConfirmSubscriptionPaymentResult(
        success: json['success'] as bool? ?? false,
        message: _nullableString(json['message']),
        subscriptionId: json['subscription_id']?.toString(),
      );

  static CurrentSubscription currentFromJson(Map<String, dynamic> json) {
    final plan = json['plan'];
    final planMap = plan is Map<String, dynamic> ? plan : null;
    return CurrentSubscription(
      id: _readInt(json['id']) ?? 0,
      planId: _readInt(json['plan_id'] ?? planMap?['id']) ?? 0,
      planName: json['plan_name']?.toString() ??
          planMap?['name']?.toString() ??
          '',
      status: json['status']?.toString() ?? '',
      startDate: DateTime.tryParse(json['start_date']?.toString() ?? '') ??
          DateTime.now(),
      endDate: DateTime.tryParse(json['end_date']?.toString() ?? '') ??
          DateTime.now(),
      isExpired: json['is_expired'] as bool? ?? false,
      price: _readDouble(json['price'] ?? planMap?['price']),
      currency: (json['currency'] ?? planMap?['currency'])?.toString() ?? 'INR',
      tripLimit: _readInt(json['trip_limit']),
      tripsUsed: _readInt(json['trips_used']),
      tripsRemaining: _readInt(json['trips_remaining']),
    );
  }

  static int? _readInt(dynamic raw) {
    if (raw == null) return null;
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    return int.tryParse(raw.toString());
  }

  static double? _readDouble(dynamic raw) {
    if (raw == null) return null;
    if (raw is num) return raw.toDouble();
    return double.tryParse(raw.toString());
  }

  static String? _nullableString(dynamic raw) {
    if (raw == null) return null;
    final value = raw.toString().trim();
    return value.isEmpty ? null : value;
  }
}
