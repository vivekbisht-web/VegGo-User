//
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/api_endpoints.dart';
import 'package:vegon_user/core/utils/permission_handler_service.dart';
import 'package:vegon_user/core/local_storage/shared_prefs_helper.dart';
import 'package:vegon_user/features/home/controllers/home_controller.dart';
import 'package:vegon_user/features/profile/services/address_service.dart';

class LocationController extends GetxController {
  final RxnDouble currentLatitude = RxnDouble();
  final RxnDouble currentLongitude = RxnDouble();
  final RxString currentLocationName = ''.obs;
  final RxBool isFetchingLocation = false.obs;

  double? get latitude {
    final val = currentLatitude.value ?? SharedPrefsHelper.getLatitude();
    return (val != null && val != 0.0) ? val : null;
  }

  double? get longitude {
    final val = currentLongitude.value ?? SharedPrefsHelper.getLongitude();
    return (val != null && val != 0.0) ? val : null;
  }

  bool get hasValidLocation => latitude != null && longitude != null;

  @override
  void onInit() {
    super.onInit();
    _loadLocationFromLocal();
  }

  void _loadLocationFromLocal() {
    final lat = SharedPrefsHelper.getLatitude();
    final lng = SharedPrefsHelper.getLongitude();
    final name = SharedPrefsHelper.getLocationName();

    if (lat != null && lng != null && lat != 0.0 && lng != 0.0) {
      currentLatitude.value = lat;
      currentLongitude.value = lng;
      currentLocationName.value = name ?? '';
      _notifyControllers(lat, lng);
    } else {
      fetchAndSaveUserLocation();
    }
  }

  Future<void> fetchAndSaveUserLocation() async {
    isFetchingLocation.value = true;
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        isFetchingLocation.value = false;
        return;
      }

      final hasPermission =
          await PermissionHandlerService.handleLocationPermission();
      if (!hasPermission) {
        isFetchingLocation.value = false;
        return;
      }

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
        currentLatitude.value = position.latitude;
        currentLongitude.value = position.longitude;

        final addressService = AddressService();
        final addressData = await addressService.fetchAddressFromCoordinates(
          position.latitude,
          position.longitude,
          ApiEndpoints.googleMapsApiKey,
        );

        if (addressData != null) {
          final line1 = addressData['addressLine1']?.toString() ?? '';
          final city = addressData['city']?.toString() ?? '';
          if (line1.isNotEmpty && city.isNotEmpty) {
            currentLocationName.value = '$line1, $city';
          } else if (line1.isNotEmpty) {
            currentLocationName.value = line1;
          } else if (city.isNotEmpty) {
            currentLocationName.value = city;
          }
        }
        
        // Save live location as the new current location in local DB
        await SharedPrefsHelper.saveLocation(
          position.latitude,
          position.longitude,
          currentLocationName.value,
        );

        _notifyControllers(position.latitude, position.longitude);
      }
    } catch (e) {
      debugPrint('Error fetching user location: $e');
    } finally {
      isFetchingLocation.value = false;
    }
  }

  void setCustomLocation({
    required double latitude,
    required double longitude,
    required String locationName,
    bool saveToLocal = true,
  }) {
    currentLatitude.value = latitude;
    currentLongitude.value = longitude;
    currentLocationName.value = locationName;

    if (saveToLocal) {
      SharedPrefsHelper.saveLocation(latitude, longitude, locationName);
    }

    _notifyControllers(latitude, longitude);
  }

  void _notifyControllers(double lat, double lng) {
    if (Get.isRegistered<HomeController>()) {
      final homeCtrl = Get.find<HomeController>();
      homeCtrl.fetchNearbyShops(latitude: lat, longitude: lng);
      homeCtrl.fetchDailyDeals(latitude: lat, longitude: lng);
      homeCtrl.fetchAllProducts(latitude: lat, longitude: lng);
    }
  }
}
