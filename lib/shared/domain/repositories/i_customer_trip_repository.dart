import '../models/customer_trip_request_result.dart';

abstract class ICustomerTripRepository {
  Future<CustomerTripRequestResult> submitTripRequest({
    required String tripId,
  });

  Future<String> reportTrip({
    required String tripId,
    required String reason,
    String? description,
  });
}
