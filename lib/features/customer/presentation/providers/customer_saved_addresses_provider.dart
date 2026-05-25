import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/shared_preferences_provider.dart';
import '../../../../shared/data/local/saved_address_preferences_store.dart';
import '../../../../shared/domain/entities/saved_address.dart';
import '../../../../shared/domain/enums/saved_address_label.dart';

class CustomerSavedAddressesState {
  const CustomerSavedAddressesState({
    this.addresses = const [],
    this.isLoading = false,
  });

  final List<SavedAddress> addresses;
  final bool isLoading;

  CustomerSavedAddressesState copyWith({
    List<SavedAddress>? addresses,
    bool? isLoading,
  }) =>
      CustomerSavedAddressesState(
        addresses: addresses ?? this.addresses,
        isLoading: isLoading ?? this.isLoading,
      );
}

class CustomerSavedAddressesNotifier
    extends StateNotifier<CustomerSavedAddressesState> {
  CustomerSavedAddressesNotifier(this._store)
      : super(const CustomerSavedAddressesState()) {
    _load();
  }

  final SavedAddressPreferencesStore _store;
  Future<void> _load() async {
    state = state.copyWith(isLoading: true);
    final list = await _store.load();
    state = CustomerSavedAddressesState(addresses: list);
  }

  SavedAddress? byId(String id) {
    for (final a in state.addresses) {
      if (a.id == id) return a;
    }
    return null;
  }

  Future<void> upsert({
    String? id,
    required SavedAddressLabel label,
    required String title,
    required String fullAddressLine,
    required String city,
    required String pincode,
    required double latitude,
    required double longitude,
    String? landmark,
  }) async {
    final resolvedId =
        id ?? 'addr_${DateTime.now().millisecondsSinceEpoch}';
    final next = SavedAddress(
      id: resolvedId,
      label: label,
      title: title,
      fullAddressLine: fullAddressLine,
      city: city,
      pincode: pincode,
      latitude: latitude,
      longitude: longitude,
      landmark: landmark?.trim().isEmpty == true ? null : landmark?.trim(),
    );

    final list = List<SavedAddress>.from(state.addresses);
    final index = list.indexWhere((a) => a.id == resolvedId);
    if (index >= 0) {
      list[index] = next;
    } else {
      list.add(next);
    }

    await _store.save(list);
    state = state.copyWith(addresses: list);
  }

  Future<void> remove(String id) async {
    final list =
        state.addresses.where((a) => a.id != id).toList(growable: false);
    await _store.save(list);
    state = state.copyWith(addresses: list);
  }
}

final customerSavedAddressesProvider = StateNotifierProvider<
    CustomerSavedAddressesNotifier, CustomerSavedAddressesState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return CustomerSavedAddressesNotifier(SavedAddressPreferencesStore(prefs));
});
