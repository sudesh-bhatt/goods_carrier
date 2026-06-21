/// Query params for `GET /api/driver/trips` (Postman / API_IMPLEMENTATION.md).
class DriverTripListQuery {
  const DriverTripListQuery({
    this.status,
    this.search,
    this.page = 1,
    this.perPage = 20,
  });

  final String? status;
  final String? search;
  final int page;
  final int perPage;

  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };
    if (status != null && status!.isNotEmpty) params['status'] = status;
    if (search != null && search!.isNotEmpty) params['search'] = search;
    return params;
  }

  DriverTripListQuery copyWith({int? page}) => DriverTripListQuery(
        status: status,
        search: search,
        page: page ?? this.page,
        perPage: perPage,
      );
}
