// 
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/widgets/custom_button.dart';
import 'package:vegon_user/core/widgets/custom_icon_button.dart';
import 'package:vegon_user/core/widgets/custom_text_field.dart';
import 'package:vegon_user/features/profile/controllers/address_controller.dart';
import 'package:vegon_user/features/profile/models/address_models.dart';

class AddAddressScreen extends StatefulWidget {
  final AddressModel? initialAddress;

  const AddAddressScreen({super.key, this.initialAddress});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  bool _isDefault = true;
  double _latitude = 28.6139;
  double _longitude = 77.2090;
  bool _isFetchingLocation = false;
  String _selectedLabel = AppStrings.home;
  final MapController _mapController = MapController();

  final AddressController controller = Get.find<AddressController>();

  @override
  void initState() {
    super.initState();
    if (widget.initialAddress != null) {
      final addr = widget.initialAddress!;
      _titleController.text = addr.title;
      _selectedLabel = addr.title.isNotEmpty ? addr.title : AppStrings.home;
      _isDefault = addr.isDefault;
      if (addr.rawAddressData != null) {
        final raw = addr.rawAddressData!;
        _addressLine1Controller.text = raw.addressLine1;
        _addressLine2Controller.text = raw.addressLine2;
        _cityController.text = raw.city;
        _stateController.text = raw.state;
        _postalCodeController.text = raw.postalCode;
        if (raw.latitude != 0.0) _latitude = raw.latitude;
        if (raw.longitude != 0.0) _longitude = raw.longitude;
      } else {
        _addressLine1Controller.text = addr.address;
      }
    } else {
      _titleController.text = AppStrings.home;
      _fetchLiveLocation();
    }
  }

  void _fetchLiveLocation() {
    if (!mounted) return;
    setState(() {
      _isFetchingLocation = true;
    });

    controller.fetchLiveLocationAndAddress((data) {
      if (!mounted) return;
      final double lat = (data['latitude'] as num?)?.toDouble() ?? _latitude;
      final double lng = (data['longitude'] as num?)?.toDouble() ?? _longitude;

      setState(() {
        _latitude = lat;
        _longitude = lng;
        _addressLine1Controller.text = data['addressLine1'] as String? ?? '';
        _cityController.text = data['city'] as String? ?? '';
        _stateController.text = data['state'] as String? ?? '';
        _postalCodeController.text = data['postalCode'] as String? ?? '';
        _isFetchingLocation = false;
      });

      _mapController.move(latlng.LatLng(lat, lng), 15.0);
    }).whenComplete(() {
      if (mounted) {
        setState(() {
          _isFetchingLocation = false;
        });
      }
    });
  }

  void _onMapTapped(latlng.LatLng position) {
    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
      _isFetchingLocation = true;
    });

    controller.reverseGeocodeCoordinates(
      position.latitude,
      position.longitude,
      (data) {
        if (!mounted) return;
        setState(() {
          _addressLine1Controller.text = data['addressLine1'] as String? ?? '';
          _cityController.text = data['city'] as String? ?? '';
          _stateController.text = data['state'] as String? ?? '';
          _postalCodeController.text = data['postalCode'] as String? ?? '';
          _isFetchingLocation = false;
        });
      },
    );
  }

  void _onLabelSelected(String label) {
    setState(() {
      _selectedLabel = label;
      _titleController.text = label;
      if (label == AppStrings.home) {
        _isDefault = true;
      } else if (label == AppStrings.office) {
        _isDefault = false;
      }
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    _titleController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (_formKey.currentState!.validate()) {
      final initial = widget.initialAddress;
      final String addressId = (initial?.id.isNotEmpty == true)
          ? initial!.id
          : (initial?.rawAddressData?.id ?? '');

      if (initial != null && addressId.isNotEmpty) {
        await controller.updateAddress(
          id: addressId,
          title: _titleController.text.trim(),
          label: _selectedLabel,
          addressLine1: _addressLine1Controller.text.trim(),
          addressLine2: _addressLine2Controller.text.trim(),
          city: _cityController.text.trim(),
          state: _stateController.text.trim(),
          postalCode: _postalCodeController.text.trim(),
          latitude: _latitude,
          longitude: _longitude,
          isDefault: _isDefault,
        );
      } else {
        await controller.addAddress(
          title: _titleController.text.trim(),
          label: _selectedLabel,
          addressLine1: _addressLine1Controller.text.trim(),
          addressLine2: _addressLine2Controller.text.trim(),
          city: _cityController.text.trim(),
          state: _stateController.text.trim(),
          postalCode: _postalCodeController.text.trim(),
          latitude: _latitude,
          longitude: _longitude,
          isDefault: _isDefault,
        );
      }
    }
  }

  Widget _buildMapSection() {
    return Container(
      height: AppSpacing.screenWidth * 0.48,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.chipBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radius12),
        border: Border.all(color: AppColors.chipBorder),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radius12),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: latlng.LatLng(_latitude, _longitude),
                initialZoom: 15.0,
                onTap: (tapPosition, point) => _onMapTapped(point),
              ),
              children: [
                TileLayer(
                  urlTemplate: AppStrings.mapTileUrl,
                  userAgentPackageName: AppStrings.mapTileUserAgent,
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: latlng.LatLng(_latitude, _longitude),
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_on,
                        color: AppColors.error,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              bottom: AppSpacing.radius12,
              right: AppSpacing.radius12,
              child: CustomIconButton(
                icon: Icons.my_location,
                color: AppColors.primary,
                onPressed: _fetchLiveLocation,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabelChips() {
    final labels = [AppStrings.home, AppStrings.office, AppStrings.otherLabel];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.addressTypeLabel,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        AppSpacing.h8,
        Row(
          children: labels.map((label) {
            final isSelected = _selectedLabel == label;
            return Padding(
              padding: AppSpacing.paddingHorizontal4,
              child: ChoiceChip(
                label: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? AppColors.surface
                        : AppColors.textPrimary,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                selected: isSelected,
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.chipBackground,
                onSelected: (_) => _onLabelSelected(label),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.initialAddress != null
              ? AppStrings.editAddress
              : AppStrings.addNewAddress,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: CustomIconButton(
          icon: Icons.arrow_back,
          color: AppColors.primary,
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingResponsiveAll(0.05),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMapSection(),
              AppSpacing.h16,
              if (_isFetchingLocation) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: AppSpacing.screenWidth * 0.05,
                      height: AppSpacing.screenWidth * 0.05,
                      child: const CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2.0,
                      ),
                    ),
                    AppSpacing.w12,
                    Text(
                      AppStrings.fetchingLocation,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                AppSpacing.h16,
              ],
              _buildLabelChips(),
              AppSpacing.h16,
              CustomTextField(
                controller: _titleController,
                hintText: AppStrings.addressTitleLabel,
                label: AppStrings.addressTitleLabel,
                prefixIcon: Icons.label_outline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppStrings.enterAddressTitle;
                  }
                  return null;
                },
              ),
              AppSpacing.h16,
              CustomTextField(
                controller: _addressLine1Controller,
                hintText: AppStrings.addressLine1Label,
                label: AppStrings.addressLine1Label,
                rightActionText: _isFetchingLocation
                    ? null
                    : AppStrings.useCurrentLocation,
                onRightActionTap:
                    _isFetchingLocation ? null : _fetchLiveLocation,
                prefixIcon: Icons.location_on_outlined,
                customSuffix: CustomIconButton(
                  icon: Icons.my_location,
                  color: AppColors.primary,
                  onPressed: _fetchLiveLocation,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppStrings.enterAddressLine1;
                  }
                  return null;
                },
              ),
              AppSpacing.h16,
              CustomTextField(
                controller: _addressLine2Controller,
                hintText: AppStrings.addressLine2Label,
                label: AppStrings.addressLine2Label,
                prefixIcon: Icons.my_location,
              ),
              AppSpacing.h16,
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _cityController,
                      hintText: AppStrings.cityLabel,
                      label: AppStrings.cityLabel,
                      prefixIcon: Icons.location_city,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppStrings.enterCity;
                        }
                        return null;
                      },
                    ),
                  ),
                  AppSpacing.w16,
                  Expanded(
                    child: CustomTextField(
                      controller: _stateController,
                      hintText: AppStrings.stateLabel,
                      label: AppStrings.stateLabel,
                      prefixIcon: Icons.map_outlined,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppStrings.enterState;
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              AppSpacing.h16,
              CustomTextField(
                controller: _postalCodeController,
                hintText: AppStrings.postalCodeLabel,
                label: AppStrings.postalCodeLabel,
                prefixIcon: Icons.markunread_mailbox_outlined,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppStrings.enterPostalCode;
                  }
                  return null;
                },
              ),
              AppSpacing.h24,
              Row(
                children: [
                  Checkbox(
                    value: _isDefault,
                    onChanged: (value) {
                      setState(() {
                        _isDefault = value ?? false;
                      });
                    },
                    activeColor: AppColors.primary,
                  ),
                  Expanded(
                    child: Text(
                      AppStrings.setAsDefaultAddress,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              AppSpacing.responsiveHeight(0.04),
              Obx(
                () => CustomButton(
                  text: AppStrings.saveAddress,
                  isLoading: controller.isLoading.value,
                  onPressed: _saveAddress,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
