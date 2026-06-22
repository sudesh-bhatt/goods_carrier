import '../../../api/driver/driver_address_api_client.dart';
import '../../../../domain/entities/driver_saved_address.dart';
import '../../../../domain/repositories/i_driver_address_repository.dart';

class RemoteDriverAddressRepository implements IDriverAddressRepository {
  RemoteDriverAddressRepository({required DriverAddressApiClient apiClient})
      : _api = apiClient;

  final DriverAddressApiClient _api;

  @override
  Future<List<DriverSavedAddress>> listAddresses() => _api.listAddresses();

  @override
  Future<DriverSavedAddress> createAddress({
    required String label,
    required String addressLine,
    required String city,
    required String state,
    required String pincode,
    required double latitude,
    required double longitude,
    bool isDefault = false,
  }) =>
      _api.createAddress(
        label: label,
        addressLine: addressLine,
        city: city,
        state: state,
        pincode: pincode,
        latitude: latitude,
        longitude: longitude,
        isDefault: isDefault,
      );

  @override
  Future<DriverSavedAddress> updateAddress({
    required int id,
    required String label,
    required String addressLine,
    required String city,
    required String state,
    required String pincode,
    required double latitude,
    required double longitude,
    bool isDefault = false,
  }) =>
      _api.updateAddress(
        id: id,
        label: label,
        addressLine: addressLine,
        city: city,
        state: state,
        pincode: pincode,
        latitude: latitude,
        longitude: longitude,
        isDefault: isDefault,
      );

  @override
  Future<void> deleteAddress(int id) => _api.deleteAddress(id);

  @override
  Future<DriverSavedAddress> setDefaultAddress(int id) =>
      _api.setDefaultAddress(id);
}
