import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_spacing.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/core/widgets/custom_icon_button.dart';
import 'package:vegon_user/features/profile/controllers/address_controller.dart';

class AddressMapPicker extends StatefulWidget {
  final MapController mapController;
  final double initialLatitude;
  final double initialLongitude;
  final ValueChanged<Map<String, dynamic>> onLocationSelected;
  final VoidCallback onMyLocationTap;

  const AddressMapPicker({
    super.key,
    required this.mapController,
    required this.initialLatitude,
    required this.initialLongitude,
    required this.onLocationSelected,
    required this.onMyLocationTap,
  });

  @override
  State<AddressMapPicker> createState() => _AddressMapPickerState();
}

class _AddressMapPickerState extends State<AddressMapPicker> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final List<Map<String, dynamic>> _suggestions = [];
  bool _isSearchingPlaces = false;
  bool _showSuggestions = false;
  Timer? _debounceTimer;

  AddressController get _addressCtrl => Get.isRegistered<AddressController>()
      ? Get.find<AddressController>()
      : Get.put(AddressController());

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchQueryChanged(String query) {
    _debounceTimer?.cancel();
    final clean = query.trim();
    if (clean.length < 2) {
      if (mounted) {
        setState(() {
          _suggestions.clear();
          _showSuggestions = false;
          _isSearchingPlaces = false;
        });
      }
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 380), () async {
      if (!mounted) return;
      setState(() {
        _isSearchingPlaces = true;
      });

      final results = await _addressCtrl.searchPlaces(clean);
      if (!mounted) return;

      setState(() {
        _suggestions.clear();
        _suggestions.addAll(results);
        _showSuggestions = _suggestions.isNotEmpty;
        _isSearchingPlaces = false;
      });
    });
  }

  void _selectSuggestion(Map<String, dynamic> place) {
    final double lat = (place['latitude'] as num?)?.toDouble() ?? 0.0;
    final double lon = (place['longitude'] as num?)?.toDouble() ?? 0.0;

    _searchFocusNode.unfocus();
    setState(() {
      _showSuggestions = false;
      _searchController.text = place['displayName']?.toString() ?? '';
    });

    if (lat != 0.0 && lon != 0.0) {
      widget.mapController.move(latlng.LatLng(lat, lon), 16.0);
      widget.onLocationSelected(place);
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(() {
      _suggestions.clear();
      _showSuggestions = false;
      _isSearchingPlaces = false;
    });
  }

  void _zoomIn() {
    final currentZoom = widget.mapController.camera.zoom;
    final center = widget.mapController.camera.center;
    widget.mapController.move(center, (currentZoom + 1.0).clamp(3.0, 19.0));
  }

  void _zoomOut() {
    final currentZoom = widget.mapController.camera.zoom;
    final center = widget.mapController.camera.center;
    widget.mapController.move(center, (currentZoom - 1.0).clamp(3.0, 19.0));
  }

  @override
  Widget build(BuildContext context) {
    final mapHeight = (AppSpacing.screenWidth * 0.72).clamp(240.0, 320.0);

    return Container(
      height: mapHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.chipBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radius16),
        border: Border.all(color: AppColors.chipBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radius16),
        child: Stack(
          children: [
            // Map Canvas
            FlutterMap(
              mapController: widget.mapController,
              options: MapOptions(
                initialCenter: latlng.LatLng(
                  widget.initialLatitude,
                  widget.initialLongitude,
                ),
                initialZoom: 15.0,
                onTap: (tapPosition, point) {
                  _searchFocusNode.unfocus();
                  setState(() {
                    _showSuggestions = false;
                  });
                  _addressCtrl.reverseGeocodeCoordinates(
                    point.latitude,
                    point.longitude,
                    (data) {
                      widget.onLocationSelected(data);
                    },
                  );
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: AppStrings.mapTileUrl,
                  userAgentPackageName: AppStrings.mapTileUserAgent,
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: latlng.LatLng(
                        widget.initialLatitude,
                        widget.initialLongitude,
                      ),
                      width: AppSpacing.radius40,
                      height: AppSpacing.radius40,
                      child: const Icon(
                        Icons.location_on,
                        color: AppColors.error,
                        size: AppSpacing.radius40,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Hint Pill at the bottom
            Positioned(
              left: AppSpacing.radius12,
              bottom: AppSpacing.radius12,
              child: Container(
                padding: AppSpacing.paddingSymmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(AppSpacing.radius12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.touch_app_outlined,
                      size: 13,
                      color: AppColors.primary,
                    ),
                    AppSpacing.w4,
                    Text(
                      AppStrings.mapDragHint,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                    ),
                  ],
                ),
              ),
            ),

            // Controls: Zoom and My Location
            Positioned(
              bottom: AppSpacing.radius12,
              right: AppSpacing.radius12,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildControlPill(
                    icon: Icons.add_rounded,
                    onTap: _zoomIn,
                  ),
                  AppSpacing.h6,
                  _buildControlPill(
                    icon: Icons.remove_rounded,
                    onTap: _zoomOut,
                  ),
                  AppSpacing.h8,
                  CustomIconButton(
                    icon: Icons.my_location_rounded,
                    color: AppColors.primary,
                    onPressed: () {
                      _searchFocusNode.unfocus();
                      setState(() {
                        _showSuggestions = false;
                      });
                      widget.onMyLocationTap();
                    },
                  ),
                ],
              ),
            ),

            // Top Floating Search Bar
            Positioned(
              top: AppSpacing.radius10,
              left: AppSpacing.radius10,
              right: AppSpacing.radius10,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.radius12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(
                        color: _searchFocusNode.hasFocus
                            ? AppColors.primary
                            : AppColors.chipBorder,
                      ),
                    ),
                    child: Row(
                      children: [
                        AppSpacing.w10,
                        const Icon(
                          Icons.search_rounded,
                          color: AppColors.primary,
                          size: 18,
                        ),
                        AppSpacing.w8,
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            onChanged: _onSearchQueryChanged,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontSize: 13,
                                ),
                            decoration: InputDecoration(
                              isDense: true,
                              filled: false,
                              contentPadding: AppSpacing.paddingVertical8,
                              hintText: AppStrings.searchLocationOrAddress,
                              hintStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                          ),
                        ),
                        if (_isSearchingPlaces)
                          const Padding(
                            padding: AppSpacing.paddingHorizontal8,
                            child: SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            ),
                          )
                        else if (_searchController.text.isNotEmpty)
                          InkWell(
                            onTap: _clearSearch,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radius16,
                            ),
                            child: const Padding(
                              padding: AppSpacing.paddingHorizontal8,
                              child: Icon(
                                Icons.close_rounded,
                                color: AppColors.textSecondary,
                                size: 16,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Suggestions Dropdown Card
                  if (_showSuggestions && _suggestions.isNotEmpty)
                    Container(
                      margin: AppSpacing.paddingFromLTRB(0, 4, 0, 0),
                      constraints: const BoxConstraints(maxHeight: 180),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radius12,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: ListView.separated(
                        padding: AppSpacing.paddingVertical4,
                        shrinkWrap: true,
                        itemCount: _suggestions.length,
                        separatorBuilder: (context, index) => const Divider(
                          height: 1,
                          color: AppColors.borderLight,
                        ),
                        itemBuilder: (context, index) {
                          final place = _suggestions[index];
                          final line1 = place['addressLine1']?.toString() ?? '';
                          final full = place['displayName']?.toString() ?? '';

                          return InkWell(
                            onTap: () => _selectSuggestion(place),
                            child: Padding(
                              padding: AppSpacing.paddingFromLTRB(10, 8, 10, 8),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.place_outlined,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                  AppSpacing.w8,
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          line1.isNotEmpty ? line1 : full,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textPrimary,
                                              ),
                                        ),
                                        if (full.isNotEmpty && full != line1)
                                          Text(
                                            full,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall
                                                ?.copyWith(
                                                  color:
                                                      AppColors.textSecondary,
                                                  fontSize: 10,
                                                ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlPill({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppSpacing.radius8),
      elevation: 2,
      shadowColor: AppColors.black.withValues(alpha: 0.15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radius8),
        child: Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 18,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
