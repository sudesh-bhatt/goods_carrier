import '../../domain/models/customer_trip_request_result.dart';
import '../../domain/repositories/i_customer_trip_repository.dart';

class LocalCustomerTripRepository implements ICustomerTripRepository {
  int _requestCounter = 87;
  int _reportCounter = 9000;

  @override
  Future<CustomerTripRequestResult> submitTripRequest({
    required String tripId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _requestCounter += 1;
    final tripNumeric = int.tryParse(tripId) ?? 55;
    return CustomerTripRequestResult(
      id: _requestCounter,
      driverTripId: tripNumeric,
      status: 'pending',
    );
  }

  @override
  Future<String> reportTrip({
    required String tripId,
    required String reason,
    String? description,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _reportCounter += 1;
    return 'REP-$_reportCounter';
  }
}
