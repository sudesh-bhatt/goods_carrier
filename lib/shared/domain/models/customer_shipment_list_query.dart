/// Query params for `GET /api/customer/shipments` (Postman / API_IMPLEMENTATION.md).
class CustomerShipmentListQuery {
  const CustomerShipmentListQuery({
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
}
