import '../entities/driver_saved_address.dart';

abstract class IDriverAddressRepository {
  Future<List<DriverSavedAddress>> listAddresses();

  Future<DriverSavedAddress> createAddress({
    required String label,
    required String addressLine,
    required String city,
    required String state,
    required String pincode,
    required double latitude,
    required double longitude,
    bool isDefault,
  });

  Future<DriverSavedAddress> updateAddress({
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

  Future<DriverSavedAddress> setDefaultAddress(int id);
}
