//
class ShopDataModel {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double distanceInKm;
  final String? image;

  ShopDataModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.distanceInKm,
    this.image,
  });

  factory ShopDataModel.fromJson(Map<String, dynamic> json) {
    return ShopDataModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['shopName']?.toString() ?? '',
      latitude: (json['latitude'] is num)
          ? (json['latitude'] as num).toDouble()
          : (double.tryParse(json['latitude']?.toString() ?? '') ?? 0.0),
      longitude: (json['longitude'] is num)
          ? (json['longitude'] as num).toDouble()
          : (double.tryParse(json['longitude']?.toString() ?? '') ?? 0.0),
      distanceInKm: (json['distanceInKm'] is num)
          ? (json['distanceInKm'] as num).toDouble()
          : (double.tryParse(json['distanceInKm']?.toString() ?? '') ?? 0.0),
      image:
          json['image']?.toString() ??
          json['imageUrl']?.toString() ??
          json['banner']?.toString(),
    );
  }
}

class GetShopsResponseModel {
  final bool success;
  final String message;
  final List<ShopDataModel> shops;

  GetShopsResponseModel({
    required this.success,
    required this.message,
    required this.shops,
  });

  factory GetShopsResponseModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'] ?? json['shops'];
    return GetShopsResponseModel(
      success: json['success'] as bool? ?? true,
      message: json['message']?.toString() ?? '',
      shops: rawData is List
          ? rawData
                .whereType<Map<String, dynamic>>()
                .map((e) => ShopDataModel.fromJson(e))
                .toList()
          : [],
    );
  }
}
