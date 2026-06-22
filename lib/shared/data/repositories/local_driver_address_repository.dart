import '../../domain/entities/driver_saved_address.dart';
import '../../domain/repositories/i_driver_address_repository.dart';

/// In-memory driver addresses for offline / demo mode.
class LocalDriverAddressRepository implements IDriverAddressRepository {
  LocalDriverAddressRepository() : _items = List.of(DriverSavedAddress.seedDefaults());

  final List<DriverSavedAddress> _items;
  int _nextId = 100;

  static Future<void> _delay() =>
      Future.delayed(const Duration(milliseconds: 300));

  @override
  Future<List<DriverSavedAddress>> listAddresses() async {
    await _delay();
    return List.unmodifiable(_items);
  }

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
  }) async {
    await _delay();
    final id = _nextId++;
    final created = DriverSavedAddress(
      id: id,
      label: label,
      addressLine: addressLine,
      city: city,
      state: state,
      pincode: pincode,
      latitude: latitude.toString(),
      longitude: longitude.toString(),
      isDefault: isDefault,
    );
    if (isDefault) {
      for (var i = 0; i < _items.length; i++) {
        _items[i] = _items[i].copyWith(isDefault: false);
      }
    }
    _items.add(created);
    return created;
  }

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
  }) async {
    await _delay();
    final index = _items.indexWhere((item) => item.id == id);
    if (index < 0) throw StateError('Address not found: $id');

    if (isDefault) {
      for (var i = 0; i < _items.length; i++) {
        _items[i] = _items[i].copyWith(isDefault: false);
      }
    }

    final updated = DriverSavedAddress(
      id: id,
      label: label,
      addressLine: addressLine,
      city: city,
      state: state,
      pincode: pincode,
      latitude: latitude.toString(),
      longitude: longitude.toString(),
      isDefault: isDefault,
    );
    _items[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteAddress(int id) async {
    await _delay();
    _items.removeWhere((item) => item.id == id);
  }

  @override
  Future<DriverSavedAddress> setDefaultAddress(int id) async {
    await _delay();
    final index = _items.indexWhere((item) => item.id == id);
    if (index < 0) throw StateError('Address not found: $id');

    for (var i = 0; i < _items.length; i++) {
      _items[i] = _items[i].copyWith(isDefault: i == index);
    }
    return _items[index];
  }
}
