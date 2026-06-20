/// Query params for `GET /api/customer/dashboard` (Postman / API_IMPLEMENTATION.md).
class CustomerDashboardQuery {
  const CustomerDashboardQuery({
    this.search,
    this.vehicleTypeId,
    this.fromCity,
    this.toCity,
    this.pickupDate,
    this.capacityMin,
    this.capacityMax,
    this.page = 1,
    this.perPage = 10,
  });

  final String? search;
  final int? vehicleTypeId;
  final String? fromCity;
  final String? toCity;
  final DateTime? pickupDate;
  final num? capacityMin;
  final num? capacityMax;
  final int page;
  final int perPage;

  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };
    if (search != null && search!.trim().isNotEmpty) {
      params['search'] = search!.trim();
    }
    if (vehicleTypeId != null) params['vehicle_type_id'] = vehicleTypeId;
    if (fromCity != null && fromCity!.trim().isNotEmpty) {
      params['from_city'] = fromCity!.trim();
    }
    if (toCity != null && toCity!.trim().isNotEmpty) {
      params['to_city'] = toCity!.trim();
    }
    if (pickupDate != null) {
      final d = pickupDate!;
      params['pickup_date'] =
          '${d.year.toString().padLeft(4, '0')}-'
          '${d.month.toString().padLeft(2, '0')}-'
          '${d.day.toString().padLeft(2, '0')}';
    }
    if (capacityMin != null) params['capacity_min'] = capacityMin;
    if (capacityMax != null) params['capacity_max'] = capacityMax;
    return params;
  }

  CustomerDashboardQuery copyWith({
    String? search,
    int? vehicleTypeId,
    String? fromCity,
    String? toCity,
    DateTime? pickupDate,
    num? capacityMin,
    num? capacityMax,
    int? page,
    int? perPage,
    bool clearSearch = false,
    bool clearVehicleTypeId = false,
    bool clearFromCity = false,
    bool clearToCity = false,
    bool clearPickupDate = false,
    bool clearCapacityMin = false,
    bool clearCapacityMax = false,
  }) =>
      CustomerDashboardQuery(
        search: clearSearch ? null : (search ?? this.search),
        vehicleTypeId: clearVehicleTypeId
            ? null
            : (vehicleTypeId ?? this.vehicleTypeId),
        fromCity: clearFromCity ? null : (fromCity ?? this.fromCity),
        toCity: clearToCity ? null : (toCity ?? this.toCity),
        pickupDate:
            clearPickupDate ? null : (pickupDate ?? this.pickupDate),
        capacityMin:
            clearCapacityMin ? null : (capacityMin ?? this.capacityMin),
        capacityMax:
            clearCapacityMax ? null : (capacityMax ?? this.capacityMax),
        page: page ?? this.page,
        perPage: perPage ?? this.perPage,
      );
}
