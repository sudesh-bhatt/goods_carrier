import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_envelope.dart';
import '../../../domain/entities/driver_saved_address.dart';
import 'driver_address_api_mapper.dart';

class DriverAddressApiClient {
  DriverAddressApiClient(this._dio);

  final Dio _dio;

  Future<List<DriverSavedAddress>> listAddresses() async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.driverAddresses,
    );
    final rows = ApiEnvelope.parseDataListFlexible(response.data);
    return rows.map(DriverAddressApiMapper.fromJson).toList(growable: false);
  }

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
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.driverAddresses,
      data: DriverAddressApiMapper.toRequestBody(
        label: label,
        addressLine: addressLine,
        city: city,
        state: state,
        pincode: pincode,
        latitude: latitude,
        longitude: longitude,
        isDefault: isDefault,
      ),
    );
    return DriverAddressApiMapper.fromJson(
      ApiEnvelope.parseData(response.data),
    );
  }

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
    final response = await _dio.put<Map<String, dynamic>>(
      ApiConstants.driverAddress(id),
      data: DriverAddressApiMapper.toRequestBody(
        label: label,
        addressLine: addressLine,
        city: city,
        state: state,
        pincode: pincode,
        latitude: latitude,
        longitude: longitude,
        isDefault: isDefault,
      ),
    );
    return DriverAddressApiMapper.fromJson(
      ApiEnvelope.parseData(response.data),
    );
  }

  Future<void> deleteAddress(int id) async {
    await _dio.delete<void>(ApiConstants.driverAddress(id));
  }

  Future<DriverSavedAddress> setDefaultAddress(int id) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.setDefaultDriverAddress(id),
    );
    return DriverAddressApiMapper.fromJson(
      ApiEnvelope.parseData(response.data),
    );
  }
}
