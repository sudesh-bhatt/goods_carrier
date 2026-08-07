class SubscriptionPlan {
  const SubscriptionPlan({
    required this.id,
    required this.name,
    this.tagline,
    this.description,
    required this.price,
    required this.currency,
    required this.durationDays,
    this.isActive = true,
    this.isRecommended = false,
    this.features = const [],
    this.tripLimit,
    this.billingCycle,
    this.canPurchase = true,
  });

  final int id;
  final String name;
  final String? tagline;
  final String? description;
  final double price;
  final String currency;
  final int durationDays;
  final bool isActive;
  final bool isRecommended;
  final List<String> features;

  /// Max trips included in this plan (from API).
  final int? tripLimit;

  /// e.g. `monthly` from API.
  final String? billingCycle;

  /// Server-owned purchase gate: false while this plan still has unused trips
  /// for the driver (FCFO stack). True again after that plan's trips are used.
  final bool canPurchase;

  String get displayTagline => tagline ?? description ?? '';

  String get priceLabel =>
      '₹${price.toStringAsFixed(price.truncateToDouble() == price ? 0 : 2)}';
}
