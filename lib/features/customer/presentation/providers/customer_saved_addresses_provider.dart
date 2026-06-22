import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception_mapper.dart';
import '../../../../core/providers/repository_providers.dart';
import '../../../../shared/domain/entities/customer_saved_address.dart';
import '../../../../shared/domain/enums/saved_address_label.dart';
import '../../../../shared/domain/repositories/i_customer_address_repository.dart';

class CustomerSavedAddressesState {
  const CustomerSavedAddressesState({
    this.addresses = const [],
    this.isLoading = false,
    this.error,
  });

  final List<CustomerSavedAddress> addresses;
  final bool isLoading;
  final String? error;

  CustomerSavedAddressesState copyWith({
    List<CustomerSavedAddress>? addresses,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) =>
      CustomerSavedAddressesState(
        addresses: addresses ?? this.addresses,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
      );
}

class CustomerSavedAddressesNotifier
    extends StateNotifier<CustomerSavedAddressesState> {
  CustomerSavedAddressesNotifier(this._repo)
      : super(const CustomerSavedAddressesState()) {
    load();
  }

  final ICustomerAddressRepository _repo;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final addresses = await _repo.listAddresses();
      state = CustomerSavedAddressesState(addresses: addresses);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ApiExceptionMapper.userMessage(e),
      );
    }
  }

  CustomerSavedAddress? byId(String id) {
    final parsed = int.tryParse(id);
    if (parsed == null) return null;
    return state.addresses.where((a) => a.id == parsed).firstOrNull;
  }

  static String labelForChip(SavedAddressLabel label) => switch (label) {
        SavedAddressLabel.home => 'Home',
        SavedAddressLabel.office => 'Office',
        SavedAddressLabel.other => 'Other',
      };

  Future<bool> saveAddress({
    int? id,
    required SavedAddressLabel label,
    required String addressLine,
    required String city,
    required String stateName,
    required String pincode,
    required double latitude,
    required double longitude,
    bool isDefault = false,
  }) async {
    state = state.copyWith(clearError: true);
    final apiLabel = labelForChip(label);
    try {
      if (id != null) {
        await _repo.updateAddress(
          id: id,
          label: apiLabel,
          addressLine: addressLine,
          city: city,
          state: stateName,
          pincode: pincode,
          latitude: latitude,
          longitude: longitude,
          isDefault: isDefault,
        );
      } else {
        await _repo.createAddress(
          label: apiLabel,
          addressLine: addressLine,
          city: city,
          state: stateName,
          pincode: pincode,
          latitude: latitude,
          longitude: longitude,
          isDefault: isDefault,
        );
      }
      await load();
      return true;
    } catch (e) {
      state = state.copyWith(error: ApiExceptionMapper.userMessage(e));
      return false;
    }
  }

  Future<bool> deleteAddress(int id) async {
    state = state.copyWith(clearError: true);
    try {
      await _repo.deleteAddress(id);
      await load();
      return true;
    } catch (e) {
      state = state.copyWith(error: ApiExceptionMapper.userMessage(e));
      return false;
    }
  }

  Future<bool> setDefaultAddress(int id) async {
    state = state.copyWith(clearError: true);
    try {
      await _repo.setDefaultAddress(id);
      await load();
      return true;
    } catch (e) {
      state = state.copyWith(error: ApiExceptionMapper.userMessage(e));
      return false;
    }
  }
}

final customerSavedAddressesProvider = StateNotifierProvider<
    CustomerSavedAddressesNotifier, CustomerSavedAddressesState>(
  (ref) => CustomerSavedAddressesNotifier(
    ref.read(customerAddressRepositoryProvider),
  ),
);
