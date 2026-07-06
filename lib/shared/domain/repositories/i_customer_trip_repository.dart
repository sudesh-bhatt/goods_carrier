import '../models/customer_trip_request_result.dart';

abstract class ICustomerTripRepository {
  Future<CustomerTripRequestResult> submitTripRequest({
    required String tripId,
    required int shipmentId,
    required String note,
  });

  Future<String> reportTrip({
    required String tripId,
    required String reason,
    String? description,
  });
}
