import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../models/address_models.dart';

class AddressService {
  final ApiClient _apiClient;

  AddressService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient(baseUrl: ApiEndpoints.baseUrl);

  /// Calls POST /customer/addresses
  Future<AddAddressResponseModel> addAddress(
    AddAddressRequestModel request,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.addresses,
        data: request.toJson(),
      );
      var data = response.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }
      if (data is Map<String, dynamic>) {
        return AddAddressResponseModel.fromJson(data);
      }
      if (response.statusCode == 200 || response.statusCode == 201) {
        return AddAddressResponseModel(success: true, message: '');
      }
      return AddAddressResponseModel(success: false, message: '');
    } on DioException catch (e) {
      final responseData = e.response?.data;
      String errorMsg = e.message ?? '';
      if (responseData is Map<String, dynamic>) {
        errorMsg = responseData['message']?.toString() ??
            responseData['error']?.toString() ??
            errorMsg;
      } else if (responseData is String && responseData.isNotEmpty) {
        errorMsg = responseData;
      }
      return AddAddressResponseModel(success: false, message: errorMsg);
    } catch (e) {
      debugPrint('Error adding address: $e');
      return AddAddressResponseModel(success: false, message: e.toString());
    }
  }

  /// Calls PUT /customer/addresses/{id}
  Future<AddAddressResponseModel> updateAddress(
    String addressId,
    AddAddressRequestModel request,
  ) async {
    try {
      final response = await _apiClient.put(
        '${ApiEndpoints.addresses}/$addressId',
        data: request.toJson(),
      );
      var data = response.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }
      if (data is Map<String, dynamic>) {
        return AddAddressResponseModel.fromJson(data);
      }
      if (response.statusCode == 200 || response.statusCode == 201) {
        return AddAddressResponseModel(success: true, message: '');
      }
      return AddAddressResponseModel(success: false, message: '');
    } on DioException catch (e) {
      final responseData = e.response?.data;
      String errorMsg = e.message ?? '';
      if (responseData is Map<String, dynamic>) {
        errorMsg = responseData['message']?.toString() ??
            responseData['error']?.toString() ??
            errorMsg;
      } else if (responseData is String && responseData.isNotEmpty) {
        errorMsg = responseData;
      }
      return AddAddressResponseModel(success: false, message: errorMsg);
    } catch (e) {
      debugPrint('Error updating address: $e');
      return AddAddressResponseModel(success: false, message: e.toString());
    }
  }

  Future<AddAddressResponseModel> deleteAddress(String addressId) async {
    try {
      final response = await _apiClient.delete(
        '${ApiEndpoints.addresses}/$addressId',
      );
      var data = response.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }
      if (data is Map<String, dynamic>) {
        return AddAddressResponseModel.fromJson(data);
      }
      if (response.statusCode == 200 || response.statusCode == 204) {
        return AddAddressResponseModel(success: true, message: '');
      }
      return AddAddressResponseModel(success: false, message: '');
    } on DioException catch (e) {
      final responseData = e.response?.data;
      String errorMsg = e.message ?? '';
      if (responseData is Map<String, dynamic>) {
        errorMsg = responseData['message']?.toString() ??
            responseData['error']?.toString() ??
            errorMsg;
      } else if (responseData is String && responseData.isNotEmpty) {
        errorMsg = responseData;
      }
      return AddAddressResponseModel(success: false, message: errorMsg);
    } catch (e) {
      debugPrint('Error deleting address: $e');
      return AddAddressResponseModel(success: false, message: e.toString());
    }
  }

  Future<GetAddressesResponseModel> fetchAddresses() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.addresses);
      var data = response.data;

      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }

      if (data is List || data is Map<String, dynamic>) {
        return GetAddressesResponseModel.fromJson(data);
      }
      return GetAddressesResponseModel(success: false, addresses: []);
    } catch (e) {
      debugPrint('Error fetching addresses: $e');
      return GetAddressesResponseModel(success: false, addresses: []);
    }
  }

  Future<Map<String, String>?> fetchAddressFromCoordinates(
    double latitude,
    double longitude,
    String apiKey,
  ) async {
    try {
      final dio = Dio();

      if (apiKey.isNotEmpty && apiKey != 'YOUR_GOOGLE_MAPS_API_KEY') {
        final url =
            '${ApiEndpoints.googleMapsGeocodeApi}?latlng=$latitude,$longitude&key=$apiKey';
        final response = await dio.get(url);
        if (response.statusCode == 200) {
          final data = response.data;
          if (data['status'] == 'OK' && data['results'] is List) {
            final results = data['results'] as List;
            if (results.isNotEmpty && results[0] is Map && results[0]['address_components'] is List) {
              final addressComponents =
                  results[0]['address_components'] as List;
              String addressLine1 = results[0]['formatted_address'] ?? '';
              String city = '';
              String state = '';
              String postalCode = '';
              for (var component in addressComponents) {
                if (component is Map && component['types'] is List) {
                  final types = component['types'] as List;
                  if (types.contains('locality')) {
                    city = component['long_name'];
                  }
                  if (types.contains('administrative_area_level_1')) {
                    state = component['long_name'];
                  }
                  if (types.contains('postal_code')) {
                    postalCode = component['long_name'];
                  }
                }
              }

              return {
                'addressLine1': addressLine1,
                'city': city,
                'state': state,
                'postalCode': postalCode,
              };
            }
          }
        }
      }

      final osmUrl =
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude';
      final osmResponse = await dio.get(
        osmUrl,
        options: Options(headers: {'User-Agent': 'veggofresh_user_app/1.0'}),
      );

      if (osmResponse.statusCode == 200) {
        final data = osmResponse.data;
        final address = data['address'] ?? {};

        String city =
            address['city'] ??
            address['town'] ??
            address['village'] ??
            address['county'] ??
            '';
        String state = address['state'] ?? '';
        String postalCode = address['postcode'] ?? '';
        String road =
            address['road'] ??
            address['suburb'] ??
            address['neighbourhood'] ??
            '';
        String name = data['name'] ?? '';

        String addressLine1 = road;
        if (name.isNotEmpty && name != road) {
          addressLine1 = '$name, $road'.trim();
          if (addressLine1.endsWith(',')) {
            addressLine1 = addressLine1.substring(0, addressLine1.length - 1);
          }
        }
        if (addressLine1.isEmpty) {
          addressLine1 = data['display_name'] ?? 'Current Location';
        }

        return {
          'addressLine1': addressLine1,
          'city': city,
          'state': state,
          'postalCode': postalCode,
        };
      }
    } catch (e) {
      debugPrint('Error fetching address from coordinates: $e');
    }
    return null;
  }
}
