import 'package:vegon_user/features/product/models/product_details_model.dart';

class WishlistResponseModel {
  final bool? success;
  final String? message;
  final List<ProductDetailsData>? data;
  final String? timestamp;

  WishlistResponseModel({
    this.success,
    this.message,
    this.data,
    this.timestamp,
  });

  factory WishlistResponseModel.fromJson(Map<String, dynamic> json) {
    List<ProductDetailsData> items = [];
    final rawData = json['data'];
    if (rawData is List) {
      items = rawData
          .whereType<Map<String, dynamic>>()
          .map((e) => ProductDetailsData.fromJson(e))
          .toList();
    } else if (rawData is Map<String, dynamic>) {
      final list = rawData['items'] ?? rawData['products'] ?? rawData['content'];
      if (list is List) {
        items = list
            .whereType<Map<String, dynamic>>()
            .map((e) => ProductDetailsData.fromJson(e))
            .toList();
      }
    }
    return WishlistResponseModel(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String?,
      data: items,
      timestamp: json['timestamp'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'data': data?.map((e) => e.toJson()).toList(),
        'timestamp': timestamp,
      };
}

class WishlistActionResponseModel {
  final bool? success;
  final String? message;
  final String? timestamp;

  WishlistActionResponseModel({
    this.success,
    this.message,
    this.timestamp,
  });

  factory WishlistActionResponseModel.fromJson(Map<String, dynamic> json) =>
      WishlistActionResponseModel(
        success: json['success'] as bool?,
        message: json['message'] as String?,
        timestamp: json['timestamp'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'timestamp': timestamp,
      };
}
