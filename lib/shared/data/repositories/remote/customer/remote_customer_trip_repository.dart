import '../../../../domain/models/customer_trip_request_result.dart';
import '../../../../domain/repositories/i_customer_trip_repository.dart';
import '../../../api/customer/customer_trip_api_client.dart';

class RemoteCustomerTripRepository implements ICustomerTripRepository {
  RemoteCustomerTripRepository({required CustomerTripApiClient apiClient})
      : _api = apiClient;

  final CustomerTripApiClient _api;

  @override
  Future<CustomerTripRequestResult> submitTripRequest({
    required String tripId,
  }) =>
      _api.submitTripRequest(tripId: tripId);

  @override
  Future<String> reportTrip({
    required String tripId,
    required String reason,
    String? description,
  }) =>
      _api.reportTrip(
        tripId: tripId,
        reasonSlug: reason,
        description: description,
      );
}
