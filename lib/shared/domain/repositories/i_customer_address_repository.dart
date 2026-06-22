import '../entities/customer_saved_address.dart';

abstract class ICustomerAddressRepository {
  Future<List<CustomerSavedAddress>> listAddresses();

  Future<CustomerSavedAddress> getAddressDetail(int id);

  Future<CustomerSavedAddress> createAddress({
    required String label,
    required String addressLine,
    required String city,
    required String state,
    required String pincode,
    required double latitude,
    required double longitude,
    bool isDefault,
  });

  Future<CustomerSavedAddress> updateAddress({
    required int id,
    required String label,
    required String addressLine,
    required String city,
    required String state,
    required String pincode,
    required double latitude,
    required double longitude,
    bool isDefault,
  });

  Future<void> deleteAddress(int id);

  Future<CustomerSavedAddress> setDefaultAddress(int id);
}
