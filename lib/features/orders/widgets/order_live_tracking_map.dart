//
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart' as latlng;
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../home/controllers/location_controller.dart';
import '../models/order_track_response_model.dart';

class OrderLiveTrackingMap extends StatefulWidget {
  final OrderTrackData? trackData;
  final double? destinationLat;
  final double? destinationLng;

  const OrderLiveTrackingMap({
    super.key,
    this.trackData,
    this.destinationLat,
    this.destinationLng,
  });

  @override
  State<OrderLiveTrackingMap> createState() => _OrderLiveTrackingMapState();
}

class _OrderLiveTrackingMapState extends State<OrderLiveTrackingMap> {
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  latlng.LatLng _getUserDestination() {
    if (widget.destinationLat != null && widget.destinationLng != null) {
      return latlng.LatLng(widget.destinationLat!, widget.destinationLng!);
    }

    if (Get.isRegistered<LocationController>()) {
      final locCtrl = Get.find<LocationController>();
      if (locCtrl.latitude != null && locCtrl.longitude != null) {
        return latlng.LatLng(locCtrl.latitude!, locCtrl.longitude!);
      }
    }

    // Default city fallback (Dehradun coordinates matching app default)
    return const latlng.LatLng(30.3165, 78.0322);
  }

  latlng.LatLng _getAgentLocation(latlng.LatLng dest) {
    final curLat = widget.trackData?.currentLatitude;
    final curLng = widget.trackData?.currentLongitude;

    if (curLat != null && curLng != null && curLat != 0.0 && curLng != 0.0) {
      return latlng.LatLng(curLat, curLng);
    }

    // Realistic offset for delivery partner when on route (~900 meters away)
    return latlng.LatLng(dest.latitude + 0.0072, dest.longitude - 0.0065);
  }

  List<latlng.LatLng> _generatePolylinePoints(
    latlng.LatLng start,
    latlng.LatLng end,
  ) {
    // Generate smooth route path between agent and customer
    final mid1 = latlng.LatLng(
      start.latitude * 0.7 + end.latitude * 0.3,
      start.longitude * 0.65 + end.longitude * 0.35 + 0.0012,
    );
    final mid2 = latlng.LatLng(
      start.latitude * 0.35 + end.latitude * 0.65 - 0.0008,
      start.longitude * 0.35 + end.longitude * 0.65,
    );

    return [start, mid1, mid2, end];
  }

  void _recenterMap(latlng.LatLng agent, latlng.LatLng dest) {
    final centerLat = (agent.latitude + dest.latitude) / 2;
    final centerLng = (agent.longitude + dest.longitude) / 2;
    _mapController.move(latlng.LatLng(centerLat, centerLng), 14.5);
  }

  @override
  Widget build(BuildContext context) {
    final destPoint = _getUserDestination();
    final agentPoint = _getAgentLocation(destPoint);
    final polylinePoints = _generatePolylinePoints(agentPoint, destPoint);
    final centerLat = (agentPoint.latitude + destPoint.latitude) / 2;
    final centerLng = (agentPoint.longitude + destPoint.longitude) / 2;
    final etaText =
        widget.trackData?.estimatedDeliveryWindow ?? '20-30 mins';

    return Container(
      height: AppSpacing.screenWidth * 0.65,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.chipBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radius16),
        border: Border.all(
          color: AppColors.chipBorder.withValues(alpha: 0.8),
          width: 1,
        ),
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
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: latlng.LatLng(centerLat, centerLng),
                initialZoom: 14.2,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: AppStrings.mapTileUrl,
                  userAgentPackageName: AppStrings.mapTileUserAgent,
                ),
                PolylineLayer(
                  polylines: [
                    // Outer glow / shadow polyline
                    Polyline(
                      points: polylinePoints,
                      color: AppColors.primary.withValues(alpha: 0.25),
                      strokeWidth: 7.0,
                    ),
                    // Inner route polyline
                    Polyline(
                      points: polylinePoints,
                      color: AppColors.primary,
                      strokeWidth: 4.0,
                      strokeCap: StrokeCap.round,
                      strokeJoin: StrokeJoin.round,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    // Delivery Partner Marker
                    Marker(
                      point: agentPoint,
                      width: 52,
                      height: 52,
                      child: _buildAgentMarker(context),
                    ),
                    // Customer Destination Marker
                    Marker(
                      point: destPoint,
                      width: 46,
                      height: 46,
                      child: _buildDestinationMarker(context),
                    ),
                  ],
                ),
              ],
            ),

            // Top Status & ETA Pill
            Positioned(
              top: AppSpacing.radius12,
              left: AppSpacing.radius12,
              child: Container(
                padding: AppSpacing.paddingFromLTRB(10, 6, 12, 6),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radius20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    AppSpacing.w6,
                    Text(
                      '${AppStrings.arrivingIn} $etaText',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Recenter Live Location Button
            Positioned(
              bottom: AppSpacing.radius12,
              right: AppSpacing.radius12,
              child: InkWell(
                onTap: () => _recenterMap(agentPoint, destPoint),
                borderRadius: BorderRadius.circular(AppSpacing.radius20),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.my_location_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgentMarker(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.surface, width: 2.2),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(
            Icons.delivery_dining_rounded,
            color: AppColors.surface,
            size: 22,
          ),
        ),
      ],
    );
  }

  Widget _buildDestinationMarker(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.error,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.surface, width: 2.2),
            boxShadow: [
              BoxShadow(
                color: AppColors.error.withValues(alpha: 0.35),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(
            Icons.home_rounded,
            color: AppColors.surface,
            size: 19,
          ),
        ),
      ],
    );
  }
}
