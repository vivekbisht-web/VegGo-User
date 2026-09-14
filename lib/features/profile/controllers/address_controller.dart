//
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/api_endpoints.dart';
import 'package:geolocator/geolocator.dart';
import '../models/address_models.dart';
import '../services/address_service.dart';
import 'package:vegon_user/core/utils/permission_handler_service.dart';

class AddressController extends GetxController {
  var addresses = <AddressModel>[].obs;
  var defaultAddressDisplay = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isFetching = false.obs;
  final AddressService _addressService = AddressService();

  @override
  void onInit() {
    super.onInit();
    fetchAddresses();
  }

  Future<void> fetchAddresses() async {
    isFetching.value = true;
    final response = await _addressService.fetchAddresses();
    if (response.success) {
      addresses.clear();
      AddressDataModel? foundDefault;
      for (var addressData in response.addresses) {
        if (addressData.isDefault || foundDefault == null) {
          foundDefault = addressData;
        }
        addresses.add(
          AddressModel(
            id: addressData.id,
            title: addressData.label.isNotEmpty
                ? addressData.label
                : AppStrings.home,
            address: _buildFullAddress(
              addressData.addressLine1,
              addressData.addressLine2,
              addressData.city,
              addressData.state,
              addressData.postalCode,
            ),
            icon: addressData.label.toLowerCase() == 'office'
                ? Icons.business
                : Icons.home_outlined,
            isDefault: addressData.isDefault,
            rawAddressData: addressData,
          ),
        );
      }
      if (foundDefault != null) {
        defaultAddressDisplay.value =
            '${foundDefault.label}: ${foundDefault.addressLine1}, ${foundDefault.city}';
      }
    }
    isFetching.value = false;
  }

  String _buildFullAddress(
    String line1,
    String line2,
    String city,
    String state,
    String zip,
  ) {
    return [
      if (line1.isNotEmpty) line1,
      if (line2.isNotEmpty) line2,
      if (city.isNotEmpty) city,
      if (state.isNotEmpty) state,
      if (zip.isNotEmpty) zip,
    ].join(', ');
  }

  void _showSnackbar(String message, {bool isError = true}) {
    Get.snackbar(
      AppStrings.appName,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError ? AppColors.error : AppColors.success,
      colorText: AppColors.surface,
    );
  }

  Future<void> addAddress({
    required String title,
    required String addressLine1,
    required String addressLine2,
    required String city,
    required String state,
    required String postalCode,
    required double latitude,
    required double longitude,
    required bool isDefault,
    String label = 'Home',
  }) async {
    if (isLoading.value) return;
    isLoading.value = true;

    try {
      final request = AddAddressRequestModel(
        addressLine1: addressLine1,
        addressLine2: addressLine2,
        city: city,
        state: state,
        postalCode: postalCode,
        latitude: latitude,
        longitude: longitude,
        isDefault: isDefault,
        label: label.isNotEmpty ? label : title,
      );

      final response = await _addressService.addAddress(request);
      if (isClosed) return;

      if (response.success) {
        await fetchAddresses();
        Get.back();
        _showSnackbar(AppStrings.addressAddedSuccess, isError: false);
      } else {
        _showSnackbar(
          response.message.isNotEmpty
              ? response.message
              : AppStrings.addressAddFailed,
        );
      }
    } catch (e) {
      _showSnackbar(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateAddress({
    required String id,
    required String title,
    required String addressLine1,
    required String addressLine2,
    required String city,
    required String state,
    required String postalCode,
    required double latitude,
    required double longitude,
    required bool isDefault,
    String label = 'Home',
  }) async {
    if (isLoading.value) return;
    isLoading.value = true;

    try {
      final request = AddAddressRequestModel(
        addressLine1: addressLine1,
        addressLine2: addressLine2,
        city: city,
        state: state,
        postalCode: postalCode,
        latitude: latitude,
        longitude: longitude,
        isDefault: isDefault,
        label: label.isNotEmpty ? label : title,
      );

      final response = await _addressService.updateAddress(id, request);
      if (isClosed) return;

      if (response.success) {
        await fetchAddresses();
        Get.back();
        _showSnackbar(AppStrings.updateAddressSuccess, isError: false);
      } else {
        _showSnackbar(
          response.message.isNotEmpty
              ? response.message
              : AppStrings.updateAddressFailed,
        );
      }
    } catch (e) {
      _showSnackbar(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteAddress(int index) async {
    if (index < 0 || index >= addresses.length) return;
    final addressItem = addresses[index];
    final String addressId = addressItem.id;

    if (addressId.isNotEmpty) {
      isLoading.value = true;
      final response = await _addressService.deleteAddress(addressId);
      if (isClosed) return;
      isLoading.value = false;

      if (response.success) {
        addresses.removeAt(index);
        if (addressItem.isDefault) {
          fetchAddresses();
        } else {
          addresses.refresh();
        }
        _showSnackbar(AppStrings.deleteAddressSuccess, isError: false);
      } else {
        _showSnackbar(
          response.message.isNotEmpty
              ? response.message
              : AppStrings.deleteAddressFailed,
        );
      }
    } else {
      addresses.removeAt(index);
      addresses.refresh();
    }
  }

  void setDefault(int index) {
    for (int i = 0; i < addresses.length; i++) {
      addresses[i].isDefault = (i == index);
    }
    addresses.refresh();
  }

  Future<void> fetchLiveLocationAndAddress(
    Function(Map<String, dynamic>) onSuccess,
  ) async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar(
          AppStrings.appName,
          AppStrings.locationServiceDisabled,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: AppColors.surface,
          mainButton: TextButton(
            onPressed: () => Geolocator.openLocationSettings(),
            child: Text(
              AppStrings.settings,
              style: Theme.of(Get.context!).textTheme.labelLarge?.copyWith(
                color: AppColors.surface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
        return;
      }

      final hasPermission =
          await PermissionHandlerService.handleLocationPermission();
      if (!hasPermission) return;

      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 8),
          ),
        );
      } catch (_) {
        position = await Geolocator.getLastKnownPosition();
      }

      if (position != null) {
        await reverseGeocodeCoordinates(
          position.latitude,
          position.longitude,
          onSuccess,
        );
      } else {
        _showSnackbar(AppStrings.liveLocationFetchFailed);
      }
    } catch (e) {
      _showSnackbar(AppStrings.liveLocationFetchFailed);
    }
  }

  Future<void> reverseGeocodeCoordinates(
    double lat,
    double lng,
    Function(Map<String, dynamic>) onSuccess,
  ) async {
    try {
      final addressData = await _addressService.fetchAddressFromCoordinates(
        lat,
        lng,
        ApiEndpoints.googleMapsApiKey,
      );

      if (addressData != null) {
        onSuccess({
          'latitude': lat,
          'longitude': lng,
          'addressLine1': addressData['addressLine1'] ?? '',
          'city': addressData['city'] ?? '',
          'state': addressData['state'] ?? '',
          'postalCode': addressData['postalCode'] ?? '',
        });
      } else {
        onSuccess({
          'latitude': lat,
          'longitude': lng,
          'addressLine1':
              '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}',
          'city': '',
          'state': '',
          'postalCode': '',
        });
      }
    } catch (e) {
      debugPrint('Error reverse geocoding: $e');
    }
  }
}
