import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../../../../core/network/api_envelope.dart';
import '../../../domain/entities/customer_saved_address.dart';
import 'customer_address_api_mapper.dart';

class CustomerAddressApiClient {
  CustomerAddressApiClient(this._dio);

  final Dio _dio;

  Future<List<CustomerSavedAddress>> listAddresses() async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.customerAddresses,
    );
    final rows = ApiEnvelope.parseDataListFlexible(response.data);
    return rows.map(CustomerAddressApiMapper.fromJson).toList(growable: false);
  }

  Future<CustomerSavedAddress> getAddressDetail(int id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.customerAddress(id),
    );
    return CustomerAddressApiMapper.fromJson(
      ApiEnvelope.parseData(response.data),
    );
  }

  Future<CustomerSavedAddress> createAddress({
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
      ApiConstants.customerAddresses,
      data: CustomerAddressApiMapper.toRequestBody(
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
    return CustomerAddressApiMapper.fromJson(
      ApiEnvelope.parseData(response.data),
    );
  }

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
  }) async {
    final response = await _dio.put<Map<String, dynamic>>(
      ApiConstants.customerAddress(id),
      data: CustomerAddressApiMapper.toRequestBody(
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
    return CustomerAddressApiMapper.fromJson(
      ApiEnvelope.parseData(response.data),
    );
  }

  Future<void> deleteAddress(int id) async {
    await _dio.delete<void>(ApiConstants.customerAddress(id));
  }

  Future<CustomerSavedAddress> setDefaultAddress(int id) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.setDefaultCustomerAddress(id),
    );
    return CustomerAddressApiMapper.fromJson(
      ApiEnvelope.parseData(response.data),
    );
  }
}
