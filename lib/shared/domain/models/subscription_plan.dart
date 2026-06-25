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

  String get displayTagline => tagline ?? description ?? '';

  String get priceLabel => '₹${price.toStringAsFixed(price.truncateToDouble() == price ? 0 : 2)}';
}
