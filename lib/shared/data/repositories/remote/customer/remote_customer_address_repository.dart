import '../../../api/customer/customer_address_api_client.dart';
import '../../../../domain/entities/customer_saved_address.dart';
import '../../../../domain/repositories/i_customer_address_repository.dart';

class RemoteCustomerAddressRepository implements ICustomerAddressRepository {
  RemoteCustomerAddressRepository({required CustomerAddressApiClient apiClient})
      : _api = apiClient;

  final CustomerAddressApiClient _api;

  @override
  Future<List<CustomerSavedAddress>> listAddresses() => _api.listAddresses();

  @override
  Future<CustomerSavedAddress> getAddressDetail(int id) =>
      _api.getAddressDetail(id);

  @override
  Future<CustomerSavedAddress> createAddress({
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
  Future<CustomerSavedAddress> updateAddress({
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
  Future<CustomerSavedAddress> setDefaultAddress(int id) =>
      _api.setDefaultAddress(id);
}
