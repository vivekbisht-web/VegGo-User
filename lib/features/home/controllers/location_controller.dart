import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:vegon_user/core/constants/api_endpoints.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/utils/permission_handler_service.dart';
import 'package:vegon_user/core/local_storage/shared_prefs_helper.dart';
import 'package:vegon_user/features/home/controllers/home_controller.dart';
import 'package:vegon_user/features/profile/services/address_service.dart';

import 'package:vegon_user/features/profile/models/address_models.dart';
import 'package:vegon_user/features/profile/controllers/address_controller.dart';
import 'package:vegon_user/features/cart/controllers/checkout_controller.dart';

import 'package:vegon_user/core/widgets/location_permission_bottom_sheet.dart';

class LocationController extends GetxController with WidgetsBindingObserver {
  final RxnDouble currentLatitude = RxnDouble();
  final RxnDouble currentLongitude = RxnDouble();
  final RxString currentLocationName = ''.obs;
  final RxBool isFetchingLocation = false.obs;
  final RxBool isLocationPromptVisible = false.obs;

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
    WidgetsBinding.instance.addObserver(this);
    _initLocation();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkLocationOnResume();
    }
  }

  Future<void> _checkLocationOnResume() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      final permission = await Geolocator.checkPermission();
      final bool hasPermission = permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;

      if (serviceEnabled && hasPermission) {
        if (isLocationPromptVisible.value) {
          if (Get.isBottomSheetOpen == true) {
            Get.back();
          }
          isLocationPromptVisible.value = false;
        }
        await fetchAndSaveUserLocation();
      }
    } catch (_) {}
  }

  Future<void> _initLocation() async {
    final lat = SharedPrefsHelper.getLatitude();
    final lng = SharedPrefsHelper.getLongitude();
    final name = SharedPrefsHelper.getLocationName();

    if (lat != null && lng != null && lat != 0.0 && lng != 0.0) {
      currentLatitude.value = lat;
      currentLongitude.value = lng;
      currentLocationName.value = name ?? '';
      _notifyControllers(lat, lng);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkAndPromptLocation();
    });
  }

  Future<void> checkAndPromptLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      final permission = await Geolocator.checkPermission();
      final bool hasPermission = permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;

      if (serviceEnabled && hasPermission) {
        if (currentLatitude.value == null) {
          await fetchAndSaveUserLocation();
        }
        return;
      }

      if (isLocationPromptVisible.value) return;

      final targetContext = Get.context;
      if (targetContext != null && targetContext.mounted) {
        LocationPermissionBottomSheet.show(
          targetContext,
          isServiceDisabled: !serviceEnabled,
          isPermissionDenied: !hasPermission,
        );
      }
    } catch (e) {
      debugPrint('Error checking location status: $e');
    }
  }

  Future<bool> handleLocationPromptAction() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return false;
      }

      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final reqStatus = await Geolocator.requestPermission();
        if (reqStatus == LocationPermission.always ||
            reqStatus == LocationPermission.whileInUse) {
          await fetchAndSaveUserLocation(showFeedback: true);
          return true;
        } else if (reqStatus == LocationPermission.deniedForever) {
          await Geolocator.openAppSettings();
        }
        return false;
      }

      if (permission == LocationPermission.deniedForever) {
        await Geolocator.openAppSettings();
        return false;
      }

      await fetchAndSaveUserLocation(showFeedback: true);
      return true;
    } catch (e) {
      debugPrint('Error handling location prompt action: $e');
      return false;
    }
  }

  Future<void> fetchAndSaveUserLocation({
    bool showFeedback = false,
    bool saveToApi = false,
  }) async {
    isFetchingLocation.value = true;
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        isFetchingLocation.value = false;
        if (showFeedback) {
          Get.snackbar(
            AppStrings.appName,
            AppStrings.pleaseEnableLocationService,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.error,
            colorText: AppColors.surface,
          );
        }
        return;
      }

      final hasPermission =
          await PermissionHandlerService.handleLocationPermission(
            showFeedback: showFeedback,
          );
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

        String line1 = '';
        String city = '';
        String state = '';
        String postalCode = '';

        if (addressData != null) {
          line1 = addressData['addressLine1']?.toString() ?? '';
          city = addressData['city']?.toString() ?? '';
          state = addressData['state']?.toString() ?? '';
          postalCode = addressData['postalCode']?.toString() ?? '';

          if (line1.isNotEmpty && city.isNotEmpty) {
            currentLocationName.value = '$line1, $city';
          } else if (line1.isNotEmpty) {
            currentLocationName.value = line1;
          } else if (city.isNotEmpty) {
            currentLocationName.value = city;
          }
        }

        if (currentLocationName.value.isEmpty) {
          currentLocationName.value = AppStrings.currentLocationLabel;
        }

        await SharedPrefsHelper.saveLocation(
          position.latitude,
          position.longitude,
          currentLocationName.value,
        );

        bool isExistingAddress = false;
        final token = SharedPrefsHelper.getToken();
        final bool isLoggedIn = token != null && token.trim().isNotEmpty;

        if (isLoggedIn) {
          try {
            final addressController = Get.isRegistered<AddressController>()
                ? Get.find<AddressController>()
                : Get.put(AddressController());

            if (addressController.addresses.isEmpty) {
              await addressController.fetchAddresses();
            }

            List<AddressDataModel> savedAddresses = addressController.addresses
                .map((a) => a.rawAddressData)
                .whereType<AddressDataModel>()
                .toList();

            if (savedAddresses.isEmpty) {
              final response = await addressService.fetchAddresses();
              if (response.success && response.addresses.isNotEmpty) {
                savedAddresses = response.addresses;
              }
            }

            final matchingAddress = _findMatchingAddress(
              savedAddresses,
              latitude: position.latitude,
              longitude: position.longitude,
              addressLine1: line1.isNotEmpty ? line1 : currentLocationName.value,
              city: city,
              postalCode: postalCode,
            );

            if (matchingAddress != null) {
              isExistingAddress = true;
              final matchedLat = matchingAddress.latitude != 0.0
                  ? matchingAddress.latitude
                  : position.latitude;
              final matchedLng = matchingAddress.longitude != 0.0
                  ? matchingAddress.longitude
                  : position.longitude;

              String matchedDisplayName = matchingAddress.addressLine1;
              if (matchingAddress.city.isNotEmpty &&
                  !matchedDisplayName
                      .toLowerCase()
                      .contains(matchingAddress.city.toLowerCase())) {
                matchedDisplayName =
                    '$matchedDisplayName, ${matchingAddress.city}';
              }
              if (matchedDisplayName.isEmpty) {
                matchedDisplayName = currentLocationName.value;
              }

              currentLatitude.value = matchedLat;
              currentLongitude.value = matchedLng;
              currentLocationName.value = matchedDisplayName;

              await SharedPrefsHelper.saveLocation(
                matchedLat,
                matchedLng,
                matchedDisplayName,
              );

              if (saveToApi &&
                  !matchingAddress.isDefault &&
                  matchingAddress.id.isNotEmpty) {
                try {
                  await addressService.updateAddress(
                    matchingAddress.id,
                    AddAddressRequestModel(
                      addressLine1: matchingAddress.addressLine1,
                      addressLine2: matchingAddress.addressLine2,
                      city: matchingAddress.city,
                      state: matchingAddress.state,
                      postalCode: matchingAddress.postalCode,
                      latitude: matchedLat,
                      longitude: matchedLng,
                      isDefault: true,
                      label: matchingAddress.label,
                    ),
                  );
                } catch (e) {
                  debugPrint('Error updating address to default: $e');
                }
              }

              if (saveToApi) {
                addressController.fetchAddresses();
              }

              if (Get.isRegistered<CheckoutController>()) {
                final matchingModel = addressController.addresses
                    .firstWhereOrNull((a) => a.id == matchingAddress.id);
                if (matchingModel != null) {
                  Get.find<CheckoutController>().selectAddress(matchingModel);
                }
              }
            } else if (saveToApi) {
              final request = AddAddressRequestModel(
                addressLine1: line1.isNotEmpty
                    ? line1
                    : currentLocationName.value,
                addressLine2: '',
                city: city,
                state: state,
                postalCode: postalCode,
                latitude: position.latitude,
                longitude: position.longitude,
                isDefault: true,
                label: AppStrings.home,
              );
              final response = await addressService.addAddress(request);
              if (response.success) {
                addressController.fetchAddresses();
              }
            }
          } catch (e) {
            debugPrint('Error checking/saving address via API: $e');
          }
        }

        _notifyControllers(
          currentLatitude.value ?? position.latitude,
          currentLongitude.value ?? position.longitude,
        );

        if (showFeedback && currentLocationName.value.isNotEmpty) {
          final String feedbackMessage;
          if (isExistingAddress) {
            feedbackMessage = AppStrings.deliveryLocationUpdated;
          } else if (saveToApi) {
            feedbackMessage = AppStrings.addressSavedAndSet;
          } else {
            feedbackMessage = AppStrings.locationUpdated;
          }

          Get.snackbar(
            feedbackMessage,
            currentLocationName.value,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.primary,
            colorText: AppColors.surface,
            duration: const Duration(seconds: 2),
          );
        }
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

  AddressDataModel? _findMatchingAddress(
    List<AddressDataModel> addresses, {
    required double latitude,
    required double longitude,
    required String addressLine1,
    required String city,
    required String postalCode,
  }) {
    if (addresses.isEmpty) return null;

    AddressDataModel? closestAddress;
    double minDistance = double.infinity;
    bool foundDirectMatch = false;

    final cleanLine1 = _cleanText(addressLine1);
    final cleanCity = _cleanText(city);
    final cleanZip = postalCode.trim();

    for (final addr in addresses) {
      final existingLine1 = _cleanText(addr.addressLine1);
      final existingCity = _cleanText(addr.city);
      final existingZip = addr.postalCode.trim();

      bool textMatches = false;
      if (cleanLine1.isNotEmpty && existingLine1.isNotEmpty) {
        if (cleanLine1 == existingLine1 ||
            (cleanLine1.length >= 8 &&
                existingLine1.length >= 8 &&
                (cleanLine1.contains(existingLine1) ||
                    existingLine1.contains(cleanLine1)))) {
          if (cleanCity.isEmpty ||
              existingCity.isEmpty ||
              cleanCity == existingCity) {
            textMatches = true;
          }
        }
      }

      if (cleanZip.isNotEmpty &&
          existingZip.isNotEmpty &&
          cleanZip == existingZip) {
        if (cleanLine1.isNotEmpty &&
            existingLine1.isNotEmpty &&
            (cleanLine1.contains(existingLine1) ||
                existingLine1.contains(cleanLine1))) {
          textMatches = true;
        }
      }

      if (addr.latitude != 0.0 && addr.longitude != 0.0) {
        final dist = Geolocator.distanceBetween(
          latitude,
          longitude,
          addr.latitude,
          addr.longitude,
        );

        if (dist <= 120.0) {
          if (textMatches) {
            return addr;
          }
          if (dist < minDistance) {
            minDistance = dist;
            closestAddress = addr;
          }
        }
      } else if (textMatches) {
        if (!foundDirectMatch) {
          closestAddress = addr;
          foundDirectMatch = true;
        }
      }
    }

    return closestAddress;
  }

  static String _cleanText(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
